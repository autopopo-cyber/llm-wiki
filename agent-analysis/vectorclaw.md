# VectorClaw — Anki Vector + OpenClaw MCP Integration

> Discovered: 2026-04-25 idle loop GitHub scan

- **Repo**: https://github.com/danmartinez78/VectorClaw
- **Stars**: 13
- **Description**: Anki Vector + OpenClaw integration via MCP. Give your AI assistant a body. MCP server connecting Anki Vector robot to AI assistants.
- **Relevance**: Direct proof of concept for MCP-native robot control. Uses OpenClaw (Hermes upstream) framework. Demonstrates the MCP → robot bridge pattern we need for Unitree Go2/G1.
- **Key insight**: Low star count but high conceptual value — shows the community is already building MCP bridges for physical robots, validating our ABot-Claw + Auto-Drive integration architecture.

## Relation to Our Stack
- VectorClaw: MCP server → robot (Anki Vector)
- Our target: MCP server → robot (Unitree Go2/G1)
- ABot-Claw: Hermes + VLM → robot (Unitree Go2/G1)
- Pattern: MCP is becoming the standard protocol for AI → robot communication

