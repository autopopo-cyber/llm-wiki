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


---

## 2026-04-24 03:48 — Idle Loop Scan

### AI Agent Ecosystem
- **langflow** (147.3K⭐) — AI agent builder, actively pushed 4/23
- **dify** (138.9K⭐) — Agentic workflow platform, pushed 4/23
- **everything-claude-code** (165K⭐) — Claude Code harness with skills/memory
- **opencode** (148.3K⭐) — Open source coding agent (anomalyco)

### MCP Server Ecosystem
- **awesome-mcp-servers** (85.4K⭐) — Master list, pushed 4/23
- **playwright-mcp** (31.3K⭐) — Microsoft's browser automation MCP
- **github-mcp-server** (29.2K⭐) — GitHub official MCP
- **fastmcp** (24.8K⭐) — Pythonic MCP server builder (PrefectHQ)

### Robotics / Embodied AI
- **dimos** (3.1K⭐) 🆕 — **Agentic OS for physical space** — NLP control of humanoids, quadrupeds, drones. SLAM, spatial memory, multi-agent. Python + Nix + Docker. Very relevant to NAV_DOG. [Deep-dive → wiki:dimos-agentic-physical-os]
- **sesame-robot** (1.6K⭐) 🆕 — ESP32 mini quadruped, open/affordable
- **xr_teleoperate** (1.4K⭐) — Unitree humanoid teleoperation via XR

### Hermes Releases
- Latest: v2026.4.16 (v0.10.0) — Tool Gateway release (web search, image gen, TTS, browser for paid subscribers)
- Previous: v2026.4.13 (v0.9.0) — 487 commits, 269 PRs, 167 issues, 24 cont

[... earlier entries truncated ...]

---

## 2026-04-24 14:39 — Idle Loop Pass

### Ecosystem Updates
- **Hermes v0.11.0** (released 2026-04-23): Ink TUI, Transport ABC (pluggable), AWS Bedrock, GPT-5.5 via Codex OAuth, QQBot (17th platform), expanded plugin surface (register_command, dispatch_tool, pre_tool_call veto, transform_tool_result, image_gen backends, dashboard tabs), 5 new inference paths (NVIDIA NIM, Arcee AI, Step Plan, Gemini CLI OAuth, Vercel ai-gateway)
- **ABot-Claw ecosystem**: ABot-World 7⭐ (real-time interactive world sim), ABot-PhysWorld 295⭐, ABot-Explorer 5⭐, ABot-Claw 119⭐ — AMAP CVLab expanding fast
- **Unitree repos**: go2_omniverse 994⭐, FAST_LIO_LOCALIZATION_HUMANOID 766⭐, unitree_lerobot 630⭐
- **Top quadruped repos**: towr 1054⭐ (trajectory optimization), dial-mpc 962⭐, rl-mpc-locomotion 961⭐

### System Status
- Disk: 17% used (95G free), RAM: 1.5G/7.5G, Load: 0.20, Uptime: 5d 3h
- Gateway + Hindsight + PostgreSQL: all running
- 94 skills, 21 backups, credentials intact
- MoLing: not running (on-demand only)

### Notes
- Hermes v0.11.0 upgrade available (current: v0.10.0) — awaits user decision
- ABot-Claw (119⭐) remains our primary embodied AI reference; ABot-World adds real-time sim capability
- dial-mpc and rl-mpc-locomotion are directly relevant to NAV_DOG MPC locomotion work

---

## Idle Loop Scan — 2026-04-24 15:37

### Agent Ecosystem
- **hermes-agent v0.11.0** released 2026-04-23: "Interface release" — Ink-based TUI (`hermes --tui`), pluggable transport ABC, native AWS Bedrock, GPT-5.5 via Codex OAuth, 17th messaging platform (QQBot). 1,556 commits since v0.9.0.
- **everything-claude-code** (165K⭐): Agent harness performance optimization system — skills, instincts, memory
- **opencode** (148K⭐): Open source coding agent, very active
- **claude-code** (117K⭐): Anthropic's agentic coding tool
- **codex** (77K⭐): OpenAI's lightweight coding agent
- **claude-mem** (66K⭐): Claude Code plugin auto-captures everything during sessions

### MCP Ecosystem
- **awesome-mcp-servers** (85K⭐): Master collection, still growing
- **fastmcp** (24K⭐): Fast Pythonic MCP server builder, actively developed
- **activepieces** (21K⭐): AI Agents + MCPs + Workflow Automation (~400 MCP servers)
- **playwright-mcp** (31K⭐): Browser automation via MCP
- **mcp-toolbox** (14K⭐): Database MCP server

### Robotics / Embodied AI
- **ABot-Claw** (120⭐): Now 120 stars (was 116), pushed 2026-04-14
- **ABot-PhysWorld** (296⭐): CVPR 2026 World Model track — leaderboard repo created 2026-04-24!
- **go2_omniverse** (994⭐): Unitree Go2/G1 Isaac Lab support (stable)
- **go2_ros2_sdk** (899⭐): Unofficial ROS2 SDK for Go2

### Key Observation
- Hermes v0.11.0 introduces pluggable transports and Ink TUI — relevant for A2A integration architecture
- CVPR 2026 World Model track with ABot-PhysWorld leaderboard suggests AMAP CV Lab is pushing hard on embodied world models — could accelerate ABot-Claw ecosystem
- claude-mem (66K⭐) validates the "capture everything" approach similar to our Hindsight + MemOS stack
