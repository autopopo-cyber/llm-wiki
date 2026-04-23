# Unitree A2 SDK 接口研究

**Date**: 2026-04-24 (updated 03:05)
**Status**: ⏳调研中（已 clone unitree-sdk2-mcp 源码分析）
**Context**: NAV_DOG — 需要了解 A2 的 SDK 接口以规划软件栈

## A2 规格（来自 unitree-sdk2-mcp README）

| 属性 | 值 |
|------|-----|
| 类型 | 四足 (Quadruped) |
| DOF | 12 |
| 特性 | Agile, Education |
| 重量 | ~15kg |
| 续航 | ~1.5h |
| 支持 | walking (✅), arm_control (❌) |

**注意**: A2 定位"Agile, Education"，续航仅 1.5h（比 Go2 的 2h 短）。工业巡检场景可能需要 B2/B2w。

## 官方 SDK

### unitree_sdk2 (C++, 1042⭐)
- **URL**: https://github.com/unitreerobotics/unitree_sdk2
- **License**: BSD-3-Clause
- **Last push**: 2026-04-16
- **支持机型**: Go2, Go2-W, A2, B2, B2-W, G1, H1, H1-2, R1
- **通信协议**: DDS (Data Distribution Service)
- **功能**: Low-level motor control, High-level motion commands, Sensor data access

### unitree_sdk2_python (Python, 666⭐)
- **URL**: https://github.com/unitreerobotics/unitree_sdk2_python
- **License**: BSD-3-Clause
- **Last push**: 2026-04-20
- **支持机型**: 同上
- **优势**: Python 接口 → 更快原型开发 → 可直接集成到 Hermes

## 🔑 关键发现：unitree-sdk2-mcp (MCP Server!)

### ros-claw/unitree-sdk2-mcp (1⭐, MIT License)
- **URL**: https://github.com/ros-claw/unitree-sdk2-mcp
- **已 clone 到**: ~/repos/unitree-sdk2-mcp/
- **Last push**: 2026-04-16
- **支持机型**: G1, Go2, Go2w, H1, H2, B2, B2w, **A2**, R1
- **协议**: MCP (Model Context Protocol)
- **通信**: DDS → MCP bridge

### MCP Tools 清单（源码分析）

| Tool | 功能 | A2 可用 |
|------|------|---------|
| `get_sdk_info` | SDK 元数据（版本、协议、支持机型） | ✅ |
| `list_robots` | 列出所有支持的机器人 | ✅ |
| `get_robot_info` | 机器人详细配置（关节限制、能力） | ✅ |
| `connect_robot` | 通过 DDS 连接机器人 | ✅ |
| `disconnect_robot` | 断开连接 | ✅ |
| `stand_up` | 命令机器人站立 | ✅ (support_walking=true) |
| `sit_down` | 命令机器人坐下/停止 | ✅ |
| `walk_with_velocity` | 速度控制行走 (linear_x/y, angular_z) | ✅ |
| `move_joint` | 单关节运动 | ✅ |
| `move_joints` | 多关节同时运动 | ✅ |
| `stop_movement` | 停止运动，保持当前位置 | ✅ |
| `emergency_stop` | 紧急停止 | ✅ |
| `wave_hand` | 挥手（仅人形） | ❌ (A2 无臂) |

### MCP Resources 清单

| Resource URI | 功能 |
|-------------|------|
| `unitree://{robot_id}/status` | 电池、模式、关节状态 |
| `unitree://{robot_id}/joints` | 关节限制详情 |

### 安全机制
- 关节限制验证（每个关节有 min/max 值，发送前检查）
- 速度限制：linear_x ≤ 1.0 m/s, linear_y ≤ 0.5 m/s, angular_z ≤ 1.0 rad/s
- 紧急停止（emergency_stop = mode 0）
- 状态缓冲区 100 条（100Hz 更新）

### 当前状态：DDS 为 TODO
⚠️ **重要发现**：源码中 DDS 实际通信部分标记为 `TODO`！
- `_dds_listener` 方法目前返回模拟数据
- `publish_command` 方法中 `# TODO: Publish to /lowcmd topic via DDS`
- 这意味着 **当前版本是接口原型，不能直接控制实机**

**后续行动**：
1. 关注 ros-claw/unitree-sdk2-mcp 的更新
2. 可能需要自己实现 DDS bridge（基于 unitree_sdk2_python）
3. 或等待 ROSClaw 社区完善

## Hermes 集成架构

```
Hermes Agent
  ├── MCP Client
  │   ├── unitree-sdk2-mcp  → A2 硬件控制 (运动/传感器)
  │   ├── vector-os-nano-mcp → 导航/技能 (VGG)
  │   └── vector-graph-mcp   → 行为图可视化
  ├── Auto-Drive Idle Loop
  │   └── A2 health check via MCP (电池/温度/连接状态)
  └── Skills
      ├── abotclaw-* (VLAC loop)
      └── nav-dog-* (融合定位/导航)
```

## 落地步骤

1. **配置 Hermes MCP** → 添加 unitree-sdk2-mcp server（接口层就绪）
2. **等待 DDS bridge 完善** → 或自行基于 unitree_sdk2_python 实现
3. **仿真验证** → 用 Go2 Gazebo 仿真测试
4. **A2 实机** → 到货后切换目标机型
5. **与 Vector OS Nano 集成** → 双 MCP server 协同

## 待确认

- [ ] A2 的 GNSS 天线接口（README 未提及）
- [ ] A2 的 LiDAR 配置（标配/选配）
- [ ] DDS bridge 何时完善（需要 ros-claw 更新或自行实现）
- [ ] A2 续航 1.5h 对户外导航场景是否足够（可能需要 B2）
