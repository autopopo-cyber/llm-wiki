---
title: QDD 准直驱执行器
created: 2026-04-19
updated: 2026-04-19
type: concept
tags: [actuator, embedded]
sources: [raw/articles/quadruped-robots-review-2024.md, raw/articles/unitree-go2-review-2024.md]
---

# QDD 准直驱执行器

## 定义

Quasi-Direct-Drive (QDD) 准直驱执行器是现代四足机器人的核心硬件，采用低减速比（6:1~10:1）电机+减速器组合，兼具高扭矩密度和反向驱动能力。

## 技术演进

```
液压执行器 (BigDog, 2005)
  → 笨重、噪音大、效率低
  ↓
QDD 执行器 (MIT Cheetah, 2016+)
  → 低减速比、高扭矩密度、可反向驱动
  ↓
本体感知执行器 (Proprioceptive Actuator)
  → 低惯量 + 高扭矩 = 无需复杂力控制
```

## 核心优势

1. **反向驱动性 (Backdrivability)**: 低减速比使外力可以反向驱动关节，天然柔顺
2. **本体感知 (Proprioception)**: 通过电流检测关节力矩，无需外部力传感器
3. **高带宽**: 低惯量允许快速动态响应
4. **能量效率**: 比液压系统高数倍

## 典型参数

| 参数 | 典型值 |
|------|--------|
| 减速比 | 6:1 ~ 10:1 |
| 扭矩密度 | 10-30 Nm/kg |
| 带宽 | >20 Hz |
| 反向驱动力 | <5 Nm |

## 使用产品

- [[unitree-go2]] / [[unitree-a1]]: Unitree 自研 QDD
- [[spot]] (Boston Dynamics): 电动 QDD
- MIT Mini Cheetah: 开创性 QDD 设计

## 关联

- [[unitree]] — QDD 的主要商业推广者
- [[boston-dynamics]] — 从液压到电动的转型
- [[sim2real]] — QDD 的反向驱动性降低 sim2real 难度
- [[mpc-control]] — QDD 配合力控


---

## 相关链接

- [[unitree-go2.md|Unitree Go2（QDD执行器）]]
- [[quadruped-robots-comparison.md|四足机器人产品对比]]