## 2026-04-24 17:32 — Idle Loop Digest

### 🔔 Hermes v0.11.0 Released (2026-04-23)
- **Huge release**: 1,556 commits, 761 PRs, 29 community contributors
- New Ink-based TUI (`hermes --tui`) — React/Ink rewrite with streaming, status bar
- Pluggable transport architecture — AnthropicTransport, ChatCompletionsTransport, BedrockTransport
- 5 new inference paths: NVIDIA NIM, Arcee AI, Step Plan, Gemini CLI OAuth, Vercel ai-gateway
- **GPT-5.5 via Codex OAuth** — new reasoning model, live model discovery
- QQBot (17th platform adapter)
- ⚠️ **Current version: v0.10.0** — 1,217 commits behind. Needs user approval to update.

### 🤖 Notable AI Agent Repos
- **deer-flow** (63K⭐) — SuperAgent harness: research+code+create with sandboxes+memories. New mover.
- **claude-mem** (66K⭐) — Auto-captures Claude Code sessions, LLM compression. Memory tool.
- **openai-agents-python** (24.9K⭐) — Lightweight multi-agent framework from OpenAI.

### 🐕 Quadruped Robotics
- **MGDP** (84⭐, Adv. Sci. 2026) — Generalized Depth Perception for Quadruped Locomotion
- **go2-convex-mpc** (96⭐) — Convex MPC controller for Unitree Go2 in MuJoCo — directly relevant to NAV_DOG
- **basic-locomotion-isaaclab** (68⭐) — IsaacLab extension, sim-to-real for quadrupeds
- **Awesome-Quadruped-with-Manipulator** (74⭐) — Curated papers for quadruped+manipulator

### 🧹 System Maintenance
- Killed 31 orphan MemOS bridge processes (reclaimed ~1GB RAM)
- Cleaned old backups (268MB → 23.4MB)
- Added orphan process cleanup to HEALTH_CHECK wiki

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

---

## 2026-04-24 16:13 — Idle Loop Scan

### AI Agent Ecosystem
- **Langflow** 147.3K⭐ — visual agent builder, pushed 2026-04-24
- **Dify** 139K⭐ — production agentic workflow platform
- **Hermes Agent** 114K⭐ — v0.11.0 released 2026-04-23 (Interface release: Ink TUI rewrite, pluggable transport, AWS Bedrock)
- **awesome-llm-apps** 107.3K⭐ — 100+ runnable agent/RAG apps

### Coding Agents
- **everything-claude-code** 165.7K⭐ — agent harness optimization
- **opencode** 148.6K⭐ — open source coding agent
- **claude-code** 117.5K⭐ — Anthropic's terminal coding tool
- **codex** 77.5K⭐ — OpenAI lightweight coding agent

### Embodied AI / Robotics
- **Genesis** 28.6K⭐ — generative world for robotics/embodied AI
- **RLinf** 3.2K⭐ — RL infrastructure for embodied & agentic AI
- **awesome-embodied-vla-va-vln** 3K⭐ — VLA/VLN research

### MCP Servers
- **awesome-mcp-servers** 85.5K⭐ — collection of MCP servers
- **playwright-mcp** 31.3K⭐ — Microsoft Playwright MCP server
- **fastmcp** 24.8K⭐ — Pythonic MCP server builder
- **activepieces** 21.8K⭐ — AI agents + MCP + workflow automation (~400 MCP servers)

### Notable Changes Since Last Scan
- Hermes v0.11.0: 1,556 commits, 761 merged PRs, 22 community contributors
- No significant new quadruped/locomotion repos this period
- MCP ecosystem still growing rapidly (activepieces with 400+ MCPs)

---

## 2026-04-24 16:48 — Idle Loop Scan

