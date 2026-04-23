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
- Previous: v2026.4.13 (v0.9.0) — 487 commits, 269 PRs, 167 issues, 24 contributors

### Key Insight
dimos represents a new category: "agentic OS for physical space" — it combines navigation, perception, spatial memory, and multi-agent coordination under one framework. This is directly competitive with our ABot-Claw + Auto-Drive integration path. Worth monitoring and potentially integrating.


---

## Scan 2026-04-24 04:20

### amap-cvlab Ecosystem Update (Key — ABot-Claw upstream)
- **ABot-World** (7⭐, pushed 4/19) — Real-Time Interactive World Simulation on Single Desktop GPU. NEW repo.
- **ABot-PhysWorld** (295⭐, pushed 4/16) — Physical world simulation, 295 stars is significant
- **ABot-Explorer** (4⭐, pushed 4/15) — Exploration module, NEW repo
- **ABot-Claw** (117⭐, pushed 4/14) — Our integration target, stable
- **ABot-Manipulation** (470⭐, pushed 3/30) — Manipulation framework, highest stars in org
- **CE-Nav** (38⭐) — Flow-Guided RL for cross-embodiment local navigation
- **OmniNav** (129⭐, ICLR 2026) — Unified prospective exploration + VLN framework
- **ABot-Navigation** (124⭐) — Navigation module
- **Reasoning-Over-Space** (4⭐, ACL 2026) — Spatial reasoning, NEW

**Insight**: amap-cvlab is building a full embodied AI stack: World simulation → Physics → Navigation → Manipulation → Exploration → Reasoning. ABot-Claw is the agent orchestration layer that sits on top. The ecosystem is maturing fast — 3 new repos in the last week.

### AMAP-EAI (Different org, also AMAP)
- **SocialNav** (81⭐, pushed 4/21) — Human-inspired foundation model for socially-aware embodied navigation
- **Nav-R2** (17⭐) — Dual-Relation Reasoning for open-vocabulary object-goal navigation

### Coding Agent Landscape (Stable)
- deer-flow (63.5K⭐) still leading for multi-agent SuperAgent (ByteDance)
- claude-mem (66.3K⭐) — memory compression for Claude Code sessions, relevant to our Hindsight work
- Casdoor (13.5K⭐) — Agent-first IAM + MCP gateway, could replace our planned auth layer

### MCP Ecosystem (Growing)
- fastmcp (24.8K⭐) becoming the standard Python MCP framework
- googleapis/mcp-toolbox (14.8K⭐) — Google's official database MCP
- Casdoor (13.5K⭐) — IAM + MCP gateway + OpenClaw support

### No New Hermes Releases
- Still at v0.10.0 (2026-04-16)

---

## Scan 2026-04-24 04:20

### amap-cvlab Ecosystem Update (Key - ABot-Claw upstream)
- **ABot-World** (7 stars, pushed 4/19) - Real-Time Interactive World Simulation on Single Desktop GPU. NEW repo.
- **ABot-PhysWorld** (295 stars, pushed 4/16) - Physical world simulation
- **ABot-Explorer** (4 stars, pushed 4/15) - Exploration module, NEW repo
- **ABot-Claw** (117 stars, pushed 4/14) - Our integration target, stable
- **ABot-Manipulation** (470 stars, pushed 3/30) - Manipulation framework, highest stars in org
- **CE-Nav** (38 stars) - Flow-Guided RL for cross-embodiment local navigation
- **OmniNav** (129 stars, ICLR 2026) - Unified prospective exploration + VLN framework
- **ABot-Navigation** (124 stars) - Navigation module
- **Reasoning-Over-Space** (4 stars, ACL 2026) - Spatial reasoning, NEW

**Insight**: amap-cvlab is building a full embodied AI stack: World simulation > Physics > Navigation > Manipulation > Exploration > Reasoning. ABot-Claw is the agent orchestration layer. 3 new repos in the last week.

### AMAP-EAI (Different org, also AMAP)
- **SocialNav** (81 stars, pushed 4/21) - Human-inspired foundation model for socially-aware embodied navigation
- **Nav-R2** (17 stars) - Dual-Relation Reasoning for open-vocabulary object-goal navigation

### No New Hermes Releases
- Still at v0.10.0 (2026-04-16)


---

## 2026-04-24 05:00 — Idle Loop Scan

### AI Agent Ecosystem
- langflow 147K⭐ — visual AI workflow builder (pushed 04-23)
- dify 139K⭐ — agentic workflow platform (pushed 04-23)
- langchain 135K⭐ — agent engineering platform (pushed 04-23)
- hermes-agent 113K⭐ — v0.10.0 still latest (Apr 16)
- gemini-cli 102K⭐ — Gemini terminal agent (pushed 04-23)
- browser-use 90K⭐ — web automation for AI agents (pushed 04-21)
- ragflow 79K⭐ — RAG + Agent engine (pushed 04-23)

### Robotics / Embodied AI
- Genesis 28.6K⭐ — generative world for robotics (pushed 04-22)
- LeRobot 23.5K⭐ — HuggingFace end-to-end robot learning (pushed 04-23)
- openpilot 60.7K⭐ — comma.ai self-driving OS (pushed 04-23)
- PythonRobotics 29.2K⭐ — robotics algorithm samples (pushed 04-20)

### MCP Servers
- awesome-mcp-servers 85.4K⭐ — curated MCP server list
- playwright-mcp 31.3K⭐ — Microsoft Playwright MCP
- github-mcp-server 29.2K⭐ — GitHub official MCP
- fastmcp 24.8K⭐ — Pythonic MCP server builder
- activepieces 21.8K⭐ — AI workflow + ~400 MCP servers
- mcp-toolbox 14.8K⭐ — Google database MCP server

### Notable Changes Since Last Scan
- No new Hermes release (v0.10.0 from Apr 16 still latest)
- activepieces (21.8K⭐) is new — offers ~400 MCP servers, potential integration
- mcp-toolbox (14.8K⭐) by Google — database MCP, could be useful for Postgres job queue
