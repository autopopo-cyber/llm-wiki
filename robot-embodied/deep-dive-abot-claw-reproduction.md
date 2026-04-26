# ABot-Claw 复现路径 + Marathongo 对接方案

> 2026-04-23 | 深度技术分析 | 为 Unitree A2 + G1 部署做准备

## 一、ABot-Claw 完整架构

### 三层架构

```
┌─────────────────────────────────────────────┐
│  OpenClaw Layer（Hermes 上游）                │
│  → 任务编排、skill 管理、决策                  │
│  → 8 个专用 skill                            │
│  → MISSION.md / ROBOT.md / HEARTBEAT.md      │
└──────────────┬──────────────────────────────┘
               │ HTTP API
┌──────────────┴──────────────────────────────┐
│  Robot Layer（agent_server）                  │
│  → FastAPI 服务，端口 8888                    │
│  → 认证、租约管理、代码执行、状态聚合          │
│  → ROS2 集成（关节/末端位姿/夹爪/相机）       │
│  → 安全检查 + E-stop                         │
└──────────────┬──────────────────────────────┘
               │ HTTP API
┌──────────────┴──────────────────────────────┐
│  Service Layer（GPU 推理服务）                │
│  → VLAC Critic（视觉-语言-动作评价器）         │
│  → YOLO（目标检测，端口 8012）                │
│  → GraspAnything（抓取规划，端口 8013）        │
│  → 各服务 Docker 化部署                      │
└─────────────────────────────────────────────┘
```

### 8 个核心 Skill

| Skill | 功能 | 关键点 |
|-------|------|--------|
| `abotclaw-bundle` | 打包 skill 为单文件可执行 | deps.txt 递归解析 |
| `abotclaw-memory` | SpatialMemoryHub（4类记忆） | 对象/地点/关键帧/语义帧 |
| `abotclaw-progress-critic` | VLAC 进度评价 | 当前帧 vs 参考帧 + 任务描述 |
| `abotclaw-robot-connection` | 机器人连接管理 | URL/认证/健康检查 |
| `abotclaw-robot-hardware` | 硬件角色定义 | Piper/G1/Go2 能力边界 |
| `abotclaw-run-robot-task` | 执行任务 | 分类→选机器人→SDK发现→编码→执行 |
| `abotclaw-sdk-discovery` | SDK 自动发现 | robot_hosted_docs 优先 |
| `abotclaw-active-services` | 外部服务发现 | 视觉/语音/规划/抓取/导航 |

### VLAC 闭环（核心创新）

```
任务描述 → 执行动作 → 拍照 → VLAC Critic（当前帧 vs 参考帧）
                              ↓
                    critic_list: [0.82, 0.79, 0.91]
                    value_list: [0.75, 0.70, 0.88]
                              ↓
                    进度评价 → 继续/重试/停止
```

- 模型: InternVL2（默认）
- 推理设备: CUDA 优先
- API: `POST /critic` → `CriticResponse`
- 温度 0.5, top_k=1

### SpatialMemoryHub（4 类记忆）

| 记忆类型 | 内容 | 用途 |
|----------|------|------|
| object memory | 具体检测对象 + 位姿 + 证据 | "上次看到的红色杯子在哪" |
| place memory | 命名语义地点 + 锚点 | "厨房"、"走廊尽头" |
| keyframe memory | 离线提取的关键帧 | 大场景记忆构建 |
| semantic frame memory | 图像记忆 + 文本语义检索 | "看起来像工作台的图" |

---

## 二、Marathongo 核心架构

### 4 个模块

| 模块 | 定位 | 复杂度 |
|------|------|--------|
| `glio_mapping` | GNSS+IMU+LiDAR 融合定位 | 高（核心） |
| `tangent_arc_navigation` | 最小路线：线跟随+基础避障 | 低（快速验证） |
| `marathontracking` | 完整路线：局部规划+控制+集成 | 高（实战级） |
| `vision_part` | 视觉障碍物识别 + 训练 + 部署 | 中 |

### 技术路线选择

```
快速验证（1-2周）：
  glio_mapping + tangent_arc_navigation
  → 跑通 A2 的线跟随 + 基础避障

实战优化（1-2月）：
  glio_mapping + marathontracking + vision_part
  → 高速跑、复杂避障、多模态感知
```

### 关键依赖

- ROS2（必须）
- GNSS 接收器（户外必须）
- LiDAR（推荐，glio_mapping 核心）
- IMU（内置）
- GPU（vision_part 训练/推理）

---

## 三、复现路线图

### Phase 0：纯软件验证（A2 到货前）

