---
title: "RT-2: Vision-Language-Action Models Transfer Web Knowledge to Robotic Control"
url: https://arxiv.org/abs/2307.15818
arxiv_id: "2307.15818"
authors: "Anthony Brohan, Noah Brown, Justice Carbajal, Yevgen Chebotar, Xi Chen, Krzysztof Choromanski, Tianli Ding, Danny Driess, Avinava Dubey, Chelsea Finn, Pete Florence, Chuyuan Fu, Montse Gonzalez Arenas, Keerthana Gopalakrishnan, Kehang Han, Karol Hausman, Alexander Herzog, Jasmine Hsu, Brian Ichter, Alex Irpan, Nikhil Joshi, Ryan Julian, Dmitry Kalashnikov, Yuheng Kuang, Isabel Leal, Lisa Lee, Tsang-Wei Edward Lee, Sergey Levine, Yao Lu, Henryk Michalewski, Igor Mordatch, Karl Pertsch, Kanishka Rao, Krista Reymann, Michael Ryoo, Grecia Salazar, Pannag Sanketi, Pierre Sermanet, Jaspiar Singh, Anikait Singh, Radu Soricut, Huong Tran, Vincent Vanhoucke, Quan Vuong, Ayzaan Wahid, Stefan Welker"
date: 2023-07-28
org: Google DeepMind
---

# RT-2: Vision-Language-Action Models Transfer Web Knowledge to Robotic Control

## Abstract

We study how vision-language models trained on Internet-scale data can be incorporated directly into end-to-end robotic control to boost generalization and enable emergent semantic reasoning. Our goal is to enable a single end-to-end trained model to both learn to map robot observations to actions and enjoy the benefits of large-scale pretraining on language and vision-language data from the web. To this end, we propose to co-fine-tune state-of-the-art vision-language models on both robotic trajectory data and Internet-scale vision-language tasks, such as visual question answering. In contrast to other approaches, we propose a simple, general recipe to achieve this goal: in order to fit both natural language responses and robotic actions into the same format, we express the actions as text tokens and incorporate them directly into the training set of the model in the same way as natural language tokens. We refer to such category of models as vision-language-action models (VLA) and instantiate an example of such a model, which we call RT-2. Our extensive evaluation (6k evaluation trials) shows that our approach leads to performant robotic policies and enables RT-2 to obtain a range of emergent capabilities from Internet-scale training. This includes significantly improved generalization to novel objects, the ability to interpret commands not present in the robot training data (such as placing an object onto a particular number or icon), and the ability to perform rudimentary reasoning in response to user commands (such as picking up the smallest or largest object, or the one closest to another object). We further show that incorporating chain of thought reasoning allows RT-2 to perform multi-stage semantic reasoning, for example figuring out which object to pick up for use as an improvised hammer (a rock), or which type of drink is best suited for someone who is tired (an energy drink).

## Key Contributions

1. **VLA Architecture**: Proposes representing robot actions as text tokens, enabling a single model to process language and generate actions
2. **Co-fine-tuning Recipe**: Trains VLMs on both robotic trajectory data and web-scale VLM tasks simultaneously
3. **Emergent Capabilities**: RT-2 demonstrates semantic reasoning (chain-of-thought), novel object generalization, and interpretation of unseen commands
4. **Web Knowledge Transfer**: Internet-scale pretraining enables robots to understand concepts never seen in robot training data
5. **6K Evaluation Trials**: Largest evaluation of VLA models at time of publication

## Model Variants

- RT-2 Palmm-E (5B params) — based on PaLI-X
- RT-2 Palmm (12B params) — based on PaLI-X  
- RT-2 PaLM-E (56B params) — based on PaLM-E

## Architecture

RT-2 takes camera images + language instruction as input, outputs 7-DOF action tokens as text. The model processes visual observations through a Vision Transformer, tokenizes actions into 256 discrete bins per dimension, and generates action tokens autoregressively like language tokens.

## Training Data

- Robot data: ~13k episodes from 13 robots (Google Robot platform)
- VLM pretraining: Internet-scale vision-language data
- Co-fine-tuning: Both datasets mixed during training

## Key Results

- 3x improvement on unseen object generalization vs RT-1
- Can follow commands using semantic understanding (e.g., "pick up the object closest to the blue cube")
- Chain-of-thought enables multi-step reasoning for tool use
