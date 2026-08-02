#!/usr/bin/env python3
"""PyQt control panel for SO101 joint targets."""

import math
import sys
import threading

import rospy
from PyQt5.QtCore import Qt, QTimer
from PyQt5.QtWidgets import (
    QApplication,
    QFrame,
    QGridLayout,
    QHBoxLayout,
    QLabel,
    QMainWindow,
    QPushButton,
    QSlider,
    QVBoxLayout,
    QWidget,
)
from sensor_msgs.msg import JointState

from lwh_so101_real.srv import Enable


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

JOINT_LIMITS = {
    "shoulder_pan": (-110.0, 110.0, "deg"),
    "shoulder_lift": (-100.0, 100.0, "deg"),
    "elbow_flex": (-96.8, 96.8, "deg"),
    "wrist_flex": (-95.0, 95.0, "deg"),
    "wrist_roll": (-157.2, 162.8, "deg"),
    "gripper": (0.0, 100.0, "%"),
}

SCALE = 10


def rad_to_deg(value):
    return value * 180.0 / math.pi


def deg_to_rad(value):
    return value * math.pi / 180.0


def clamp(value, lower, upper):
    return max(lower, min(upper, value))


def gripper_rad_to_percent(value):
    rad = clamp(value, GRIPPER_RAD_MIN, GRIPPER_RAD_MAX)
    return (rad - GRIPPER_RAD_MIN) * 100.0 / (GRIPPER_RAD_MAX - GRIPPER_RAD_MIN)


def gripper_percent_to_rad(value):
    pct = clamp(value, 0.0, 100.0)
    return GRIPPER_RAD_MIN + (GRIPPER_RAD_MAX - GRIPPER_RAD_MIN) * pct / 100.0


