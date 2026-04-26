# Vector OS Nano — Evaluation for NAV_DOG

**Date**: 2026-04-24 01:48
**Repo**: https://github.com/VectorRobotics/vector-os-nano
**Stars**: 135 | **License**: MIT | **Lang**: Python | **Created**: 2026-03-19
**Affiliation**: CMU Robotics Institute

## Summary

Cross-embodiment robot OS with industrial-grade autonomous navigation, natural language control, and sim-to-real transfer. Supports Unitree Go2 + SO-ARM101.

## Key Architecture

```
vector-cli  ──┐
              ├─> VectorEngine ──> VGG / tool_use ──> skill.execute()
vector-os-mcp┘         |
                       ├── VGG cognitive layer (task decomposition + verification + retry)
                       ├── 39 tools (file ops, bash, ROS2 diag, skill wrappers)
                       ├── LLM backend (Anthropic / OpenRouter / local)
                       └── permission system + session + intent router
```

## Tech Stack
- **Simulation**: MuJoCo 3.6
- **Navigation**: ROS2 Jazzy + Nav2
- **Control**: Convex MPC at 1kHz
- **LLM**: Claude (Anthropic) as brain
- **Manipulation**: LeRobot + SO-ARM100
- **Perception**: Intel RealSense D405

## NAV_DOG Relevance: ★★★★★ (HIGHEST)

### Why It Matters
1. **Go2-native**: Already supports Unitree Go2 with Convex MPC + ROS2 Nav2
2. **LLM integration**: Claude as brain → natural language task decomposition, directly aligns with ABot-Claw's VLAC concept
3. **MCP server**: `vector-os-mcp` entry point enables Claude Code / Hermes integration via MCP protocol
4. **VGG cognitive layer**: Task decomposition + verification + retry — parallels our Auto-Drive idle loop pattern
5. **Skill system**: `.execute()` skill wrappers — modular, like our Hermes skills

### Integration Path with Auto-Drive
- **Task Layer**: VectorEngine VGG → replaces manual task decomposition in ABot-Claw VLAC
- **Survival Layer**: Auto-Drive idle loop → health/capability/knowledge maintenance (unchanged)
- **Bridge**: vector-os-mcp → Hermes connects via MCP protocol, no custom API needed
- **Estimation**: Vector OS uses MuJoCo sim → real transfer; complement mujoco_mpc_deploy for hardware

### Action Items
- [ ] Clone and run vector-cli --sim-go2 to validate navigation stack
- [ ] Test vector-os-mcp as Hermes MCP tool
- [ ] Evaluate VGG cognitive layer vs ABot-Claw VLAC for task planning
- [ ] Compare Convex MPC vs BotBrain's Nav2 controller for Go2

## Risks
- Young project (created Mar 2026), may have instability
- LLM dependency (Claude API) may introduce latency for real-time control
- Sim-to-real gap not fully documented
