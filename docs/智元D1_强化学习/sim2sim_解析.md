# 智元 D1 强化学习 Sim2Sim 与 rl_sar 框架解析

> 对应原文：`sim2sim.pdf`，共 41 页。原文以开源 `rl_sar` 为主线，介绍框架架构、安装配置、控制数据流、FSM，以及接入智元 D1 的方法。本文按“为什么需要、怎样工作、怎样扩展、怎样验证”重新组织，不是逐字转写。

## 1. 一页结论

Sim2Sim 的作用，是把在 Isaac Gym/Isaac Sim 等训练环境中得到的策略，放到另一套物理引擎和运行时中验证。它重点暴露两类问题：

- 策略是否依赖训练仿真器特有的状态或动力学细节；
- 部署代码是否正确复现了训练时的观测、动作、时序和状态机语义。

`rl_sar` 为此提供统一部署层：

```text
Gazebo / MuJoCo / 真实机器人
             |
      GetState / SetCommand
             |
        RobotState / RobotCommand
             |
   观测构造 -> 模型推理 -> 动作输出
             |
       配置、历史帧、FSM
```

框架的核心价值不是“支持很多机器人”，而是把策略相关逻辑和硬件/仿真器相关逻辑分开。接入新机器人时，关键工作集中在三类接口：

```cpp
Forward();      // 模型前向推理（原文接口设计中的一个扩展点）
GetState();     // 把 SDK/仿真状态转换为统一状态
SetCommand();   // 把统一命令转换为 SDK/仿真命令
```

真正决定部署成败的契约是：观测顺序、维度、缩放、历史帧、关节映射、默认姿态、动作尺度、控制周期和坐标系必须与训练一致。

## 2. Sim2Sim 的定位

典型流程为：

```text
Isaac Gym / Isaac Sim 训练
           |
       导出 policy
           |
   MuJoCo 快速独立验证
           |
 Gazebo + ROS 集成验证
           |
      真实机器人
```

不同阶段验证的重点不同：

| 阶段 | 主要验证内容 | 不能证明的内容 |
|---|---|---|
| 训练仿真 | 策略能否学会任务 | 跨引擎和真机可迁移性 |
| MuJoCo | 独立模型、观测/动作与基础动力学 | ROS 集成和真实硬件误差 |
| Gazebo | ROS 接口、控制器、传感器和系统集成 | 真实电机、网络和结构误差 |
| 真机 | 完整物理与系统闭环 | 未覆盖工况下的绝对安全 |

因此 Sim2Sim 是真机前的重要筛选器，但不是 Sim2Real 的替代品。两个仿真器也可能共享相同的 URDF、错误参数或简化假设。

## 3. 框架分层

原文把 `rl_sar` 分为四层：

1. **仿真/实机层**：与 Gazebo、MuJoCo 或机器人 SDK 交互。
2. **核心库层 `rl_sdk`**：状态抽象、观测计算、模型推理、输出计算。
3. **策略配置层**：机器人基础参数和特定策略参数。
4. **输入接口层**：键盘、手柄和 ROS topic。

这种分层形成两个稳定边界：

```text
设备边界：设备专属数据 <-> RobotState / RobotCommand
策略边界：配置定义的观测 <-> policy 输入/输出
```

只要两个边界都满足契约，同一套推理和控制逻辑就能跨仿真器、跨硬件复用。

## 4. 核心数据结构

### 4.1 RobotState

统一状态通常包含：

- IMU 四元数、角速度、加速度；
- 关节位置 `q`；
- 关节速度 `dq`；
- 关节加速度或力矩估计等可选量。

硬件或仿真适配器负责把自己的字段、顺序、单位和坐标系转换到此结构。公共策略代码不应该直接依赖某个 SDK 的字段名。

### 4.2 RobotCommand

统一命令按关节保存：

- 控制模式 `mode`；
- 目标位置 `q`；
- 目标速度 `dq`；
- 前馈力矩 `tau`；
- 比例增益 `kp`；
- 微分增益 `kd`。

这种结构既能表达位置 PD，也能给轮式关节保留速度控制语义。

### 4.3 Observations

原文列出的策略观测包括：

- 线速度；
- 角速度；
- 投影重力；
- 用户运动命令；
- 基座四元数；
- 关节位置；
- 关节速度；
- 上一时刻动作。

并非每个策略都使用全部观测。最终输入由配置中的 `observations` 决定，列表顺序就是神经网络输入的拼接顺序。

## 5. 核心模块解析

### 5.1 RL 基类

基类统一实现：