### AI Agent Ecosystem
- Langflow 147K⭐, Dify 139K⭐, Hermes 114K⭐, awesome-llm-apps 107K⭐, gemini-cli 102K⭐, browser-use 90K⭐
- Coding agents: everything-claude-code 166K⭐, opencode 149K⭐, claude-code 117K⭐, codex 78K⭐
- Hermes v0.11.0 released 2026-04-23 (v2026.4.23): Transport ABC (A2A), Ink TUI, AWS Bedrock, plugin expansion. 1556 commits since v0.9.0.

### MCP Servers
- awesome-mcp-servers 85K⭐, playwright-mcp 31K⭐, github-mcp-server 29K⭐, fastmcp 25K⭐, activepieces 22K⭐

### Robotics
- towr 1053⭐ (ETHz trajectory optimization), dial-mpc 962⭐ (diffusion MPC), rl-mpc-locomotion 961⭐ (RL+MPC), spot_mini_mini 921⭐ (Bezier gait)

### Action Items
- HERMES_UPGRADE v0.11.0 still pending user decision
- No newrepos warranting skill creation
---

## 2026-04-24 19:22 — Idle Loop Scan

### Notable New Projects
- **dimos** (3.1K⭐) — dimensionalOS/dimos — "Agentic operating system for physical space. Vibecode humanoids, quadrupeds, drones." Pushed 2026-04-24. **Directly relevant** to our embodied AI path. Needs deep dive.
- **sesame-robot** (1.6K⭐) — Open affordable mini quadruped on ESP32
- **BotBrain** (174⭐) — Modular open-source brain for legged robots, web UI for teleops + navigation
- **quad-sdk** (924⭐) — CMU Robomechanics Lab tools for agile quadrupeds

### Coding Agent Ecosystem
- everything-claude-code 165K⭐ (harness/optimization system)
- opencode 148K⭐, claude-code 117K⭐, codex 77K⭐ — steady growth
- claude-mem 66K⭐ — auto-capture plugin for Claude Code

### MCP Ecosystem
- awesome-mcp-servers 85K⭐, playwright-mcp 31K⭐, github-mcp 29K⭐
- fastmcp 24K⭐, activepieces 21.8K⭐ (400+ MCP servers)

### Hermes
- v0.11.0 (v2026.4.23) — 1,556 commits, 761 PRs, 224K insertions since v0.9.0
- v0.10.0 (v2026.4.16) — Tool Gateway release


---

## 2026-04-24 20:00 — Idle Loop Scan

### AI Agent Ecosystem
- Langflow 147K⭐, Dify 139K⭐, Hermes 114K⭐ (v0.11.0 released 4/23)
- coding agents: everything-claude-code 166K⭐, opencode 149K⭐, claude-code 118K⭐, codex 78K⭐
- claude-mem 67K⭐ (auto-capture Claude Code sessions)

### Hermes v0.11.0 Highlights
- Ink-based TUI (`hermes --tui`), React/Ink rewrite
- Pluggable Transport ABC (Anthropic/ChatCompletions/ResponsesApi/Bedrock)
- AWS Bedrock native support
- GPT-5.5 via Codex OAuth
- QQBot (17th platform)
- Expanded plugin surface (register_command, dispatch_tool, pre_tool_call veto)
- 1,556 commits, 761 merged PRs since v0.9.0

### MCP Servers
- awesome-mcp-servers 85K⭐, playwright-mcp 31K⭐, github-mcp-server 29K⭐
- fastmcp 25K⭐, activepieces 22K⭐, mcp-toolbox 15K⭐, casdoor 13K⭐

### Embodied AI / Robotics
- RLinf 3.2K⭐ (RL infrastructure for embodied/agentic AI, pushed 4/24)
- Awesome-Embodied-Robotics-and-Agent 1.8K⭐
- HY-Embodied 652⭐ (embodied foundation models)
- loco-mujoco 1.4K⭐ (locomotion imitation learning benchmark, pushed 4/23)


---

## 2026-04-24 20:37 — Idle Loop Sweep

