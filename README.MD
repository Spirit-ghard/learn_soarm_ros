# Piper ROS 项目说明

本仓库基于 ROS Noetic，包含 Piper 机械臂的模型显示、Gazebo/MuJoCo 仿真、MoveIt 运动规划和 CAN 实机控制。本分支另外整理了带 DAE 外观的描述包 `lwh_piper_descrition`，用于解决原模型在 RViz 中只有纯色、缺少外观细节的问题。

[English](<README(EN).md>) | [完整仿真命令](SIMULATION_START.md) | [MoveIt 说明](src/piper_moveit/README.md) | [原仿真说明](src/piper_sim/README.md) | [常见问题](Q&A.MD)

> 环境：Ubuntu 20.04、ROS Noetic。下面默认工作空间位于 `/home/a/lwh_code/piper_ros`。

## 1. 简短使用方式

### 1.1 编译与加载环境

首次使用：

```bash
cd /home/a/lwh_code/piper_ros
source /opt/ros/noetic/setup.bash
catkin_make
source devel/setup.bash
```

当前机器的 `~/.bashrc` 已加载 ROS Noetic 和这个工作空间，因此新终端通常可以直接运行 `roslaunch`。若包找不到，重新执行上面的两个 `source`。

### 1.2 RViz 查看带皮肤模型

只显示模型，不连接 Gazebo，也不会控制实机：

```bash
roslaunch lwh_piper_descrition display_urdf.launch
```

拖动 `joint_state_publisher_gui` 的滑块即可检查关节、TF 和 DAE 外观。

### 1.3 Gazebo + RViz 滑块联动

一条命令启动带外观模型、Gazebo 控制器、RViz 和关节滑块：

```bash
roslaunch lwh_piper_descrition gazebo_rviz_control.launch
```

也可以分两个终端启动，便于观察日志：

```bash
roslaunch lwh_piper_descrition piper_gazebo.launch
```

```bash
roslaunch lwh_piper_descrition display_control.launch
```

不要同时启动 `gazebo_visual.launch`、`display_urdf.launch` 和联动入口。它们都会使用 `/robot_description`，混用可能造成模型重复、TF 冲突或显示散架。

### 1.4 原版 Gazebo 仿真

有夹爪：

```bash
roslaunch piper_gazebo piper_gazebo.launch
```

无夹爪：

```bash
roslaunch piper_gazebo piper_no_gripper_gazebo.launch
```

原版仿真继续使用原仓库的模型和控制配置，作为稳定基线。所有启动组合见 [SIMULATION_START.md](SIMULATION_START.md)。

### 1.5 MoveIt

只做规划演示，不连接实机：

```bash
roslaunch piper_with_gripper_moveit demo.launch
```

Gazebo 与 MoveIt 联动时，先启动 Gazebo，再在新终端启动 MoveIt：

```bash
roslaunch piper_gazebo piper_gazebo.launch
```

```bash
roslaunch piper_with_gripper_moveit demo.launch
```

### 1.6 实机入口（谨慎使用）

以下命令会连接 CAN，并可能使真实机械臂运动。首次测试应清空工作区、降低速度，并将 `auto_enable` 设为 `false`：

```bash
cd /home/a/lwh_code/piper_ros
bash can_activate.sh can0 1000000
roslaunch piper start_single_piper_rviz.launch can_port:=can0 auto_enable:=false
```

使能服务：

```bash
rosservice call /enable_srv "enable_request: true"
```

详细话题、服务、关节限制和控制示例见 [MoveIt 说明](src/piper_moveit/README.md) 与 [常见问题](Q&A.MD)。

## 2. “皮肤丢失”问题回顾

### 2.1 现象与原因

原模型在 RViz/Gazebo 中能够正确运动，但外观看起来是单一纯色。原因不是 RViz 本身缺少渲染能力，而是模型资源的职责不同：

- STL 主要保存几何三角面，不携带完整材质和纹理表达，原仿真 xacro 主要引用 STL，因此显示稳定但外观简单。
- DAE 可以携带材质、颜色和更丰富的视觉信息，仓库的 `meshes/dae/` 中已有这套资源。
- URDF 的 `<material><color>` 只能给模型统一着色，不能恢复 DAE 内部的分区材质细节。

