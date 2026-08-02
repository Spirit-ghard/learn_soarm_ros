cmake_minimum_required(VERSION 3.0.2)
project(lwh_so101_description)

find_package(catkin REQUIRED COMPONENTS
  rospy
  sensor_msgs
  std_msgs
)

catkin_package()

catkin_install_python(PROGRAMS
  scripts/joint_states_ctrl.py
  scripts/spawn_so101_model.py
  DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}
)

install(DIRECTORY
  config
  launch
  meshes
  rviz
  urdf
  DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION}
)
