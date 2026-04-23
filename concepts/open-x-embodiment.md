---
title: Open X-Embodiment 数据集
created: 2026-04-19
updated: 2026-04-19
type: concept
tags: [open-source, benchmark]
sources: [raw/papers/rt2-vision-language-action-2023.md, raw/papers/octo-generalist-robot-policy-2024.md, raw/papers/openvla-open-source-vla-2024.md]
---

# Open X-Embodiment 数据集

## 定义

Open X-Embodiment (OXE) 是 Google DeepMind 发起的最大开源机器人操作数据集，汇集了全球 20+ 机构的数据，是 Octo 和 OpenVLA 的训练基础。

## 数据规模

- **总轨迹数**: 800k-970k+（不同子集）
- **机器人平台**: 20+ 种
- **任务类型**: 抓取、放置、桌面整理、厨房任务等
- **机构**: Google, Stanford, UC Berkeley, CMU, Toyota 等

## 核心价值

1. **跨实体学习**: 单一模型可从多种机器人的数据中学习
2. **开源开放**: 降低机器人学习研究门槛
3. **标准化基准**: 提供统一的评估协议

## 使用该数据集的模型

- [[rt2-vla]] — RT-2-X 使用了扩展版 OXE
- [[octo]] — 800k 轨迹
- [[openvla]] — 970k 轨迹

## 关联

- [[google-deepmind]] — 发起方
- [[stanford-ai-lab]] — 主要贡献方


---

## 相关链接

- [[rt2-vla.md|RT-2 VLA 模型]]
- [[openvla.md|OpenVLA]]
- [[octo.md|Octo]]
- [[google-deepmind.md|Google DeepMind]]