# Daily Digest #3 — 2026-04-23

## 🔥 关键发现

### 1. OpenClaw A2A Gateway（457⭐）

**替代我们自研群控模块的最佳选择**。原生 Hermes/OpenClaw 插件，一条命令安装：
- Google A2A v0.3.0 协议
- 三传输（JSON-RPC/REST/gRPC）+ 自动降级
- Hill 方程仿生路由
- DNS-SD 自动发现 + mDNS 自广播
- 四态仿生熔断器
- Bearer Token + Ed25519 设备身份

**结论**：放弃自研 `hermes_swarm.py`，改用 A2A Gateway + Auto-Drive 协作框架。

### 2. ABot-Claw 完整架构解析

三层架构：OpenClaw Layer → Robot Layer（agent_server）→ Service Layer（GPU 推理）

8 个核心 skill + VLAC 闭环 + SpatialMemoryHub（4 类记忆）

**关键**：直接支持 Unitree Go2 + G1，FastAPI 服务器（端口 8888），ROS2 集成。

### 3. Marathongo 深度解析

4 个模块：glio_mapping + tangent_arc_navigation + marathontracking + vision_part

**快速验证路径**：glio_mapping + tangent_arc_navigation（1-2 周跑通 A2）

## 📋 待做

| 优先级 | 任务 | 类型 |
|--------|------|------|
| P0 | 本地服务器安装 A2A Gateway | 代码（需确认） |
| P0 | A2 到货后复现 ABot-Claw | 硬件依赖 |
| P1 | isaac-go2-ros2 仿真环境搭建 | 代码（需确认） |
| P1 | awesome-ai-agents PR 合并追踪 | 跟进 |
| P2 | MoLing 浏览器 headless 调试 | 代码（需确认） |

## 📊 社区动态

- agent 协作已成风口：Google A2A、OpenClaw A2A Gateway、Swarms、Solace Agent Mesh
- 大厂编码效率 10-100x 提升（agent 辅助）
- browser-use 类项目持续增长（89K⭐）
- 反 bot 检测也在升级（Trace Guard 等）