- 读取 YAML；
- 初始化策略；
- 构造与裁剪观测；
- 调用推理后端；
- 把动作转换为关节目标和力矩；
- 管理历史观测与状态。

子类只处理仿真器或真实机器人的差异。它采用模板方法思想：主流程固定，设备相关步骤由派生类提供。

### 5.2 Inference Runtime

原文描述了统一 `Model` 接口和两个实现：

| 后端 | 文件 | 特点 |
|---|---|---|
| TorchScript | `.pt` | 与 PyTorch 生态衔接方便，适合开发迭代 |
| ONNX Runtime | `.onnx` | 通常依赖更轻，适合资源受限部署 |

模型工厂按扩展名自动选择后端。选择后端时不应只看平均推理速度，还应比较：

- 模型算子是否完全支持；
- 输出数值与训练端是否一致；
- 首次加载时间和内存占用；
- P99/最大推理时延；
- ARM64 与 Jetson 环境的构建复杂度。

建议为同一批固定输入保存 TorchScript 和 ONNX 输出，做逐元素误差对比。

### 5.3 Observation Buffer

历史观测用于处理部分可观测性和时序信息。原文提供两种排列方式：

- `time` priority：按时间帧组织；
- `term` priority：按观测项组织。

假设单帧观测为：

```text
o_t = [ang_vel, gravity, command, dof_pos, dof_vel, last_action]
```

历史帧在两种 priority 下的展平顺序可能完全不同。即使总维度相同，排列错误也会让模型接收无意义输入。因此必须与训练导出逻辑一致。

还应明确 reset 时怎样填充历史：全零、重复首帧或保留旧值会产生不同启动行为。

### 5.4 Loop Control

原文采用多个周期循环：

- 输入循环：低频接收键盘/手柄；
- 推理循环：中频产生动作；
- 控制循环：高频发送最新命令。

这是生产者-消费者结构：

```text
输入线程 ----> command
                  |
状态 ----------> 推理线程 ----> 最新关节目标队列
                                   |
设备状态 ----> 高频控制线程 <------+----> 设备命令
```

原文示例常见频率为输入约 20 Hz、推理约 50 Hz、控制约 200 Hz；D1 的 Sim2Real 上篇还给出了 500 Hz 控制环。具体频率取决于机器人底层要求，不应混为框架固定值。

## 6. 安装与编译

### 6.1 原文支持矩阵

| 系统 | ROS | 原文标注 |
|---|---|---|
| Ubuntu 20.04 | ROS Noetic / ROS 2 Foxy | 完全支持 |
| Ubuntu 22.04 | ROS 2 Humble | 完全支持 |
| macOS | 无 ROS，仅 MuJoCo | 实验性支持 |

这是 PDF 编写时的状态，不代表当前仓库或依赖的最新兼容矩阵。

### 6.2 获取源码

```bash
git clone --recursive --depth 1 https://github.com/fan-ziqi/rl_sar.git

# 更新已有仓库及子模块
git pull
git submodule update --init --recursive --recommend-shallow --progress
```

浅克隆适合快速使用；需要切换历史提交或排查版本问题时，可能需要补全历史。

### 6.3 基础依赖

原文 Ubuntu 示例：

```bash
sudo apt install cmake g++ build-essential libyaml-cpp-dev libeigen3-dev \
  libboost-all-dev libspdlog-dev libfmt-dev libtbb-dev liblcm-dev
```

ROS/Gazebo 依赖应按 ROS 1 或 ROS 2 版本分别安装。不要把两套包名机械混用。

### 6.4 编译模式

```bash
# 默认：构建所有 ROS 包
./build.sh

# 仅构建指定包
./build.sh package1 package2

# 纯 CMake，不依赖 ROS，常用于实机
./build.sh -m
# 等价长参数
./build.sh --cmake

# 启用 MuJoCo
./build.sh -mj
./build.sh --mujoco

# 清理构建产物
./build.sh -c
./build.sh --clean
```

可执行文件位置：

| 模式 | 目录 |
|---|---|
| ROS 1 | `devel/lib/rl_sar/` |
| ROS 2 | `install/rl_sar/lib/rl_sar/` |
| CMake | `cmake_build/bin/` |

参数是 PDF 所对应仓库版本的接口，执行前应查看当前 `./build.sh --help`。

## 7. 两级配置系统

原文使用以下布局：

```text
policy/
└── <ROBOT>/
    ├── base.yaml
    └── <CONFIG>/
        ├── config.yaml
        └── <MODEL>.pt   # 也可为 ONNX
```

### 7.1 `base.yaml`：机器人基础契约

