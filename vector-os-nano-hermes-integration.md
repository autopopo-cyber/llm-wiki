# Vector OS Nano + Hermes MCP 集成研究

**Date**: 2026-04-24 (03:10)
**Status**: ⏳调研完成，待集成验证
**Context**: NAV_DOG pending task — Vector OS Nano + Hermes MCP 集成验证

## 项目概况

| 属性 | 值 |
|------|-----|
| 名称 | Vector OS Nano |
| 组织 | VectorRobotics (CMU Robotics Institute) |
| Stars | 135 |
| License | MIT |
| Language | Python 3.10+ |
| 推送日期 | 2026-04-21 |
| URL | https://github.com/VectorRobotics/vector-os-nano |

**核心定位**: Cross-embodiment robot OS — natural language control, industrial-grade navigation, sim-to-real. No training. No fine-tuning. Just say what you want.

## 🔑 核心发现

### 1. 原生 MCP Server ✅
Vector OS Nano **自带 MCP server** (`vector-os-mcp`)！无需自行开发 MCP 桥接。

```bash
vector-os-mcp --sim --stdio          # MuJoCo 仿真，stdio 传输
vector-os-mcp --hardware --stdio     # 真实硬件
vector-os-mcp --sim                  # SSE 模式 (:8100)
```

**MCP Tools**: 全部 22 个 skills + natural_language + run_goal + diagnostics + debug_perception
**MCP Resources**: world://state, world://objects, world://robot, camera://overhead, camera://front, camera://side, camera://live

### 2. VGG 认知层（Verified Goal Graph）
这是 Vector OS 的"大脑"——类似于 ABot-Claw 的 VLAC 循环，但更结构化：

```
User input
  ├── Action → VGG (Verified Goal Graph)
  │     ├── Simple (skill match) → 1-step GoalTree (no LLM, <1ms)
  │     └── Complex (multi-step) → LLM decomposition → GoalTree
  │           VGG Harness: 3-layer feedback loop
  │             Layer 1: step retry (alt strategies)
  │             Layer 2: continue past failure
  │             Layer 3: re-plan with failure context
  └── Conversation → tool_use (LLM direct)
```

**30 primitives**: locomotion (8), navigation (5), perception (6), world (11)

### 3. Go2 Navigation Stack（可直接复用）
```
TARE (frontier exploration)
  → FAR V-Graph (global visibility-graph routing)
    → localPlanner (terrain-aware obstacle avoidance)
      → pathFollower → Go2 MPC (1kHz control)
```

**Sim-to-real**: 导航栈与真实 Unitree Go2 完全相同，只需更换 bridge node。

### 4. SkillFlow 声明式路由
```python
@skill(
    aliases=["grab", "grasp", "抓", "拿"],
    direct=False,
    auto_steps=["scan", "detect", "pick"],
)
class PickSkill:
    name = "pick"
    preconditions = ["gripper_empty"]
    postconditions = ["gripper_holding_any"]
```

## 与 Hermes 集成架构

### 双 MCP Server 架构

```
Hermes Agent
  ├── MCP Client
  │   ├── vector-os-mcp          → 机器人控制 (VGG + 22 skills + navigation)
  │   ├── unitree-sdk2-mcp       → 底层硬件控制 (DDS → joints/movement)
  │   ├── moling                 → 浏览器/文件系统/命令执行
  │   └── [future] vector-graph-mcp → 行为图可视化
  ├── Auto-Drive Idle Loop
  │   ├── Health check: vector-os-mcp world://robot → battery/mode
  │   ├── Navigation: vector-os-mcp navigate skill
  │   └── Explore: vector-os-mcp explore skill
  └── VGG ↔ Auto-Drive 协同
      ├── VGG = 任务层 (goal decompose → verify → retry)
      ├── Auto-Drive = 生存层 (health → capability → knowledge)
      └── Hermes = 桥接层 (tools + memory + scheduling)
```

### VGG vs VLAC 对比

| 维度 | VGG (Vector OS) | VLAC (ABot-Claw) |
|------|-----------------|------------------|
| 语言控制 | ✅ 原生 (natural language) | ✅ 原生 |
| 任务分解 | LLM → GoalTree | LLM → task chain |
| 验证循环 | 3-layer (retry/continue/replan) | Critic layer |
| 空间记忆 | Scene graph (rooms/doors/objects) | Visual shared memory |
| MCP 集成 | ✅ 原生 MCP server | ❌ 需自行开发 |
| 代码质量 | MIT, Python, clean arch | 学术原型 |
| 导航栈 | ✅ 完整 (TARE + V-Graph + MPC) | ✅ ROS2-based |
| 多机器人 | 单机器人为主 | ✅ hot-plug |

**结论**: Vector OS Nano > ABot-Claw 对于 Hermes 集成（原生 MCP + 更干净的代码）。ABot-Claw 的多机器人 hot-plug 在第二阶段仍有价值。

## 集成步骤

### Phase 1: 仿真验证（1-2 周，云端服务器）
1. Clone vector-os-nano + 安装依赖（Python 3.10+, MuJoCo）
2. 配置 Hermes MCP config 添加 vector-os-mcp server
3. 测试 `vector-os-mcp --sim --stdio` 通过 Hermes 调用
4. 验证 VGG：让 Hermes 通过 MCP 执行 navigate/explore
5. 基准测试：导航成功率、任务完成时间

### Phase 2: 实机 Go2（A2 到货后）
1. 切换 `vector-os-mcp --hardware --stdio`
2. 配置 ROS2 bridge (go2_vnav_bridge.py)
3. 安装 Vector Navigation Stack
4. 场地测试：室内导航 + 探索

### Phase 3: 多机协同
1. 集成 unitree-sdk2-mcp（底层 DDS 控制）
2. 多机器人场景：Go2 + G1 或 Go2 + A2
3. 参考 ABot-Claw 的 multi-robot hot-plug 模式

## 依赖项

| 依赖 | 版本 | 用途 |
|------|------|------|
| Python | 3.10+ | 运行时 |
| MuJoCo | 3.6 | 仿真 |
| ROS2 | Jazzy | 导航栈 |
| Anthropic API | - | LLM backend（可用 OpenRouter 替代） |
| Livox MID360 | - | LiDAR（实机） |
| Intel RealSense D405 | - | 视觉（arm 场景） |

## 风险与注意

1. **MuJoCo 许可证**: 个人免费，商业需许可证
2. **ROS2 Jazzy**: 需要 Ubuntu 24.04，服务器是 22.04 → 需要升级或 Docker
3. **LLM 成本**: VGG 的 3-layer retry 可能产生大量 API 调用 → 建议用 local LLM 做简单分解
4. **A2 vs Go2**: Vector OS 默认配置为 Go2，A2 支持 unitree-sdk2-mcp 但 Vector OS skill 可能需要适配
5. **ROS2 依赖**: 完整导航栈需要 ROS2 Jazzy，但基础 skills (walk, turn, stand) 不需要

## 下一步

- [ ] 安装 vector-os-nano 到云服务器（MuJoCo sim 模式）
- [ ] 配置 Hermes MCP → vector-os-mcp
- [ ] 端到端测试：Hermes → MCP → VectorEngine → Go2 sim
- [ ] 对比 Vector OS VGG vs ABot-Claw VLAC 的实际表现
