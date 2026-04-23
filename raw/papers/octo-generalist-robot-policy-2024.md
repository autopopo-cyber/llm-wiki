---
title: "Octo: An Open-Source Generalist Robot Policy"
url: https://arxiv.org/abs/2405.12213
arxiv_id: "2405.12213"
authors: "Octo Model Team, Dibya Ghosh, Homer Walke, Karl Pertsch, Kevin Black, Oier Mees, Sudeep Dasari, Joey Hejna, Tobias Kreiman, Charles Xu, Jianlan Luo, You Liang Tan, Lawrence Yunliang Chen, Pannag Sanketi, Quan Vuong, Ted Xiao, Dorsa Sadigh, Chelsea Finn, Sergey Levine"
date: 2024-05-20
org: "UC Berkeley, Stanford, CMU, Google"
---

# Octo: An Open-Source Generalist Robot Policy

## Abstract

Large policies pretrained on diverse robot datasets have the potential to transform robotic learning: instead of training new policies from scratch, such generalist robot policies may be finetuned with only a little in-domain data, yet generalize broadly. However, to be widely applicable across a range of robotic learning scenarios, environments, and tasks, such policies need to handle diverse sensors and action spaces, accommodate a variety of commonly used robotic platforms, and finetune readily and efficiently to new domains. In this work, we aim to lay the groundwork for developing open-source, widely applicable, generalist policies for robotic manipulation. As a first step, we introduce Octo, a large transformer-based policy trained on 800k trajectories from the Open X-Embodiment dataset, the largest robot manipulation dataset to date. It can be instructed via language commands or goal images and can be effectively finetuned to robot setups with new sensory inputs and action spaces within a few hours on standard consumer GPUs. In experiments across 9 robotic platforms, we demonstrate that Octo serves as a versatile policy initialization that can be effectively finetuned to new observation and action spaces. We also perform detailed ablations of design decisions for the Octo model, from architecture to training data, to guide future research on building generalist robot models.

## Key Contributions

1. **Open-Source Generalist Policy**: First large-scale open-source generalist robot policy for manipulation
2. **800K Training Trajectories**: Trained on Open X-Embodiment dataset — largest robot manipulation dataset
3. **Multi-Modal Instructions**: Supports both language commands and goal images
4. **Flexible Architecture**: Handles diverse sensors, action spaces, and robot platforms
5. **Efficient Finetuning**: Can adapt to new setups in hours on consumer GPUs

## Architecture

- Transformer-based policy with block-structured attention
- Separate tokenizers for different observation modalities (RGB, depth, proprioception)
- Action chunking with diffusion action head
- Two model sizes: Octo-Small (27M) and Octo-Base (93M)

## Training Data

- Open X-Embodiment dataset: 800k trajectories from 24 robot setups
- Diverse manipulation tasks: pick-place, table organization, kitchen tasks, etc.

## Evaluation

- Tested across 9 robotic platforms (WidowX, Franka, etc.)
- Outperforms single-embodiment policies on multi-task evaluation
- Effective zero-shot and few-shot finetuning on new platforms