### 2.2 尝试过但失败的方案

最直接的方案是把原 URDF 中所有 STL 路径替换成 DAE。这样确实出现了外观，但模型发生错位、散架，Gazebo 中还可能抖动。根因包括：

- DAE 和 STL 的导出原点、局部坐标轴或预旋转不一定一致。
- URDF 关节的 `origin` 描述的是父子 link 坐标关系，不能用修改关节坐标的方式补偿任意网格偏移。
- 若视觉网格、碰撞网格和惯性参数被一起替换，Gazebo 的碰撞接触和动力学会随之改变。
- 为掩盖抖动盲目增加 PID，只会压住表象，无法修复碰撞体重叠、惯性不合理或网格坐标错误。
- 同一 ROS master 下重复启动多个模型入口，会覆盖 `/robot_description` 或生成同名 Gazebo entity，看起来也像模型损坏。

### 2.3 最终方案

新增独立包 `src/lwh_piper_descrition/`，不直接覆盖原来的 `piper_description`：

```text
lwh_piper_descrition/
├── launch/                 # RViz、Gazebo 预览和联动入口
├── meshes/dae/             # 带材质的视觉网格
├── meshes/*.STL            # 稳定的碰撞网格
├── rviz/                   # 固定坐标系和 RobotModel 配置
└── urdf/
    ├── piper_description.urdf
    ├── piper_description_gazebo_preview.xacro
    └── piper_description_gazebo_control.xacro
```

核心原则是将视觉、碰撞和动力学分开：

```xml
<visual>
  <geometry>
    <mesh filename="package://lwh_piper_descrition/meshes/dae/link2.dae"/>
  </geometry>
</visual>

<collision>
  <geometry>
    <mesh filename="package://lwh_piper_descrition/meshes/link2.STL"/>
  </geometry>
</collision>
```

- `visual` 使用 DAE，负责 RViz/Gazebo 中看到的外观。
- `collision` 保留 STL，避免视觉资源改变碰撞行为。
- `inertial`、关节拓扑、关节限制和 transmission 以原版可运行模型为基线。
- `base_to_dummy` 额外固定根 link，用于规避 KDL 不支持根 link 惯性所产生的警告。
- 原包仍可独立启动，便于随时对照和回退。

这里保留了两个 Gazebo 用途不同的入口：

- `gazebo_visual.launch`：只检查 DAE 外观，不加载 `ros_control`。
- `gazebo_rviz_control.launch`：加载控制版 xacro、原版 Gazebo 控制器、RViz 和滑块，用于联动。

### 2.4 新模型复用这套方案时需要的材料

至少需要：

- 一份关节拓扑正确的 URDF/xacro，包括 link、joint、axis、origin 和 limit。
- 每个 link 对应的视觉网格，优先 DAE；若使用外部贴图，还需要纹理图片并保证 DAE 内相对路径有效。
- 单独的碰撞网格，最好是简化 STL/OBJ，而不是直接使用高面数视觉模型。
- 每个动态 link 的质量、质心和惯性矩阵。
- Gazebo 控制需要 transmission、`gazebo_ros_control` 插件和控制器 YAML。
- MoveIt 还需要 SRDF、运动学求解器、关节限制和控制器映射。

处理顺序应当是：先在 RViz 验证静态外观，再逐关节验证 TF，然后验证碰撞体，最后才接 Gazebo 动力学和控制器。这样一旦模型错位，可以快速判断问题属于网格坐标、URDF 关节还是动力学参数。

## 3. 后续 Sim2Real 计划

第一项任务建议选择无接触的关节空间 Reach：给定一个机械臂可达目标点，让末端移动到目标附近。它比抓取更适合第一次 Sim2Real，因为暂时不引入物体摩擦、视觉遮挡和接触动力学三类额外误差。

### 阶段 0：冻结基线和安全边界