### AI Agent Ecosystem
- **Hermes Agent v0.11.0** (114K⭐) — Interface release: Ink TUI, Bedrock, GPT-5.5, QQBot, plugin surface
- **Langflow** 147K⭐, **Dify** 139K⭐, **Langchain** 135K⭐ — all active
- **browser-use** 90K⭐ — web automation for agents
- **Gemini CLI** 102K⭐ — Google's terminal agent

### Embodied AI / Robotics
- **Genesis** 28.6K⭐ — generative world for robotics & embodied AI (active, pushed today)
- **FluxVLA** 295⭐ — all-in-one VLA engineering platform, data→real-robot (NEW, pushed 4/23)
- **VectorClaw** 13⭐ — Anki Vector + OpenClaw MCP integration (NEW, pushed 4/21) — relevant to our MCP + robotics path
- **Awesome-Embodied-Robotics-and-Agent** 1.8K⭐ — curated list, good reference

### MCP Servers
- **awesome-mcp-servers** 85.5K⭐ — master list
- **playwright-mcp** 31.3K⭐ — Microsoft Playwright MCP
- **github-mcp-server** 29.2K⭐ — official GitHub MCP
- **fastmcp** 24.8K⭐ — Pythonic MCP framework
- **mcp-toolbox** 14.8K⭐ — Google's MCP for databases
- **activepieces** 21.9K⭐ — 400+ MCP servers, workflow automation

### System Status
- Disk: 17%, RAM: 2.1/7.5Gi, Load: 0.38, Uptime: 5d9h
- MemOS orphans: 9 killed, ~400MB recovered
- Gateway running, PostgreSQL running
- 97 skills, all valid


---

## 2026-04-24 21:13 — Autonomous Drive Scan

### Hermes Ecosystem
- **Hermes v0.11.0** released 2026-04-23: Ink-based TUI rewrite, pluggable transport ABC + AWS Bedrock, 5 new inference paths (NVIDIA NIM, Arcee AI, Step Plan, Gemini CLI OAuth, Vercel ai-gateway), GPT-5.5 via Codex OAuth, QQBot (17th platform). 1,556 commits since v0.9.0.

### Agent Ecosystem (Trending)
- **everything-claude-code** (165,916⭐) — Agent harness optimization system for Claude Code
- **opencode** (148,731⭐) — Open source coding agent (anomalyco)
- **claude-mem** (66,777⭐) — Auto-capture plugin for Claude Code sessions

### Embodied AI / Robotics (New)
- **RLinf** (3,176⭐) — RL infrastructure for embodied and agentic AI (pushed 2026-04-24)
- **PhyAgentOS** (205⭐) — Self-evolving embodied AI OS built on agentic workflows (pushed 2026-04-24)
- **embodied-agents** (54⭐) — ROS2 framework for interactive physical agents (pushed 2026-04-20)
- **SAGE** (265⭐) — NVlabs: Scalable Agentic 3D Scene Generation for Embodied AI (pushed 2026-04-22)
- **SurveyBrainBody** (306⭐) — Embodied Co-Design for Rapidly Evolving Agents taxonomy

### Key Observations
- PhyAgentOS "self-evolving embodied AI OS" concept overlaps with our Auto-Drive survival layer. Worth monitoring for integration ideas.
- RLinf at 3,176⭐ is the top new embodied AI project — RL infrastructure could complement our navigation training pipeline.
- Hermes v0.11.0 transport ABC is directly relevant: pluggable transport means easier A2A gateway integration.

### Incremental Update — 2026-04-24 21:52

#### New Findings
- **datawhalechina/every-embodied** (1,573⭐) — Chinese tutorial: build embodied AI robot from scratch with Python, covers VLA/OpenVLA/SmolVLA/Pi0. **Directly relevant to NAV_DOG**: practical VLA implementation guide.
- **Genesis** (28,572⭐) — Generative world for robotics & embodied AI learning. Simulation platform that could accelerate NAV_DOG software validation phase.

