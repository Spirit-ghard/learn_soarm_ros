#!/home/a/anaconda3/envs/lerobot05/bin/python
"""ROS1 bridge for a LeRobot SO101 follower.

The node intentionally avoids SOFollower.connect(), because that method writes
configuration registers. Startup only connects the Feetech bus and reads state.
Motor writes happen only after read_only is false and the user explicitly
enables torque or sends a command.
"""

from __future__ import annotations

import math
import sys
import threading
from glob import glob
from pathlib import Path
from typing import Dict, Iterable, Optional


ROS_PYTHON_PATHS = [
    "/home/a/lerobot_05/src",
    "/opt/ros/noetic/lib/python3/dist-packages",
    "/usr/lib/python3/dist-packages",
]


def _append_runtime_paths() -> None:
    for path in ROS_PYTHON_PATHS:
        if path not in sys.path:
            sys.path.append(path)


_append_runtime_paths()

if sys.version_info < (3, 10):
    raise RuntimeError(
        "lwh_so101_real needs the LeRobot Python environment. "
        "Run it with /home/a/anaconda3/envs/lerobot05/bin/python."
    )

import rospy
from sensor_msgs.msg import JointState
from std_msgs.msg import Bool
from std_srvs.srv import SetBool, SetBoolResponse, Trigger, TriggerResponse

from lerobot.robots.so_follower.config_so_follower import SOFollowerRobotConfig
from lerobot.robots.so_follower.so_follower import SOFollower

from lwh_so101_real.msg import SO101Status
from lwh_so101_real.srv import Enable, EnableResponse, GoZero, GoZeroResponse, Gripper, GripperResponse


JOINT_NAMES = [
    "shoulder_pan",
    "shoulder_lift",
    "elbow_flex",
    "wrist_flex",
    "wrist_roll",
    "gripper",
]
BODY_JOINTS = JOINT_NAMES[:-1]
GRIPPER_JOINT = "gripper"

GRIPPER_RAD_MIN = -0.174533
GRIPPER_RAD_MAX = 1.74533
DEFAULT_CALIBRATION_DIR = Path.home() / ".cache/huggingface/lerobot/calibration/robots/so101_follower"
SERIAL_PORT_PATTERNS = ["/dev/ttyACM*", "/dev/ttyUSB*"]
EXPECTED_MOTOR_IDS = set(range(1, 7))
FALLBACK_POSITIONS = {
    "shoulder_pan": 0.0,
    "shoulder_lift": 0.0,
    "elbow_flex": 0.0,
    "wrist_flex": 0.0,
    "wrist_roll": 0.0,
    "gripper": 0.0,
}


def clamp(value: float, lower: float, upper: float) -> float:
    return max(lower, min(upper, value))


def deg_to_rad(value: float) -> float:
    return value * math.pi / 180.0


def rad_to_deg(value: float) -> float:
    return value * 180.0 / math.pi


def gripper_percent_to_rad(value: float) -> float:
    pct = clamp(value, 0.0, 100.0)
    return GRIPPER_RAD_MIN + (GRIPPER_RAD_MAX - GRIPPER_RAD_MIN) * pct / 100.0


def gripper_rad_to_percent(value: float) -> float:
    rad = clamp(value, GRIPPER_RAD_MIN, GRIPPER_RAD_MAX)
    return (rad - GRIPPER_RAD_MIN) * 100.0 / (GRIPPER_RAD_MAX - GRIPPER_RAD_MIN)


