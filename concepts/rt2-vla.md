---
title: RT-2 VLA 模型
created: 2026-04-19
updated: 2026-04-19
type: concept
tags: [foundation-model, end2end]
sources: [raw/papers/rt2-vision-language-action-2023.md]
---

# RT-2 VLA 模型

## 定义

RT-2（Robotic Transformer 2）是 Google DeepMind 提出的视觉-语言-动作（VLA）模型，首次将大规模预训练的视觉语言模型与机器人控制端到端结合。

## 核心创新

将机器人动作表示为文本 token，使单个模型同时处理语言理解和动作生成：

```
输入: 图像 + 语言指令
  → ViT 视觉编码
  → LLM 处理
输出: 7-DOF 动作 token（每维度 256 个离散 bin）
```

## 涌现能力

1. **语义推理**: 能理解"最小的物体""离蓝色方块最近的物体"
2. **链式思维**: 多步推理，如"找临时锤子→选石头"
3. **泛化到新物体**: 未见过的物体上成功率提升 3 倍

## 模型变体

| 变体 | 基座模型 | 参数量 |
|------|---------|--------|
| RT-2 Palmm-E | PaLI-X | 5B |
| RT-2 Palmm | PaLI-X | 12B |
| RT-2 PaLM-E | PaLM-E | 56B |

## 局限

- 闭源，不可复现
- 推理延迟高（56B 模型）
- 仅在 Google Robot 平台验证

## 关联

- [[openvla]] — 开源替代，7B 超越 55B
- [[octo]] — 另一个开源方案
- [[google-deepmind]] — 开发机构
- [[open-x-embodiment]] — 训练数据集


---

## 相关链接

- [[openvla.md|OpenVLA（开源替代）]]
- [[open-x-embodiment.md|Open X-Embodiment 数据集]]
- [[google-deepmind.md|Google DeepMind]]
- [[vla-models-comparison.md|VLA 模型对比]]