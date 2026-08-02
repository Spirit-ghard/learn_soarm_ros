#!/usr/bin/env python3
"""Spawn SO101 into Gazebo after deleting a stale model with the same name."""

import rospy
from gazebo_msgs.srv import DeleteModel, GetWorldProperties, SpawnModel
from geometry_msgs.msg import Pose


def main():
    rospy.init_node("so101_robust_spawner")
    model_name = rospy.get_param("~model_name", "so101")
    robot_description_param = rospy.get_param("~robot_description_param", "/robot_description")

    rospy.wait_for_service("/gazebo/get_world_properties")
    rospy.wait_for_service("/gazebo/delete_model")
    rospy.wait_for_service("/gazebo/spawn_urdf_model")

    get_world_properties = rospy.ServiceProxy("/gazebo/get_world_properties", GetWorldProperties)
    delete_model = rospy.ServiceProxy("/gazebo/delete_model", DeleteModel)
    spawn_model = rospy.ServiceProxy("/gazebo/spawn_urdf_model", SpawnModel)

    try:
        world = get_world_properties()
        if model_name in world.model_names:
            rospy.logwarn("Gazebo model '%s' already exists; deleting it before respawn.", model_name)
            delete_model(model_name)
            rospy.sleep(0.5)
    except Exception as exc:  # noqa: BLE001
        rospy.logwarn("Could not inspect/delete stale Gazebo model '%s': %s", model_name, exc)

    robot_xml = rospy.get_param(robot_description_param)
    response = spawn_model(model_name, robot_xml, "", Pose(), "world")
    if not response.success:
        rospy.logerr("SpawnModel failed: %s", response.status_message)
        raise SystemExit(1)
    rospy.loginfo("SpawnModel succeeded: %s", response.status_message)


if __name__ == "__main__":
    main()
