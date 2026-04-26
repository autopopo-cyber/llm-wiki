# Marathongo 技术分析报告

> 朗毅机器人开源人形机器人马拉松全栈导航系统深度分析与四足机器狗适配评估

---

## 1 项目概述

**Marathongo** 是朗毅机器人（landitbot）开源的面向人形机器人马拉松比赛场景的导航全栈方案，聚焦于大尺度室外环境中高速、稳定、自主运行能力。该系统已在 2026 年人形机器人马拉松竞赛中实现 21 公里全程自主导航。

**核心特征：**
- 大规模室外场景下的鲁棒定位与导航
- 多技术路线并存（极简路线 + 复杂路线）
- 多模态协同（视觉 + 激光 + GNSS + IMU）
- 面向真实机器人适配，接近开箱即用
- 基于 ROS Noetic 的全栈实现

---

## 2 项目架构与模块划分

```
marathongo/
├── glio_mapping/              # [核心] GNSS+LiDAR+IMU 多源融合建图定位
├── marathontracking/          # [复杂路线] 完整巡线避障导航框架
│   ├── src/local_planner/     #   局部规划器（避障+路径选择+控制一体化）
│   ├── src/path_process/      #   路径处理（全局路径跟踪点提取）
│   ├── src/robot_interface/   #   机器人接口（ZMQ通信）
│   ├── src/mpc_controller/    #   MPC控制器（已禁用，.disable后缀）
│   ├── src/ros1_sender_general/#  控制指令UDP发送器
│   ├── src/sim_interface/     #   仿真接口
│   └── src/python_ws/         #   Python工具集
│       ├── RLFuzzyTracking/   #     RL增强模糊跟踪控制器
│       ├── general_ppo/       #     PPO强化学习框架
│       ├── Joy/               #     遥控器驱动（SBUS/ROS Joy）
│       ├── rl_control_node.py #     RL控制节点
│       └── fuzzy_control_node.py #  模糊控制节点
├── tangent_arc_navigation/    # [极简路线] 切弧导航算法
│   └── src/
│       ├── vo_navigation/     #   速度障碍+切弧避障核心
│       ├── costmap_converter/ #   代价地图转换器
│       ├── speed_controller/  #   PID速度控制器
│       ├── path_tools/        #   路径工具集
│       └── sim_interface/     #   仿真接口
├── vision_part/               # [感知] 视觉障碍物识别
│   ├── seg_fusion/            #   YOLO分割模型训练+权重融合
│   ├── seg_lightning/         #   PyTorch Lightning训练框架
│   └── seg_tensorrt/          #   TensorRT部署（Python/C++/DeepStream）
└── gif/                       # 运行展示动图
```

### 2.1 系统数据流

```
传感器层                    定位层                   规划层                控制层             执行层
┌─────────┐            ┌──────────┐          ┌──────────────┐        ┌──────────┐      ┌──────────┐
│ LiDAR   ├──────────► │          │          │              │        │          │      │          │
│ IMU     ├──────────► │ glio_    ├────────► │ local_      ├──────► │ 模糊/PID │─────►│ UDP发送  │──► 机器人
│ GNSS    ├──────────► │ mapping  │ /odometry│ planner     │/fuzzy  │ 控制器   │/cmd  │ server   │    底层
│ Camera  ├─────┐     │          │          │ 或 vo_node  │_cmd_vel│          │_vel  │          │
└─────────┘     │     └──────────┘          └──────────────┘        └──────────┘      └──────────┘
                │                                     ▲
                ▼                                     │
         ┌──────────────┐                    ┌────────┴──────┐
         │ vision_part  ├──────────────────► │ 障碍物信息     │
         │ (TensorRT)   │   /obstacles      │ /left,right   │
         └──────────────┘   /smoothed_path   │ /smoothed_path│
                                             └───────────────┘
```

---

## 3 核心技术要点分析

### 3.1 GNSS + IMU + LiDAR 多源融合定位方案（glio_mapping）

#### 3.1.1 技术路线

`glio_mapping` 基于 **FAST-LIO** 系列进行扩展，核心是 **IKFoM（Iterated Kalman Filter on Manifold）** 实现的紧耦合融合方案。系统采用前端里程计 + 后端图优化的分层架构。