典型字段：

- `dt`：底层仿真/控制时间步；
- `decimation`：策略相对底层步长的降采样倍数；
- `num_of_dofs`：自由度数量；
- `fixed_kp` / `fixed_kd`：起身等固定状态使用的增益；
- `torque_limits`：逐关节力矩上限；
- `default_dof_pos`：默认站姿及相对观测零点；
- `joint_names`：必须与 URDF 一致；
- `joint_mapping`：设备顺序与框架顺序的映射；
- `wheel_indices`：轮足机器人中使用速度语义的关节。

### 7.2 `config.yaml`：策略契约

典型字段：

- `model_name`；
- `num_observations`；
- `observations` 及其顺序；
- `observations_history` 和 priority；
- `clip_obs`；
- `clip_actions_lower` / `upper`；
- `rl_kp` / `rl_kd`；
- `action_scale`；
- 线速度、角速度、关节位置、关节速度和命令缩放。

可以把两类文件理解为：

```text
base.yaml   = 这台机器人怎样运动、怎样安全执行
config.yaml = 这个 policy 怎样理解输入、怎样解释输出
```

策略文件和 `config.yaml` 必须成对版本化。只替换模型、不替换对应配置，是非常常见的隐蔽错误。

## 8. 控制数据流

完整一轮可拆为五步：

```text
1. GetState()
   设备/仿真原始状态 -> RobotState

2. ComputeObservation()
   坐标变换 -> 相对量 -> 缩放 -> 拼接 -> 历史帧 -> 裁剪

3. Forward()
   模型输入 -> TorchScript/ONNX -> 归一化动作

4. ComputeOutput()
   动作裁剪 -> 动作缩放 -> 目标位置/速度 -> PD -> 力矩限幅

5. SetCommand()
   统一命令 -> 设备关节映射 -> SDK/仿真器
```

### 8.1 观测计算

常见变换包括：

```text
body_ang_vel = R(q)^T * world_ang_vel   # 仅输入为世界系时
gravity_body = R(q)^T * gravity_world
q_relative   = q - q_default
```

然后逐项缩放、按 `observations` 顺序拼接并裁剪：

```text
o = concat(scale_i * term_i)
o_clipped = clamp(o, -clip_obs, clip_obs)
```

最重要的不是公式复杂度，而是训练和部署执行完全相同的定义。

### 8.2 推理与模型重载

原文示例在模型可能重新初始化时尝试获取互斥锁；拿不到锁就沿用上一帧动作。这避免模型重载阻塞实时控制。

该策略还需加入上限：若连续多帧无法更新动作，不能无限沿用旧动作，应触发命令归零或进入安全状态。

### 8.3 输出与 PD 控制

四足位置动作的基本形式：

```text
a_s   = a .* action_scale
q_des = q_default + a_s
tau   = kp .* (q_des - q) - kd .* dq
tau   = clamp(tau, -tau_limit, tau_limit)
```

轮式关节可把动作解释为目标速度，并从位置动作中剥离。`wheel_indices` 的存在说明统一框架不能假设所有自由度都使用同一种控制语义。

## 9. FSM 安全状态机

原文的 D1 状态大致为：

```text
                    +--------------------+
                    |                    v
Passive -> GetUp -> RLLocomotion -> GetDown
   ^          |           |             |
   +----------+-----------+-------------+
                 安全退回
```

每个状态实现：

```cpp
Enter();       // 一次性初始化
Run();         // 每个控制周期执行
Exit();        // 退出清理
CheckChange(); // 判断状态转换
```

### 9.1 Passive

位置增益为零，只保留阻尼，机器人可被外力移动。它应是启动、异常和用户急停时的安全落点。

### 9.2 GetUp

原文采用两阶段插值：

```text
当前姿态 --约 1 s--> 预备蹲伏姿态 --约 2 s--> 默认站姿
```

分段插值避免从任意落地姿态直接拉向站姿造成大关节跳变。插值使用固定增益，不依赖尚未启用的策略输出。

### 9.3 RLLocomotion

进入时加载指定策略配置与模型，运行时持续执行 RL 控制；初始化失败则退回 Passive。退出时清除 RL 初始化状态。

进入策略状态之前还应验证：模型已加载、观测维度匹配、最新状态未超时、机器人姿态处于允许范围。

### 9.4 GetDown

负责从站立或 RL 状态平滑回到低姿态/被动状态，避免直接卸力摔落。虽然 PDF 展示较少，但它是安全闭环不可缺的一段。

### 9.5 FSM 工厂

框架通过工厂和注册宏按机器人类型创建状态机。新增 D1 时需：

