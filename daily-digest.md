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

