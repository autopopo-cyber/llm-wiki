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

## 2026-04-24 — Idle Loop Scan

### AI Agent Ecosystem
- **hermes-agent** 113K⭐ — stable, v0.10.0 (Apr 16, Tool Gateway release)
- **everything-claude-code** 165K⭐ — Claude Code optimization system
- **opencode** 148K⭐ — Open source coding agent (TypeScript)
- **langflow** 147K⭐ — Visual agent builder
- **dify** 139K⭐ — Production agentic workflow platform

### VLA / Embodied AI (NEW discoveries)
- **VITRA** 355⭐ (ICRA 2026) — Scalable VLA pretraining with rewards → relevant to ABot-Claw VLAC
- **MemoryVLA** 216⭐ (ICLR 2026) — Perceptual-Cognitive Memory in VLA → relevant to layered-memory-architecture
- **Awesome-RL-VLA** 644⭐ — Survey on RL for VLA robotic manipulation
- **VLA-Handbook** 159⭐ — Chinese VLA learning/interview guide
- **open-h-embodiment** 109⭐ — Community dataset for shared embodiment

### Unitree Ecosystem
- **xr_teleoperate** 1411⭐ — XR-based humanoid robot teleoperation
- **unitree_lerobot** 629⭐ — LeRobot integration for Unitree (useful for Go2)
- **unitree_rl_mjlab** 333⭐ — RL with MuJoCo Lab for Unitree robots

### ABot Ecosystem
- **ABot-PhysWorld** 295⭐ — Physical world simulation (new from AMAP CVLab)
- **ABot-Claw** 117⭐ — Stable, updated Apr 23
- **ABot-World** 7⭐ — Real-time interactive world sim on single GPU

### MCP Ecosystem
- **awesome-mcp-servers** 85K⭐ — master list
- **playwright-mcp** 31K⭐ — browser automation
- **fastmcp** 25K⭐ — Pythonic MCP server builder
- **activepieces** 22K⭐ — 400+ MCP servers + workflow automation


---

## 2026-04-24 06:44 — Cooldown Sweep

### ENSURE_CONTINUATION
- Health: disk 16%/96G avail, RAM 17%, load 0.01, uptime 4d19h — all healthy
- BACKUP_DATA: Skipped (cooldown, last 06:11)
- SKILL_INTEGRITY: Skipped (cooldown, last 06:11)

### EXPAND_CAPABILITIES
- No new patterns ≥3x, no critical patches, no stale temp files

### EXPAND_WORLD_MODEL — GitHub Scan
- **🚨 Hermes v0.11.0 released (Apr 23)!** — "The Interface release"
  - New Ink-based TUI (React/Ink rewrite)
  - Pluggable transport ABC + native AWS Bedrock
  - 5 new inference paths (NVIDIA NIM, Arcee AI, Step Plan, Gemini CLI OAuth, Vercel ai-gateway)
  - GPT-5.5 over Codex OAuth
  - QQBot — 17th platform
  - Plugin surface expanded (slash commands, tool dispatch, pre_tool_call veto, etc.)
  - `/steer` — mid-run agent nudges
  - Shell hooks for lifecycle events
  - Webhook direct-delivery mode
  - Smarter delegation with orchestrator role + max_spawn_depth
  - Auxiliary model configuration
- VLA/Embodied AI:
  - Awesome-RL-VLA (644⭐) — RL+VLA survey
  - VLA-Handbook (159⭐) — Chinese VLA learning guide
  - InternVLA-A1 — end-to-end VLA for manipulation
- AMAP CVLab:
  - ABot-PhysWorld (295⭐), ABot-Claw (117⭐), ABot-World (7⭐), ABot-Explorer (4⭐)
- MCP ecosystem:
  - awesome-mcp-servers (85K⭐), playwright-mcp (31K⭐), github-mcp-server (29K⭐), fastmcp (25K⭐)
## 2026-04-24 07:57 — Idle Loop Digest

