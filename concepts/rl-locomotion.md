---
title: 强化学习运动控制
created: 2026-04-19
updated: 2026-04-19
type: concept
tags: [rl, control, quadruped, gait]
sources: [raw/papers/learning-to-walk-in-minutes-2023.md, raw/articles/quadruped-robots-review-2024.md]
---

# 强化学习运动控制

## 定义

使用深度强化学习（DRL）训练四足机器人运动策略，通常在仿真中训练后迁移到真实机器人。相比传统 MPC，DRL 可以学习更复杂的行为但可解释性更低。

## 主流算法

| 算法 | 类型 | 适用场景 |
|------|------|---------|
| PPO | On-policy | 最常用，稳定 |
| SAC | Off-policy | 样本效率高 |
| DDPG | Off-policy | 连续动作 |

## 训练流水线

```
Isaac Gym (GPU 并行仿真)
  → 数千并行环境
  → PPO 训练
  → Domain Randomization
  ↓
零样本 Sim2Real 迁移
  → Unitree A1/Go2 真机
```

## 奖励设计

典型运动控制奖励组成：
- **速度跟踪**: 沿指令速度行走
- **姿态稳定**: 保持身体水平
- **能量惩罚**: 减少能量消耗
- **关节限位**: 避免超限
- **步态风格**: 奖励自然步态模式

## 关联

- [[sim2real]] — 核心迁移技术
- [[domain-randomization]] — Sim2Real 的关键方法
- [[mpc-control]] — 替代/补充方案
- [[unitree-go2]] — DRL+MPC 混合控制


---

## 相关链接

- [[sim2real.md|Sim2Real 迁移学习]]
- [[domain-randomization.md|领域随机化]]
- [[Marathongo-深度技术分析.md|Marathongo深度分析（含RL策略缺失）]]
- [[unitree-go2.md|Unitree Go2（出厂RL运控）]]