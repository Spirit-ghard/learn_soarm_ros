# generated from genmsg/cmake/pkg-genmsg.cmake.em

message(STATUS "lwh_so101_real: 1 messages, 3 services")

set(MSG_I_FLAGS "-Ilwh_so101_real:/home/a/lwh_code/soarm_ros/src/lwh_so101_real/msg;-Istd_msgs:/opt/ros/noetic/share/std_msgs/cmake/../msg")

# Find all generators
find_package(gencpp REQUIRED)
find_package(geneus REQUIRED)
find_package(genlisp REQUIRED)
find_package(gennodejs REQUIRED)
find_package(genpy REQUIRED)

add_custom_target(lwh_so101_real_generate_messages ALL)

# verify that message/service dependencies have not changed since configure



get_filename_component(_filename "/home/a/lwh_code/soarm_ros/src/lwh_so101_real/msg/SO101Status.msg" NAME_WE)
add_custom_target(_lwh_so101_real_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "lwh_so101_real" "/home/a/lwh_code/soarm_ros/src/lwh_so101_real/msg/SO101Status.msg" "std_msgs/Header"
)

get_filename_component(_filename "/home/a/lwh_code/soarm_ros/src/lwh_so101_real/srv/Enable.srv" NAME_WE)
add_custom_target(_lwh_so101_real_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "lwh_so101_real" "/home/a/lwh_code/soarm_ros/src/lwh_so101_real/srv/Enable.srv" ""
)

get_filename_component(_filename "/home/a/lwh_code/soarm_ros/src/lwh_so101_real/srv/Gripper.srv" NAME_WE)
add_custom_target(_lwh_so101_real_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "lwh_so101_real" "/home/a/lwh_code/soarm_ros/src/lwh_so101_real/srv/Gripper.srv" ""
)

get_filename_component(_filename "/home/a/lwh_code/soarm_ros/src/lwh_so101_real/srv/GoZero.srv" NAME_WE)
add_custom_target(_lwh_so101_real_generate_messages_check_deps_${_filename}
  COMMAND ${CATKIN_ENV} ${PYTHON_EXECUTABLE} ${GENMSG_CHECK_DEPS_SCRIPT} "lwh_so101_real" "/home/a/lwh_code/soarm_ros/src/lwh_so101_real/srv/GoZero.srv" ""
)

#
#  langs = gencpp;geneus;genlisp;gennodejs;genpy
#

### Section generating for lang: gencpp
### Generating Messages
_generate_msg_cpp(lwh_so101_real
  "/home/a/lwh_code/soarm_ros/src/lwh_so101_real/msg/SO101Status.msg"
  "${MSG_I_FLAGS}"
  "/opt/ros/noetic/share/std_msgs/cmake/../msg/Header.msg"
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/lwh_so101_real
)

### Generating Services
_generate_srv_cpp(lwh_so101_real
  "/home/a/lwh_code/soarm_ros/src/lwh_so101_real/srv/Enable.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/lwh_so101_real
)
_generate_srv_cpp(lwh_so101_real
  "/home/a/lwh_code/soarm_ros/src/lwh_so101_real/srv/Gripper.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/lwh_so101_real
)
_generate_srv_cpp(lwh_so101_real
  "/home/a/lwh_code/soarm_ros/src/lwh_so101_real/srv/GoZero.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/lwh_so101_real
)

### Generating Module File
_generate_module_cpp(lwh_so101_real
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/lwh_so101_real
  "${ALL_GEN_OUTPUT_FILES_cpp}"
)

add_custom_target(lwh_so101_real_generate_messages_cpp
  DEPENDS ${ALL_GEN_OUTPUT_FILES_cpp}
)
add_dependencies(lwh_so101_real_generate_messages lwh_so101_real_generate_messages_cpp)

