# NAV_DOG — Unitree A2 四足导航系统（完整子树）

> 状态：⏸️ 暂停（机器狗未到货）
> 最后更新：2026-04-22

## LV.2 — 感知系统 [last: - | ⏳]
- LV.3 GNSS+IMU 多源融合定位 [last: - | ⏳]
- LV.3 LiDAR 点云处理管线 [last: - | ⏳]
- LV.3 多模态感知融合框架 [last: - | ⏳]

## LV.2 — 规划系统 [last: - | ⏳]
- LV.3 全局路径规划（A*/RRT*）[last: - | ⏳]
- LV.3 局部避障（DWA/TEB）[last: - | ⏳]
- LV.3 室内外过渡策略 [last: - | ⏳]

## LV.2 — 控制系统 [last: - | ⏳]
- LV.3 步态生成与切换 [last: - | ⏳]
- LV.3 MPC 运动控制 [last: - | ⏳]
- LV.3 落地冲击缓冲策略 [last: - | ⏳]

## LV.2 — 地图系统 [last: - | ⏳]
- LV.3 建图方案选型（LOAM/LIO-SAM）[last: - | ⏳]
- LV.3 地图融合与更新 [last: - | ⏳]
- LV.3 语义地图标注 [last: - | ⏳]

## LV.2 — Marathongo 学习 [last: 2026-04-22 22:46 | 🔄]
- LV.3 克隆并分析架构 [last: 2026-04-22 22:30 | ✅]
- LV.3 提取 vo_navigation 模块设计 [last: 2026-04-22 22:46 | ✅]
- LV.3 适配 A2 硬件差异 [last: - | ⏳]


### 新发现：BotBrain (2026-04-24)

**botbotrobotics/BotBrain** — 174⭐, MIT, ROS2 + Next.js

- "One Brain, any Bot" — modular open-source brain for legged robots
- Web UI for teleops, autonomous navigation, mapping & monitoring
- 3D-printable hardware support, runs on Jetson
- Actively updated (pushed 2026-04-23)
- **与 NAV_DOG 的关系**: 可作为 Vector OS Nano 的替代或补充方案。ROS2 原生，导航+建图+监控一体化。
- **下一步**: 机器狗到货后评估 BotBrain vs Vector OS Nano 作为基础软件栈

