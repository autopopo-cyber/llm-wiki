---
title: Octo
created: 2026-04-19
updated: 2026-04-19
type: concept
tags: [foundation-model, open-source]
sources: [raw/papers/octo-generalist-robot-policy-2024.md]
---

# Octo

## 定义

Octo 是 UC Berkeley/Stanford/CMU/Google 联合发布的开源通用机器人策略，基于 Transformer 架构，在 Open X-Embodiment 数据集的 800k 轨迹上训练。

## 核心架构

```
输入: 多模态观测（RGB/深度/本体感知）+ 指令（语言/目标图像）
  → 分模态 tokenizer
  → Transformer backbone（block-structured attention）
输出: 动作 chunk（diffusion action head）
```

## 模型变体

| 变体 | 参数量 | 适用场景 |
|------|--------|---------|
| Octo-Small | 27M | 快速实验/嵌入式 |
| Octo-Base | 93M | 标准研究 |

## 核心特点

1. **多模态指令**: 同时支持语言和目标图像
2. **灵活架构**: 处理不同传感器和动作空间
3. **9 平台验证**: 在 9 种机器人平台上测试
4. **快速微调**: 消费级 GPU 数小时即可适配新平台

## 与 OpenVLA 对比

| | Octo | OpenVLA |
|---|------|---------|
| 参数量 | 27M/93M | 7B |
| 训练数据 | 800k | 970k |
| 指令类型 | 语言+图像 | 仅语言 |
| 视觉编码 | 单模态 | DINOv2+SigLIP |
| 灵活性 | 多平台 | 单平台为主 |

## 关联

- [[openvla]] — 同领域开源 VLA
- [[rt2-vla]] — 闭源前身
- [[open-x-embodiment]] — 训练数据集
- [[stanford-ai-lab]] — 开发机构


---

## 相关链接

- [[rt2-vla.md|RT-2 VLA 模型]]
- [[open-x-embodiment.md|Open X-Embodiment 数据集]]
- [[stanford-ai-lab.md|Stanford AI Lab]]
- [[vla-models-comparison.md|VLA 模型对比]]