**前端：**
- 基于 IKFoM 的迭代扩展卡尔曼滤波，状态维度 23
- LiDAR 点云通过 ikd-Tree 增量式管理，支持 scan-to-map 配准
- IMU 以 200Hz 前向传播，LiDAR 到达时进行后向传播和运动补偿
- 支持多种 LiDAR 类型：Livox 系列、Velodyne、Ouster、Robosense、速腾聚创

**GNSS 融合：**
- `GPSProcessor` 类处理 GNSS 数据，支持 RTK/PPP 模式
- 坐标转换链：WGS84 → GCJ02 → CGCS2000 3度带投影（使用 GDAL 库）
- GNSS 初始化：首个有效 Fix 信号自动设定原点
- 前端融合：`GlioEstimator::h_share_model_gnss()` 将 GNSS 位置作为 ESKF 观测量
- 后端融合：`PoseGraphManager` 通过 GTSAM 进行位姿图优化，GNSS 作为全局约束

**后端：**
- 基于欧氏距离的回环检测（`EuclideanLoop`）
- GTSAM 位姿图优化，GNSS 节点作为全局约束
- 双重一致性保障：前端里程计 + 后端图优化

#### 3.1.2 关键参数配置（robosense.yaml 示例）

```yaml
imu_processing:
  initUseRtk: true           # 使用RTK初始化
  acc_cov: 0.1               # 加速度计噪声
  gyr_cov: 0.1               # 陀螺仪噪声
  extrinsic_T: [0.065, 0.0, 0.07]  # LiDAR-IMU 平移外参
  gnss_heading_need_init: true    # GNSS航向需要初始化

front:
  gnss_cov: [0.00001, 0.00001, 0.00001]  # 前端GNSS观测协方差
  gnss_front: true                       # 启用前端GNSS融合

gps_processing:
  extrinsic_T_gnss: [0.07, 0.27, 0.12]   # GNSS-IMU 外参
  initXYZ: [463619.839, 4404452.67, 29.148]  # 赛道起点CGCS2000坐标

back:
  gnss_cov: [0.0001, 0.0001, 0.0001]  # 后端GNSS协方差
  gnss_back: true                       # 启用后端GNSS约束
  useGpsElevation: true                  # 使用GPS高程
```

#### 3.1.3 ROS 话题接口

| 话题 | 类型 | 方向 | 说明 |
|------|------|------|------|
| `/imu` | `sensor_msgs/Imu` | 输入 | IMU数据（6轴或9轴） |
| `/lidar` | `sensor_msgs/PointCloud2` | 输入 | LiDAR点云 |
| `/gnss` | `sensor_msgs/NavSatFix` | 输入 | GNSS定位数据 |
| `/Odometry` | `nav_msgs/Odometry` | 输出 | 融合后的全局里程计 |
| `/cloud_registered_body` | `sensor_msgs/PointCloud2` | 输出 | body系下去畸变点云 |

#### 3.1.4 GlioEstimator 多源融合架构

`GlioEstimator` 类是核心融合引擎，支持多种观测类型：

```cpp
enum class ObsType {
    LIDAR,                  // LiDAR点云配准
    WHEEL_SPEED,            // 轮速计观测
    WHEEL_SPEED_AND_LIDAR,  // 轮速+Lidar
    ACC_AS_GRAVITY,         // 重力作为加计观测
    GPS,                    // GPS/RTK 六自由度位姿
    BIAS,                   // 零偏观测
};
```

- **IMU 预测**：`predict()` 函数执行 INS 递推
- **GNSS 更新**：`gnssUpdate()` 通过 `h_share_model_gnss()` 进行 ESKF 更新
- **轮速更新**：`odoNHCUpdate()` 非完整约束（NHC）更新
- **角度更新**：`angleUpdate()` 用于外部角度传感器融合
- **ZUPT**：`detectZUPT()` + `ZUPT()` 零速检测与修正

### 3.2 多模态感知实现（视觉 + 激光）

#### 3.2.1 激光感知

