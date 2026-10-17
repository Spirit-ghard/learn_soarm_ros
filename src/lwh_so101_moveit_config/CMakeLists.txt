cmake_minimum_required(VERSION 3.0.2)
project(lwh_so101_moveit_config)

find_package(catkin REQUIRED)

catkin_package()

catkin_install_python(PROGRAMS
  scripts/gazebo_joint_state_sync.py
  scripts/joint_state_retimestamp.py
  DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}
)

install(DIRECTORY config launch worlds
  DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION}
)