# add dependencies to all check dependencies targets
get_filename_component(_filename "/home/a/lwh_code/soarm_ros/src/lwh_so101_real/msg/SO101Status.msg" NAME_WE)
add_dependencies(lwh_so101_real_generate_messages_cpp _lwh_so101_real_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/a/lwh_code/soarm_ros/src/lwh_so101_real/srv/Enable.srv" NAME_WE)
add_dependencies(lwh_so101_real_generate_messages_cpp _lwh_so101_real_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/a/lwh_code/soarm_ros/src/lwh_so101_real/srv/Gripper.srv" NAME_WE)
add_dependencies(lwh_so101_real_generate_messages_cpp _lwh_so101_real_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/a/lwh_code/soarm_ros/src/lwh_so101_real/srv/GoZero.srv" NAME_WE)
add_dependencies(lwh_so101_real_generate_messages_cpp _lwh_so101_real_generate_messages_check_deps_${_filename})

# target for backward compatibility
add_custom_target(lwh_so101_real_gencpp)
add_dependencies(lwh_so101_real_gencpp lwh_so101_real_generate_messages_cpp)

# register target for catkin_package(EXPORTED_TARGETS)
list(APPEND ${PROJECT_NAME}_EXPORTED_TARGETS lwh_so101_real_generate_messages_cpp)

### Section generating for lang: geneus
### Generating Messages
_generate_msg_eus(lwh_so101_real
  "/home/a/lwh_code/soarm_ros/src/lwh_so101_real/msg/SO101Status.msg"
  "${MSG_I_FLAGS}"
  "/opt/ros/noetic/share/std_msgs/cmake/../msg/Header.msg"
  ${CATKIN_DEVEL_PREFIX}/${geneus_INSTALL_DIR}/lwh_so101_real
)

### Generating Services
_generate_srv_eus(lwh_so101_real
  "/home/a/lwh_code/soarm_ros/src/lwh_so101_real/srv/Enable.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${geneus_INSTALL_DIR}/lwh_so101_real
)
_generate_srv_eus(lwh_so101_real
  "/home/a/lwh_code/soarm_ros/src/lwh_so101_real/srv/Gripper.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${geneus_INSTALL_DIR}/lwh_so101_real
)
_generate_srv_eus(lwh_so101_real
  "/home/a/lwh_code/soarm_ros/src/lwh_so101_real/srv/GoZero.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${geneus_INSTALL_DIR}/lwh_so101_real
)

### Generating Module File
_generate_module_eus(lwh_so101_real
  ${CATKIN_DEVEL_PREFIX}/${geneus_INSTALL_DIR}/lwh_so101_real
  "${ALL_GEN_OUTPUT_FILES_eus}"
)

add_custom_target(lwh_so101_real_generate_messages_eus
  DEPENDS ${ALL_GEN_OUTPUT_FILES_eus}
)
add_dependencies(lwh_so101_real_generate_messages lwh_so101_real_generate_messages_eus)

# add dependencies to all check dependencies targets
get_filename_component(_filename "/home/a/lwh_code/soarm_ros/src/lwh_so101_real/msg/SO101Status.msg" NAME_WE)
add_dependencies(lwh_so101_real_generate_messages_eus _lwh_so101_real_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/a/lwh_code/soarm_ros/src/lwh_so101_real/srv/Enable.srv" NAME_WE)
add_dependencies(lwh_so101_real_generate_messages_eus _lwh_so101_real_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/a/lwh_code/soarm_ros/src/lwh_so101_real/srv/Gripper.srv" NAME_WE)
add_dependencies(lwh_so101_real_generate_messages_eus _lwh_so101_real_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/a/lwh_code/soarm_ros/src/lwh_so101_real/srv/GoZero.srv" NAME_WE)
add_dependencies(lwh_so101_real_generate_messages_eus _lwh_so101_real_generate_messages_check_deps_${_filename})

# target for backward compatibility
add_custom_target(lwh_so101_real_geneus)
add_dependencies(lwh_so101_real_geneus lwh_so101_real_generate_messages_eus)

# register target for catkin_package(EXPORTED_TARGETS)
list(APPEND ${PROJECT_NAME}_EXPORTED_TARGETS lwh_so101_real_generate_messages_eus)

### Section generating for lang: genlisp
### Generating Messages
_generate_msg_lisp(lwh_so101_real
  "/home/a/lwh_code/soarm_ros/src/lwh_so101_real/msg/SO101Status.msg"
  "${MSG_I_FLAGS}"
  "/opt/ros/noetic/share/std_msgs/cmake/../msg/Header.msg"
  ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/lwh_so101_real
)

### Generating Services
_generate_srv_lisp(lwh_so101_real
  "/home/a/lwh_code/soarm_ros/src/lwh_so101_real/srv/Enable.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/lwh_so101_real
)
_generate_srv_lisp(lwh_so101_real
  "/home/a/lwh_code/soarm_ros/src/lwh_so101_real/srv/Gripper.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/lwh_so101_real
)
_generate_srv_lisp(lwh_so101_real
  "/home/a/lwh_code/soarm_ros/src/lwh_so101_real/srv/GoZero.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/lwh_so101_real
)

### Generating Module File
_generate_module_lisp(lwh_so101_real
  ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/lwh_so101_real
  "${ALL_GEN_OUTPUT_FILES_lisp}"
)

add_custom_target(lwh_so101_real_generate_messages_lisp
  DEPENDS ${ALL_GEN_OUTPUT_FILES_lisp}
)
add_dependencies(lwh_so101_real_generate_messages lwh_so101_real_generate_messages_lisp)

# add dependencies to all check dependencies targets
get_filename_component(_filename "/home/a/lwh_code/soarm_ros/src/lwh_so101_real/msg/SO101Status.msg" NAME_WE)
add_dependencies(lwh_so101_real_generate_messages_lisp _lwh_so101_real_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/a/lwh_code/soarm_ros/src/lwh_so101_real/srv/Enable.srv" NAME_WE)
add_dependencies(lwh_so101_real_generate_messages_lisp _lwh_so101_real_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/a/lwh_code/soarm_ros/src/lwh_so101_real/srv/Gripper.srv" NAME_WE)
add_dependencies(lwh_so101_real_generate_messages_lisp _lwh_so101_real_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/a/lwh_code/soarm_ros/src/lwh_so101_real/srv/GoZero.srv" NAME_WE)
add_dependencies(lwh_so101_real_generate_messages_lisp _lwh_so101_real_generate_messages_check_deps_${_filename})

# target for backward compatibility
add_custom_target(lwh_so101_real_genlisp)
add_dependencies(lwh_so101_real_genlisp lwh_so101_real_generate_messages_lisp)

# register target for catkin_package(EXPORTED_TARGETS)
list(APPEND ${PROJECT_NAME}_EXPORTED_TARGETS lwh_so101_real_generate_messages_lisp)

### Section generating for lang: gennodejs
### Generating Messages
_generate_msg_nodejs(lwh_so101_real
  "/home/a/lwh_code/soarm_ros/src/lwh_so101_real/msg/SO101Status.msg"
  "${MSG_I_FLAGS}"
  "/opt/ros/noetic/share/std_msgs/cmake/../msg/Header.msg"
  ${CATKIN_DEVEL_PREFIX}/${gennodejs_INSTALL_DIR}/lwh_so101_real
)

### Generating Services
_generate_srv_nodejs(lwh_so101_real
  "/home/a/lwh_code/soarm_ros/src/lwh_so101_real/srv/Enable.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${gennodejs_INSTALL_DIR}/lwh_so101_real
)
_generate_srv_nodejs(lwh_so101_real
  "/home/a/lwh_code/soarm_ros/src/lwh_so101_real/srv/Gripper.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${gennodejs_INSTALL_DIR}/lwh_so101_real
)
_generate_srv_nodejs(lwh_so101_real
  "/home/a/lwh_code/soarm_ros/src/lwh_so101_real/srv/GoZero.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${gennodejs_INSTALL_DIR}/lwh_so101_real
)

### Generating Module File
_generate_module_nodejs(lwh_so101_real
  ${CATKIN_DEVEL_PREFIX}/${gennodejs_INSTALL_DIR}/lwh_so101_real
  "${ALL_GEN_OUTPUT_FILES_nodejs}"
)

add_custom_target(lwh_so101_real_generate_messages_nodejs
  DEPENDS ${ALL_GEN_OUTPUT_FILES_nodejs}
)
add_dependencies(lwh_so101_real_generate_messages lwh_so101_real_generate_messages_nodejs)

# add dependencies to all check dependencies targets
get_filename_component(_filename "/home/a/lwh_code/soarm_ros/src/lwh_so101_real/msg/SO101Status.msg" NAME_WE)
add_dependencies(lwh_so101_real_generate_messages_nodejs _lwh_so101_real_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/a/lwh_code/soarm_ros/src/lwh_so101_real/srv/Enable.srv" NAME_WE)
add_dependencies(lwh_so101_real_generate_messages_nodejs _lwh_so101_real_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/a/lwh_code/soarm_ros/src/lwh_so101_real/srv/Gripper.srv" NAME_WE)
add_dependencies(lwh_so101_real_generate_messages_nodejs _lwh_so101_real_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/a/lwh_code/soarm_ros/src/lwh_so101_real/srv/GoZero.srv" NAME_WE)
add_dependencies(lwh_so101_real_generate_messages_nodejs _lwh_so101_real_generate_messages_check_deps_${_filename})

# target for backward compatibility
add_custom_target(lwh_so101_real_gennodejs)
add_dependencies(lwh_so101_real_gennodejs lwh_so101_real_generate_messages_nodejs)

# register target for catkin_package(EXPORTED_TARGETS)
list(APPEND ${PROJECT_NAME}_EXPORTED_TARGETS lwh_so101_real_generate_messages_nodejs)

### Section generating for lang: genpy
### Generating Messages
_generate_msg_py(lwh_so101_real
  "/home/a/lwh_code/soarm_ros/src/lwh_so101_real/msg/SO101Status.msg"
  "${MSG_I_FLAGS}"
  "/opt/ros/noetic/share/std_msgs/cmake/../msg/Header.msg"
  ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/lwh_so101_real
)

### Generating Services
_generate_srv_py(lwh_so101_real
  "/home/a/lwh_code/soarm_ros/src/lwh_so101_real/srv/Enable.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/lwh_so101_real
)
_generate_srv_py(lwh_so101_real
  "/home/a/lwh_code/soarm_ros/src/lwh_so101_real/srv/Gripper.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/lwh_so101_real
)
_generate_srv_py(lwh_so101_real
  "/home/a/lwh_code/soarm_ros/src/lwh_so101_real/srv/GoZero.srv"
  "${MSG_I_FLAGS}"
  ""
  ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/lwh_so101_real
)

### Generating Module File
_generate_module_py(lwh_so101_real
  ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/lwh_so101_real
  "${ALL_GEN_OUTPUT_FILES_py}"
)

add_custom_target(lwh_so101_real_generate_messages_py
  DEPENDS ${ALL_GEN_OUTPUT_FILES_py}
)
add_dependencies(lwh_so101_real_generate_messages lwh_so101_real_generate_messages_py)

# add dependencies to all check dependencies targets
get_filename_component(_filename "/home/a/lwh_code/soarm_ros/src/lwh_so101_real/msg/SO101Status.msg" NAME_WE)
add_dependencies(lwh_so101_real_generate_messages_py _lwh_so101_real_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/a/lwh_code/soarm_ros/src/lwh_so101_real/srv/Enable.srv" NAME_WE)
add_dependencies(lwh_so101_real_generate_messages_py _lwh_so101_real_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/a/lwh_code/soarm_ros/src/lwh_so101_real/srv/Gripper.srv" NAME_WE)
add_dependencies(lwh_so101_real_generate_messages_py _lwh_so101_real_generate_messages_check_deps_${_filename})
get_filename_component(_filename "/home/a/lwh_code/soarm_ros/src/lwh_so101_real/srv/GoZero.srv" NAME_WE)
add_dependencies(lwh_so101_real_generate_messages_py _lwh_so101_real_generate_messages_check_deps_${_filename})

# target for backward compatibility
add_custom_target(lwh_so101_real_genpy)
add_dependencies(lwh_so101_real_genpy lwh_so101_real_generate_messages_py)

# register target for catkin_package(EXPORTED_TARGETS)
list(APPEND ${PROJECT_NAME}_EXPORTED_TARGETS lwh_so101_real_generate_messages_py)



if(gencpp_INSTALL_DIR AND EXISTS ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/lwh_so101_real)
  # install generated code
  install(
    DIRECTORY ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/lwh_so101_real
    DESTINATION ${gencpp_INSTALL_DIR}
  )
endif()
if(TARGET std_msgs_generate_messages_cpp)
  add_dependencies(lwh_so101_real_generate_messages_cpp std_msgs_generate_messages_cpp)
endif()

if(geneus_INSTALL_DIR AND EXISTS ${CATKIN_DEVEL_PREFIX}/${geneus_INSTALL_DIR}/lwh_so101_real)
  # install generated code
  install(
    DIRECTORY ${CATKIN_DEVEL_PREFIX}/${geneus_INSTALL_DIR}/lwh_so101_real
    DESTINATION ${geneus_INSTALL_DIR}
  )
endif()
if(TARGET std_msgs_generate_messages_eus)
  add_dependencies(lwh_so101_real_generate_messages_eus std_msgs_generate_messages_eus)
endif()

if(genlisp_INSTALL_DIR AND EXISTS ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/lwh_so101_real)
  # install generated code
  install(
    DIRECTORY ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/lwh_so101_real
    DESTINATION ${genlisp_INSTALL_DIR}
  )
endif()
if(TARGET std_msgs_generate_messages_lisp)
  add_dependencies(lwh_so101_real_generate_messages_lisp std_msgs_generate_messages_lisp)
endif()

if(gennodejs_INSTALL_DIR AND EXISTS ${CATKIN_DEVEL_PREFIX}/${gennodejs_INSTALL_DIR}/lwh_so101_real)
  # install generated code
  install(
    DIRECTORY ${CATKIN_DEVEL_PREFIX}/${gennodejs_INSTALL_DIR}/lwh_so101_real
    DESTINATION ${gennodejs_INSTALL_DIR}
  )
endif()
if(TARGET std_msgs_generate_messages_nodejs)
  add_dependencies(lwh_so101_real_generate_messages_nodejs std_msgs_generate_messages_nodejs)
endif()

if(genpy_INSTALL_DIR AND EXISTS ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/lwh_so101_real)
  install(CODE "execute_process(COMMAND \"/usr/bin/python3\" -m compileall \"${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/lwh_so101_real\")")
  # install generated code
  install(
    DIRECTORY ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/lwh_so101_real
    DESTINATION ${genpy_INSTALL_DIR}
  )
endif()
if(TARGET std_msgs_generate_messages_py)
  add_dependencies(lwh_so101_real_generate_messages_py std_msgs_generate_messages_py)
endif()