### Hermes v0.11.0 Released (2026-04-23)
- **Transport ABC**: Pluggable transport layer extracted from run_agent.py. AnthropicTransport, ChatCompletionsTransport, ResponsesApiTransport, BedrockTransport. **Impact on Auto-Drive**: Our cron and subagent spawning may need transport configuration updates.
- **Ink TUI**: Full React/Ink rewrite of interactive CLI. `hermes --tui`. Not directly relevant to cron/idle-loop.
- **Plugin Surface Expansion**: `register_command`, `dispatch_tool`, `pre_tool_call` veto, `transform_tool_result`, `transform_terminal_output`, image_gen backends, custom dashboard tabs. **Impact on Auto-Drive**: Plugin hooks could replace some of our shell-based lock management with native plugin hooks.
- **5 New Inference Paths**: NVIDIA NIM, Arcee AI, Step Plan, Google Gemini CLI OAuth, Vercel ai-gateway.
- **GPT-5.5 over Codex OAuth**: Available through ChatGPT Codex OAuth with live model discovery.
- **QQBot**: 17th platform adapter. Not directly relevant.
- **Upgrade Priority**: MEDIUM — Transport ABC + plugin surface are architecturally significant but current setup works fine. Should evaluate after next user session.

### ABot-PhysWorld (295★, new)
- AMAP CVLab (same org as ABot-Claw)
- Python, last pushed 2026-04-16
- No description yet — likely physical world simulation companion to ABot-Claw
- **Relevance**: Could be Nav/Sim environment for NAV_DOG project

### RLinf (3,171★)
- "Reinforcement Learning Infrastructure for Embodied and Agentic AI"
- Relevant to NAV_DOG training pipeline
- Worth deeper investigation when A2 is ready

### Embodied AI Landscape
- HCPLab-SYSU/Embodied_AI_Paper_List (2,020★) — comprehensive paper list
- zchoi/Awesome-Embodied-Robotics-and-Agent (1,772★) — curated list

---

## Agent Ecosystem Scan -- 2026-04-24 08:33

### Top AI Agent Projects (by stars)
- JavaGuide 155K - Java backend + AI app dev guide
- Langflow 147K - AI agent workflow builder
- Dify 139K - Agentic workflow platform
- System Prompts Collection 136K - Curated AI tool prompts
- Langchain 135K - Agent engineering platform
- Hermes Agent 113K - The agent that grows with you
- Awesome LLM Apps 107K - 100+ agent and RAG apps
- Gemini CLI 102K - Gemini in terminal

### Recent Coding Agents (pushed after Apr 20)
- everything-claude-code 165K - Agent harness optimization system
- opencode 148K - Open source coding agent
- claude-code 117K - Anthropic terminal coding agent
- codex 77K - OpenAI lightweight coding agent

### Recent MCP Servers
- awesome-mcp-servers 85K - Curated MCP server list
- playwright-mcp 31K - Microsoft browser MCP
- github-mcp-server 29K - GitHub official MCP
- fastmcp 25K - Pythonic MCP framework
- activepieces 22K - AI agents + 400 MCPs

### Hermes Releases
- v0.11.0 (Apr 23): Interface release, React/Ink CLI rewrite, plugin surface expansion
- No new release since last scan

### Key Observations
- everything-claude-code at 165K: agent harness optimization aligns with Auto-Drive survival layer
- opencode 148K continues rapid growth as open-source coding agent
- MCP ecosystem still expanding fast (fastmcp + activepieces as frameworks)
- No new Hermes release since v0.11.0

---

## 2026-04-24 09:12 — Idle Loop Scan

### Hermes Agent v0.11.0 Released (2026-04-23)
Key changes for Auto-Drive:
- **Transport ABC** — pluggable transport layer. Format conversion extracted from run_agent.py. Implications: custom transports possible, easier A2A integration.
- **Ink TUI** — `hermes --tui` React/Ink rewrite. Subagent spawn observability overlay (useful for monitoring idle-loop spawned subagents).
- **AWS Bedrock native** — new inference path via Converse API.
- **GPT-5.5 via Codex OAuth** — new reasoning model available.
- **Plugin surface expansion** — more hooks for Auto-Drive integration.
- **5 new inference paths** — NVIDIA NIM, Arcee AI, Step Plan, Gemini CLI OAuth, Vercel ai-gateway.
- **QQBot adapter** — 17th platform.

