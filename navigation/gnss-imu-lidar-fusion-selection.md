# GNSS+IMU+LiDAR 多源融合方案选型

**Date**: 2026-04-24
**Status**: ⏳方案选型
**Context**: NAV_DOG — 机器狗户外导航需要多源融合定位

## 需求分析

Unitree Go2/A2 户外导航场景：
- **室内/遮挡区**：LiDAR SLAM + IMU 为主（无 GNSS 信号）
- **户外开阔区**：GNSS 绝对定位 + LiDAR SLAM 修正
- **过渡区**：GNSS 信号弱时平滑切换到 LiDAR+IMU
- **关键约束**：实时性（≥10Hz 输出）、Go2 计算资源有限（RK3588）

## 候选方案

### 方案 A：LIO-SAM + GNSS（⭐ 推荐）

| 项目 | LIO-SAM (4701⭐) | LIO_SAM_6AXIS (838⭐) |
|------|-------------------|----------------------|
| 核心 | 紧耦合 LiDAR-IMU 因子图 | 6轴IMU + GNSS 扩展 |
| GNSS | 支持（需 gnss_to_odom 节点） | 原生支持 |
| 语言 | C++ | C++ |
| ROS版本 | ROS1 (社区有 ROS2 移植) | ROS1 |
| License | BSD | - |
| 维护 | 2025-02 last push | 2025-12 last push |

**优势**：成熟稳定，社区大，因子图架构天然支持多源融合
**劣势**：ROS1 原生，ROS2 需要社区移植版；计算开销较大

### 方案 B：FAST-LIO2 + GNSS Fusion

| 项目 | FAST-LIO2 | FAST-LIO-Multi-Sensor-Fusion (301⭐) |
|------|-----------|--------------------------------------|
| 核心 | 紧耦合 LiDAR-IMU IEKF | FAST-LIO + IKFOM + GNSS + Wheel |
| GNSS | 需额外融合 | 原生支持 |
| 语言 | C++ | C++ |
| License | GPL-2.0 | - |
| 维护 | 活跃 | 2026-04 last push |

**优势**：FAST-LIO2 速度快（适合嵌入式），Multi-Sensor-Fusion 直接加 GNSS
**劣势**：GPL-2.0 限制商用；FAST-LIO2 本身不含 GNSS，需二次开发

### 方案 C：Point-LIO + 外部融合

| 项目 | Point-LIO (1179⭐) | point_lio_unilidar (479⭐) |
|------|---------------------|---------------------------|
| 核心 | 逐点处理 LiDAR-IMU | Unitree LiDAR 专用版 |
| GNSS | 无，需外部融合 | 无 |
| 语言 | C++ | C++ |
| 优势 | 最低延迟，逐点处理 | 直接支持 Unitree LiDAR |
| 劣势 | 无 GNSS 融合，需自己加 | 无 GNSS |

**优势**：Unitree LiDAR 直接兼容，延迟最低
**劣势**：需自己写 GNSS 融合层，工作量大

### 方案 D：ROS2 robot_localization + LiDAR SLAM

| 项目 | robot_localization | ros2_tools_ws (GNSS/IMU) |
|------|-------------------|--------------------------|
| 核心 | EKF/UKF 多源融合 | GNSS/IMU fusion wrapper |
| 架构 | 松耦合：各传感器独立 → EKF 融合 | robot_localization + GNSS |
| 优势 | 模块化，易于调试 | ROS2 原生 |
| 劣势 | 松耦合精度低于紧耦合 | 社区小 |

## 推荐方案

### 首选：FAST-LIO-Multi-Sensor-Fusion (方案 B)

**理由**：
1. 原生 GNSS + Wheel + LiDAR + IMU 融合，减少二次开发
2. 基于 FAST-LIO2（IEKF），计算效率适合 Go2/RK3588
3. 最近更新（2026-04），活跃维护
4. IKFOM 框架支持灵活添加传感器

### 备选：LIO_SAM_6AXIS (方案 A 扩展)

**理由**：
1. 因子图架构更灵活（添加新传感器只需加 factor）
2. 原生 6轴 IMU + GNSS
3. 社区更大（4701 + 838 ⭐）
4. 如果 FAST-LIO 融合效果不理想，切换成本低

### 落地路线

```
Phase 1: 仿真验证（2周）
  → FAST-LIO-Multi-Sensor-Fusion 编译运行
  → 用 Go2 Gazebo 仿真测试 GNSS+LiDAR 融合
  
Phase 2: 实机部署（A2 到货后）
  → Unitree LiDAR (point_lio_unilidar) + GNSS 天线
  → FAST-LIO-Multi-Sensor-Fusion 适配
  → 对比纯 LiDAR SLAM vs 融合定位精度

Phase 3: 与导航栈集成
  → 融合定位 → Nav2 / Vector OS Nano nav stack
  → 室内外切换逻辑
```

## 与已有方案的协同

| 已有组件 | 与融合方案的接口 |
|----------|-----------------|
| Marathongo glio_mapping | LiDAR SLAM 层（可替换为 FAST-LIO） |
| Vector OS Nano nav stack | 消费融合定位的 pose 话题 |
| ABot-Claw VLAC | VLM 理解场景 → 切换室内外模式 |
| unitree_sdk2_python | 获取 IMU/wheel odom 原始数据 |

## 待确认

- [ ] Go2/A2 的 GNSS 天线接口（是否有预留？需要外接？）
- [ ] RK3588 算力是否足够运行 FAST-LIO + GNSS fusion
- [ ] FAST-LIO-Multi-Sensor-Fusion 的 License（README 未标注）
