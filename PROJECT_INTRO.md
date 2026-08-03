# SO101 真实机械臂 RViz 联动项目说明

这个工作空间现在只保留一个目标：连接真实 SO101 follower 机械臂，把真实关节状态显示到 RViz，并提供一个滑块控制窗口发送安全的关节目标。

启动入口只有一个：

```bash
roslaunch lwh_so101_real start_so101_follower_rviz_control.launch port:=/dev/ttyACM0 robot_id:=my_awesome_follower_arm
```

## 1. 当前文件结构

```text
soarm_ros/
  PROJECT_INTRO.md
  src/
    lwh_so101_description/
      package.xml
      CMakeLists.txt
      urdf/so101.urdf
      meshes/*.stl
      rviz/so101.rviz
    lwh_so101_real/
      package.xml
      CMakeLists.txt
      launch/start_so101_follower_rviz_control.launch
      scripts/so101_ctrl_single_node.py
      scripts/so101_relative_control_gui.py
      msg/SO101Status.msg
      srv/Enable.srv
      srv/Gripper.srv
      srv/GoZero.srv
```

`lwh_so101_description` 只负责模型显示材料：URDF、mesh、RViz 配置。

`lwh_so101_real` 只负责真实臂：串口连接、电机读写、ROS topic/service、RViz 启动和控制窗口。

## 2. 从 URDF 到 RViz 显示

第一步是准备机器人描述包 `lwh_so101_description`。

必须材料：

- 一个完整 URDF：`urdf/so101.urdf`
- URDF 引用到的 mesh：`meshes/*.stl`
- 一个 RViz 配置：`rviz/so101.rviz`

URDF 里最重要的是：

- `link`：定义机械臂每个刚体，例如 `base_link`、`shoulder_link`、`upper_arm_link`
- `joint`：定义父子 link 的连接关系、转轴、限位
- `visual`：引用 mesh，让 RViz 显示带皮肤/外形的模型

RViz 本身不会直接读取串口，它只看 ROS 参数和 TF：

```text
robot_description  -> robot_state_publisher -> /tf -> RViz RobotModel
/joint_states      -> robot_state_publisher
```

所以 launch 里需要先加载 URDF：

```xml
<param name="robot_description" textfile="$(find lwh_so101_description)/urdf/so101.urdf"/>
```

然后启动：

```xml
<node name="robot_state_publisher" pkg="robot_state_publisher" type="robot_state_publisher"/>
```

只要 `/joint_states` 里有关节名和角度，`robot_state_publisher` 就会根据 URDF 发布 `/tf`，RViz 模型就会跟着动。

## 3. 真实臂桥接节点

核心文件是：

```text
src/lwh_so101_real/scripts/so101_ctrl_single_node.py
```

它做三件事。

第一，连接 LeRobot 的 SO101 follower 总线：

```python
self._follower = SOFollower(SOFollowerRobotConfig(**config_kwargs))
self._bus = self._follower.bus
self._bus.connect(handshake=True)
```

这里 `handshake=True` 会检查 1-6 号 Feetech 电机是否存在。如果电机电源没开、串口选错、总线线没插好，会看到 `Missing motor IDs`。

第二，读取真实机械臂当前位置并发布 ROS `JointState`：

```python
positions = self._bus.sync_read("Present_Position")
self._publish_joint_state(positions)
```

发布的话题是：

```text
/joint_states_single
```

它使用 ROS 标准消息 `sensor_msgs/JointState`，关节名固定为：

```text
shoulder_pan
shoulder_lift
elbow_flex
wrist_flex
wrist_roll
gripper
```

第三，接收控制窗口发来的目标：

```text
/joint_ctrl_single
```

节点收到目标后会检查：

- `read_only` 是否为 `false`
- torque 是否已经使能
- 是否被 stop/block 服务阻止
- 每次目标变化是否超过安全步长

安全步长来自 launch 参数：

```xml
<param name="max_relative_target_deg" value="$(arg max_relative_target_deg)"/>
<param name="max_relative_target_gripper" value="$(arg max_relative_target_gripper)"/>
```

这样即使滑块突然跳很远，也不会一次性把真实机械臂拉走。

## 4. 为什么需要 relay 到 `/joint_states`

真实臂桥接节点发布的是：

```text
/joint_states_single
```

RViz 和 `robot_state_publisher` 默认看的是：

```text
/joint_states
```

所以 launch 里用了 `topic_tools/relay`：

