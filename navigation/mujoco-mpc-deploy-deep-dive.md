# MuJoCo MPC Deploy — Deep Analysis

**Source**: https://github.com/johnzhang3/mujoco_mpc_deploy
**Stars**: 127
**License**: MIT
**Paper**: https://arxiv.org/abs/2503.04613
**Date analyzed**: 2026-04-24

## Summary

Hardware deployment interface for MuJoCo MPC (MJPC) on Unitree robots (Go1/Go2).

The MPC solver and tasks live in the official [MuJoCo MPC](https://github.com/google-deepmind/mujoco_mpc) repo. Robot models from [MuJoCo Menagerie](https://github.com/google-deepmind/mujoco_menagerie).

## Go2 Interface Architecture

```python
class Go2Interface:
    - MuJoCo model: quadruped/task_flat.xml
    - Unitree SDK2: DDS communication (LowCmd_/LowState_)
    - Motion capture: ROS OptiTrack (Odometry + TwistStamped)
    - MPC agent: mujoco_mpc.agent (MJPC solver)
    - PD gains: Kp=60, Kd=5
```

## Key Files

- `src/go2interface.py` — Main Go2 interface class
- `examples/go2.py` — Standalone Go2 control example
- `examples/mjpc_gui.py` — GUI for MPC visualization
- `setup.py` — pip-installable package

## Integration Requirements

1. MuJoCo MPC Python interface (from google-deepmind/mujoco_mpc)
2. Unitree SDK2 (unitree_sdk2py)
3. ROS1 (for OptiTrack mocap — can be replaced with onboard estimation)
4. Go2-specific MJPC branch: `git clone https://github.com/johnzhang3/mujoco_mpc -b go2`

## Relevance to Auto-Drive

**Critical path**: This repo provides the hardware bridge from MuJoCo MPC → real Go2.
- Our Marathongo navigation stack needs this for locomotion control
- VGG cognitive layer (from Vector OS Nano) can use this as the action layer
- Auto-Drive survival loop monitors this as a critical service

**Deployment flow**:
```
Hermes Agent → Vector OS Nano (VGG) → mujoco_mpc_deploy (Go2 interface) → Unitree SDK2 → Go2 hardware
```

## Limitations

- Currently requires OptiTrack mocap (no onboard state estimation)
- ROS1 dependency (outdated; needs migration to ROS2)
- No autonomous navigation — only MPC locomotion control
- Paper focuses on whole-body MPC, not navigation

## Next Steps

1. Test in MuJoCo simulation (no hardware needed)
2. Replace OptiTrack with onboard IMU + LiDAR estimation
3. Integrate with Vector OS Nano navigation stack
4. Bridge to Hermes via MCP

