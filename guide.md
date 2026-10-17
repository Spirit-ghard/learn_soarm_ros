# SO101 真实机械臂 ROS1 项目代码解析

这个工作空间的目标是：连接真实 SO101 follower 机械臂，把真实关节状态显示到 RViz，并提供一个滑块控制窗口发送安全的关节目标。

当前仓库不包含 Isaac Sim、物体抓取、视觉识别、运动规划或逆运动学代码。

启动入口只有一个：

~~~bash
roslaunch lwh_so101_real start_so101_follower_rviz_control.launch \
  port:=/dev/ttyACM0 \
  robot_id:=my_awesome_follower_arm
~~~

## 1. 当前文件结构

~~~text
learn_soarm_ros/
  PROJECT_INTRO.md
  仓库代码梳理与实现解析.md
  URDF真实模型可视化.html
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
~~~

lwh_so101_description 负责机器人模型：

- urdf/so101.urdf：link、joint、关节限位、transmission。
- meshes/*.stl：机械臂外观和碰撞网格。
- rviz/so101.rviz：RViz 的 Fixed Frame 和 RobotModel 配置。

lwh_so101_real 负责真实机械臂：

- 连接 LeRobot SO101 follower。
- 读取和写入 Feetech 电机。
- 发布关节状态和连接状态。
- 接收关节控制目标。
- 提供使能、夹爪、回零、停止和阻塞服务。
- 启动 RViz 和 PyQt 控制窗口。

build/ 和 devel/ 是 catkin 生成的构建结果。

## 2. 运行环境和启动命令

源码依赖 ROS1 Noetic、Python 3.10 以上、LeRobot、PyQt5 和 Linux 串口设备。

控制节点的源码头部保留了作者机器上的 Python 路径：

~~~python
ROS_PYTHON_PATHS = [
    "/home/a/lerobot_05/src",
    "/opt/ros/noetic/lib/python3/dist-packages",
    "/usr/lib/python3/dist-packages",
]
~~~

换到其他机器后，需要将这些路径改成实际路径，或者把 LeRobot 安装到当前 Python 环境。

### 2.1 编译工作空间

~~~bash
cd /home/a/lwh_code/soarm_ros
source /opt/ros/noetic/setup.bash
catkin_make
source devel/setup.bash
~~~

当前仓库位于 Windows 路径 D:\pythonProject\learn_soarm_ros，但 ROS1 Noetic 和 /dev/ttyACM0 属于 Linux 环境。实际运行需要在 Ubuntu、虚拟机或配置好的 WSL 环境中执行。

### 2.2 只读启动

~~~bash
roslaunch lwh_so101_real start_so101_follower_rviz_control.launch \
  port:=/dev/ttyACM0 \
  robot_id:=my_awesome_follower_arm \
  read_only:=true
~~~

只读模式下：

- 读取真实机械臂状态。
- 发布 /joint_states_single。
- 驱动 RViz 模型跟随机械臂。
- 拒绝扭矩和关节写入命令。

### 2.3 可控制启动

~~~bash
roslaunch lwh_so101_real start_so101_follower_rviz_control.launch \
  port:=/dev/ttyACM0 \
  robot_id:=my_awesome_follower_arm \
  read_only:=false
~~~

launch 文件的默认值是：

~~~xml
<arg name="read_only" default="false"/>
~~~

省略 read_only 时，节点允许在扭矩使能后写入目标位置。

### 2.4 断开硬件时查看 RViz

allow_disconnected 默认值为 true：

~~~xml
<arg name="allow_disconnected" default="true"/>
~~~

硬件连接失败时，控制节点继续运行并发布 fallback joint state：

~~~bash
roslaunch lwh_so101_real start_so101_follower_rviz_control.launch \
  allow_disconnected:=true \
  read_only:=true
~~~

此时可以查看 URDF、TF 和 RViz，真实机械臂控制命令会被拒绝。

## 3. launch 文件

唯一启动文件：

~~~text
src/lwh_so101_real/launch/start_so101_follower_rviz_control.launch
~~~

启动内容：

~~~xml
<param name="robot_description"
       textfile="$(find lwh_so101_description)/urdf/so101.urdf"/>

<node name="so101_ctrl_single_node"
      pkg="lwh_so101_real"
      type="so101_ctrl_single_node.py"/>

<node name="robot_state_publisher"
      pkg="robot_state_publisher"
      type="robot_state_publisher"/>

<node name="joint_state_mux"
      pkg="topic_tools"
      type="relay"
      args="/joint_states_single /joint_states"/>

<node name="rviz"
      pkg="rviz"
      type="rviz"
      args="-d $(find lwh_so101_description)/rviz/so101.rviz"/>

<node name="so101_relative_control_gui"
      pkg="lwh_so101_real"
      type="so101_relative_control_gui.py"/>
~~~

启动参数：

| 参数 | 默认值 | 作用 |
|---|---|---|
| port | /dev/ttyACM0 | 电机串口 |
| robot_id | my_awesome_follower_arm | LeRobot 机器人 ID |
| calibration_dir | ~/.cache/huggingface/lerobot/calibration/robots/so101_follower | 校准目录 |
| read_only | false | 是否只读 |
| auto_enable | false | 启动时是否自动使能 |
| auto_port | false | 是否扫描其他串口 |
| allow_disconnected | true | 连接失败后是否继续运行 |
| publish_rate | 50.0 | 反馈发布频率 |
| max_relative_target_deg | 10.0 | 身体关节单次最大变化 |
| max_relative_target_gripper | 15.0 | 夹爪单次最大变化 |
| disable_torque_on_shutdown | false | 退出时是否关闭扭矩 |

## 4. URDF 到 RViz

URDF 文件：

~~~text
src/lwh_so101_description/urdf/so101.urdf
~~~

URDF 结构：

~~~text
dummy_link
  └── dummy_to_base
        └── base_link
              └── shoulder_pan
                    └── shoulder_link
                          └── shoulder_lift
                                └── upper_arm_link
                                      └── elbow_flex
                                            └── lower_arm_link
                                                  └── wrist_flex
                                                        └── wrist_link
                                                              └── wrist_roll
                                                                    └── gripper_link
                                                                          └── gripper
                                                                                └── moving_jaw_so101_v1_link
~~~

六个可动关节和电机 ID：

| joint | 电机 ID | 类型 | URDF 限制 |
|---|---:|---|---|
| shoulder_pan | 1 | revolute | -1.91986 到 1.91986 rad |
| shoulder_lift | 2 | revolute | -1.74533 到 1.74533 rad |
| elbow_flex | 3 | revolute | -1.69 到 1.69 rad |
| wrist_flex | 4 | revolute | -1.65806 到 1.65806 rad |
| wrist_roll | 5 | revolute | -2.74385 到 2.84121 rad |
| gripper | 6 | revolute | -0.174533 到 1.74533 rad |

URDF 的 visual 节点引用 STL：

~~~xml
<mesh filename="package://lwh_so101_description/meshes/base_so101_v2.stl"/>
~~~

RViz 和 robot_state_publisher 使用：

~~~text
robot_description  -> robot_state_publisher -> /tf -> RViz RobotModel
/joint_states      -> robot_state_publisher
~~~

只要 /joint_states 中的关节名称和角度正确，robot_state_publisher 就会根据 URDF 发布 /tf，RViz 模型跟随关节状态更新。

RViz 配置文件：

~~~text
src/lwh_so101_description/rviz/so101.rviz
~~~

关键配置：

~~~text
Robot Description: robot_description
Fixed Frame: dummy_link
Display: rviz/RobotModel
~~~

## 5. 真实臂桥接节点

核心文件：

~~~text
src/lwh_so101_real/scripts/so101_ctrl_single_node.py
~~~

它负责：

1. 读取 ROS 参数。
2. 创建 ROS Publisher、Subscriber 和 Service。
3. 加载 LeRobot 配置和校准文件。
4. 连接 Feetech 总线。
5. 周期性读取六个电机位置。
6. 发布 JointState 和 SO101Status。
7. 接收关节目标并写入 Goal_Position。
8. 执行只读、扭矩、阻塞和相对步长检查。

程序入口：

~~~python
def main() -> None:
    rospy.init_node("so101_ctrl_single_node")
    node = SO101CtrlSingleNode()
    rospy.on_shutdown(node.shutdown)
    node.spin()
~~~

### 5.1 固定关节顺序

~~~python
JOINT_NAMES = [
    "shoulder_pan",
    "shoulder_lift",
    "elbow_flex",
    "wrist_flex",
    "wrist_roll",
    "gripper",
]
~~~

### 5.2 连接 LeRobot 总线

~~~python
config_kwargs = {
    "port": self.port,
    "id": self.robot_id,
    "use_degrees": True,
    "disable_torque_on_disconnect": (
        self.disable_torque_on_shutdown
    ),
}

calibration_dir = Path(self.calibration_dir).expanduser()
config_kwargs["calibration_dir"] = calibration_dir

self._follower = SOFollower(
    SOFollowerRobotConfig(**config_kwargs)
)
self._bus = self._follower.bus
self._bus.connect(handshake=True)
~~~

校准文件检查：

~~~python
if self.require_calibration and not self._bus.calibration:
    raise RuntimeError(
        "No SO101 calibration file was loaded."
    )
~~~

预期电机 ID：

~~~python
EXPECTED_MOTOR_IDS = set(range(1, 7))
~~~

自动扫描串口：

~~~python
SERIAL_PORT_PATTERNS = [
    "/dev/ttyACM*",
    "/dev/ttyUSB*",
]
~~~

### 5.3 Publisher、Subscriber 和 Service

Publisher：

~~~python
self.joint_pub = rospy.Publisher(
    "joint_states_single",
    JointState,
    queue_size=10,
)

self.status_pub = rospy.Publisher(
    "arm_status",
    SO101Status,
    queue_size=10,
    latch=True,
)
~~~

Subscriber：

~~~python
rospy.Subscriber(
    "joint_ctrl_single",
    JointState,
    self._joint_command_callback,
    queue_size=1,
)

rospy.Subscriber(
    "enable_flag",
    Bool,
    self._enable_flag_callback,
    queue_size=1,
)
~~~

Service：

~~~python
rospy.Service("enable_srv", Enable, self._enable_service)
rospy.Service("gripper_srv", Gripper, self._gripper_service)
rospy.Service("go_zero_srv", GoZero, self._go_zero_service)
rospy.Service("stop_srv", Trigger, self._stop_service)
rospy.Service("reset_srv", Trigger, self._reset_service)
rospy.Service("block_arm", SetBool, self._block_service)
~~~

## 6. 反馈数据流

主循环：

~~~python
def spin(self) -> None:
    rate = rospy.Rate(self.publish_rate)
    while not rospy.is_shutdown():
        with self._lock:
            self._read_and_publish_once()
            self._publish_status()
        rate.sleep()
~~~

读取电机位置：

~~~python
positions = self._bus.sync_read("Present_Position")
~~~

完整反馈链路：

~~~text
Present_Position
        │
        ▼
_read_positions()
        │
        ▼
_publish_joint_state()
        │
        ├── /joint_states_single
        │       ├── GUI
        │       └── topic_tools relay
        │               │
        │               ▼
        │         /joint_states
        │               │
        │               ▼
        │       robot_state_publisher
        │               │
        │               ▼
        │              /tf
        │               │
        │               ▼
        │              RViz
        │
        └── /arm_status
~~~

### 6.1 单位转换

LeRobot 使用度数：

~~~python
"use_degrees": True
~~~

ROS JointState 使用弧度：

~~~python
def deg_to_rad(value: float) -> float:
    return value * math.pi / 180.0
~~~

发布身体关节：

~~~python
msg.position = [
    deg_to_rad(positions["shoulder_pan"]),
    deg_to_rad(positions["shoulder_lift"]),
    deg_to_rad(positions["elbow_flex"]),
    deg_to_rad(positions["wrist_flex"]),
    deg_to_rad(positions["wrist_roll"]),
    gripper_percent_to_rad(positions["gripper"]),
]
~~~

夹爪范围：

~~~python
GRIPPER_RAD_MIN = -0.174533
GRIPPER_RAD_MAX = 1.74533
~~~

夹爪百分比转弧度：

~~~python
def gripper_percent_to_rad(value: float) -> float:
    pct = clamp(value, 0.0, 100.0)
    return GRIPPER_RAD_MIN + (
        GRIPPER_RAD_MAX - GRIPPER_RAD_MIN
    ) * pct / 100.0
~~~

### 6.2 JointState 发布

~~~python
def _publish_joint_state(
    self,
    positions: Dict[str, float],
) -> None:
    msg = JointState()
    msg.header.stamp = rospy.Time.now()
    msg.name = list(JOINT_NAMES)
    msg.position = [
        deg_to_rad(positions["shoulder_pan"]),
        deg_to_rad(positions["shoulder_lift"]),
        deg_to_rad(positions["elbow_flex"]),
        deg_to_rad(positions["wrist_flex"]),
        deg_to_rad(positions["wrist_roll"]),
        gripper_percent_to_rad(positions["gripper"]),
    ]
    self.joint_pub.publish(msg)
~~~

## 7. 控制命令流

控制窗口发布：

~~~text
/joint_ctrl_single
~~~

消息类型：

~~~text
sensor_msgs/JointState
~~~

控制链路：

~~~text
GUI 滑块
    │
    ▼
_publish_target()
    │
    ▼
/joint_ctrl_single
    │
    ▼
_joint_command_callback()
    │
    ▼
_send_joint_command()
    │
    ▼
_extract_joint_targets()
    │
    ▼
_ros_position_to_lerobot()
    │
    ▼
_limit_relative_target()
    │
    ▼
_bus.sync_write("Goal_Position", safe_target)
    │
    ▼
真实电机
~~~

### 7.1 命令检查

~~~python
if self.read_only:
    return False, "read_only=true, ignoring joint command."

if not self._torque_enabled:
    return False, "torque is disabled, ignoring joint command."

if self._command_blocked:
    return False, "command_blocked=true, ignoring joint command."

if self._bus is None:
    return False, "SO101 bus is not available."
~~~

### 7.2 目标提取和单位转换

消息带关节名时：

~~~python
indexed = {
    name: idx
    for idx, name in enumerate(msg.name)
}

missing = [
    name
    for name in JOINT_NAMES
    if name not in indexed
]

if missing:
    return None
~~~

ROS 到 LeRobot：

~~~python
def _ros_position_to_lerobot(
    self,
    joint_name: str,
    position: float,
) -> float:
    if joint_name == GRIPPER_JOINT:
        return gripper_rad_to_percent(float(position))
    return rad_to_deg(float(position))
~~~

### 7.3 相对安全步长

身体关节：

~~~python
for name in BODY_JOINTS:
    delta = target[name] - current[name]
    limited[name] = current[name] + clamp(
        delta,
        -self.max_relative_target_deg,
        self.max_relative_target_deg,
    )
~~~

夹爪：

~~~python
gripper_delta = (
    target[GRIPPER_JOINT]
    - current[GRIPPER_JOINT]
)

limited[GRIPPER_JOINT] = (
    current[GRIPPER_JOINT]
    + clamp(
        gripper_delta,
        -self.max_relative_target_gripper,
        self.max_relative_target_gripper,
    )
)
~~~

写入目标：

~~~python
safe_target = self._limit_relative_target(target)
self._bus.sync_write(
    "Goal_Position",
    safe_target,
)
~~~

### 7.4 停止和恢复

停止服务：

~~~python
def _stop_service(self, _req: Trigger) -> TriggerResponse:
    with self._lock:
        self._command_blocked = True
        self._last_status = "commands blocked by stop_srv"
        return TriggerResponse(
            success=True,
            message="Commands are blocked.",
        )
~~~

恢复服务：

~~~python
def _reset_service(self, _req: Trigger) -> TriggerResponse:
    with self._lock:
        self._command_blocked = False
        self._last_status = "command block cleared"
        return TriggerResponse(
            success=True,
            message=self._last_status,
        )
~~~

## 8. 控制窗口

控制窗口文件：

~~~text
src/lwh_so101_real/scripts/so101_relative_control_gui.py
~~~

窗口类：

~~~python
class SO101ControlWindow(QMainWindow):
~~~

反馈和命令话题：

~~~python
self.feedback_topic = rospy.get_param(
    "~feedback_topic",
    "/joint_states_single",
)

self.command_topic = rospy.get_param(
    "~command_topic",
    "/joint_ctrl_single",
)
~~~

反馈订阅：

~~~python
rospy.Subscriber(
    self.feedback_topic,
    JointState,
    self._feedback_callback,
    queue_size=1,
)
~~~

目标发布：

~~~python
self.command_pub = rospy.Publisher(
    self.command_topic,
    JointState,
    queue_size=1,
)
~~~

反馈转换：

~~~python
by_name = {
    name: msg.position[idx]
    for idx, name in enumerate(msg.name)
}

for name in BODY_JOINTS:
    values[name] = rad_to_deg(
        float(by_name[name])
    )

values[GRIPPER_JOINT] = gripper_rad_to_percent(
    float(by_name[GRIPPER_JOINT])
)
~~~

使能服务：

~~~python
rospy.wait_for_service(
    "/enable_srv",
    timeout=2.0,
)
service = rospy.ServiceProxy(
    "/enable_srv",
    Enable,
)
resp = service(enable_request=bool(enable))
~~~

真实节点执行：

~~~python
self._bus.enable_torque()
self._bus.disable_torque()
~~~

GUI 发布目标：

~~~python
msg = JointState()
msg.header.stamp = rospy.Time.now()
msg.name = list(JOINT_NAMES)
msg.position = [
    deg_to_rad(targets["shoulder_pan"]),
    deg_to_rad(targets["shoulder_lift"]),
    deg_to_rad(targets["elbow_flex"]),
    deg_to_rad(targets["wrist_flex"]),
    deg_to_rad(targets["wrist_roll"]),
    gripper_percent_to_rad(targets["gripper"]),
]
self.command_pub.publish(msg)
~~~

使能状态下，定时器周期性调用 _publish_target_if_enabled，默认频率为 20 Hz。

## 9. ROS 接口

### 9.1 Topic

| Topic | 类型 | 方向 | 用途 |
|---|---|---|---|
| /joint_states_single | sensor_msgs/JointState | 节点发布 | 真实机械臂反馈 |
| /joint_states | sensor_msgs/JointState | relay 发布 | robot_state_publisher 输入 |
| /joint_ctrl_single | sensor_msgs/JointState | GUI 发布、节点订阅 | 关节目标 |
| /arm_status | lwh_so101_real/SO101Status | 节点发布 | 连接和控制状态 |
| /enable_flag | std_msgs/Bool | 外部发布、节点订阅 | 扭矩开关 |

### 9.2 SO101Status.msg

~~~text
std_msgs/Header header
bool connected
bool torque_enabled
bool read_only
bool command_blocked
string port
string message
~~~

### 9.3 Service

| 服务 | 请求 | 响应 | 处理函数 |
|---|---|---|---|
| /enable_srv | bool enable_request | bool enable_response, string message | _enable_service |
| /gripper_srv | float64 gripper_position | bool status, string message | _gripper_service |
| /go_zero_srv | bool confirm | bool status, string message | _go_zero_service |
| /stop_srv | 空 | success, message | _stop_service |
| /reset_srv | 空 | success, message | _reset_service |
| /block_arm | bool data | success, message | _block_service |

消息和服务定义：

~~~text
src/lwh_so101_real/msg/SO101Status.msg
src/lwh_so101_real/srv/Enable.srv
src/lwh_so101_real/srv/Gripper.srv
src/lwh_so101_real/srv/GoZero.srv
~~~

## 10. 自定义消息生成

CMakeLists.txt 中配置：

~~~cmake
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
~~~

执行：

~~~bash
catkin_make
source devel/setup.bash
~~~

生成的接口位于 devel/，Python 节点通过以下方式导入：

~~~python
from lwh_so101_real.msg import SO101Status
from lwh_so101_real.srv import (
    Enable,
    EnableResponse,
    GoZero,
    GoZeroResponse,
    Gripper,
    GripperResponse,
)
~~~

## 11. 完整运行流程

~~~text
1. 加载 ROS Noetic
        │
        ▼
2. 加载 devel/setup.bash
        │
        ▼
3. roslaunch 唯一 launch 文件
        │
        ├── 加载 robot_description
        ├── 启动 so101_ctrl_single_node
        ├── 启动 robot_state_publisher
        ├── 启动 joint_state_mux
        ├── 启动 RViz
        └── 启动 PyQt 控制窗口
                │
                ▼
4. 控制节点连接 LeRobot 总线
        │
        ├── 连接成功：读取 Present_Position
        └── 连接失败：发布 fallback joint state
                │
                ▼
5. 发布 /joint_states_single
        │
        ├── GUI 更新当前关节值
        └── relay 转发到 /joint_states
                │
                ▼
6. robot_state_publisher 发布 /tf
                │
                ▼
7. RViz 更新 RobotModel
                │
                ▼
8. GUI 调用 /enable_srv
                │
                ▼
9. GUI 发布 /joint_ctrl_single
                │
                ▼
10. 控制节点检查状态、转换单位、限制步长
                │
                ▼
11. sync_write("Goal_Position", safe_target)
                │
                ▼
12. 真实机械臂运动
~~~

## 12. 常用检查命令

~~~bash
rosnode list
rostopic list
rostopic echo -n1 /arm_status
rostopic echo -n1 /joint_states_single
rostopic echo -n1 /joint_states
rostopic echo -n1 /tf
rostopic info /joint_states_single
rostopic info /joint_states
rostopic info /joint_ctrl_single
rosservice list
rosservice info /enable_srv
rosservice info /gripper_srv
rosservice info /go_zero_srv
rosservice info /stop_srv
rosservice info /reset_srv
rosservice info /block_arm
~~~

验证 URDF：

~~~bash
check_urdf src/lwh_so101_description/urdf/so101.urdf
~~~

## 13. 常见问题

### 13.1 Missing motor IDs

检查：

1. 电机电源。
2. Feetech 总线线缆。
3. USB 转接板。
4. port 参数。
5. 电机 ID 是否为 1–6。
6. robot_id 对应的校准文件。
7. calibration_dir 路径。

启用串口扫描：

~~~bash
roslaunch lwh_so101_real start_so101_follower_rviz_control.launch \
  auto_port:=true
~~~

### 13.2 connected: False

~~~bash
rostopic echo -n1 /arm_status
~~~

connected: False 表示 ROS 节点仍在运行，但 Feetech 总线没有连接成功。

### 13.3 RViz 模型不显示

检查：

1. robot_description 是否加载。
2. so101.urdf 是否能通过 check_urdf。
3. URDF 引用的 STL 是否存在。
4. RViz Fixed Frame 是否为 dummy_link。
5. robot_state_publisher 是否运行。
6. /tf 是否发布。

### 13.4 RViz 模型不动

检查：

1. /joint_states_single 是否有消息。
2. /joint_states 是否有消息。
3. JointState.name 是否包含六个正确名称。
4. joint name 是否与 URDF 完全一致。
5. /tf 是否有消息。
6. RViz Robot Description 是否为 robot_description。

### 13.5 滑块能动，机械臂不动

检查 /arm_status：

~~~text
connected: true
read_only: false
torque_enabled: true
command_blocked: false
~~~

检查日志：

~~~text
read_only=true, ignoring joint command.
torque is disabled, ignoring joint command.
command_blocked=true, ignoring joint command.
SO101 bus is not available.
~~~

## 14. 按实现顺序重新搭建

### 第一步：创建 description 包

~~~text
lwh_so101_description/
  package.xml
  CMakeLists.txt
  urdf/so101.urdf
  meshes/*.stl
  rviz/so101.rviz
~~~

### 第二步：编写 URDF

写入 link：

~~~text
dummy_link
base_link
shoulder_link
upper_arm_link
lower_arm_link
wrist_link
gripper_link
moving_jaw_so101_v1_link
~~~

写入六个 revolute joint：

~~~text
shoulder_pan
shoulder_lift
elbow_flex
wrist_flex
wrist_roll
gripper
~~~

为 link 添加 visual、collision、inertial，为关节添加 limit 和 transmission。

### 第三步：验证 URDF

~~~bash
check_urdf urdf/so101.urdf
~~~

### 第四步：生成 ROS 消息和服务

在 msg/ 和 srv/ 放入接口文件，在 CMakeLists.txt 中配置 add_message_files、add_service_files 和 generate_messages。

~~~bash
catkin_make
source devel/setup.bash
~~~

### 第五步：连接 LeRobot

~~~python
SOFollowerRobotConfig(...)
SOFollower(...)
_bus.connect(handshake=True)
~~~

读取：

~~~python
_bus.sync_read("Present_Position")
~~~

写入：

~~~python
_bus.sync_write("Goal_Position", target)
~~~

### 第六步：发布标准 JointState

固定：

- name 顺序；
- 位置单位；
- 时间戳；
- fallback 位置；
- 反馈发布频率。

### 第七步：连接 robot_state_publisher 和 RViz

~~~xml
<param name="robot_description"
       textfile="$(find lwh_so101_description)/urdf/so101.urdf"/>

<node name="robot_state_publisher"
      pkg="robot_state_publisher"
      type="robot_state_publisher"/>
~~~

### 第八步：增加 relay

~~~xml
<node name="joint_state_mux"
      pkg="topic_tools"
      type="relay"
      args="/joint_states_single /joint_states"/>
~~~

### 第九步：增加控制检查

~~~text
read_only
    ↓
connected
    ↓
torque_enabled
    ↓
command_blocked
    ↓
JointState 名称和长度
    ↓
ROS 单位转 LeRobot 单位
    ↓
相对步长限制
    ↓
Goal_Position
~~~

### 第十步：增加 PyQt 控制窗口

窗口完成：

- 订阅 /joint_states_single。
- 显示六个滑块。
- 同步当前姿态。
- 调用 /enable_srv。
- 发布 /joint_ctrl_single。

## 15. 更换新 URDF

需要准备：

- 新 URDF。
- URDF 引用的 STL 或 DAE。
- link 名称。
- joint 名称、类型、父子关系。
- axis 和 limit。
- 电机 ID 与 joint 名称的映射。
- 电机反馈单位和 ROS 单位的转换关系。
- RViz 配置。

步骤：

1. 新建 description 包。
2. 放置 urdf/、meshes/、rviz/。
3. 运行 check_urdf。
4. 加载 robot_description。
5. 启动 robot_state_publisher。
6. 发布 /joint_states。
7. 确认 JointState.name 与 URDF joint 名称一致。
8. 设置 RViz Fixed Frame。
9. 接入真实控制节点。
10. 添加单位转换和电机 ID 映射。

## 16. 文件索引

- 项目说明：PROJECT_INTRO.md
- 启动文件：src/lwh_so101_real/launch/start_so101_follower_rviz_control.launch
- 真实机械臂控制节点：src/lwh_so101_real/scripts/so101_ctrl_single_node.py
- PyQt 控制窗口：src/lwh_so101_real/scripts/so101_relative_control_gui.py
- SO101 状态消息：src/lwh_so101_real/msg/SO101Status.msg
- 使能服务：src/lwh_so101_real/srv/Enable.srv
- 夹爪服务：src/lwh_so101_real/srv/Gripper.srv
- 回零服务：src/lwh_so101_real/srv/GoZero.srv
- SO101 URDF：src/lwh_so101_description/urdf/so101.urdf
- RViz 配置：src/lwh_so101_description/rviz/so101.rviz
- URDF 浏览器可视化：URDF真实模型可视化.html
