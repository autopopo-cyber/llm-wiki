---
title: "Learning to Walk in Minutes: Massively Parallel Deep Reinforcement Learning for Quadruped Locomotion"
url: https://arxiv.org/abs/2309.07796
arxiv_id: "2309.07796"
authors: "Nikita Rudin, David Hoeller, Philipp Reist, Marco Hutter"
date: 2023-09-14
org: "ETH Zurich, ANYbotics"
---

# Learning to Walk in Minutes: Massively Parallel Deep RL for Quadruped Locomotion

## Abstract

We present a massively parallel deep reinforcement learning (DRL) approach for quadrupedal locomotion. Training is performed in a GPU-accelerated simulator Isaac Gym, which allows for thousands of simulated robots to learn in parallel. Our approach demonstrates the ability to learn quadrupedal locomotion policies in minutes rather than hours or days, achieving robust performance that can be deployed on real robots without additional fine-tuning.

## Key Contributions

1. **Massively Parallel Training**: Uses Isaac Gym for thousands of parallel environments on GPU
2. **Minutes-Level Training**: Reduces locomotion policy training from hours/days to <10 minutes
3. **Zero-Shot Sim2Real**: Successfully deploys trained policies on Unitree A1 without real-world fine-tuning
4. **Reward Design**: Reward formulation enabling rapid convergence and sim2real transfer
5. **Domain Randomization**: Bridges sim2real gap through systematic domain randomization

## Method

- Simulator: NVIDIA Isaac Gym (GPU-accelerated)
- Algorithm: PPO (Proximal Policy Optimization)
- Observation: body orientation, angular velocity, joint positions/velocities
- Action: joint position targets (12 DOF for quadruped)
- Domain randomization: friction, mass, joint offsets, control delays

## Results

- Training time: <10 minutes on single GPU
- Zero-shot transfer to Unitree A1 hardware
- Stable walking on flat ground, slopes, stairs
- Robust to external disturbances (pushes)