#### System Status
- Disk: 17%, RAM: 1.7/7.5Gi (effective after orphan cleanup), Load: 0.20, Uptime: 5d10h
- MemOS orphans: 2 (within tolerance)
- Backup: hermes-backup-20260424-2149.tar.gz (52K), rotation verified
- 97 skills, all valid
- Cron active: autonomous-drive-idle-loop every 30m

### Incremental Update — 2026-04-24 22:33

#### New Findings
- **MarcHesse/mhflocke** (13⭐) — Biologically Grounded Embodied Cognition for Quadruped Locomotion Learning. New repo (created 2026-03-28). Directly relevant to NAV_DOG quadruped locomotion research.
- **Awesome-RL-VLA** (646⭐) — Survey on RL of VLA models for robotic manipulation. Key reference for ABot-Claw reproduction.
- **VITRA** (358⭐) — ICRA 2026, scalable VLA pretraining from real-life human activity videos.
- **MemoryVLA** (216⭐) — ICLR 2026, perceptual-cognitive memory in VLA models. Memory-augmented VLA could improve ABot-Claw VLAC loop.
- **VLA-Handbook** (162⭐) — Chinese VLA handbook for robotics engineers. Practical reference for our Chinese-speaking team.
- **InternVLA-A1** (4⭐) — End-to-end VLA for dynamic environments. Early but interesting.

#### Hermes v0.11.0 Released (2026-04-23)
- **New Ink-based TUI** (`hermes --tui`) — React/Ink rewrite with streaming, status bar, subagent observability
- **Transport ABC** — Pluggable transport layer: Anthropic, ChatCompletions, ResponsesApi, Bedrock. Makes A2A gateway integration easier.
- **5 new inference paths** — NVIDIA NIM, Arcee AI, Step Plan, Gemini CLI OAuth, Vercel ai-gateway
- **GPT-5.5 via Codex OAuth** — New OpenAI reasoning model with live model discovery
- **QQBot** (17th platform) — Native QQ adapter with QR setup wizard
- **Plugin surface expanded** — register_command, dispatch_tool, pre_tool_call veto, rewrite tool results
- **1,556 commits, 761 PRs, 224K insertions** since v0.9.0 — massive release

#### System Status
- Disk: 18%, RAM: 2.2/7.5Gi (30%), Load: 0.12, Uptime: 5d10h
- MemOS orphans: 0 (cleaned 11, SIGKILL + gateway restart needed)
- Backup: hermes-backup-20260424-2230.tar.gz, rotation verified
- 98 skills (all valid), cron active
- Wiki: 15 files committed and pushed


## 2026-04-24 23:08 — Idle Loop Scan

### AI Agent Ecosystem
- **langflow** 147K⭐ — visual agent workflow builder (pushed 4/24)
- **dify** 139K⭐ — agentic workflow platform (pushed 4/24)
- **hermes-agent** 114.7K⭐ — v0.11.0 released (pushed 4/24)
- **gemini-cli** 102K⭐ — Google Gemini terminal agent (pushed 4/24)
- **browser-use** 90K⭐ — web automation for AI agents (pushed 4/21)

### MCP Servers
- **awesome-mcp-servers** 85.5K⭐ — comprehensive MCP server collection
- **playwright-mcp** 31.4K⭐ — Playwright browser MCP
- **github-mcp-server** 29.2K⭐ — GitHub official MCP
- **fastmcp** 24.8K⭐ — fast Python MCP framework
- **activepieces** 21.9K⭐ — AI workflow automation with ~400 MCP servers

### Embodied AI / Robotics
- **Genesis** 28.6K⭐ — generative world for robotics/embodied AI
- **RLinf** 3.2K⭐ — RL infrastructure for embodied & agentic AI
- **Embodied_AI_Paper_List** 2K⭐ — NEW: comprehensive survey papers (added to wiki)
- **Awesome-Embodied-Robotics-and-Agent** 1.8K⭐ — curated list
- **every-embodied** 1.6K⭐ — VLA/OpenVLA tutorial