**障碍物检测（marathontracking 路线）：**
- 环形哈希体素地图（`RingVoxelMap`）管理局部高程图
- 基于相对高度的地面去除算法：障碍物高度需 > 0.4m
- `RingVoxelMapObstacleIterator` 遍历体素生成障碍物地图
- 地面厚度参数 `groundThickness=2`，障碍物厚度 `obstacleThickness=1`

**障碍物检测（tangent_arc_navigation 路线）：**
- `lidar_obstacle_node` 将 LiDAR 点云转换为障碍物列表
- `costmap_converter` 将代价地图转换为多边形/线段表示
- 支持动态障碍物追踪（Kalman 滤波 + 匈牙利算法匹配）

#### 3.2.2 视觉感知（vision_part）

**训练管线：**
- 基础模型：YOLO11s-seg（实例分割）
- 目标类别：`robot`、`person`、`car` 三类
- 采用分阶段训练 + 权重融合策略解决部分标注问题
  - 第一阶段：冻结 backbone，自定义 `robot` 数据微调 head
  - 第二阶段：与 COCO 预训练权重融合，双 head 结构保留通用类别能力
- PyTorch Lightning 训练框架（`seg_lightning`）

**部署管线：**
- ONNX 导出 → TensorRT Engine 构建（FP16/INT8）
- 三种推理路径：
  - Python: `robot_seg_trt_video.py` / `robot_seg_trt_image.py`
  - C++ + V4L2: `fusion_v4l2_deepstream_app`
  - DeepStream: `DeepStream-Yolo-Seg`（含自定义 NMS / RoIAlign 插件）
- 输入尺寸：640×640 或 960×544
- 支持摄像头实时推理

**⚠️ 注意：** 视觉感知与导航的在线融合需要用户自行完成传感器标定和系统集成，开源仅提供训练与部署能力。

### 3.3 导航规划算法

#### 3.3.1 复杂路线（marathontracking）

**三阶段状态机：**

| 模式 | 触发条件 | 行为 |
|------|----------|------|
| `TRACKING` | 无障碍物 | 全速寻线（Bang-Bang控制） |
| `AVOIDANCE` | 障碍物距离 > 1.5m | 高速避障 |
| `RECOVERY` | 障碍物距离 < 1.5m | 停车 → A*规划 → 绕开 → 恢复 |

**路径规划：**
1. **三次样条采样路径规划**：`PathSampler` 从预录路径库中采样候选路径
   - 预录路径存储在 `pathes/` 目录下（A000.path ~ A019.path，共20条）
   - 路径以逗号分隔的浮点数序列存储
   - 采样时根据机器人位姿进行裁剪和变换
2. **Dijkstra/A* 路径规划**：用于 Recovery 模式
   - 26 连通体素地图上的图搜索
   - 支持欧氏距离/曼哈顿/Octile启发函数
   - 二叉堆优先队列，线性化内存布局

**路径选择评分：**
- 路径与障碍物地图的碰撞检测（`collision_range_` 3体素半径）
- 路径与参考路径的平行度评分（`score_unparallelism`）
- 能量一致性权重（`kWeightEnergyConsistency = 1.0`）
- 路径安全性评分（基于障碍物距离的加权计算）

#### 3.3.2 极简路线（tangent_arc_navigation）

**切弧避障算法（vo_node）：**
- 核心思想：在速度空间中模拟多组圆弧轨迹，检测与障碍物的碰撞
- 左右两侧分别生成切线方向，选择碰撞时间最长的方向
- 支持动态障碍物速度估计
- 碰撞检测梯形：根据当前速度动态调整前方检测区域的张角
  - `collision_slope_deg = 18.0`（速度为3.5m/s时的最大张角）
  - 速度越快，前方检测区域越宽

**速度-角速度限制：**
- CSV 表驱动的角速度限制（`vo_angular_limits.csv`）
- 速度平滑：低通滤波 + 加速度限制
  - `speed_rise_limit_mps2 = 1.0`（加速限制）
  - `speed_fall_limit_mps2 = 2.5`（减速限制）

**Recovery 规划：**
- 体素栅格分辨率 `recovery_grid_res_ = 0.3m`
- 搜索半径 `recovery_grid_radius_ = 12.0m`
- Recovery 速度 `recovery_v_ = 0.5m/s`
- 超时 30s 后退出 Recovery

