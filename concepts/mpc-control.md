---
title: MPC 模型预测控制
created: 2026-04-19
updated: 2026-04-19
type: concept
tags: [control, planning]
sources: [raw/articles/quadruped-robots-review-2024.md]
---

# MPC 模型预测控制

## 定义

Model Predictive Control (MPC) 是四足机器人最常用的控制架构之一，通过在滚动时间窗口上求解优化问题来确定最优地面反力/关节力矩。

## 控制架构

```
MPC (全身运动规划)
  → 输出: 地面反力 / 质心轨迹
  ↓
WBC (Whole-Body Control)
  → 将 MPC 输出映射到关节力矩
  ↓
QDD 执行器
  → 执行关节力矩
```

## 核心方法

1. **Raibert 足迹启发式**: Bounding/Galloping 的奠基方法
2. **凸优化 MPC**: 将非凸优化放松为凸问题，实时求解
3. **WBC**: 全身动力学求解关节级指令

## 优势

- 可以显式处理约束（关节极限、摩擦锥）
- 前馈+反馈一体化
- 对模型精度要求适中

## 局限

- 计算延迟限制控制频率
- 对模型误差敏感
- 难以处理高度非线性行为

## 使用产品

- [[spot]] (Boston Dynamics): 核心 MPC 架构
- [[unitree-go2]]: MPC + DRL 混合控制
- [[anymal]]: MPC + WBC 架构

## 关联

- [[sim2real]] — MPC 的模型依赖使其 sim2real 迁移更复杂
- [[qdd-actuator]] — QDD 的力控能力与 MPC 互补
- [[rl-locomotion]] — 替代/补充方案


---

## 相关链接

- [[rl-locomotion.md|强化学习运动控制（替代MPC）]]
- [[Marathongo-深度技术分析.md|Marathongo深度分析（MPC已废弃）]]