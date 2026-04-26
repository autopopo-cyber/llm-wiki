# Marathongo 架构快速分析

> 执行时间: 2026-04-22 22:26 | 状态: 已克隆，已分析

## 仓库位置
`~/projects/marathongo` (https://github.com/landitbot/marathongo)

## 顶层模块

```
marathongo/
├── glio_mapping/          # 建图：GLIO (GNSS+LiDAR+IMU+Odometry)
├── tangent_arc_navigation/ # 导航：切线圆弧局部规划 + VO避障
├── vision_part/            # 视觉：分割模型训练 + TensorRT部署
└── marathontracking/       # 赛道跟踪：Bang-Bang寻线 + A*避障 + PID控制
```

## 各模块细节

### 1. glio_mapping
- 基于 FAST-LIO / GLIO 架构
- 关键文件: `imu_processing.cpp`, `laser_mapping.cpp`, `preprocess.cpp`
- 支持多传感器融合定位

### 2. tangent_arc_navigation (ROS2/ROS1 混合)
五个子包:
- `vo_navigation` — 速度障碍(VO)局部规划节点，包含 lidar_obstacle, subgoal_selector, vo_node
- `costmap_converter` — 成本图转换插件，支持多种聚类算法（DBS、RANSAC、凸包等）
- `speed_controller` — 速度控制器，连续/离散双实现
- `path_tools` — 路径处理工具（拟合、偏移、CSV导入导出）
- `sim_interface` — 仿真接口

### 3. vision_part
三级梯度:
- `seg_lightning` — PyTorch Lightning 训练架构，基于 YOLO11 分割
- `seg_fusion` — 多支路融合模型训练（支持10/robotbase两种架构）
- `seg_tensorrt` — TensorRT/DeepStream 部署，支持 C++/Python/DeepStream 三种推理方式

### 4. marathontracking
- 赛道级追踪系统（独立于导航）
- 三阶段控制: 全速寻线 → 全速避障 → 低速恢复(A*)
- 基于环形 hash 体素地图
- 控制器: PID（仅角速度）+ 运动学包络器
- 输入: 去畸变点云 + 里程计 + 左右边线
- 服务化启动: `marago.service` → `marago.sh`

## 与 Unitree A2 的适配差异

| 维度 | Marathongo (G1/人形机) | Unitree A2 (四足) |
|--------|------------------------|-------------------|
| 底盘 | 轮式底盘，巧克力控制 | 四足，步态生成 |
| 控制输出 | /fuzzy_cmd_vel (线速度) | 速度+角速度+机体高度/姿态 |
| 避障 | 视觉分割 + 点云 | 点云为主，视觉为辅 |
| 建图 | GLIO (GNSS+LiDAR+IMU) | LIO-SAM / FAST-LIO2 |
| 追踪 | 赛道级Bang-Bang | 需要全局路径规划 |

## 关键可复用组件
1. **vo_navigation** — 速度障碍局部规划，可直接移植到 A2 局部规划层
2. **costmap_converter** — 成本图转换插件集，完全通用
3. **glio_mapping** — 定位建图管线，需适配 A2 传感器布局
4. **vision_part/seg_tensorrt** — TensorRT 部署流水线，可复用

## 下一步建议
- 深度分析 `vo_navigation/src/vo_node.cpp` 的 VO 算法实现
- 比对 A2 的 `unitree_sdk2` 控制接口与 marathontracking 的控制流
- 考虑将 `marathontracking` 的 A* 恢复逻辑整合到 A2 全局规划器
