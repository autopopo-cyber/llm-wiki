# dimos — Agentic OS for Physical Space

**Source**: https://github.com/dimensionalOS/dimos
**Stars**: 3,111 | **Language**: Python | **Created**: 2024-10-19 | **Last pushed**: 2026-04-23
**Scanned**: 2026-04-24

## Summary
DimOS (Dimensional OS) is an agentic operating system for physical space. It enables natural-language control of humanoids, quadrupeds, drones, and other hardware, with multi-agent systems that integrate physical sensors (cameras, lidar, actuators).

## Key Capabilities
- **Navigation & Mapping**: SLAM, dynamic obstacle avoidance, route planning, autonomous exploration. Both native and ROS.
- **Perception**: Detectors, 3D projections, VLMs, audio processing
- **Agentic Control**: Natural language task assignment to robots
- **Spatial Memory**: Persistent geometric + semantic maps
- **Multi-Agent**: Multiple robots coordinated via shared spatial understanding

## Relevance to NAV_DOG / ABot-Claw Path
- **Direct competitor/complement to ABot-Claw**: Both do embodied AI with VLM perception + spatial memory
- **Key difference**: dimos focuses on NixOS reproducibility and Docker deployment; ABot-Claw focuses on VLAC loop rigor
- **Integration potential**: dimos navigation + ABot-Claw VLAC critic = robust embodied loop
- **Unitree support**: Not explicitly listed but architecture supports "quadrupeds"

## Technical Notes
- Uses Nix flakes for reproducible builds
- CUDA + Docker support
- Python-based (compatible with Hermes tooling)
- Active Discord community

## Action Items
- [ ] Deep-dive: check if dimos supports Unitree Go2 SDK
- [ ] Compare dimos navigation vs Marathongo modules
- [ ] Evaluate dimos spatial memory vs ABot-Claw visual-centric shared memory