- 实现 `D1FSMFactory`；
- 返回支持的状态；
- 指定初始状态；
- 使用注册宏；
- 在 `fsm_all.hpp` 中包含 D1 状态机头文件。

这使主程序不必硬编码每一种机器人。

## 10. D1 关节映射

原文给出的两种顺序：

```text
rl_sar 按腿分组：FR(0..2), FL(3..5), RR(6..8), RL(9..11)
D1 SDK 腿索引： FL=0, FR=1, RL=2, RR=3
```

因此映射表为：

```cpp
static const int SDK_LEG_MAP[4] = {1, 0, 3, 2};
// rl_sar: FR -> SDK 1
//         FL -> SDK 0
//         RR -> SDK 3
//         RL -> SDK 2
```

同一映射必须双向使用：

- `GetState()`：SDK 状态重排到 rl_sar 顺序；
- `SetCommand()`：rl_sar 命令重排回 SDK 顺序。

如果只映射上行或只映射下行，闭环仍然错误。最可靠的验证不是看整机步态，而是逐腿逐关节做小幅静态测试并记录对应字段。

### 10.1 坐标系冲突提醒

`sim2sim.pdf` 的 D1 构造函数示例写了：

```cpp
this->ang_vel_axis = "world";
```

但 `sim2real_上.pdf` 明确提醒，Isaac Lab 的 `root_ang_vel_b` 是机体系量，且 D1 使用了名为 `getBodyGyro()` 的接口，部署示例应确认是否设为 `body`。

两份材料对此不一致。不能仅凭函数名或示例注释下结论，必须依据当前 D1 SDK 定义并通过三轴旋转实验验证。错误地对 body-frame 角速度再做一次逆旋转，会产生系统性错误而不会报程序异常。

## 11. 新增机器人的文件结构

原文建议新增或修改以下内容：

```text
<robot_description_package>/
├── CMakeLists.txt
├── package.ros1.xml
├── package.ros2.xml
├── urdf/robot_description.urdf
├── xacro/robot.xacro
├── xacro/gazebo.xacro
├── mjcf/<robot>.xml
├── mjcf/scene.xml
├── mjcf/assets/
├── config/robot_control.yaml
├── config/robot_control_ros2.yaml
└── launch/gazebo.launch

policy/<robot>/
├── base.yaml
└── <config>/
    ├── config.yaml
    └── <model>.pt

src/rl_sar/fsm_robot/
├── fsm_<robot>.hpp
└── fsm_all.hpp

src/rl_sar/include/rl_real_<robot>.hpp
src/rl_sar/src/rl_real_<robot>.cpp
```

扩展步骤建议按依赖顺序进行：

1. 建立 URDF/MJCF，统一关节名、顺序、方向和零位；
2. 在 MuJoCo/Gazebo 中验证无策略的关节控制；
3. 填写 `base.yaml`，验证默认姿态、限位和增益；
4. 填写策略 `config.yaml`，核对训练导出契约；
5. 实现 `GetState()` 和 `SetCommand()`；
6. 实现并注册 FSM；
7. 先 Sim2Sim，再吊架真机，再地面真机。

## 12. MuJoCo 与 Gazebo 验证

原文示例的 MuJoCo 启动形式为：

```bash
./cmake_build/bin/rl_sim_mujoco d1 scene
```

进入仿真后按原文流程：

```text
0 -> 进入/加载被动与起身流程
R -> 重置机器人
1 -> 进入 RL 控制
```

Gazebo/ROS 2 示例：

```bash
# 终端 1：启动 Gazebo 与机器人模型
ros2 launch rl_sar gazebo.launch.py rname:=d1

# 终端 2：启动 RL 控制节点
ros2 run rl_sar rl_sim
```

命令名称可能随仓库版本变化，应以实际构建出的可执行文件和 launch 参数为准。

### 12.1 不要只看“能走”

Sim2Sim 应至少比较：

- 零命令站立漂移；
- 速度阶跃和斜坡跟踪；
- yaw 响应；
- 关节目标/实际误差；
- 足端接触时序和打滑；
- 机身高度与姿态；
- 动作、力矩和关节限位饱和率；
- 相同初态下的多次重复性；
- 不同地面摩擦、质量和延迟扰动下的稳定性。

最好把两个仿真器的日志转换为相同字段，按时间对齐后比较，而不是只凭视频观感。

## 13. 常见故障表

