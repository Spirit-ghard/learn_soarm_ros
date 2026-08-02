# SO101 ROS1 仿真使用说明
--------
• 我刚检查了：

  /home/a/lwh_code/soarm_ros

  这个目录还不是 Git 仓库，所以要从初始化开始。

  你的远端仓库地址是：

  https://github.com/haozhuzhuzhu/soarm_ros.git

  建议这样做，先不要把 ROS 编译产物 build/、devel/ 推上去：

  cd /home/a/lwh_code/soarm_ros

  git init

  cat > .gitignore <<'EOF'
  build/
  devel/
  install/
  log/
  .catkin_tools/
  *.pyc
  __pycache__/
  EOF

  git add .
  git commit -m "Initial commit"

  git branch -M main
  git remote add origin https://github.com/haozhuzhuzhu/soarm_ros.git
  git push -u origin main

  如果 git push 的时候让你登录，GitHub 现在不能用账号密码，需要用 GitHub Token，
  或者先登录 GitHub CLI：

  gh auth login

  然后再执行：

  git push -u origin main

  你现在本机的 Git 提交身份已经有了，但 GitHub 推送认证还没完全配好，所以最可能
  卡在最后一步 git push。

--------
这个工作空间已经写入 `~/.bashrc`，新开终端后默认可以直接使用：

```bash
rospack find lwh_so101_description
```

如果当前终端是在修改 `.bashrc` 之前打开的，执行一次：

```bash
source ~/.bashrc
```

## 工作空间

```bash
cd /home/a/lwh_code/soarm_ros
```

修改包内容之后重新编译：

```bash
catkin_make
source devel/setup.bash
```

## RViz 单独看模型

只打开 RViz 和关节滑块，不启动 Gazebo：

```bash
roslaunch lwh_so101_description display_urdf.launch
```

## Gazebo 静态预览

只在 Gazebo 里看固定模型，不加载控制器。Gazebo 版本使用仿真专用 URDF，保留普通 STL 外观 mesh，但物理碰撞不使用复杂 STL mesh：

```bash
roslaunch lwh_so101_description gazebo_visual.launch
```

## Gazebo 仿真控制

启动 Gazebo、模型和 6 个 position controller：

```bash
roslaunch lwh_so101_description so101_gazebo.launch
```

另开终端启动 RViz 和关节滑块：

```bash
roslaunch lwh_so101_description display_control.launch
```

## 一条命令启动 Gazebo + RViz

推荐直接用这个：

```bash
roslaunch lwh_so101_description gazebo_rviz_control.launch
```

打开后用 `joint_state_publisher_gui` 的滑块动关节，Gazebo 和 RViz 会一起动。

## 真实 SO101 Follower

真实臂控制包是 `lwh_so101_real`。默认只读启动，只连接串口并发布真实关节反馈，不开 torque，不接受运动命令：

```bash
roslaunch lwh_so101_real start_so101_follower.launch port:=/dev/ttyACM0 robot_id:=my_awesome_follower_arm read_only:=true
```

带 RViz 的真实臂反馈显示：

```bash
roslaunch lwh_so101_real start_so101_follower_rviz.launch port:=/dev/ttyACM0 robot_id:=my_awesome_follower_arm read_only:=true
```

带 RViz 和当前姿态初始化的控制窗口：

```bash
roslaunch lwh_so101_real start_so101_follower_rviz_control.launch port:=/dev/ttyACM0 robot_id:=my_awesome_follower_arm
```

带 RViz、Gazebo 和同一套控制窗口：

```bash
roslaunch lwh_so101_real start_so101_follower_rviz_gazebo_control.launch port:=/dev/ttyACM0 robot_id:=my_awesome_follower_arm
```

确认反馈正确后，再按这个文档打开真实控制：

```bash
less /home/a/lwh_code/soarm_ros/src/lwh_so101_real/REAL_ARM_USAGE.md
```

## 常用检查命令

检查包是否被 ROS 找到：

```bash
rospack find lwh_so101_description
```

检查 URDF：

```bash
check_urdf /home/a/lwh_code/soarm_ros/src/lwh_so101_description/urdf/so101.urdf
```

检查 Gazebo 控制器：

```bash
rosservice call /gazebo/controller_manager/list_controllers
```

查看 Gazebo 关节状态：

```bash
rostopic echo /gazebo/joint_states
```

## ROS 网络变量

本机仿真一般不需要设置 `ROS_IP`。如果当前终端继承了旧的远程 ROS 配置，可以先清掉：

```bash
unset ROS_IP
unset ROS_HOSTNAME
export ROS_MASTER_URI=http://localhost:11311
```
