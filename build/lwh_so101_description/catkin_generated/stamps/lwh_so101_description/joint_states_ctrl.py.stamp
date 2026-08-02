#!/usr/bin/env python3

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

PUBLISHERS = {
    name: rospy.Publisher(
        "/gazebo/{}_position_controller/command".format(name),
        Float64,
        queue_size=10,
    )
    for name in JOINT_NAMES
}

LAST_POSITIONS = {name: None for name in JOINT_NAMES}


def joint_state_callback(msg):
    joint_positions = dict(zip(msg.name, msg.position))

    for joint_name in JOINT_NAMES:
        if joint_name not in joint_positions:
            continue

        position = joint_positions[joint_name]
        last_position = LAST_POSITIONS[joint_name]
        if last_position is None or abs(position - last_position) > 1e-5:
            PUBLISHERS[joint_name].publish(Float64(position))
            LAST_POSITIONS[joint_name] = position


def main():
    rospy.init_node("so101_joint_states_ctrl", anonymous=True)
    rospy.Subscriber("/joint_states", JointState, joint_state_callback, queue_size=1)
    rospy.spin()


if __name__ == "__main__":
    main()