### Ecosystem Scan
**Top AI Agent Projects (by stars)**:
- langflow (147K⭐) — agent workflow builder
- dify (139K⭐) — agentic workflow platform  
- langchain (135K⭐) — agent engineering platform
- hermes-agent (113K⭐) — the agent that grows with you
- gemini-cli (102K⭐) — Gemini terminal agent

**Hot Coding Agents (recent push)**:
- claude-mem (66K⭐) — Claude Code auto-memory plugin
- opencode (148K⭐) — open source coding agent

**MCP Servers Trending**:
- playwright-mcp (31K⭐) — Microsoft Playwright MCP
- github-mcp-server (29K⭐) — GitHub official MCP
- fastmcp (25K⭐) — Pythonic MCP framework
- mcp-toolbox (15K⭐) — Google database MCP

### Action Items
- ⏳ HERMES_V0.11_UPGRADE — evaluate upgrade path (Transport ABC is relevant for A2A)
- ⏳ AUTONOMOUS_DRIVE_SPEC_REPO — still needs GitHub auth
---

## 2026-04-24 09:51 — Idle Loop Scan

### Hermes v0.11.0 Released (Apr 23)
- **Ink-based TUI** — `hermes --tui` with React/Ink rewrite, JSON-RPC backend, streaming, subagent overlay
- **Transport ABC** — Pluggable transport layer: Anthropic, ChatCompletions, ResponsesApi, Bedrock
- **5 New Inference Paths** — NVIDIA NIM, Arcee AI, Step Plan, Gemini CLI OAuth, Vercel ai-gateway
- **GPT-5.5 over Codex OAuth** — live model discovery from OpenAI without catalog updates
- **QQBot** — 17th messaging platform
- **Tool Gateway** (v0.10.0) — deferrred features folded in
- 1,556 commits, 761 PRs, 224K insertions, 224+ contributors since v0.9.0
- **Notable**: No A2A/swarm mentions yet in this release

### AI Agent Ecosystem
- Top agents: langflow (147K*), dify (139K*), hermes-agent (113K*)
- Coding agents: everything-claude-code (165K*), opencode (148K*), claude-code (117K*), codex (77K*)
- claude-mem (67K*) — auto-capture plugin for Claude Code (relevant to our memory work)

### MCP Servers Trending
- awesome-mcp-servers (85K*), playwright-mcp (31K*), github-mcp-server (29K*)
- fastmcp (25K*) — Pythonic MCP server builder
- activepieces (22K*) — 400+ MCP servers for agents
- googleapis/mcp-toolbox (15K*) — database MCP server

### Key Takeaway
Hermes v0.11.0 is a massive release focused on transport abstraction and UI. The pluggable transport layer could simplify our A2A integration. GPT-5.5 support via Codex OAuth is notable for multi-model orchestration.


---

## 2026-04-24 10:29 — Auto-Drive Idle Scan

### Hermes Ecosystem
- **Hermes v0.11.0** released 2026-04-23 — "The Interface release": full React/Ink CLI rewrite, 1,556 commits since v0.9.0, 761 merged PRs, 29 community contributors
- v0.10.0 (2026-04-16) — "Tool Gateway release": Nous Portal subscribers get web search, image gen, TTS, browser automation with zero API keys

### Coding Agent Landscape
- **claude-mem** (66K⭐) — Auto-captures everything Claude Code does; could complement/replace our MemOS approach for session recording
- **deer-flow** (63K⭐, ByteDance) — Long-horizon SuperAgent: research + code + create. Open-source.
- **opencode** (148K⭐) — Open-source coding agent (anomalyco). Rapidly growing.
- **everything-claude-code** (165K⭐) — Agent harness optimization: skills, instincts, memory, security

### MCP Server Ecosystem
- **awesome-mcp-servers** (85K⭐) — Still the canonical list
- **Google mcp-toolbox** (15K⭐) — Open-source MCP server for databases
- **casdoor** (13K⭐) — Agent-first IAM / LLM MCP & agent gateway + auth
- **activepieces** (22K⭐) — ~400 MCP servers for AI agents, workflow automation