| 现象 | 可能原因 | 优先检查 |
|---|---|---|
| 腿部运动混乱 | 关节/腿序映射错误 | `SDK_LEG_MAP` 及双向映射 |
| 原地打转 | 角速度坐标系或 yaw 符号错误 | `ang_vel_axis` 和三轴实验 |
| 倒向一侧 | 四元数顺序/方向错误 | `wxyz`/`xyzw`、姿态旋转定义 |
| 策略输出异常 | 观测顺序、历史帧或维度错误 | `config.yaml` 与导出配置 |
| 关节高频抖动 | PD 增益、控制周期或延迟 | `rl_kp`、`rl_kd`、loop jitter |
| 力矩持续饱和 | 增益/动作过大或上限不合理 | 目标误差、action scale、额定力矩 |
| 起身跳变 | 默认姿态/插值/关节零位错误 | `default_dof_pos` 和 GetUp |
| MuJoCo 正常、Gazebo 异常 | 模型、控制器或接触参数差异 | URDF/MJCF、惯量、摩擦、控制接口 |
| 两个仿真都正常、真机异常 | reality gap 或真机链路问题 | SDK 语义、时延、噪声、执行器模型 |

## 14. 安全与调试策略

原文建议：

1. 首次真机必须吊起或使用可靠保护；
2. 开启 CSV 日志记录关节位置、速度、力矩；
3. 使用实时绘图对比目标位置与实际位置；
4. 按 Passive、GetUp、RLLocomotion 顺序渐进验证。

进一步建议补齐：

- 状态和命令看门狗；
- 姿态、关节、速度、力矩和温度保护；
- 模型/配置维度启动校验；
- 异常退出发送阻尼命令；
- 推理超时和旧动作最大沿用帧数；
- 控制线程 deadline miss 统计；
- 日志统一使用单调时钟时间戳。

## 15. 对原文的校勘与局限

1. **标题是 Sim2Sim，后半篇实际扩展到实机接入**：内容更接近 `rl_sar` 全框架与 D1 适配教程。
2. **部分代码截图是说明性片段**：不能保证可直接编译，类名、参数和文件路径应以仓库实际版本为准。
3. **角速度 frame 存在材料间冲突**：必须实测，不能照抄 `world` 或 `body`。
4. **频率示例不完全一致**：框架介绍用约 200 Hz 控制，D1 上篇用 500 Hz；应由底层协议和测得的实时性决定。
5. **Sim2Sim 通过不等于真机安全**：它主要验证软件契约和部分跨引擎鲁棒性。
6. **参数值只是示例**：PD、力矩限制、默认姿态和动作尺度都与机器人版本和策略有关。
7. **缺少自动化回归指标**：实际项目应把固定场景和阈值做成可重复测试，而不只依赖人工观察。

## 16. 推荐验收清单

### 模型与配置

- [ ] 模型输入/输出维度与配置一致。
- [ ] 观测项顺序、缩放、裁剪与训练一致。
- [ ] 历史帧索引、排列 priority 和 reset 填充一致。
- [ ] `default_dof_pos`、动作尺度和命令尺度一致。

### 机器人抽象

- [ ] URDF、MJCF、SDK 的关节名、顺序、方向和单位一致。
- [ ] 上行状态和下行命令使用同一映射。
- [ ] 四元数顺序、角速度 frame、重力方向已通过实验确认。
- [ ] 位置、速度、力矩和机械限位合理。

### 运行时

- [ ] 推理和控制线程解耦，队列/共享数据线程安全。
- [ ] 测量而非假设控制频率、抖动和推理长尾。
- [ ] 旧动作、状态超时、网络断开均有安全处理。
- [ ] FSM 任意运行状态都能可靠退回 Passive。

### 验证

- [ ] MuJoCo 固定场景通过。
- [ ] Gazebo/ROS 接口与固定场景通过。
- [ ] 两个仿真器有同字段日志和量化对比。
- [ ] 域扰动测试覆盖质量、摩擦、延迟和噪声。
- [ ] 吊架真机按状态读取、被动、起身、RL 逐级验收。

## 17. 最终理解

`rl_sar` 解决的是部署代码的可复用性，而 Sim2Sim 解决的是在接触真实硬件前尽早暴露契约错误和仿真器依赖。二者共同建立了一条逐步增加真实性的验证链：

```text
训练正确
  -> 模型导出正确
  -> 部署观测/动作契约正确
  -> 第二仿真器中行为正确
  -> ROS/系统集成正确
  -> 真机控制链正确
  -> 真实任务表现可接受
```

每一层只回答自己的问题。严格守住这些边界，才能在出现异常时知道应该修改模型、配置、仿真描述、框架适配，还是硬件控制链。