**速度控制器：**
- PID 控制（`speed_controller_continuous.cpp`）
- 输入：`/speed_command`（目标航向+速度）
- 输出：`/fuzzy_cmd_vel`（geometry_msgs/Twist）

### 3.4 运动控制接口

#### 3.4.1 控制指令流

```
local_planner / vo_node
        │
        ▼
   /fuzzy_cmd_vel (Twist)     ← 自动控制器输出
        │
        ▼
   joy_node.py (路由)
        │ ← /joy (手柄) 或 /dev/tty_elrs (SBUS遥控)
        ▼
   /final_stampd_cmd_vel (TwistStamped)
        │
        ▼
   ros1_sender_general (UDP Server)
        │
        ▼
   机器人底层控制器 (UDP Client, Port 8888)
```

#### 3.4.2 运动学包络器（Kinematic Envelope）

`KinematicEnvelope` 是一个创新的多变量约束控制器，确保输出控制量在机器人可响应范围内：

- 二维空间 `(velx, velz)` 上的线性包络约束
- 三种模式对应不同约束区域：
  - **TRACKING**：velx ∈ [2.5, 3.5]，velz ∈ [-2.3, 2.3]
  - **AVOIDANCE**：velx ∈ [1.0, 2.3]，velz ∈ [-1.5, 1.5]
  - **RECOVERY**：velx ∈ [0, 0.6]，velz ∈ [-0.8, 0.8]
- 迭代投影求解，最多 10 次迭代

#### 3.4.3 速度指令协议

UDP 自定义协议，帧结构：
```
[4B 帧头 0xA5A5A5A5] [4B 数据长度] [1B 消息类型] [6×float 速度数据] [4B CRC32] [4B 帧尾 0x5A5A5A5A]
```

消息类型：
- `MSGTYPE_CMD_VEL = 0x01`：速度指令
- `MSGTYPE_HEARTBEAT = 0x02`：心跳包
- `MSGTYPE_CMD = 0x03`：模式指令（初始化/零力矩/阻尼/行走/奔跑/关机）

速度数据为 6 个 float：`linear.x/y/z + angular.x/y/z`（标准 Twist 分解）

#### 3.4.4 模糊控制 + RL 增强

**模糊控制器（FuzzyTracking）：**
- 三输入：目标距离 `in_x`、航向误差 `in_theta`、路径曲率 `in_curve`
- 二输出：`out_vel_x`（归一化线速度）、`out_vel_z`（角速度）
- 模糊集定义：7个航向误差子集 + 3个距离子集 + 2个曲率子集
- 带速度平滑器（`VelSmoother`）

**RL-PPO 增强：**
- 在模糊控制器输出基础上叠加 RL 微调
- 状态空间：`[yaw_error, curvature, vel_x, vel_z]`（4维）
- 动作空间：2维连续动作（线速度/角速度修正量）
- 奖励函数：`-10×|yaw_error|² + 2×vel_x - 0.5×|vel_z|² + 航向精度奖励`
- PPO 超参：lr=3e-4, gamma=0.99, eps_clip=0.2, K_epochs=4

### 3.5 ROS 依赖和节点结构

#### 3.5.1 ROS 版本与依赖

- **ROS 版本**：ROS Noetic（ROS1）
- **构建系统**：catkin_make
- **关键依赖**：
  - PCL >= 1.8, Eigen >= 3.3.4
  - GTSAM（后端图优化）
  - GDAL（坐标转换）
  - glog/gflags
  - TBB（并行计算）
  - ZMQ（robot_interface 通信）
  - livox_ros_driver（Livox LiDAR 驱动）

#### 3.5.2 核心节点列表