class SO101ControlWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.feedback_topic = rospy.get_param("~feedback_topic", "/joint_states_single")
        self.command_topic = rospy.get_param("~command_topic", "/joint_ctrl_single")
        self.publish_rate = float(rospy.get_param("~publish_rate", 20.0))

        self._lock = threading.RLock()
        self._current = {}
        self._have_feedback = False
        self._enabled = False
        self._syncing = False
        self._initial_synced = False

        self.command_pub = rospy.Publisher(self.command_topic, JointState, queue_size=1)

        self.sliders = {}
        self.value_labels = {}
        self.current_labels = {}
        self.status_label = QLabel("等待真实机械臂反馈")

        self._build_ui()
        self._setup_timers()
        rospy.Subscriber(self.feedback_topic, JointState, self._feedback_callback, queue_size=1)

    def _build_ui(self):
        self.setWindowTitle("SO101 控制台")
        self.resize(720, 520)

        root = QWidget()
        root.setObjectName("root")
        root_layout = QVBoxLayout(root)
        root_layout.setContentsMargins(22, 22, 22, 22)
        root_layout.setSpacing(16)
        self.setCentralWidget(root)

        header = QHBoxLayout()
        title_block = QVBoxLayout()
        title = QLabel("SO101 控制台")
        title.setObjectName("title")
        subtitle = QLabel("滑块会从真实机械臂当前姿态初始化；使能后拖动即可运动")
        subtitle.setObjectName("subtitle")
        title_block.addWidget(title)
        title_block.addWidget(subtitle)
        header.addLayout(title_block, 1)

        self.state_badge = QLabel("拖拽模式")
        self.state_badge.setObjectName("badgeDrag")
        header.addWidget(self.state_badge, 0, Qt.AlignRight | Qt.AlignTop)
        root_layout.addLayout(header)

        button_row = QHBoxLayout()
        button_row.setSpacing(10)
        self.enable_button = QPushButton("使能")
        self.enable_button.setObjectName("modeButton")
        self.disable_button = QPushButton("拖拽")
        self.disable_button.setObjectName("modeButtonActive")
        self.sync_button = QPushButton("同步当前位置")
        self.sync_button.setObjectName("secondaryButton")

        self.enable_button.clicked.connect(self._enable)
        self.disable_button.clicked.connect(self._disable)
        self.sync_button.clicked.connect(self._sync_current)

        button_row.addWidget(self.enable_button)
        button_row.addWidget(self.disable_button)
        button_row.addWidget(self.sync_button)
        button_row.addStretch(1)
        root_layout.addLayout(button_row)

        card = QFrame()
        card.setObjectName("card")
        grid = QGridLayout(card)
        grid.setContentsMargins(18, 16, 18, 16)
        grid.setHorizontalSpacing(14)
        grid.setVerticalSpacing(12)
        grid.setColumnStretch(1, 1)

        grid.addWidget(self._head("关节"), 0, 0)
        grid.addWidget(self._head("目标"), 0, 1)
        grid.addWidget(self._head("数值"), 0, 2)
        grid.addWidget(self._head("当前"), 0, 3)

        for row, name in enumerate(JOINT_NAMES, start=1):
            lower, upper, unit = JOINT_LIMITS[name]
            name_label = QLabel(name)
            name_label.setObjectName("jointName")

            slider = QSlider(Qt.Horizontal)
            slider.setMinimum(round(lower * SCALE))
            slider.setMaximum(round(upper * SCALE))
            slider.setSingleStep(1)
            slider.setPageStep(10)
            slider.valueChanged.connect(self._on_slider_moved)

            value_label = QLabel("--")
            value_label.setObjectName("value")
            value_label.setAlignment(Qt.AlignRight | Qt.AlignVCenter)

            current_label = QLabel("--")
            current_label.setObjectName("current")
            current_label.setAlignment(Qt.AlignRight | Qt.AlignVCenter)

            grid.addWidget(name_label, row, 0)
            grid.addWidget(slider, row, 1)
            grid.addWidget(value_label, row, 2)
            grid.addWidget(current_label, row, 3)

            self.sliders[name] = slider
            self.value_labels[name] = (value_label, unit)
            self.current_labels[name] = (current_label, unit)

        root_layout.addWidget(card)

        self.status_label.setObjectName("status")
        root_layout.addWidget(self.status_label)

        self.setStyleSheet(
            """
            QWidget#root {
                background: #eef2f7;
                color: #182230;
                font-family: "Noto Sans CJK SC", "Microsoft YaHei", "Sans";
                font-size: 14px;
            }
            QLabel#title {
                font-size: 24px;
                font-weight: 700;
                color: #101828;
            }
            QLabel#subtitle {
                color: #667085;
                font-size: 13px;
                margin-top: 4px;
            }
            QLabel#badgeDrag, QLabel#badgeEnable {
                border-radius: 14px;
                padding: 6px 12px;
                font-weight: 700;
            }
            QLabel#badgeDrag {
                background: #eff4ff;
                color: #1849a9;
            }
            QLabel#badgeEnable {
                background: #dcfae6;
                color: #067647;
            }
            QPushButton {
                border: 0;
                border-radius: 8px;
                padding: 10px 18px;
                font-weight: 700;
                min-width: 110px;
            }
            QPushButton#modeButtonActive {
                background: #2563eb;
                color: white;
            }
            QPushButton#modeButtonActive:hover {
                background: #1d4ed8;
            }
            QPushButton#modeButton, QPushButton#secondaryButton {
                background: white;
                color: #344054;
                border: 1px solid #d0d5dd;
            }
            QPushButton#modeButton:hover, QPushButton#secondaryButton:hover {
                background: #f8fafc;
            }
            QFrame#card {
                background: white;
                border: 1px solid #d9e0ea;
                border-radius: 12px;
            }
            QLabel#tableHead {
                color: #667085;
                font-size: 12px;
                font-weight: 700;
            }
            QLabel#jointName {
                color: #344054;
                font-weight: 700;
            }
            QLabel#value {
                color: #101828;
                font-weight: 700;
                min-width: 78px;
            }
            QLabel#current {
                color: #667085;
                min-width: 78px;
            }
            QLabel#status {
                background: #e9eef5;
                border-radius: 8px;
                padding: 10px 12px;
                color: #344054;
            }
            QSlider::groove:horizontal {
                height: 8px;
                border-radius: 4px;
                background: #e4e7ec;
            }
            QSlider::sub-page:horizontal {
                background: #3b82f6;
                border-radius: 4px;
            }
            QSlider::handle:horizontal {
                background: white;
                border: 2px solid #2563eb;
                width: 18px;
                height: 18px;
                margin: -6px 0;
                border-radius: 9px;
            }
            """
        )

    def _head(self, text):
        label = QLabel(text)
        label.setObjectName("tableHead")
        return label

    def _setup_timers(self):
        self.feedback_timer = QTimer(self)
        self.feedback_timer.timeout.connect(self._refresh_current_labels)
        self.feedback_timer.start(100)

        self.publish_timer = QTimer(self)
        self.publish_timer.timeout.connect(self._publish_target_if_enabled)
        self.publish_timer.start(max(40, int(1000.0 / self.publish_rate)))

    def _feedback_callback(self, msg):
        values = self._joint_state_to_values(msg)
        if not values:
            return

        with self._lock:
            self._current = values
            self._have_feedback = True

    def _joint_state_to_values(self, msg):
        if not msg.name or len(msg.position) < len(msg.name):
            return {}

        by_name = {name: msg.position[idx] for idx, name in enumerate(msg.name)}
        if any(name not in by_name for name in JOINT_NAMES):
            return {}

        values = {}
        for name in BODY_JOINTS:
            values[name] = rad_to_deg(float(by_name[name]))
        values[GRIPPER_JOINT] = gripper_rad_to_percent(float(by_name[GRIPPER_JOINT]))
        return values

    def _sync_current(self):
        with self._lock:
            if not self._current:
                self._set_status("还没有收到真实机械臂反馈")
                return
            current = dict(self._current)

        self._syncing = True
        try:
            for name, value in current.items():
                lower, upper, _unit = JOINT_LIMITS[name]
                self.sliders[name].setValue(round(clamp(value, lower, upper) * SCALE))
        finally:
            self._syncing = False

        self._refresh_target_labels()
        self._refresh_current_labels()
        self._set_status("已同步到当前位置")

    def _enable(self):
        self._sync_current()
        if self._call_enable(True):
            self._enabled = True
            self._set_mode(True)
            self._set_status("已切换为使能模式")
            self._publish_target()

    def _disable(self):
        if self._call_enable(False):
            self._enabled = False
            self._set_mode(False)
            self._set_status("已切换为拖拽模式")

    def _call_enable(self, enable):
        try:
            rospy.wait_for_service("/enable_srv", timeout=2.0)
            service = rospy.ServiceProxy("/enable_srv", Enable)
            resp = service(enable_request=bool(enable))
            if not resp.enable_response:
                self._set_status(resp.message)
            return bool(resp.enable_response)
        except Exception as exc:  # noqa: BLE001
            self._set_status("使能服务调用失败: %s" % exc)
            return False

    def _on_slider_moved(self):
        if self._syncing:
            return
        self._refresh_target_labels()
        if not self._enabled and self._have_feedback:
            self._set_status("点击“使能”后拖动滑块即可运动")

    def _publish_target_if_enabled(self):
        if self._enabled and self._have_feedback:
            self._publish_target()

    def _publish_target(self):
        targets = self._target_values()
        if not targets:
            return

        msg = JointState()
        msg.header.stamp = rospy.Time.now()
        msg.name = list(JOINT_NAMES)
        msg.position = [
            deg_to_rad(targets["shoulder_pan"]),
            deg_to_rad(targets["shoulder_lift"]),
            deg_to_rad(targets["elbow_flex"]),
            deg_to_rad(targets["wrist_flex"]),
            deg_to_rad(targets["wrist_roll"]),
            gripper_percent_to_rad(targets["gripper"]),
        ]
        self.command_pub.publish(msg)

    def _target_values(self):
        if not self._have_feedback:
            return {}
        return {name: self.sliders[name].value() / float(SCALE) for name in JOINT_NAMES}

    def _refresh_target_labels(self):
        for name, (label, unit) in self.value_labels.items():
            label.setText("%.1f %s" % (self.sliders[name].value() / float(SCALE), unit))

    def _refresh_current_labels(self):
        with self._lock:
            current = dict(self._current)
        if not current:
            return
        if not self._initial_synced:
            self._initial_synced = True
            self._sync_current()
            return
        for name, (label, unit) in self.current_labels.items():
            value = current.get(name)
            if value is not None:
                label.setText("%.1f %s" % (value, unit))

    def _set_mode(self, enabled):
        self.state_badge.setText("使能模式" if enabled else "拖拽模式")
        self.state_badge.setObjectName("badgeEnable" if enabled else "badgeDrag")
        self.enable_button.setObjectName("modeButtonActive" if enabled else "modeButton")
        self.disable_button.setObjectName("modeButton" if enabled else "modeButtonActive")
        for widget in [self.state_badge, self.enable_button, self.disable_button]:
            widget.style().unpolish(widget)
            widget.style().polish(widget)

    def _set_status(self, text):
        self.status_label.setText(text)


def main():
    rospy.init_node("so101_simple_control_gui")
    app = QApplication(sys.argv)
    window = SO101ControlWindow()
    window.show()
    exit_code = app.exec_()
    sys.exit(exit_code)


if __name__ == "__main__":
    main()