- 固定一版 URDF、关节顺序、正负方向、零位和单位换算。
- 记录真机每个关节的软件限位、最大单步增量、最大速度和通信超时策略。
- 保留急停、失能、指令限幅和看门狗；策略节点不得直接绕过安全层访问 CAN。
- 用 rosbag 记录 `/joint_states_single`、目标、策略输出、使能状态、末端位姿和故障码。

验收标准：真机静止时模型姿态一致，逐关节小幅运动方向一致，断开策略后机械臂进入预定安全状态。

### 阶段 1：建立 Reach 仿真任务

- 观测：关节角、关节速度、目标点相对末端的位置；首版不使用相机。
- 动作：低频相对关节位置增量，而不是绝对角度或力矩。
- 奖励：末端到目标距离、动作平滑度、关节限位惩罚和到达奖励。
- 控制频率先设为 10 至 20 Hz，底层仍由位置控制器执行。

验收标准：随机目标上的成功率稳定，动作无明显高频振荡，策略不会长期贴着关节限位运行。

### 阶段 2：缩小模型差异

- 标定 URDF 零位、连杆尺寸、末端工具坐标和关节可达范围。
- 从真机阶跃/缓慢扫频数据估计响应延迟、速度上限和静摩擦特征。
- 在仿真中随机化质量、阻尼、摩擦、零位偏差、观测噪声、控制延迟和动作缩放。
- 训练时加入动作低通或速率限制，并与部署端使用同样的处理。

验收标准：在随机化参数范围内都能完成任务，且回放真机日志时，仿真响应趋势与真机接近。

### 阶段 3：建立 ROS 策略适配层

新增独立策略节点，职责保持单一：

```text
目标 + 关节反馈
      │
      ▼
策略推理节点（归一化、推理、反归一化）
      │
      ▼
安全监督器（限位、限速、超时、使能状态）
      │
      ▼
/joint_ctrl_single → piper_ctrl_single_node → Piper SDK → CAN
```

先使用 shadow mode：策略持续计算并记录目标，但不发布控制命令。离线检查动作方向、范围和连续性后，再接仿真控制接口。

### 阶段 4：逐级部署

1. 在 IsaacLab/Gazebo 中接入导出的策略并回归测试。
2. 真机失能状态下运行 shadow mode，对比策略目标与当前关节位置。
3. 机械臂悬空或处于安全姿态，以极小动作缩放、低速度、单目标运行。
4. 扩展工作空间和目标分布，统计成功率、最大误差、超限次数和急停次数。
5. Reach 稳定后，再考虑带接触的 Push，最后才进入 Pick/Lift。

这条路线部署的是“策略给位置目标，ROS 安全层和机械臂底层控制器负责执行”。当前接口适合这种位置策略；它不等同于力矩控制或阻抗控制。若以后研究阻抗，需要确认硬件是否开放实时力矩/电流控制和足够高频、确定性的反馈链路，不能仅靠现有 `/joint_states` 位置接口实现。

## 4. 项目整体分析

### 4.1 当前实现了什么

| 能力 | 主要包 | 实现方式 | 当前定位 |
|---|---|---|---|
| 机器人模型与 TF | `piper_description` | URDF/xacro + `robot_state_publisher` | 原版模型基线 |
| 带材质模型显示 | `lwh_piper_descrition` | DAE visual + STL collision | 本分支新增 |
| Gazebo 仿真 | `piper_gazebo` | `gazebo_ros_control` + 关节位置控制器 | 支持滑块/话题控制 |
| MuJoCo 仿真 | `piper_mujoco` | MuJoCo 模型与 ROS 话题桥接 | 原仓库能力 |
| 运动规划 | `piper_*_moveit` | SRDF、OMPL/CHOMP/Pilz、MoveIt controller 配置 | 支持规划演示和仿真对接 |
| MoveIt 服务封装 | `moveit_ctrl` | `moveit_commander` + 自定义服务 | 关节/末端/夹爪目标接口 |
| 实机通信 | `piper` | `piper_sdk` + SocketCAN | 状态反馈、位置命令、使能和急停等服务 |
| ROS 接口定义 | `piper_msgs` | msg/srv | 状态、末端命令和控制服务 |

### 4.2 数据如何流动

