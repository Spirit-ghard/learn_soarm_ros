cmake_minimum_required(VERSION 3.0.2)
project(lwh_so101_real)

find_package(catkin REQUIRED COMPONENTS
  message_generation
  rospy
  sensor_msgs
  std_msgs
  std_srvs
)

add_message_files(
  FILES
  SO101Status.msg
)

add_service_files(
  FILES
  Enable.srv
  Gripper.srv
  GoZero.srv
)

generate_messages(
  DEPENDENCIES
  std_msgs
)

catkin_package(
  CATKIN_DEPENDS message_runtime rospy sensor_msgs std_msgs std_srvs
)

install(PROGRAMS
  scripts/so101_ctrl_single_node.py
  scripts/so101_relative_control_gui.py
  DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}
)

install(DIRECTORY launch
  DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION}
)
