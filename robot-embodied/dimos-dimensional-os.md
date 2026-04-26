# DimOS — Dimensional Agentic Operating System

**Repo**: https://github.com/dimensionalOS/dimos  
**Stars**: 3,117 (as of 2026-04-25)  
**License**: NOASSERTION (pre-release beta)  
**Language**: Python  
**Homepage**: https://dimensionalos.com/

## What It Does

"Agentic operating system for physical space" — vibecode humanoids, quadrupeds, drones in natural language. Build multi-agent systems that work with physical input (cameras, lidar, actuators).

**No ROS required** — pure Python, simple install. This is a major differentiator from ABot-Claw (ROS2-based).

## Key Features

| Feature | Description |
|---------|-------------|
| **Navigation & Mapping** | SLAM, dynamic obstacle avoidance, route planning, autonomous exploration |
| **Perception** | Detectors, 3D projections, VLMs, audio processing |
| **Agentive Control + MCP** | Natural language robot control via agent CLI + MCP protocol |
| **Spatial Memory** | Spatio-temporal RAG, dynamic memory, object localization & permanence |
| **Multi-agent** | Local & hosted multi-agent systems |
| **Hardware support** | Humanoids, quadrupeds, drones — majority of robot manufacturers |

## Comparison with ABot-Claw

| Aspect | ABot-Claw | DimOS |
|--------|-----------|-------|
| ROS dependency | ROS2 required | No ROS needed |
| Language | Python + ROS2 | Pure Python |
| Agent integration | VLAC loop (custom) | MCP protocol (standard) |
| Spatial memory | Geometric + semantic map | Spatio-temporal RAG |
| Hardware support | Unitree Go2/G1 | Multiple manufacturers |
| Maturity | 116⭐ research | 3.1K⭐, pre-release beta |
| Agent framework | OpenClaw/Hermes native | Agent CLI + MCP |

## Integration Potential with Hermes Auto-Drive

- **DimOS = task layer** (natural language → robot action via MCP)
- **Auto-Drive = survival layer** (idle loop: health → capability → knowledge)
- **Hermes = bridge** (tools + memory + scheduling + MCP client)

DimOS's MCP support means Hermes can potentially control robots directly as MCP tools — no custom bridge needed. This is cleaner than ABot-Claw's custom VLAC protocol.

## Action Items

- [ ] Evaluate DimOS for Go2 deployment (compare with ABot-Claw + glio_mapping path)
- [ ] Test MCP integration: DimOS MCP server → Hermes MCP client
- [ ] Check if DimOS supports Unitree Go2 specifically (their "majority manufacturers" claim)
- [ ] Consider DimOS + Marathongo navigation modules as alternative to glio_mapping

## Scanned

- 2026-04-25 08:40 — Initial scan during EXPAND_WORLD_MODEL idle loop
