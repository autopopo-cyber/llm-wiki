# Vector OS Nano — Deep Analysis

**Source**: https://github.com/VectorRobotics/vector-os-nano
**Stars**: ~500 (new repo, CMU Robotics Institute)
**License**: MIT
**Date analyzed**: 2026-04-24

## Key Architecture: VGG (Verified Goal Graph)

All actionable commands flow through the VGG cognitive layer:
- **Simple commands** → 1-step GoalTree (no LLM, <1ms)
- **Complex commands** → LLM decomposition → GoalTree with verification
- **3-layer feedback loop**: step retry → continue past failure → re-plan with failure context

## Skill System

30 primitives across 4 categories:
- Locomotion (8): walk, trot, pace, crawl, etc.
- Navigation (5): navigate, explore, etc.
- Perception (6): scene understanding, object detection
- World (11): pick, place, open, close, etc.

**Skill protocol**: `docs/skill-protocol.md` — structured skill definition
**Custom skill example**: `examples/custom_skill.py`

## Go2 Navigation Stack

```
TARE (frontier exploration)
  → FAR V-Graph (global visibility-graph routing)
    → localPlanner (terrain-aware obstacle avoidance)
      → pathFollower → Go2 MPC (1kHz control)
```

**Sim-to-real**: nav stack is identical to real Go2 with Livox MID360. Only bridge node changes.

## MCP Integration

- `.mcp.json` with `vector-os-nano` + `vector-graph` servers
- CLI (`vector-cli`) and MCP dual entry points → same VectorEngine

## Relevance to Auto-Drive / Hermes

| Feature | Vector OS Nano | Auto-Drive / Hermes |
|---------|---------------|---------------------|
| VGG cognitive layer | LLM decomposes → verify → retry | Our VGG design spec in `docs/vgg-design-spec.md` |
| Skill system | 30 primitives + custom skills | Hermes skills (90+) |
| MCP server | Built-in `vector-os-nano.mcp` | MoLing MCP + native MCP |
| Go2 support | Native + MuJoCo sim | Planned via mujoco_mpc_deploy |
| Navigation | CMU Vector Nav Stack (TARE + V-Graph) | Marathongo modules (glio_mapping + tangent_arc) |

**Integration path**: Vector OS Nano → MCP bridge → Hermes agent → Auto-Drive survival loop
This is the most promising "LLM brain + robot OS" project found. Directly compatible with Hermes MCP.

## Dependencies

- Python 3.10+
- MuJoCo 3.6+
- ROS2 Jazzy
- Anthropic/OpenAI SDK (for LLM)
- Optional: RealSense D405, SO-101 arm, LeRobot

## Reproduction Path

1. `pip install -e ".[sim]"` — install with MuJoCo simulation
2. `vector-cli` — launch CLI with Go2 in MuJoCo
3. Configure MCP in Hermes config → test skill execution from Hermes
4. Add custom skills for Auto-Drive integration