| 节点名 | 包名 | 功能 | 关键话题 |
|--------|------|------|----------|
| `glio_mapping` | glio_mapping | 多源融合定位 | /odometry, /current_scan_body |
| `local_planner` | local_planner | 局部规划+避障+控制 | /fuzzy_cmd_vel |
| `path_process_node` | path_process | 全局路径处理 | /central/smoothed_path, /left/smoothed_path, /right/smoothed_path |
| `udp_cmd_vel_server` | ros1_sender_general | UDP控制指令发送 | /final_stampd_cmd_vel |
| `robot_interface_node` | robot_interface | ZMQ机器人状态接收 | - |
| `joy_node.py` | python_ws | 遥控器+指令路由 | /joy, /fuzzy_cmd_vel |
| `fuzzy_control_node.py` | python_ws | 模糊控制 | /fuzzy_cmd_vel |
| `rl_control_node.py` | python_ws | RL增强控制 | /rl_cmd_vel |
| `vo_node` | vo_navigation | 切弧导航 | /speed_command |
| `speed_controller` | speed_controller | PID速度控制 | /fuzzy_cmd_vel |
| `lidar_obstacle_node` | vo_navigation | 激光障碍物检测 | /obstacles |
| `subgoal_selector_node` | vo_navigation | 子目标选择 | /vo/subgoal |
| `sim_interface_node` | sim_interface | 仿真接口 | /odometry转发, /tf |

#### 3.5.3 启动流程

通过 systemd service 启动 `marago.sh`，启动链：
1. `roscore`
2. `joy_node.py`（Python 虚拟环境）
3. `ros1_sender_general sender_node`
4. `local_planner`

---

## 4 四足机器狗适配可行性评估

### 4.1 整体可行性

**评估结论：中高可行性，需要实质性改造。**

Marathongo 的定位层（glio_mapping）通用性较强，可直接用于四足机器狗。规划与控制层需要根据四足运动学特性进行大幅调整。视觉感知层可复用。

### 4.2 各模块适配分析

#### 4.2.1 定位模块（glio_mapping）—— ✅ 高度可复用

| 适配项 | 难度 | 说明 |
|--------|------|------|
| 传感器接口 | 低 | 标准ROS话题，更换传感器只需修改YAML配置 |
| IMU运动模型 | 低 | 四足步态频率更高，但EKF框架通用 |
| LiDAR安装位置 | 低 | 修改外参配置即可 |
| GNSS融合 | 低 | 无需修改，通用GPS处理器 |
| 回环检测 | 低 | 欧氏距离回环与平台无关 |
| ZUPT检测 | **中** | 四足步态无明显零速时段，需禁用或重新标定 |
| 运动畸变 | **中** | 四足步态振荡更大，点云去畸变可能需要加强 |

**改造要点：**
1. 禁用 ZUPT 或修改阈值参数（`zupt_angular_velocity_threshold`, `zupt_special_force_threshold`）
2. 调整 IMU 噪声参数以匹配四足平台更高频的振动
3. LiDAR 安装位置通常低于人形机器人，修改外参
4. 可能需要增加 IMU 预积分的振动滤波

#### 4.2.2 规划模块 —— ⚠️ 中等改造量

| 子模块 | 适配难度 | 说明 |
|--------|----------|------|
| 全局路径处理 | 低 | 通用路径格式，与平台无关 |
| 障碍物检测 | 低 | 基于高程差的检测通用 |
| 路径采样 | **中** | 预录路径库需重新录制/生成 |
| Dijkstra/A* | 低 | 图搜索算法通用 |
| 切弧避障 | **高** | 基于差速运动模型，四足需修改 |

**改造要点：**
1. 预录路径库需要替换为适合四足机器狗的路径集
2. 切弧避障（vo_node）的圆弧轨迹假设基于差速模型，四足支持全向移动，需重新设计
3. 障碍物检测的高度阈值需调整（四足体型更矮）
4. 碰撞检测的机器人半径需更新

#### 4.2.3 控制模块 —— ⚠️ 需大幅改造

| 适配项 | 难度 | 说明 |
|--------|------|------|
| 运动学包络 | **高** | 速度范围完全不同，需重新标定 |
| 模糊控制器 | **高** | 输入输出范围需重调，规则需改写 |
| RL控制器 | **中** | 状态/动作空间需重新设计，奖励函数需修改 |
| PID速度控制 | **中** | 参数需重调 |
| UDP协议 | 低 | 协议通用，只需对接四足底层 |

