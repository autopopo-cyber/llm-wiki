---
title: Sim2Real 迁移学习
created: 2026-04-19
updated: 2026-04-19
type: concept
tags: [rl, simulation]
sources: [raw/papers/learning-to-walk-in-minutes-2023.md, raw/articles/quadruped-robots-review-2024.md]
---

# Sim2Real 迁移学习

## 定义

Sim2Real（Simulation to Reality）是指在仿真环境中训练机器人策略，然后迁移到真实机器人上执行的技术。这是当前具身智能最核心的工程挑战之一。

## 核心方法

### 1. 领域随机化 (Domain Randomization)
在仿真中随机化物理参数，使策略对现实不确定性具有鲁棒性：
- 摩擦系数、质量、关节偏移
- 控制延迟、传感器噪声
- 地形参数、光照条件

### 2. 系统辨识 (System Identification)
精确测量真实机器人参数，缩小仿真与现实差距。

### 3. 自适应控制 (Adaptive Control)
在真实机器人上微调预训练策略。

## 成功案例

- **Learning to Walk in Minutes**: 在 Isaac Gym 训练 <10 分钟，零样本迁移到 Unitree A1
- **ANYmal**: 系统性领域随机化 + 自适应微调
- **Unitree Go2**: MPC + DRL 混合，仿真训练→实体部署

## 关键工具

| 工具 | 特点 | 适用场景 |
|------|------|---------|
| Isaac Gym | GPU 并行，数千环境 | 大规模 DRL 训练 |
| MuJoCo | 高精度物理 | 精确仿真 |
| PyBullet | 轻量级 | 快速原型 |
| Gazebo | ROS 集成 | 导航/感知仿真 |

## 核心挑战

1. **现实差距**: 仿真无法完美模拟物理世界
2. **延迟差异**: 仿真忽略通信/计算延迟
3. **传感器噪声**: 现实传感器有噪声和漂移
4. **地形复杂性**: 复杂地形难以精确仿真

## 关联

- [[domain-randomization]] — 核心方法
- [[qdd-actuator]] — 硬件设计降低 sim2real 难度
- [[mpc-control]] — 模型方法减少迁移依赖
- [[unitree-go2]] — 典型应用


---

## 相关链接

- [[rl-locomotion.md|强化学习运动控制]]
- [[domain-randomization.md|领域随机化]]