# MuJoCo MPC Deploy — Evaluation for NAV_DOG

**Date**: 2026-04-24 01:48
**Repo**: https://github.com/johnzhang3/mujoco_mpc_deploy
**Stars**: 127 | **License**: MIT | **Lang**: C++ | **Created**: 2025-03-28
**Paper**: arXiv 2503.04613 (Whole-Body MPC of Legged Robots with MuJoCo)

## Summary

Hardware deployment interface for MuJoCo MPC on Unitree robots (A1, Go1, Go2). Provides real-time whole-body MPC control with 1kHz solve rates.

## Key Features
- Whole-body MPC using MuJoCo MPC solver (Google DeepMind)
- Go1 and Go2 support via dedicated branches
- Unitree SDK/SDK2 hardware interface
- Currently uses OptiTrack for state estimation (onboard estimation WIP)
- C++ core for real-time performance

## NAV_DOG Relevance: ★★★★☆ (HIGH)

### Why It Matters
1. **Go2 hardware deployment**: Direct Go2 branch with SDK2 interface
2. **MPC control**: Whole-body MPC at 1kHz — complements BotBrain's Nav2 navigation stack
3. **Sim-to-real**: MuJoCo sim → Go2 hardware pipeline already exists
4. **Academic backing**: Published paper with rigorous validation

### Integration Path
- **Control Layer**: mujoco_mpc_deploy → Go2 locomotion MPC
- **Navigation Layer**: BotBrain / Vector OS → Nav2 path planning
- **Task Layer**: ABot-Claw VLAC / Auto-Drive → high-level task management
- **Architecture**: MPC for low-level control + Nav2 for path planning + VLAC for task execution

### Limitations
1. **Estimation still WIP**: Relies on external motion capture (OptiTrack) — not suitable for field deployment yet
2. **C++ codebase**: Harder to prototype/integrate than Python alternatives
3. **Single-robot**: No multi-robot coordination
4. **No LLM integration**: Pure control, needs separate task layer

### Comparison with Alternatives
| Feature | mujoco_mpc_deploy | Vector OS | BotBrain |
|---------|-------------------|-----------|----------|
| Go2 support | ✅ (branch) | ✅ native | ✅ native |
| MPC | ✅ whole-body | ✅ convex | ✅ convex |
| Nav2 | ❌ | ✅ | ✅ |
| LLM brain | ❌ | ✅ Claude | ❌ |
| MCP interface | ❌ | ✅ | ❌ |
| Estimation | ⚠️ mocap only | ✅ onboard | ✅ onboard |
| Sim-to-real | ✅ pipeline exists | ✅ | ✅ |

### Action Items
- [ ] Clone go2 branch and test in MuJoCo sim
- [ ] Monitor onboard estimation module development
- [ ] Evaluate MPC performance vs Convex MPC (BotBrain/Vector OS)
- [ ] Consider as low-level controller alongside Vector OS Nav2 stack
