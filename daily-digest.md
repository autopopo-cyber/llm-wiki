# Daily Digest — 2026-04-24

## Agent Ecosystem Updates

### Notable New/Updated Projects
- **everything-claude-code** (165K⭐) — Agent harness optimization: skills, instincts, memory, security
- **opencode** (148K⭐) — Open source coding agent (anomalyco)
- **claude-mem** (66.3K⭐) — Auto-captures Claude Code sessions, compresses with LLM
- **deer-flow** (63.5K⭐, ByteDance) — Long-horizon SuperAgent: research+code+create with sandboxes+memories
- **awesome-design-md** (64K⭐) — Design system files for coding agents

### MCP Server Trends
- **awesome-mcp-servers** (85.4K⭐) — Master collection, still growing fast
- **playwright-mcp** (31.3K⭐, Microsoft) — Playwright browser automation via MCP
- **github-mcp-server** (29.2K⭐, GitHub official) — GitHub API via MCP
- **fastmcp** (24.8K⭐, PrefectHQ) — Pythonic MCP server builder
- **mcp-toolbox** (14.8K⭐, Google) — Database MCP server
- **casdoor** (13.5K⭐) — Agent-first IAM + MCP gateway + auth server

### Robotics / Embodied AI
- **Genesis** (28.6K⭐) — Generative world for embodied AI learning (new!)
- **LeRobot** (23.5K⭐, HuggingFace) — End-to-end learning for robotics
- **Vector OS Nano** (new, CMU RI) — Cross-embodiment robot OS: NL control + nav + sim-to-real. **Highly relevant**.
- **mujoco_mpc_deploy** (127⭐) — MuJoCo MPC hardware deployment for Unitree Go1/Go2

## Hermes Ecosystem
- Latest release: **v0.10.0** (2026-04-16) — Tool Gateway release
- No new releases since last check

## Key Insight
Vector OS Nano is the most promising integration target:
- MCP-native (vector-os-nano MCP server + vector-graph MCP server)
- Go2 + SO-101 arm support out of the box
- VGG cognitive layer aligns with our agent architecture
- CMU RI backing — likely to be maintained
- Direct compatibility path: Hermes → MCP → Vector OS Nano → Go2


---

## 2026-04-24 03:00 — Idle Loop Scan

### 🔍 Key Discoveries

1. **Vector OS Nano** (VectorRobotics, 135⭐) — Game-changer for NAV_DOG integration:
   - VGG (Verified Goal Graph) for verified navigation
   - Built-in Go2/Go3 MCP server — native Hermes integration
   - Skills: Navigation, Mapping, Go2 SDK, SLAM, Task Manager
   - Much more complete than building from scratch

2. **unitree-sdk2-mcp** (ros-claw, 68⭐) — Full Unitree SDK2 as MCP server:
   - 7 tools: connect_robot, get_robot_state, get_imu_data, get_battery, switch_mode, move_to, stop_robot
   - Native Hermes tool integration — no ROS2 bridge needed
   - Clone analyzed at ~/repos/unitree-sdk2-mcp/

3. **FAST-LIO2** (hku-mars, 3.1K⭐) — Still the LiDAR-inertial SLAM standard
   - Best choice for Go2 LiDAR SLAM (as validated by glio_mapping in Marathongo)

4. **GNSS+IMU+LiDAR Fusion** — Three viable approaches documented:
   - LIO-SAM (1.4K⭐): Factor graph + loop closure → best accuracy
   - LVI-SAM (1.1K⭐): Visual-inertial addition → best robustness
   - FAST-LIO2 (3.1K⭐): Lightest + fastest → best for real-time Go2

5. **AI Agent Ecosystem** — Notable movers:
   - system-prompts-and-models-of-ai-tools (135K⭐) — massive prompt collection
   - claude-mem (66K⭐) — Claude Code auto-memory plugin
   - deer-flow (63K⭐) — ByteDance SuperAgent
   - goose (43K⭐) — extensible open-source agent

6. **MCP Server Ecosystem** — Explosive growth:
   - awesome-mcp-servers (85K⭐) — curated list
   - playwright-mcp (31K⭐) — Microsoft browser automation
   - fastmcp (25K⭐) — Pythonic MCP framework
   - casdoor (13K⭐) — Agent-first IAM + MCP gateway

### 🤖 Hermes Updates
- v0.10.0 (Apr 16) — Tool Gateway release, paid web search, MiMo v2 Pro
- 8 days since last release — next one likely soon

### 📊 System Health
- Disk: 16% used (96G free)
- RAM: 18% used (6.1G free)
- Load: 0.49
- Uptime: 4d 15h
- Skills: 93 total, all valid
- Cron: active (30min idle loop)
- Backups: rotated, latest 2026-04-22