| 任务 | 时间 | 输出 |
|------|------|------|
| 安装 ABot-Claw workspace | 1天 | OpenClaw + 8 个 skill 可用 |
| 配置 MISSION.md / ROBOT.md | 半天 | 适配 A2 + G1 |
| 安装 Marathongo + isaac-go2-ros2 | 2天 | 仿真环境可跑 |
| VLAC Critic 部署测试 | 1天 | Docker 服务运行 |
| SpatialMemoryHub 测试 | 1天 | 4 类记忆可用 |

### Phase 1：A2 单机验证（到货后 2 周）

| 任务 | 时间 | 输出 |
|------|------|------|
| A2 传感器标定 | 2天 | GNSS/LiDAR/IMU 外参 |
| glio_mapping 上 A2 | 3天 | 户外定位可用 |
| tangent_arc_navigation 上 A2 | 3天 | 线跟随 + 基础避障 |
| ABot-Claw agent_server 部署 | 2天 | Hermes 可控制 A2 |
| VLAC 闭环验证 | 2天 | 自动任务评价 |

### Phase 2：A2 + G1 多机协作（到货后 1-2 月）

| 任务 | 时间 | 输出 |
|------|------|------|
| G1 传感器标定 + 部署 | 1周 | G1 导航可用 |
| marathontracking 替换 | 1周 | 高速避障 |
| Go2=A2 适配 ABot-Claw | 1周 | 多机 skill 可用 |
| 群控模块集成 | 2周 | Hermes 团队协调 A2+G1 |

### Phase 3：Auto-Drive + ABot-Claw 融合

```
ABot-Claw = 任务层（VLAC闭环：看→想→做→评）
Auto-Drive = 生存层（idle loop：健康→能力→知识）
Hermes = 桥梁层（工具+记忆+调度）
hermes_swarm = 协作层（消息+心跳+任务路由）
```

---

## 四、关键参考项目

| 项目 | Stars | 用途 |
|------|-------|------|
| `amap-cvlab/ABot-Claw` | 116 | 核心复现目标 |
| `landitbot/marathongo` | 115 | 导航框架 |
| `Zhefan-Xu/isaac-go2-ros2` | 512 | Isaac 仿真 + ROS2 |
| `h-naderi/unitree-go2-slam-nav2` | 152 | Go2 SLAM+Nav2 集成 |
| `andy-zhuo-02/go2_ros2_toolbox` | 148 | Go2 SLAM+导航工具箱 |
| `VectorRobotics/vector-os-nano` | 134 | 跨形态 OS，Go2+SO-ARM101 |
| `botbotrobotics/BotBrain` | 174 | 腿式机器人脑，WebUI+自主导航 |

---

## 五、与 Auto-Drive 的融合点

### 1. ABot-Claw 的 HEARTBEAT.md → 我们的 idle loop

ABot-Claw 用 HEARTBEAT.md 定义周期性检查（skill 进度、机群就绪）。
我们的 idle loop 更通用（ENSURE_CONTINUATION → EXPAND_CAPABILITIES → EXPAND_WORLD_MODEL）。

**融合方案**：在 A2/G1 的 agent 上，idle loop 的 ENSURE_CONTINUATION 分支加入机器人特定检查：
- 传感器健康
- 电池电量
- 网络连通性
- VLAC 服务可达性

### 2. SpatialMemoryHub → 我们的 Hindsight

ABot-Claw 的空间记忆（对象/地点/关键帧/语义帧）和我们的 Hindsight 长期记忆互补：
- Hindsight = 语义记忆（对话、知识、经验）
- SpatialMemoryHub = 空间记忆（位置、对象、场景）

**融合方案**：Hindsight 存策略/经验，SpatialMemoryHub 存空间数据，idle loop 同时维护两者。

### 3. VLAC Critic → 我们的 Progress-Critic

VLAC 的"当前帧 vs 参考帧"评价机制可以直接用于 idle loop 的 EXPAND_CAPABILITIES：
- 执行 skill → 截图 → VLAC 评价 → 自动改进

---

## 六、A2 vs Go2 vs G1 对比

| 维度 | Unitree A2 | Unitree Go2 | Unitree G1 |
|------|-----------|-------------|------------|
| 类型 | 四足（放大 Go2） | 四足 | 人形 |
| 载荷 | 更大 | 有限 | 上半身操作 |
| 定位 | 户外长距离 | 巡检/跟随 | 人环境交互 |
| ABot-Claw | ✅ 直接兼容 | ✅ 原生支持 | ✅ 原生支持 |
| Marathongo | ✅ 需适配 | ✅ 需适配 | ✅ 主要目标 |
| 我们的分工 | 巡逻/侦查/长距离 | （和 A2 重叠，备用） | 操作/交互/展示 |
