---
title: "A Comprehensive Review of Quadruped Robots: Evolution, Challenges, and Future Directions"
url: https://www.mdpi.com/2076-3417/14/2/818
date: 2024-01-10
type: review
---

# A Comprehensive Review of Quadruped Robots

## Evolution Timeline

- **BigDog (2005)**: Boston Dynamics' hydraulic quadruped demonstrating rough-terrain mobility
- **Spot (2016)**: Electric actuator-based commercial quadruped
- **ANYmal (2016)**: Force-controllable actuators for industrial inspection
- **Unitree A1 (2019)**: Affordable quadruped for research and education
- **Unitree Go2 (2023)**: Consumer-oriented quadruped with AI integration

## Actuator Evolution

- **Hydraulic**: High power density but heavy, noisy, and inefficient (BigDog era)
- **QDD Actuators**: Low gear ratio (6:1 to 10:1) with high torque density, enabling proprioceptive sensing and backdrivability
- **Proprioceptive Actuator Design**: Low inertia + high torque density = robust dynamic behaviors without complex force control

## Control Algorithms

### Model-Based
- **Raibert's Foot Placement Heuristic**: Foundational approach for bounding/galloping
- **MPC (Model Predictive Control)**: Whole-body motion planning, solves optimization over receding horizon
- **WBC (Whole-Body Control)**: Combines MPC with full-body dynamics for joint-level commands

### Learning-Based
- **DRL (Deep Reinforcement Learning)**: PPO/SAC in Isaac Gym, domain randomization for sim2real
- **Imitation Learning**: Learning from demonstration to replicate expert behaviors
- **Sim2Real Transfer**: Domain randomization, system identification, adaptive control

### Gait Generation
- **Static Gait**: ≥3 feet on ground (crawl)
- **Dynamic Gait**: Trot (2 feet), pace, bound, gallop
- **Adaptive Gait**: Transitions based on terrain and speed

## Key Challenges

1. Sim-to-Real Gap
2. Energy Efficiency
3. Robustness to Disturbances
4. Autonomous Operation
5. Cost Reduction

## Future Directions

- Foundation models for robotics
- Soft actuators and compliant mechanisms
- Multi-robot coordination (swarm)
- LLM integration for task planning
- Standardized benchmarks
