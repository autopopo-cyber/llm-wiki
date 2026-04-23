---
title: Unitree Go2
created: 2026-04-19
updated: 2026-04-19
type: entity
tags: [product, quadruped]
sources: [raw/articles/unitree-go2-review-2024.md]
---

# Unitree Go2

## 概述

Unitree Go2 是宇树科技 2023 年推出的消费级四足机器人，以高性价比和 AI 集成为核心卖点，标志着四足机器人从实验室走向消费市场。

## 硬件规格

| 参数 | 规格 |
|------|------|
| 主控 | Nvidia Jetson Orin NX |
| 激光雷达 | 4D LiDAR, 360°×90°, 100m |
| 摄像头 | 广角 + 深度 |
| 电池 | 8000mAh, 续航 2-4h |
| 最大速度 | 3-5 m/s |
| 最大负载 | 3-5 kg |
| 自由度 | 12 (3×4 legs) |

## 版本

- **Go2 Air**: 入门级，教育/爱好者
- **Go2 Pro**: 中端，开发者/研究
- **Go2 Edu**: 高端，科研/工业
- **Go2 Max**: 旗舰，专业应用

## 核心技术亮点

1. **LLM 集成**: 内置 GPT 等大模型，自然语言理解和任务规划
2. **4D LiDAR 避障**: 360° 感知 + 实时避障
3. **MPC + DRL 混合控制**: 模型预测控制与深度强化学习结合
4. **完整 SDK**: C++/Python, ROS/ROS2, Isaac Gym/MuJoCo

## 关联

- [[unitree]] — 制造商
- [[unitree-a1]] — 前代产品
- [[qdd-actuator]] — 执行器技术
- [[mpc-control]] — 控制方法
- [[sim2real]] — 部署方法


---

## 相关链接

- [[unitree.md|宇树科技 Unitree]]
- [[Marathongo-深度技术分析.md|Marathongo深度分析（四足适配目标）]]
- [[rl-locomotion.md|强化学习运动控制（Go2出厂运控）]]
- [[quadruped-robots-comparison.md|四足机器人产品对比]]