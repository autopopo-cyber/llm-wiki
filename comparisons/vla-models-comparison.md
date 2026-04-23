---
title: VLA 模型对比：RT-2 vs Octo vs OpenVLA
created: 2026-04-19
updated: 2026-04-19
type: comparison
tags: [comparison, foundation-model]
sources: [raw/papers/rt2-vision-language-action-2023.md, raw/papers/octo-generalist-robot-policy-2024.md, raw/papers/openvla-open-source-vla-2024.md]
---

# VLA 模型对比：RT-2 vs Octo vs OpenVLA

## 核心对比

| 维度 | RT-2 | Octo | OpenVLA |
|------|------|------|---------|
| **发布时间** | 2023.07 | 2024.05 | 2024.06 |
| **机构** | Google DeepMind | UCB/Stanford/CMU/Google | Stanford/UCB/Google/MIT |
| **参数量** | 5B/12B/56B | 27M/93M | 7B |
| **开源** | ❌ 闭源 | ✅ 开源 | ✅ 开源 |
| **训练数据** | ~13k episodes | 800k (OXE) | 970k (OXE) |
| **指令类型** | 语言 | 语言+目标图像 | 语言 |
| **视觉编码** | ViT (PaLI-X/PaLM-E) | 单模态 | DINOv2+SigLIP |
| **动作表示** | 文本 token (256 bins) | Diffusion action head | 文本 token (256 bins) |
| **LLM 骨干** | PaLI-X / PaLM-E | Transformer | Llama 2 |
| **机器人平台** | Google Robot | 9 种平台 | 多种平台 |
| **微调方式** | N/A | 标准微调 | LoRA + 量化 |

## 性能对比

| 指标 | RT-2 (56B) | Octo (93M) | OpenVLA (7B) |
|------|-----------|-----------|-------------|
| 通用操作成功率 | 基准 | 中等 | 最高 (超 RT-2-X 16.5%) |
| 新物体泛化 | 强 | 中等 | 强 |
| 消费级 GPU 微调 | ❌ | ✅ | ✅ (LoRA) |
| 多平台适应 | 单平台 | 9 平台 | 多平台 |

## 结论

1. **RT-2**: 开创了 VLA 范式，但闭源且计算成本高
2. **Octo**: 轻量开源方案，适合多平台快速实验
3. **OpenVLA**: 性价比最优，7B 参数超越 55B 闭源模型，推荐首选

## 关联

- [[rt2-vla]] | [[octo]] | [[openvla]]
- [[open-x-embodiment]] — 共同训练数据集


---

## 相关链接

- [[rt2-vla.md|RT-2 VLA 模型]]
- [[octo.md|Octo]]
- [[openvla.md|OpenVLA]]