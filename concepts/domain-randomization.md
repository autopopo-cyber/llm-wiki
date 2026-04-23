---
title: 领域随机化 Domain Randomization
created: 2026-04-19
updated: 2026-04-19
type: concept
tags: [rl, simulation]
sources: [raw/papers/learning-to-walk-in-minutes-2023.md]
---

# 领域随机化 Domain Randomization

## 定义

领域随机化是在仿真训练中随机化物理/环境参数，使学习到的策略对现实世界的不确定性具有鲁棒性，是 Sim2Real 迁移的核心技术。

## 随机化参数

| 类别 | 参数 |
|------|------|
| 动力学 | 摩擦系数、质量、转动惯量 |
| 关节 | 关节偏移、阻尼、刚度 |
| 控制 | 控制延迟、PD 增益 |
| 环境 | 地形高度、坡度、障碍 |
| 传感器 | IMU 噪声、编码器噪声 |

## 设计原则

1. **覆盖真实参数范围**: 随机化范围应包含真实值
2. **渐进式扩大**: 从窄范围开始逐步扩大
3. **关键参数优先**: 对策略影响大的参数优先随机化
4. **自动调参**: 可以用贝叶斯优化自动调整随机化范围

## 关联

- [[sim2real]] — 领域随机化服务的目标
- [[rl-locomotion]] — 主要应用场景
- [[eth-zurich-robotics]] — 系统性方法论贡献


---

## 相关链接

- [[rl-locomotion.md|强化学习运动控制]]
- [[sim2real.md|Sim2Real 迁移学习]]