**改造要点：**
1. **速度范围**：人形跑步速度可达 3.5 m/s，四足典型行走 1.0-2.0 m/s，奔跑 2.5-4.0 m/s
2. **角速度范围**：四足原地转向能力更强，但高速转向稳定性不同
3. **运动学包络**：需要基于四足的实际运动能力重新标定各模式的速度约束
4. **模糊规则**：`in_x` 的模糊集范围（STOP/CLOSE/FAR）需根据四足制动距离调整
5. **RL奖励函数**：速度和角速度惩罚项的权重需根据四足动态特性重新平衡
6. **控制接口**：四足通常使用 `cmd_vel`（Twist），但底层协议可能不同（如 Unitree Go2 使用 UDP+MQTT，宇树 A1 使用自定义 SDK）

#### 4.2.4 视觉感知模块 —— ✅ 高度可复用

| 适配项 | 难度 | 说明 |
|--------|------|------|
| 模型训练 | 低 | 增加四足机器狗类别即可 |
| TensorRT部署 | 低 | 部署流程通用 |
| 传感器标定 | **中** | 摄像头安装位置不同，需重新标定 |
| 融合接入 | **中** | 视觉障碍物与导航的融合接口需适配 |

### 4.3 四足机器狗特有挑战

#### 4.3.1 运动学差异

| 特性 | 人形机器人 | 四足机器狗 | 影响 |
|------|-----------|-----------|------|
| 运动模型 | 差速/步态 | 全向/步态 | 路径规划需支持全向 |
| 重心高度 | ~1.0m | ~0.3m | LiDAR视角、碰撞检测 |
| 体宽 | ~0.5m | ~0.3m | 避障安全距离 |
| 步态振动 | 中等 | 较大（高频） | IMU/LiDAR 抗振 |
| 原地转向 | 较慢 | 快速 | 规划策略可更灵活 |
| 爬坡能力 | 中等 | 较强 | 可增加坡道规划 |
| 上下台阶 | 较好 | 有限 | 路径约束不同 |

#### 4.3.2 室内外切换

Marathongo 面向室外马拉松场景，GNSS 可用。四足机器狗室内外长距离导航需额外考虑：

1. **室内 GNSS 退化**：进入室内后需切换到纯 LiDAR-SLAM 模式
2. **地图切换**：室外全局地图（GNSS坐标系）与室内地图的衔接
3. **多楼层**：电梯/楼梯导航
4. **动态环境**：室内人群密集度更高
5. **通信**：室内 Wi-Fi/5G 覆盖

### 4.4 推荐适配路线

#### 阶段一：定位层移植（1-2 周）
1. 部署 glio_mapping，修改传感器配置
2. 调整 ZUPT 参数或禁用
3. 调整 IMU 噪声模型
4. 验证纯 LiDAR+IMU 模式（室内）
5. 验证 GNSS+LiDAR+IMU 模式（室外）

#### 阶段二：极简导航移植（2-3 周）
1. 部署 tangent_arc_navigation
2. 修改切弧避障的机器人参数
3. 调整速度控制器 PID 参数
4. 对接四足底层控制接口
5. 室内直线+弯道测试

#### 阶段三：复杂导航移植（3-4 周）
1. 部署 marathontracking local_planner
2. 重新标定运动学包络
3. 为四足录制参考路径库
4. 调整模糊控制器参数
5. 集成视觉障碍物检测

#### 阶段四：室内外一体化（3-4 周）
1. 实现 GNSS 可用性检测与模式切换
2. 室内外地图坐标系衔接
3. 全路径规划（门/走廊/电梯等关键点）
4. 完整长距离测试

---

## 5 关键依赖与第三方库

| 依赖 | 版本要求 | 用途 |
|------|----------|------|
| ROS Noetic | - | 中间件框架 |
| PCL | >= 1.8 | 点云处理 |
| Eigen | >= 3.3.4 | 线性代数 |
| GTSAM | - | 后端位姿图优化 |
| GDAL/OGR | - | WGS84↔CGCS2000 坐标转换 |
| glog/gflags | - | 日志系统 |
| TBB | - | 并行计算 |
| IKFoM | - | 流形上迭代卡尔曼滤波 |
| ikd-Tree | - | 增量式动态 KD-Tree |
| Ceres | - | 非线性优化（部分模块） |
| ZMQ | - | 机器人接口通信 |
| TensorRT | - | 视觉推理部署 |
| DeepStream | - | 视觉流处理 |
| skfuzzy | - | 模糊控制（Python） |
| PyTorch | - | RL训练/视觉训练 |
| ultralytics | - | YOLO训练 |

