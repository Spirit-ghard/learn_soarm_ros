# SO101 Follower Real Arm Usage

This package is a ROS1 bridge around the LeRobot SO101 follower motor bus.
It is intentionally conservative: launch files default to `read_only:=true`, so startup only reads and publishes the real arm state.

## 1. Build

```bash
cd /home/a/lwh_code/soarm_ros
catkin_make
source devel/setup.bash
```

## 2. Read-Only Check

This connects to the follower arm and publishes feedback, but refuses torque and motion commands.

```bash
roslaunch lwh_so101_real start_so101_follower.launch port:=/dev/ttyACM0 robot_id:=my_awesome_follower_arm read_only:=true
```

Useful checks in another terminal:

```bash
rostopic echo -n1 /joint_states_single
rostopic echo -n1 /arm_status
```

## 3. Real Arm in RViz

This shows the URDF model driven by the real arm feedback.

```bash
roslaunch lwh_so101_real start_so101_follower_rviz.launch port:=/dev/ttyACM0 robot_id:=my_awesome_follower_arm read_only:=true
```

## 4. Enable Real Control

Only do this after the read-only feedback looks correct.

The recommended control launch opens RViz plus a small joint-control window. The sliders are initialized from the current real arm pose.

```bash
roslaunch lwh_so101_real start_so101_follower_rviz_control.launch port:=/dev/ttyACM0 robot_id:=my_awesome_follower_arm
```

If you also want Gazebo to move together with the same targets:

```bash
roslaunch lwh_so101_real start_so101_follower_rviz_gazebo_control.launch port:=/dev/ttyACM0 robot_id:=my_awesome_follower_arm
```

In the control window:

- `启用` enables torque and syncs all targets to the current real pose first.
- Move a slider to command an absolute target angle. After `启用`, dragging a slider continuously publishes the target.
- The first five joints are shown in degrees. The gripper is shown as 0-100 percent.
- `同步当前位置` resets all sliders to the current real pose.
- `停用` disables torque.

The lower-level launch is also available:

```bash
roslaunch lwh_so101_real start_so101_follower.launch port:=/dev/ttyACM0 robot_id:=my_awesome_follower_arm read_only:=false
```

In another terminal:

```bash
rosservice call /enable_srv "enable_request: true"
```

The command topic is `/joint_ctrl_single`, using `sensor_msgs/JointState`.
The first five joints are radians. The gripper uses the URDF joint range in radians and is mapped internally to LeRobot 0-100 percent.

Before commanding, inspect the current pose:

```bash
rostopic echo -n1 /joint_states_single
```

Send only small changes first. The node also limits each command step with `max_relative_target_deg` and `max_relative_target_gripper`.

Disable torque when finished:

```bash
rosservice call /enable_srv "enable_request: false"
```

## 5. Services and Topics

- Publishes `/joint_states_single`: real arm feedback as ROS `JointState`.
- Publishes `/arm_status`: connection, torque, read-only, and command block state.
- Subscribes `/joint_ctrl_single`: target `JointState`, accepted only when not read-only, torque is enabled, and commands are unblocked.
- Subscribes `/enable_flag`: `std_msgs/Bool`, same behavior as `/enable_srv`.
- Service `/enable_srv`: enable or disable servo torque.
- Service `/gripper_srv`: command gripper percentage, 0-100.
- Service `/go_zero_srv`: command a zero pose with relative safety limiting; requires `confirm: true`.
- Service `/stop_srv`: block future commands without changing torque.
- Service `/reset_srv`: clear the command block.
- Service `/block_arm`: set or clear command blocking.

## 6. Calibration

The default `robot_id` is `my_awesome_follower_arm`, matching the existing file:

```text
/home/a/.cache/huggingface/lerobot/calibration/robots/so101_follower/my_awesome_follower_arm.json
```

The launch file passes this `so101_follower` calibration directory explicitly. This is needed because the LeRobot class name is generic (`so_follower`) while the saved SO101 calibration directory is model-specific (`so101_follower`).

For a new follower arm, first run LeRobot calibration outside this ROS node, then pass the matching `robot_id` or `calibration_dir`.
