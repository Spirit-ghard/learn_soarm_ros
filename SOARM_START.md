# SO101 ROS1 仿真启动命令

工作空间位置：

```bash
cd /home/a/lwh_code/soarm_ros
```

第一次使用或改过包之后编译：

```bash
source /opt/ros/noetic/setup.bash
catkin_make
source devel/setup.bash
```

只用 RViz 查看模型和关节滑块：

```bash
roslaunch lwh_so101_description display_urdf.launch
```

只用 Gazebo 查看静态模型：

```bash
roslaunch lwh_so101_description gazebo_visual.launch
```

Gazebo 版本使用 `urdf/so101_gazebo.urdf`，保留普通 STL 外观 mesh，但物理碰撞不使用复杂 STL mesh。这样主要用于稳定显示和关节运动仿真。

启动 Gazebo 仿真控制：

```bash
roslaunch lwh_so101_description so101_gazebo.launch
```

另开一个终端启动 RViz 控制界面：

```bash
source /opt/ros/noetic/setup.bash
source /home/a/lwh_code/soarm_ros/devel/setup.bash
roslaunch lwh_so101_description display_control.launch
```

一条命令同时启动 Gazebo、RViz 和关节滑块：

```bash
roslaunch lwh_so101_description gazebo_rviz_control.launch
```

真实 SO101 follower 只读连接：

```bash
roslaunch lwh_so101_real start_so101_follower.launch port:=/dev/ttyACM0 robot_id:=my_awesome_follower_arm read_only:=true
```

真实 SO101 follower + RViz 反馈显示：

```bash
roslaunch lwh_so101_real start_so101_follower_rviz.launch port:=/dev/ttyACM0 robot_id:=my_awesome_follower_arm read_only:=true
```

真实 SO101 follower + RViz + 当前姿态初始化的控制窗口：

```bash
roslaunch lwh_so101_real start_so101_follower_rviz_control.launch port:=/dev/ttyACM0 robot_id:=my_awesome_follower_arm
```

真实 SO101 follower + RViz + Gazebo + 控制窗口：

```bash
roslaunch lwh_so101_real start_so101_follower_rviz_gazebo_control.launch port:=/dev/ttyACM0 robot_id:=my_awesome_follower_arm
```

真实控制默认不上电、不发目标。确认只读反馈正确后，详细步骤看：

```bash
less /home/a/lwh_code/soarm_ros/src/lwh_so101_real/REAL_ARM_USAGE.md
```

如果当前终端继承了旧的远程 ROS 网络变量，可以先清掉：

```bash
unset ROS_IP
unset ROS_HOSTNAME
export ROS_MASTER_URI=http://localhost:11311
```
