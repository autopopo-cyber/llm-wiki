# ABot-Claw 深度分析

> 来源：https://github.com/amap-cvlab/ABot-Claw
> Stars: 116 | Forks: 8 | Language: Python | License: 无 | 更新: 2026-04-22
> 机构：AMAP CV Lab（高德地图计算机视觉实验室）

## 一句话

ABot-Claw 是基于 OpenClaw 的具身 AI 框架，通过 VLAC 闭环实现多机器人协作，直接支持 Unitree Go2 + G1。

## 核心架构：三层微服务

```
┌─────────────────────────────────────────────┐
│  Infrastructure Layer                        │
│  GPU Server: Yolo, Depth, VLA, Grasp, VLN   │
│  Robots: Dog, G1, PiPer, Cameras            │
└──────────────────┬──────────────────────────┘
                   │
┌──────────────────┴──────────────────────────┐
│  Runtime Core (Agent Runtime)                │
│  Gateway → Agent Loop (Context+Tools+Skills) │
│  Scheduler (Heartbeat/Cron) + Device         │
└──────────────────┬──────────────────────────┘
                   │
┌──────────────────┴──────────────────────────┐
│  Memory & Knowledge                          │
│  几何地图 + 语义地图 + 图像特征索引           │
│  视觉中心的共享记忆系统                       │
└─────────────────────────────────────────────┘
```

## 四大核心特性

### 1. VLAC 闭环（Vision-Language-Action-Critic）
- Agent 实时评估任务完成度
- 偏差时自动触发策略调整
- 长时间任务的鲁棒性保障

### 2. 端到端闭环交互
- VLA（Vision-Language-Action）+ WAM（World Action Model）
- 自然语言指令 → 感知 → 行动，全闭环
- 无需人工干预的多步任务执行

### 3. 多机器人协作 + 弹性架构
- 所有机器人共享一个 Agent Runtime
- 热插拔：机器人可随时加入/替换，不中断任务流
- 统一决策 + 分布式执行

### 4. 视觉中心记忆
- 几何地图（定位）+ 语义地图（理解）
- 图像特征 + GPS 索引
- 长上下文视觉历史，克服遮挡和延迟

## 与我们的关系

| ABot-Claw | 我们 | 兼容性 |
|-----------|------|--------|
| OpenClaw | Hermes | ✅ Hermes = OpenClaw 的下游 |
| VLAC 闭环 | Auto-Drive idle loop | 互补 — VLAC 管任务，idle loop 管生存 |
| 多机器人共享 Brain | 群控模块 hermes_swarm | ✅ 方向一致 |
| 视觉记忆 | Hindsight + wiki | 需要扩展 — 加入空间记忆 |
| Unitree Go2 + G1 | 我们的目标平台 | ✅ 直接兼容 |

## 复现路线图

### Phase 1：纯软件验证（云服务器，无机器人）
1. Clone ABot-Claw 仓库
2. 运行 `setup.sh --fresh` 配置 OpenClaw workspace
3. 部署服务端：SpatialMemory(8012), YOLO(8013), VLAC(8014), GraspAnything(8015)
4. 用仿真/录播数据验证 VLAC 闭环

### Phase 2：单机器人验证（A2 到货后）
1. 配置 Go2 agent server（ABot-Claw 直接支持）
2. 连接深度相机 + YOLO + VLN
3. 验证 VLA 指令 → 行动闭环

### Phase 3：多机器人协作（G1 到货后）
1. 配置 G1 agent server
2. 部署共享 Agent Runtime
3. 验证热插拔 + 协同任务

### Phase 4：融合 Auto-Drive
1. ABot-Claw 的 VLAC 作为任务层
2. Auto-Drive 的 idle loop 作为生存层
3. 两者通过 Hermes skill 体系集成

## 关键发现

1. **ABot-Claw 直接兼容 Hermes** — 它基于 OpenClaw，workspace 文件可以合并
2. **支持 Unitree Go2 + G1** — 正好是我们的平台
3. **VLAC = 任务层，Auto-Drive = 生存层** — 天然互补
4. **视觉记忆 = 空间理解** — 这是 Abot-Claw 的核心竞争力
5. **AMAP 出品** — 高德地图的 CV 实验室，地图和空间理解是强项

## 需要解决的问题

- 无 License — 法律风险，需联系作者确认
- 文档偏少 — 需要读代码理解细节
- 依赖 ROS — 本机需要 ROS 环境
- GPU 需求大 — YOLO + Depth + VLA 需要至少 RTX 3090
