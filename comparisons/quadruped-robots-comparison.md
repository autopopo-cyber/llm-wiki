---
title: 四足机器人产品对比
created: 2026-04-19
updated: 2026-04-19
type: comparison
tags: [comparison, quadruped]
sources: [raw/articles/quadruped-robots-review-2024.md, raw/articles/unitree-go2-review-2024.md]
---

# 四足机器人产品对比

## 主流四足机器人

| 维度 | Spot | ANYmal | Unitree Go2 | Unitree A1 |
|------|------|--------|-------------|------------|
| **公司** | Boston Dynamics | ANYbotics | Unitree | Unitree |
| **执行器** | 电动 QDD | SEA | QDD | QDD |
| **价格区间** | $74,500+ | $100,000+ | $1,600+ | $2,500+ |
| **定位** | 商用工业 | 工业巡检 | 消费/开发 | 教育/研究 |
| **自由度** | 12 | 12 | 12 | 12 |
| **负载** | 14 kg | 10 kg | 3-5 kg | 5 kg |
| **续航** | 90 min | 2-3h | 2-4h | 2h |
| **防护等级** | IP54 | IP67/Ex | 无 | 无 |
| **AI 能力** | 自主导航 | 自主巡检 | LLM 集成 | DRL 研究 |
| **ROS 支持** | ✅ | ✅ | ✅ | ✅ |
| **开源策略** | SDK | SDK | SDK + 开源策略 | SDK + 开源策略 |

## 执行器对比

| 类型 | 液压 | QDD | SEA |
|------|------|-----|-----|
| **功率密度** | 高 | 中高 | 中 |
| **效率** | 低 | 高 | 高 |
| **噪音** | 大 | 小 | 小 |
| **反向驱动** | 难 | 容易 | 弹性 |
| **力控** | 需传感器 | 本体感知 | 弹性感知 |
| **代表** | BigDog | Spot/Go2 | ANYmal |

## 关联

- [[boston-dynamics]] | [[unitree]] | [[eth-zurich-robotics]]
- [[qdd-actuator]] — 核心硬件技术
- [[mpc-control]] — 通用控制方法


---

## 相关链接

- [[unitree-go2.md|Unitree Go2]]
- [[anymal.md|ANYmal]]
- [[boston-dynamics.md|Boston Dynamics]]
- [[qdd-actuator.md|QDD 准直驱执行器]]