class SO101CtrlSingleNode:
    def __init__(self) -> None:
        self.port = rospy.get_param("~port", "/dev/ttyACM0")
        self.robot_id = rospy.get_param("~robot_id", "my_awesome_follower_arm")
        self.calibration_dir = rospy.get_param("~calibration_dir", str(DEFAULT_CALIBRATION_DIR))
        self.publish_rate = float(rospy.get_param("~publish_rate", 50.0))
        self.read_only = bool(rospy.get_param("~read_only", True))
        self.auto_enable = bool(rospy.get_param("~auto_enable", False))
        self.auto_port = bool(rospy.get_param("~auto_port", True))
        self.allow_disconnected = bool(rospy.get_param("~allow_disconnected", True))
        self.require_calibration = bool(rospy.get_param("~require_calibration", True))
        self.disable_torque_on_shutdown = bool(rospy.get_param("~disable_torque_on_shutdown", False))
        self.max_relative_target_deg = float(rospy.get_param("~max_relative_target_deg", 10.0))
        self.max_relative_target_gripper = float(rospy.get_param("~max_relative_target_gripper", 15.0))

        self._lock = threading.RLock()
        self._follower = None
        self._bus = None
        self._connected = False
        self._torque_enabled = False
        self._command_blocked = bool(rospy.get_param("~start_blocked", False))
        self._last_status = "starting"
        self._last_positions: Optional[Dict[str, float]] = None

        self.joint_pub = rospy.Publisher("joint_states_single", JointState, queue_size=10)
        self.status_pub = rospy.Publisher("arm_status", SO101Status, queue_size=10, latch=True)

        rospy.Subscriber("joint_ctrl_single", JointState, self._joint_command_callback, queue_size=1)
        rospy.Subscriber("enable_flag", Bool, self._enable_flag_callback, queue_size=1)

        rospy.Service("enable_srv", Enable, self._enable_service)
        rospy.Service("gripper_srv", Gripper, self._gripper_service)
        rospy.Service("go_zero_srv", GoZero, self._go_zero_service)
        rospy.Service("stop_srv", Trigger, self._stop_service)
        rospy.Service("reset_srv", Trigger, self._reset_service)
        rospy.Service("block_arm", SetBool, self._block_service)

        try:
            self._connect_bus()
        except Exception as exc:  # noqa: BLE001
            if not self.allow_disconnected:
                raise
            self._handle_connect_failure(exc)

    def spin(self) -> None:
        rate = rospy.Rate(self.publish_rate)
        while not rospy.is_shutdown():
            with self._lock:
                self._read_and_publish_once()
                self._publish_status()
            rate.sleep()

    def shutdown(self) -> None:
        with self._lock:
            if self._bus is None or not self._connected:
                return
            try:
                self._bus.disconnect(disable_torque=self.disable_torque_on_shutdown)
            except Exception as exc:  # noqa: BLE001
                rospy.logwarn("Failed to disconnect SO101 bus cleanly: %s", exc)
            finally:
                self._connected = False
                self._torque_enabled = False

    def _connect_bus(self) -> None:
        config_kwargs = {
            "port": self.port,
            "id": self.robot_id,
            "use_degrees": True,
            "disable_torque_on_disconnect": self.disable_torque_on_shutdown,
        }
        calibration_dir = Path(self.calibration_dir).expanduser()
        config_kwargs["calibration_dir"] = calibration_dir

        self._follower = SOFollower(SOFollowerRobotConfig(**config_kwargs))
        self._bus = self._follower.bus

        if self.require_calibration and not self._bus.calibration:
            raise RuntimeError(
                "No SO101 calibration file was loaded. Run lerobot-calibrate first, "
                f"or pass robot_id/calibration_dir that points to an existing calibration. "
                f"Current expected file: {calibration_dir / (str(self.robot_id) + '.json')}"
            )

        self._connect_checked_bus()
        self._connected = True
        self._last_status = "connected read-only" if self.read_only else "connected"
        rospy.loginfo("SO101 connected on %s with robot_id=%s", self.port, self.robot_id)

        if self.auto_enable:
            if self.read_only:
                rospy.logwarn("auto_enable requested but read_only=true, leaving torque disabled.")
            else:
                self._set_torque(True)

    def _connect_checked_bus(self) -> None:
        assert self._bus is not None
        try:
            self._bus.connect(handshake=True)
            return
        except RuntimeError as exc:
            if not self.auto_port or "motor check failed" not in str(exc):
                raise
            rospy.logwarn("SO101 motor check failed on %s. Scanning serial ports before giving up.", self.port)
            self._close_bus_port()

        selected_port = self._find_port_with_expected_motors()
        if selected_port is None:
            raise RuntimeError(
                "SO101 motor bus was not found. The requested port opened, but no expected motors "
                f"{sorted(EXPECTED_MOTOR_IDS)} responded.\n"
                "Check these in order:\n"
                "  1. Use the Feetech motor-controller USB port, not another ACM/USB device.\n"
                "  2. Make sure the arm motor power is on; USB alone may enumerate a port but motors stay silent.\n"
                "  3. Check the servo bus cable and adapter orientation.\n"
                "  4. If motors were reconfigured, run LeRobot motor setup/calibration so IDs 1-6 and baudrate match."
            )

        rospy.logwarn("Switching SO101 port from %s to detected motor bus %s.", self.port, selected_port)
        self.port = selected_port
        self._follower.config.port = selected_port
        self._follower = SOFollower(self._follower.config)
        self._bus = self._follower.bus
        self._bus.connect(handshake=True)

    def _close_bus_port(self) -> None:
        if self._bus is None:
            return
        try:
            if self._bus.is_connected:
                self._bus.port_handler.closePort()
        except Exception as exc:  # noqa: BLE001
            rospy.logwarn("Failed to close SO101 serial port after failed handshake: %s", exc)

    def _find_port_with_expected_motors(self) -> Optional[str]:
        ports = []
        for pattern in SERIAL_PORT_PATTERNS:
            ports.extend(glob(pattern))
        ports = sorted(set(ports))
        if not ports:
            rospy.logwarn("No serial ports found under %s.", ", ".join(SERIAL_PORT_PATTERNS))
            return None

        for port in ports:
            try:
                found_by_baud = self._bus.__class__.scan_port(port)
            except Exception as exc:  # noqa: BLE001
                rospy.logwarn("SO101 scan skipped %s: %s", port, exc)
                continue

            found_ids = set()
            for ids in found_by_baud.values():
                found_ids.update(int(id_) for id_ in ids)
            rospy.loginfo("SO101 scan %s found motor IDs: %s", port, sorted(found_ids))
            if EXPECTED_MOTOR_IDS.issubset(found_ids):
                return port
        return None

    def _read_positions(self) -> Dict[str, float]:
        assert self._bus is not None
        positions = self._bus.sync_read("Present_Position")
        return {name: float(positions[name]) for name in JOINT_NAMES}

    def _read_and_publish_once(self) -> None:
        if not self._connected:
            self._publish_joint_state(self._last_positions or FALLBACK_POSITIONS)
            return

        try:
            positions = self._read_positions()
            self._last_positions = positions
            self._publish_joint_state(positions)
            if self._last_status.startswith("read failed"):
                self._last_status = "connected"
        except Exception as exc:  # noqa: BLE001
            self._last_status = f"read failed: {exc}"
            rospy.logwarn_throttle(2.0, "SO101 read failed: %s", exc)

    def _handle_connect_failure(self, exc: Exception) -> None:
        self._close_bus_port()
        self._connected = False
        self._torque_enabled = False
        self._last_positions = dict(FALLBACK_POSITIONS)
        self._last_status = f"disconnected: {exc}"
        rospy.logerr(
            "SO101 real arm is not connected, keeping ROS/RViz alive with fallback joint states. "
            "Commands are refused until the motor bus connects. Error: %s",
            exc,
        )

    def _publish_joint_state(self, positions: Dict[str, float]) -> None:
        msg = JointState()
        msg.header.stamp = rospy.Time.now()
        msg.name = list(JOINT_NAMES)
        msg.position = [
            deg_to_rad(positions["shoulder_pan"]),
            deg_to_rad(positions["shoulder_lift"]),
            deg_to_rad(positions["elbow_flex"]),
            deg_to_rad(positions["wrist_flex"]),
            deg_to_rad(positions["wrist_roll"]),
            gripper_percent_to_rad(positions["gripper"]),
        ]
        self.joint_pub.publish(msg)

    def _publish_status(self) -> None:
        msg = SO101Status()
        msg.header.stamp = rospy.Time.now()
        msg.connected = self._connected
        msg.torque_enabled = self._torque_enabled
        msg.read_only = self.read_only
        msg.command_blocked = self._command_blocked
        msg.port = self.port
        msg.message = self._last_status
        self.status_pub.publish(msg)

    def _enable_flag_callback(self, msg: Bool) -> None:
        with self._lock:
            ok, text = self._set_torque(msg.data)
            if not ok:
                rospy.logwarn("%s", text)

    def _enable_service(self, req: Enable) -> EnableResponse:
        with self._lock:
            ok, text = self._set_torque(bool(req.enable_request))
            return EnableResponse(enable_response=ok, message=text)

    def _set_torque(self, enable: bool) -> tuple[bool, str]:
        if not self._connected or self._bus is None:
            return False, "SO101 bus is not connected."
        if self.read_only:
            return False, "read_only=true, refusing to change motor torque."

        try:
            if enable:
                self._bus.enable_torque()
                self._torque_enabled = True
                self._last_status = "torque enabled"
            else:
                self._bus.disable_torque()
                self._torque_enabled = False
                self._last_status = "torque disabled"
            return True, self._last_status
        except Exception as exc:  # noqa: BLE001
            self._last_status = f"torque command failed: {exc}"
            return False, self._last_status

    def _joint_command_callback(self, msg: JointState) -> None:
        with self._lock:
            ok, text = self._send_joint_command(msg)
            if not ok:
                rospy.logwarn_throttle(1.0, "%s", text)

    def _send_joint_command(self, msg: JointState) -> tuple[bool, str]:
        if self.read_only:
            return False, "read_only=true, ignoring joint command."
        if not self._torque_enabled:
            return False, "torque is disabled, ignoring joint command."
        if self._command_blocked:
            return False, "command_blocked=true, ignoring joint command."
        if self._bus is None:
            return False, "SO101 bus is not available."

        target = self._extract_joint_targets(msg)
        if target is None:
            return False, "JointState command did not contain usable SO101 joints."

        try:
            safe_target = self._limit_relative_target(target)
            self._bus.sync_write("Goal_Position", safe_target)
            self._last_status = "joint command sent"
            return True, self._last_status
        except Exception as exc:  # noqa: BLE001
            self._last_status = f"joint command failed: {exc}"
            return False, self._last_status

    def _extract_joint_targets(self, msg: JointState) -> Optional[Dict[str, float]]:
        if len(msg.position) == 0:
            return None

        if msg.name:
            indexed = {name: idx for idx, name in enumerate(msg.name)}
            missing = [name for name in JOINT_NAMES if name not in indexed]
            if missing:
                return None
            return {
                name: self._ros_position_to_lerobot(name, msg.position[indexed[name]])
                for name in JOINT_NAMES
            }

        if len(msg.position) < len(JOINT_NAMES):
            return None

        return {
            name: self._ros_position_to_lerobot(name, msg.position[idx])
            for idx, name in enumerate(JOINT_NAMES)
        }

    def _ros_position_to_lerobot(self, joint_name: str, position: float) -> float:
        if joint_name == GRIPPER_JOINT:
            return gripper_rad_to_percent(float(position))
        return rad_to_deg(float(position))

    def _limit_relative_target(self, target: Dict[str, float]) -> Dict[str, float]:
        current = self._last_positions
        if current is None:
            current = self._read_positions()
            self._last_positions = current

        limited: Dict[str, float] = {}
        for name in BODY_JOINTS:
            delta = target[name] - current[name]
            limited[name] = current[name] + clamp(
                delta,
                -self.max_relative_target_deg,
                self.max_relative_target_deg,
            )

        gripper_delta = target[GRIPPER_JOINT] - current[GRIPPER_JOINT]
        limited[GRIPPER_JOINT] = current[GRIPPER_JOINT] + clamp(
            gripper_delta,
            -self.max_relative_target_gripper,
            self.max_relative_target_gripper,
        )
        return limited

    def _gripper_service(self, req: Gripper) -> GripperResponse:
        with self._lock:
            if self.read_only:
                return GripperResponse(status=False, message="read_only=true, refusing gripper command.")
            if not self._torque_enabled:
                return GripperResponse(status=False, message="torque is disabled, refusing gripper command.")
            if self._command_blocked:
                return GripperResponse(status=False, message="command_blocked=true, refusing gripper command.")
            if self._bus is None:
                return GripperResponse(status=False, message="SO101 bus is not available.")

            pct = clamp(float(req.gripper_position), 0.0, 100.0)
            try:
                self._bus.write("Goal_Position", GRIPPER_JOINT, pct)
                self._last_status = f"gripper command sent: {pct:.1f}%"
                return GripperResponse(status=True, message=self._last_status)
            except Exception as exc:  # noqa: BLE001
                self._last_status = f"gripper command failed: {exc}"
                return GripperResponse(status=False, message=self._last_status)

    def _go_zero_service(self, req: GoZero) -> GoZeroResponse:
        with self._lock:
            if not bool(req.confirm):
                return GoZeroResponse(status=False, message="confirm must be true.")
            if self.read_only:
                return GoZeroResponse(status=False, message="read_only=true, refusing go_zero command.")
            if not self._torque_enabled:
                return GoZeroResponse(status=False, message="torque is disabled, refusing go_zero command.")
            if self._command_blocked:
                return GoZeroResponse(status=False, message="command_blocked=true, refusing go_zero command.")
            if self._bus is None:
                return GoZeroResponse(status=False, message="SO101 bus is not available.")

            target = {name: 0.0 for name in BODY_JOINTS}
            target[GRIPPER_JOINT] = 0.0
            try:
                safe_target = self._limit_relative_target(target)
                self._bus.sync_write("Goal_Position", safe_target)
                self._last_status = "go_zero command sent with relative safety limit"
                return GoZeroResponse(status=True, message=self._last_status)
            except Exception as exc:  # noqa: BLE001
                self._last_status = f"go_zero failed: {exc}"
                return GoZeroResponse(status=False, message=self._last_status)

    def _stop_service(self, _req: Trigger) -> TriggerResponse:
        with self._lock:
            self._command_blocked = True
            self._last_status = "commands blocked by stop_srv"
            return TriggerResponse(
                success=True,
                message="Commands are blocked. Call reset_srv or block_arm false to accept commands again.",
            )

    def _reset_service(self, _req: Trigger) -> TriggerResponse:
        with self._lock:
            self._command_blocked = False
            self._last_status = "command block cleared"
            return TriggerResponse(success=True, message=self._last_status)

    def _block_service(self, req: SetBool) -> SetBoolResponse:
        with self._lock:
            self._command_blocked = bool(req.data)
            self._last_status = "commands blocked" if self._command_blocked else "commands unblocked"
            return SetBoolResponse(success=True, message=self._last_status)


def main() -> None:
    rospy.init_node("so101_ctrl_single_node")
    node = SO101CtrlSingleNode()
    rospy.on_shutdown(node.shutdown)
    node.spin()


if __name__ == "__main__":
    main()