### Hermes Releases
- **v0.11.0** (2026-04-23) — 1,556 commits, 761 PRs, 224K insertions, 29 community contributors


---

## 2026-04-24 23:43 — Idle Loop Scan

### AI Agents (GitHub)
- langflow (147K⭐) — AI-powered agents and workflows
- dify (139K⭐) — Production-ready agentic workflow platform
- system-prompts-and-models-of-ai-tools (136K⭐) — Full prompts from Cursor, Devin, Manus, etc.
- hermes-agent (115K⭐) — v0.11.0 released 2026-04-23
- awesome-llm-apps (107K⭐) — 100+ AI Agent & RAG apps
- gemini-cli (102K⭐) — Google's terminal AI agent

### MCP Servers (GitHub)
- playwright-mcp (31K⭐) — Microsoft's Playwright MCP server
- github-mcp-server (29K⭐) — GitHub official MCP
- fastmcp (25K⭐) — Pythonic MCP server builder
- mcp-toolbox (15K⭐) — Google's database MCP server

### Embodied AI (GitHub) 🆕
- Genesis (29K⭐) — Generative world for robotics & embodied AI
- FluxVLA (296⭐) — All-in-one VLA engineering platform 🔥 NAV_DOG relevant
- rosclaw (46⭐) — OS-level framework for LLM+ROS/VLA control 🔥 NAV_DOG relevant
- agent-ros-bridge (14⭐) — Universal ROS1/ROS2 bridge for AI agents

### System Status
- Disk: 17% used | RAM: 1.8/7.5Gi | Load: 0.06 | Uptime: 5d
- MemOS orphans: 11 (~1GB) — gateway restart needed
- Skills: 100 | Backup: current | Cron: active

## 2026-04-25 01:00 — Idle Loop Scan

### AI Agents
- Hermes Agent 114.8K⭐ (v0.11.0 released 2026-04-23)
- deer-flow 63.7K⭐ (ByteDance SuperAgent)
- claude-mem 66.9K⭐ (auto-capture Claude Code sessions)
- everything-claude-code 166K⭐ (agent harness optimization)

### Embodied AI
- Genesis 28.6K⭐ (generative world for robotics)
- FluxVLA 296⭐ (VLA engineering platform)
- **VectorClaw 13⭐ (NEW)** — Anki Vector + OpenClaw MCP integration, validates MCP→robot bridge pattern

### MCP Servers
- awesome-mcp-servers 85.5K⭐
- playwright-mcp 31.4K⭐
- fastmcp 24.8K⭐

### Key Observation
MCP protocol is becoming the de facto standard for AI→robot communication. VectorClaw (OpenClaw+MCP for Anki Vector) confirms this pattern. Our ABot-Claw + Auto-Drive architecture is aligned with this trend.



---

## 2026-04-25 01:38 — Idle Loop Scan

### AI Agents
- Hermes v0.11.0 (released 2026-04-23) — 1,556 commits since v0.9.0
- everything-claude-code 166K⭐ — agent harness optimization system
- opencode 148.9K⭐ — open source coding agent

### MCP Servers
- No new significant entries beyond last scan

### Embodied AI / Robotics
- **BotBrain 174⭐** — Modular open-source brain for legged robots (Web UI, autonomous navigation) — directly relevant to NAV_DOG
- Genesis 28.6K⭐ — still leading embodied AI simulator
- FluxVLA 296⭐ — VLA platform
- JushenRenji 17⭐ — 具身人机 (Bilibili channel, embodied AI projects)

### Unitree Go2
- unitree_webrtc_connect 306⭐ — WebRTC driver for Go2/G1
- BotBrain 174⭐ — modular brain for legged robots (Go2 support)
- go2_rl_gym 162⭐ — RL implementation for Go2