```xml
<node name="joint_state_mux" pkg="topic_tools" type="relay"
      args="/joint_states_single /joint_states"/>
```

这一步是 RViz 联动的关键。真实臂一动，节点读到新角度，发布 `/joint_states_single`，relay 转成 `/joint_states`，`robot_state_publisher` 更新 `/tf`，RViz 模型跟着动。

## 5. 控制窗口

控制窗口文件是：

```text
src/lwh_so101_real/scripts/so101_relative_control_gui.py
```

它做两件事：

第一，订阅真实反馈：

```text
/joint_states_single
```

收到反馈后，把滑块初始化到真实机械臂当前位置。

第二，发布控制目标：

```text
/joint_ctrl_single
```

界面上的 `使能` 按钮调用服务：

```text
/enable_srv
```

这会让真实节点执行：

```python
self._bus.enable_torque()
```

界面上的 `拖拽` 按钮会调用同一个服务关闭 torque：

```python
self._bus.disable_torque()
```

所以正常流程是：

1. 启动 launch
2. 看 RViz 是否跟真实机械臂同步
3. 点 `使能`
4. 小幅拖动滑块
5. 结束时点 `拖拽`

## 6. 唯一启动文件

现在只保留一个 launch：

```text
src/lwh_so101_real/launch/start_so101_follower_rviz_control.launch
```

它不再 include 其它 launch，所有节点都在这个文件里：

```xml
<param name="robot_description" textfile="$(find lwh_so101_description)/urdf/so101.urdf"/>

<node name="so101_ctrl_single_node" pkg="lwh_so101_real" type="so101_ctrl_single_node.py"/>
<node name="robot_state_publisher" pkg="robot_state_publisher" type="robot_state_publisher"/>
<node name="joint_state_mux" pkg="topic_tools" type="relay" args="/joint_states_single /joint_states"/>
<node name="rviz" pkg="rviz" type="rviz" args="-d $(find lwh_so101_description)/rviz/so101.rviz"/>
<node name="so101_relative_control_gui" pkg="lwh_so101_real" type="so101_relative_control_gui.py"/>
```

这样排查问题时不用在多个 launch 之间跳。

## 7. 使用命令

先编译：

```bash
cd /home/a/lwh_code/soarm_ros
source /opt/ros/noetic/setup.bash
catkin_make
source devel/setup.bash
```

启动：

```bash
roslaunch lwh_so101_real start_so101_follower_rviz_control.launch port:=/dev/ttyACM0 robot_id:=my_awesome_follower_arm
```

如果只想看 RViz，不想因为真实臂没连上导致节点退出，默认已经开启：

```text
allow_disconnected:=true
```

这时真实臂连接失败也会发布一组零位 fallback joint state，让 RViz 模型保持正常显示。但控制命令会被拒绝，直到真实总线连接成功。

## 8. 常用检查

查看真实臂状态：

```bash
rostopic echo -n1 /arm_status
```

查看真实臂反馈：

```bash
rostopic echo -n1 /joint_states_single
```

查看 RViz 使用的关节状态：

```bash
rostopic echo -n1 /joint_states
```

查看 TF 是否发布：

```bash
rostopic echo -n1 /tf
```

如果 `/arm_status` 里是：

```text
connected: False
```

说明 ROS/RViz 已经正常，但真实电机总线没有连上。优先检查电机电源、Feetech 总线线、USB 口和 `/dev/ttyACM0` 是否正确。

## 9. 以后换新 URDF 怎么做

拿到新机械臂模型时，需要这些材料：

- URDF 文件
- URDF 引用到的 STL/DAE mesh
- 每个关节的名字、类型、父子 link、axis、limit
- 真实电机反馈里的关节顺序和单位
- 电机 ID 到关节名的映射

制作步骤：

1. 新建 description 包，放 `urdf/`、`meshes/`、`rviz/`
2. 用 `check_urdf your_robot.urdf` 检查 URDF
3. 写一个最小 launch，把 URDF 加载到 `robot_description`
4. 启动 `robot_state_publisher`
5. 让真实节点发布标准 `/joint_states`
6. 确认 joint name 和 URDF 里的 joint name 完全一致
7. RViz 加 RobotModel，Fixed Frame 选根 link 或 world
8. 再加控制节点，把 UI 目标转换成真实电机命令

最容易出错的是第 6 步。只要 `/joint_states.name` 和 URDF joint 名不一致，RViz 就不会动，或者 RobotModel 报 error。
