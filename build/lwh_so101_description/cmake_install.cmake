# Install script for directory: /home/a/lwh_code/soarm_ros/src/lwh_so101_description

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/home/a/lwh_code/soarm_ros/install")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Install shared libraries without execute permission?
if(NOT DEFINED CMAKE_INSTALL_SO_NO_EXE)
  set(CMAKE_INSTALL_SO_NO_EXE "1")
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

# Set default install directory permissions.
if(NOT DEFINED CMAKE_OBJDUMP)
  set(CMAKE_OBJDUMP "/usr/bin/objdump")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/pkgconfig" TYPE FILE FILES "/home/a/lwh_code/soarm_ros/build/lwh_so101_description/catkin_generated/installspace/lwh_so101_description.pc")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/lwh_so101_description/cmake" TYPE FILE FILES
    "/home/a/lwh_code/soarm_ros/build/lwh_so101_description/catkin_generated/installspace/lwh_so101_descriptionConfig.cmake"
    "/home/a/lwh_code/soarm_ros/build/lwh_so101_description/catkin_generated/installspace/lwh_so101_descriptionConfig-version.cmake"
    )
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/lwh_so101_description" TYPE FILE FILES "/home/a/lwh_code/soarm_ros/src/lwh_so101_description/package.xml")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/lwh_so101_description" TYPE PROGRAM FILES "/home/a/lwh_code/soarm_ros/build/lwh_so101_description/catkin_generated/installspace/joint_states_ctrl.py")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/lwh_so101_description" TYPE PROGRAM FILES "/home/a/lwh_code/soarm_ros/build/lwh_so101_description/catkin_generated/installspace/spawn_so101_model.py")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/lwh_so101_description" TYPE DIRECTORY FILES
    "/home/a/lwh_code/soarm_ros/src/lwh_so101_description/config"
    "/home/a/lwh_code/soarm_ros/src/lwh_so101_description/launch"
    "/home/a/lwh_code/soarm_ros/src/lwh_so101_description/meshes"
    "/home/a/lwh_code/soarm_ros/src/lwh_so101_description/rviz"
    "/home/a/lwh_code/soarm_ros/src/lwh_so101_description/urdf"
    )
endif()