RViz/Gazebo 滑块仿真链路：

```text
joint_state_publisher_gui
        │ /joint_states
        ▼
joint_states_ctrl.py
        │ 各关节 position_controller/command
        ▼
gazebo_ros_control → Gazebo 模型
```

实机反馈到 RViz：

```text
Piper CAN → piper_sdk → piper_ctrl_single_node.py
                           │ /joint_states_single
                           ▼
                 robot_state_publisher → /tf → RViz
```

实机命令链路：

```text
/joint_states 或 /pos_cmd
        │ launch 中 remap 到 joint_ctrl_single
        ▼
piper_ctrl_single_node.py → 单位换算/模式设置 → piper_sdk → CAN
```

MoveIt 负责生成满足关节限制和规划约束的轨迹；真正执行轨迹仍需要控制器映射到 Gazebo 控制器或实机节点。RViz 只是显示和交互界面，不是控制器。

### 4.3 关键代码位置

- `src/piper/scripts/piper_ctrl_single_node.py`：实机主节点，读取 SDK 状态，发布关节/末端/故障信息，接收关节和末端目标，并提供使能、停止、重置等服务。
- `src/piper_sim/piper_gazebo/scripts/joint_states_ctrl.py`：把统一的 `JointState` 目标拆成 Gazebo 各关节位置控制器命令。
- `src/piper_sim/piper_gazebo/config/`：Gazebo 位置控制器和 PID 参数。
- `src/piper_description/urdf/`：原版运动学、动力学、transmission 和 Gazebo 插件定义。
- `src/lwh_piper_descrition/urdf/`：带 DAE 外观的独立描述及 Gazebo 控制版本。
- `src/piper_moveit/piper_with_gripper_moveit/config/`：SRDF、运动学、关节限制、规划器和控制器配置。
- `src/piper_moveit/moveit_ctrl/scripts/joint_moveit_ctrl_server.py`：将 ROS 服务请求转换为 MoveIt 规划与执行调用。

### 4.4 架构上的优点

- 模型、仿真、规划、消息和实机驱动按 ROS package 分开，定位问题相对清晰。
- 仿真和实机都使用 `sensor_msgs/JointState` 作为主要关节接口，便于录包、回放和替换上层控制器。
- 原模型与带皮肤模型并存，外观修改不会阻断原版稳定路径。
- MoveIt 和底层 CAN 驱动之间有 ROS 话题/服务边界，后续可以插入策略节点和安全监督器。

### 4.5 当前限制与后续工程重点

- `joint_states` 在 ROS 语义上通常表示状态，本项目部分链路又将它当作目标命令；后续应明确区分 `/joint_states`、`/joint_command` 和 `/joint_states_single`，避免误接导致真机动作。
- Gazebo 使用位置控制器，仿真质量高度依赖惯性、碰撞体和 PID；视觉正确不代表动力学可信。
- 当前实机接口主要是位置/末端目标控制，不是开放式实时力矩控制，因此不能直接承担标准关节阻抗控制。
- MoveIt、Gazebo 和实机启动目前依赖多个 launch 的 topic remap，后续应增加仿真/实机模式参数和启动时互斥检查。
- Sim2Real 需要统一关节顺序、单位、零位、限位、动作频率和延迟模型；这些接口契约应先固定，再训练策略。
- ROS Noetic 已是 ROS 1 的末期版本。短期保持现有系统稳定更重要；新策略节点可以保持接口独立，为后续迁移 ROS 2 预留边界。

## 5. URDF 版本与安全提示

固件 `S-V1.6-3` 之后，J2/J3 坐标系相对旧版本偏移了 2 度。默认模型使用新版参数：

| 固件版本 | 对应 URDF |
|---|---|
| `< S-V1.6-3` | `piper_description_old.urdf` |
| `>= S-V1.6-3` | `piper_description.urdf` |

连接真机前必须确认固件对应的 URDF、CAN 端口、关节零位和运动方向。任何来自 RViz、MoveIt、rosbag 或学习策略的 topic 都可能在 remap 后成为真机命令；测试时先保持失能，并使用 `rostopic info` 检查发布者和订阅者。
