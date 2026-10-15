#!/usr/bin/env python3
"""Republish JointState messages with the current ROS time.

MoveIt fake execution publishes JointState messages that are convenient to
record, but their recorded header stamps can be stale when a bag is played
back into a running demo. This bridge keeps playback simple: record the raw
fake-controller topic, play that bag directly, and feed the display chain from
this node's retimestamped output.
"""

import rospy
from sensor_msgs.msg import JointState


class JointStateRetimestamp:
    def __init__(self):
        self.input_topic = rospy.get_param("~input_topic", "/move_group/fake_controller_joint_states")
        self.output_topic = rospy.get_param(
            "~output_topic",
            "/so101_bag/joint_states",
        )
        self.frame_id = rospy.get_param("~frame_id", "dummy_link")
        self.pub = rospy.Publisher(self.output_topic, JointState, queue_size=20)
        self.sub = rospy.Subscriber(self.input_topic, JointState, self._on_joint_state, queue_size=20)
        rospy.loginfo("Retiming JointState %s -> %s", self.input_topic, self.output_topic)

    def _on_joint_state(self, msg):
        out = JointState()
        out.header = msg.header
        out.header.stamp = rospy.Time.now()
        if not out.header.frame_id:
            out.header.frame_id = self.frame_id
        out.name = list(msg.name)
        out.position = list(msg.position)
        out.velocity = list(msg.velocity)
        out.effort = list(msg.effort)
        self.pub.publish(out)


def main():
    rospy.init_node("joint_state_retimestamp")
    JointStateRetimestamp()
    rospy.spin()


if __name__ == "__main__":
    main()
