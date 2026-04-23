---
title: OpenVLA
created: 2026-04-19
updated: 2026-04-19
type: concept
tags: [foundation-model, open-source]
sources: [raw/papers/openvla-open-source-vla-2024.md]
---

# OpenVLA

## 定义

OpenVLA 是 Stanford/UC Berkeley/Google 发布的 7B 参数开源 VLA 模型，在 970k 真实机器人演示上训练，首次证明开源 VLA 可以超越闭源方案。

## 核心架构

```
输入: RGB 图像 (256×256) + 语言指令
  → DINOv2 + SigLIP 双视觉编码器（融合特征）
  → Llama 2 (7B) 语言模型骨干
输出: 7-DOF 动作向量 (gripper + 6-DOF 位姿增量)
```

## 关键结果

- **超越 RT-2-X (55B)**: 29 任务上高 16.5%，参数仅 1/7
- **超越 Diffusion Policy**: 高 20.4%
- **LoRA 微调**: 消费级 GPU 可训练
- **INT4 量化**: 推理无精度损失

## 训练数据

- Open X-Embodiment: 970k 真实机器人轨迹
- Internet-scale VLM 预训练（继承自 Llama 2）

## 为什么重要

1. **开源**: 权重 + 训练代码 + 微调笔记本全部开放
2. **高效**: 7B > 55B，证明了模型效率的重要性
3. **实用**: LoRA + 量化使消费级硬件可用

## 关联

- [[rt2-vla]] — 闭源前身
- [[octo]] — 同期开源方案（更小模型，更广平台）
- [[open-x-embodiment]] — 训练数据集
- [[stanford-ai-lab]] — 主要开发机构


---

## 相关链接

- [[rt2-vla.md|RT-2 VLA 模型]]
- [[open-x-embodiment.md|Open X-Embodiment 数据集]]
- [[stanford-ai-lab.md|Stanford AI Lab]]
- [[vla-models-comparison.md|VLA 模型对比]]