---
title: 宇树科技 Unitree
created: 2026-04-19
updated: 2026-04-19
type: entity
tags: [company, product, quadruped, open-source]
sources: [raw/articles/unitree-go2-review-2024.md, raw/papers/learning-to-walk-in-minutes-2023.md]
---

# 宇树科技 Unitree

## 概述

宇树科技（Unitree Robotics）是中国四足机器人领域最具代表性的公司，以高性价比的四足机器人产品闻名。从 Laikago 到 Go2，Unitree 推动四足机器人从实验室走向消费市场。

## 产品线

| 产品 | 年份 | 定位 | 特点 |
|------|------|------|------|
| Laikago | 2017 | 研究 | 第一代开源四足 |
| A1 | 2019 | 教育/研究 | 低成本，广泛用于 DRL 研究 |
| Go1 | 2021 | 消费/教育 | 更轻更便宜 |
| Go2 | 2023 | 消费/开发 | 4D LiDAR + 大模型 |
| B1 | 2022 | 工业 | 工业巡检 |
| B2 | 2023 | 工业 | 增强版工业四足 |
| H1/H1-2 | 2023-2024 | 人形 | 全尺寸人形机器人 |
| G1 | 2024 | 人形 | 通用型人形 |

## 核心技术

- **QDD 执行器**: 准直驱电机，低减速比（6:1~10:1），高扭矩密度，支持本体感知和反向驱动
- **MPC 控制**: 模型预测控制用于全身运动规划
- **Sim2Real**: 通过 Isaac Gym 仿真训练 + 领域随机化实现零样本迁移
- **大模型集成**: Go2 系列集成 LLM，支持自然语言指令和任务规划

## 开发生态

- Unitree SDK（C++/Python）
- ROS/ROS2 完整支持
- Isaac Gym / MuJoCo 仿真环境
- 开源运动控制策略

## 关联

- [[unitree-go2]] — 核心消费级产品
- [[unitree-a1]] — 广泛用于学术研究的平台
- [[qdd-actuator]] — 核心硬件技术
- [[mpc-control]] — 核心控制方法
- [[sim2real]] — 训练到部署的关键技术
- [[boston-dynamics]] — 主要竞争对手


---

## 相关链接

- [[unitree-go2.md|Unitree Go2]]
- [[quadruped-robots-comparison.md|四足机器人产品对比]]