---

## 6 优势与不足

### 6.1 项目优势

1. **全栈方案**：从定位到感知到规划到控制，覆盖完整导航链路
2. **多路线选择**：极简路线快速验证 + 复杂路线深度优化
3. **GNSS融合**：支持长距离室外定位，21km 实际验证
4. **运动学包络**：创新的多变量约束控制，确保安全性
5. **视觉部署链**：完整的 TensorRT/DeepStream 部署方案
6. **RL增强**：PPO 在线学习微调模糊控制输出
7. **实战验证**：已在真实马拉松场景中验证

### 6.2 项目不足

1. **仅 ROS1**：不支持 ROS2，限制了新一代机器人平台适配
2. **代码风格不统一**：工程化代码带有调试痕迹
3. **文档分散**：部分模块文档不完整
4. **MPC 控制器已禁用**：更优的控制方案不可用
5. **视觉融合未完整开源**：视觉与导航的在线融合需自行实现
6. **机器人接口特定化**：UDP 协议为朗毅特定机器人设计
7. **预录路径依赖**：local_planner 依赖预录路径，不适应未知环境
8. **缺乏全局规划**：无动态全局路径规划能力（如 Nav2 的行为树）

---

## 7 对四足机器狗导航系统的建议

### 7.1 架构建议

1. **ROS2 迁移**：建议基于 ROS2 重构，利用 Nav2 框架整合各模块
2. **模块化设计**：将 glio_mapping 作为独立定位节点，通过话题解耦
3. **增加全局规划**：补充基于图的拓扑规划或 Nav2 行为树
4. **室内外模式切换**：设计 GNSS 退化检测与自动模式切换逻辑

### 7.2 可直接复用的模块

- **glio_mapping**：核心定位能力，修改配置即可使用
- **vision_part/seg_tensorrt**：TensorRT 部署管线通用
- **障碍物检测算法**：基于高程差的检测逻辑通用
- **Dijkstra/A* 实现**：高质量 C++ 实现，可直接复用

### 7.3 需要重新设计的模块

- **运动学包络**：完全基于四足运动能力重新标定
- **模糊控制器**：规则和参数需适配四足动态特性
- **切弧避障**：vo_node 的差速模型假设需改为全向模型
- **控制指令路由**：对接四足平台特定接口
- **室内外切换**：新增功能

---

## 8 总结

Marathongo 是一个经过 21km 真实马拉松场景验证的导航全栈开源方案，其核心价值在于：

1. **glio_mapping** 提供了经过工程化验证的 GNSS+IMU+LiDAR 紧耦合融合定位方案，这是室外长距离导航的关键基础设施
2. **双路线设计**为不同阶段的需求提供了选择弹性
3. **运动学包络器**是一个值得借鉴的安全约束设计
4. **视觉部署链**提供了从训练到端侧部署的完整参考

对四足机器狗室内外长距离导航而言，定位层可直接复用，规划与控制层需根据四足运动学特性进行适配改造，建议分阶段推进，先极简路线验证闭环，再逐步迭代到完整方案。

---

*报告生成时间：2026-04-19*
*分析仓库版本：main 分支（shallow clone）*


---

## 相关链接
- [[分布式RPA系统]] — 上层多机协作调度

- [[Marathongo-深度技术分析.md|深度技术分析（硬件采购+三大核心问题）]]
- [[Marathongo-IMU-LiDAR融合去畸变技术报告.md|IMU-LiDAR 融合去畸变技术细节]]
- [[Marathongo-高德地图导航对接报告.md|高德/百度地图导航对接方案]]
- [[重磅-全球首套人形机器人马拉松全栈导航系统开源.md|朗毅开源新闻原文]]
- [[rl-locomotion.md|强化学习运动控制（RL运控）]]
- [[mpc-control.md|MPC 模型预测控制（Marathongo已废弃）]]
- [[unitree-go2.md|Unitree Go2（目标四足平台）]]