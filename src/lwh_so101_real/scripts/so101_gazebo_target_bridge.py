#!/usr/bin/env python3
"""Forward SO101 target JointState commands to Gazebo position controllers."""

import rospy
from sensor_msgs.msg import JointState
from std_msgs.msg import Float64


JOINT_NAMES = [
    "shoulder_pan",
    "shoulder_lift",
    "elbow_flex",
    "wrist_flex",
    "wrist_roll",
    "gripper",
]


class SO101GazeboTargetBridge:
    def __init__(self):
        self.command_topic = rospy.get_param("~command_topic", "/joint_ctrl_single")
        self.namespace = rospy.get_param("~controller_namespace", "/gazebo")
        self.publishers = {
            name: rospy.Publisher(
                "%s/%s_position_controller/command" % (self.namespace.rstrip("/"), name),
                Float64,
                queue_size=10,
            )
            for name in JOINT_NAMES
        }
        rospy.Subscriber(self.command_topic, JointState, self._callback, queue_size=1)

    def _callback(self, msg):
        if not msg.name:
            return
        positions = {name: msg.position[idx] for idx, name in enumerate(msg.name) if idx < len(msg.position)}
        for name in JOINT_NAMES:
            if name in positions:
                self.publishers[name].publish(Float64(float(positions[name])))


def main():
    rospy.init_node("so101_gazebo_target_bridge")
    SO101GazeboTargetBridge()
    rospy.spin()


if __name__ == "__main__":
    main()
