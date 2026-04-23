---
title: "OpenVLA: An Open-Source Vision-Language-Action Model"
url: https://arxiv.org/abs/2406.09246
arxiv_id: "2406.09246"
authors: "Moo Jin Kim, Karl Pertsch, Siddharth Karamcheti, Ted Xiao, Ashwin Balakrishna, Suraj Nair, Rafael Rafailov, Ethan Foster, Grace Lam, Pannag Sanketi, Quan Vuong, Thomas Kollar, Benjamin Burchfiel, Russ Tedrake, Dorsa Sadigh, Sergey Levine, Percy Liang, Chelsea Finn"
date: 2024-06-13
org: "Stanford, UC Berkeley, Google DeepMind, MIT, Toyota Research"
---

# OpenVLA: An Open-Source Vision-Language-Action Model

## Abstract

Large policies pretrained on a combination of Internet-scale vision-language data and diverse robot demonstrations have the potential to change how we teach robots new skills: rather than training new behaviors from scratch, we can fine-tune such vision-language-action (VLA) models to obtain robust, generalizable policies for visuomotor control. Yet, widespread adoption of VLAs for robotics has been challenging as 1) existing VLAs are largely closed and inaccessible to the public, and 2) prior work fails to explore methods for efficiently fine-tuning VLAs for new tasks, a key component for adoption. Addressing these challenges, we introduce OpenVLA, a 7B-parameter open-source VLA trained on a diverse collection of 970k real-world robot demonstrations. OpenVLA builds on a Llama 2 language model combined with a visual encoder that fuses pretrained features from DINOv2 and SigLIP. As a product of the added data diversity and new model components, OpenVLA demonstrates strong results for generalist manipulation, outperforming closed models such as RT-2-X (55B) by 16.5% in absolute task success rate across 29 tasks and multiple robot embodiments, with 7x fewer parameters. We further show that we can effectively fine-tune OpenVLA for new settings, with especially strong generalization results in multi-task environments involving multiple objects and strong language grounding abilities, and outperform expressive from-scratch imitation learning methods such as Diffusion Policy by 20.4%. We also explore compute efficiency; as a separate contribution, we show that OpenVLA can be fine-tuned on consumer GPUs via modern low-rank adaptation methods and served efficiently via quantization without a hit to downstream success rate. Finally, we release model checkpoints, fine-tuning notebooks, and our PyTorch codebase with built-in support for training VLAs at scale on Open X-Embodiment datasets.

## Key Contributions

1. **7B Open-Source VLA**: First large-scale open VLA model with released weights and training code
2. **Outperforms RT-2-X (55B)**: 16.5% higher success rate with 7x fewer parameters
3. **DINOv2 + SigLIP Vision**: Fused visual encoder provides richer visual representations
4. **Efficient Finetuning**: LoRA on consumer GPUs, quantization for efficient serving
5. **970K Demonstrations**: Trained on Open X-Embodiment dataset (larger than Octo's subset)

## Architecture

- Base LLM: Llama 2 (7B)
- Vision Encoder: DINOv2 + SigLIP (fused features via projection)
- Action Head: Autoregressive token generation (7-DOF, 256 bins per dim)
- Input: RGB image (256x256) + language instruction
- Output: 7-DOF action vector (gripper + 6-DOF pose delta)

## Training Data

- Open X-Embodiment: 970k trajectories across multiple robot platforms
- Internet-scale VLM pretraining (inherited from Llama 2)

## Key Results

- 16.5% improvement over RT-2-X (55B) on 29-task benchmark
- 20.4% improvement over Diffusion Policy (from-scratch IL)
- LoRA finetuning preserves performance while reducing trainable params by 10x
- INT4 quantization enables serving on consumer GPUs without quality loss
