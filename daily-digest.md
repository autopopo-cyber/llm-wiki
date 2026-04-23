# Daily Digest — 2026-04-23

## 🔥 最重要发现

### 1. SkillClaw — Skill 库自动进化管家
- **Stars**: 705 (production 级别)
- **核心**：后任务进化循环，自动去重、改进、整合 skill 库
- **兼容**：Hermes / Codex / Claude Code / OpenClaw / QwenPaw 等
- **论文**：arXiv 2604.08377
- **对我们的价值**：🔥🔥🔥 直接解决 skill 库膨胀问题，建议安装
- **安装**：`skillclaw setup && skillclaw start --daemon`

### 2. Hermes Agent Self-Evolution（Nous Research 官方）
- **核心**：DSPy + GEPA 自动优化 skill/prompt/tool
- **Phase 1**：Skill 文件进化（已实现）
- **Phase 2-5**：Tool 描述 → System prompt → 代码 → 持续循环（规划中）
- **成本**：~$2-10 每次优化
- **ICLR 2026 Oral**
- **对我们的价值**：🔥🔥 可用于优化 autonomous-drive skill 本身

### 3. ARIS — 睡眠时自动研究
- **Stars**: 7.2K
- **核心**：跨模型 review（Claude 执行 + GPT 审查），Research Wiki，Meta-Optimize
- **兼容**：Claude Code / Codex / Cursor / Trae
- **对我们的价值**：🔥 可借鉴 Meta-Optimize 和 cross-model review

## 📊 Hermes 生态快照

| 组件 | 版本/状态 |
|------|----------|
| Hermes Agent | v0.10.0 (2026.4.16) |
| 核心仓库 | NousResearch/hermes-agent (23K+ stars) |
| Self-Evolution | Phase 1 完成 (DSPy+GEPA) |
| Skill 生态 | 380+ 社区 skills, agentskills.io 平台 |
| MCP 生态 | 15,400+ indexed servers (Clarvia) |

## 🔌 建议安装的插件

| 插件 | 优先级 | 理由 |
|------|--------|------|
| SkillClaw | P0 | 直接解决 skill 库混乱 |
| hermes-dojo | P1 | 自我改进，监控弱 skill |
| super-hermes | P2 | 元推理层，自生成更好 prompt |

## 📝 推广进展

| 渠道 | 状态 |
|------|------|
| Dev.to 教程 | ✅ 已发 https://dev.to/_e7afa21fa3c5d8756c6531/how-i-built-an-idle-loop-that-keeps-my-ai-agent-working-between-tasks-309a |
| GitHub awesome-list PR | ⏸️ Token 权限不足，需扩展 |
| Discord Nous Research | ✅ 已发帖 + 有人回复讨论 |
| Reddit | ❌ 被删（新号自推限制） |
| HN | ❌ 新号被限制 |

## 💡 深度对比笔记

详见 wiki:
- `agent-comparison-idle-loop.md` — ARIS vs GenericAgent vs 我们
- `agent-comparison-self-evolving.md` — 自进化 skill 树对比

---

# Daily Digest — 2026-04-22 23:58 (Autonomous Drive Idle Loop)

## 🏥 ENSURE_CONTINUATION
- **Disk**: 17G/118G (15%) — healthy
- **RAM**: 5.9G available / 7.5G total — healthy
- **Load**: 0.08 — idle
- **Uptime**: 3 days, 12 hours
- **Backups**: Latest backup_20260422-2226.tar.gz (2.5M) — recent

## 🔍 AGENT_RESEARCH — AI Agent Ecosystem Scan

### Top AI Agent Projects (by stars, pushed recently)
| Stars | Repo | Highlight |
|-------|------|-----------|
| 147K | langflow-ai/langflow | Visual agent/workflow builder, very active |
| 139K | langgenius/dify | Production agentic workflow platform |
| 136K | x1xhlol/system-prompts-and-models-of-ai-tools | System prompt leaks for all major agents |
| 134K | langchain-ai/langchain | Agent engineering platform |
| 110K | NousResearch/hermes-agent | **Our platform!** v0.10.0, 110K stars |
| 107K | Shubhamsaboo/awesome-llm-apps | 100+ runnable agent apps |
| 102K | google-gemini/gemini-cli | Gemini in terminal |
| 89K | browser-use/browser-use | Web automation for agents |
| 79K | infiniflow/ragflow | RAG engine with cutting-edge features |

### Coding Agent Landscape (recently pushed)
| Stars | Repo | Highlight |
|-------|------|-----------|
| 164K | affaan-m/everything-claude-code | Claude Code optimization system |
| 148K | anomalyco/opencode | Open source coding agent |
| 117K | anthropics/claude-code | Claude Code official |
| 77K | openai/codex | OpenAI coding agent in terminal |
| 66K | thedotmack/claude-mem | Auto-capture Claude Code sessions |
| 63K | bytedance/deer-flow | Long-horizon SuperAgent |
| 61K | cline/cline | Autonomous coding in IDE |

### Autonomous Agent Frameworks
| Stars | Repo | Highlight |
|-------|------|-----------|
| 50K | crewAIInc/crewAI | Multi-agent orchestration, very active |
| 18K | elizaOS/eliza | Autonomous agents for everyone |
| 17K | agent0ai/agent-zero | Agent Zero framework |
| 7K | MervinPraison/PraisonAI | 24/7 AI workforce |
| 466 | cordum-io/cordum | Agent control plane with policy enforcement |

### MCP Server Ecosystem
| Stars | Repo | Highlight |
|-------|------|-----------|
| 31K | microsoft/playwright-mcp | Browser automation via MCP |
| 29K | github/github-mcp-server | GitHub official MCP |
| 25K | PrefectHQ/fastmcp | Fast Pythonic MCP builder |
| 22K | activepieces/activepieces | 400+ MCP servers for agents |
| 15K | googleapis/mcp-toolbox | Database MCP server |
| 14K | GLips/Figma-Context-MCP | Figma layout for coding agents |
| 13K | casdoor/casdoor | Agent-first IAM / MCP gateway |
| 10K | mcp-use/mcp-use | Fullstack MCP framework |
| 9.5K | modelcontextprotocol/inspector | Visual MCP testing |
| 8.8K | awslabs/mcp | Official AWS MCP servers |

### Hermes Agent Updates
- **Latest Release**: v0.10.0 (2026-04-16) — "The Tool Gateway release"
  - Nous Tool Gateway: web search, image gen, TTS, browser via subscription
  - 180+ commits in this release cycle
- **Recent Commits** (2026-04-22):
  - Slack reactions lifecycle fix + SLACK_REACTIONS env toggle
  - Kimi /coding thinking block survival fix
  - Author map updates
- **Release cadence**: ~5 days between releases (v0.6→v0.7→v0.8→v0.9→v0.10)

## 🔌 Notable New Tools & Plugins
- **cordum** — Agent control plane with pre-execution policy enforcement and approval gates. Could be relevant for autonomous drive safety.
- **claude-mem** (66K stars!) — Auto-capture coding sessions. Analogous to our hindsight memory.
- **n8n-claw** — Autonomous AI agent built in n8n with RAG memory + MCP skills. Interesting architecture reference.
- **anda** — Rust-based AI agent framework. Worth watching for performance.
- **MakerAi** — Delphi AI OS with RAG 2.0 and MCP protocol. Niche but interesting.

## 💡 Key Observations
1. **Coding agents dominate** — Claude Code ecosystem (164K stars for everything-claude-code) shows massive community investment in terminal-based coding agents
2. **MCP standardization accelerating** — 9K+ star projects for MCP tooling; FastMCP at 25K shows developer adoption
3. **Agent governance emerging** — cordum (policy enforcement), casdoor (agent IAM) signal a new category
4. **Hermes competitive position** — 110K stars, strong release cadence, Tool Gateway differentiator
5. **System prompts as intelligence** — 136K stars for system-prompts repo indicates high interest in agent internals

## 🎯 Action Items
- [ ] Monitor cordum for policy enforcement patterns applicable to autonomous-drive
- [ ] Evaluate fastmcp for building custom MCP servers
- [ ] Watch for Hermes v0.11.0 release (expected ~Apr 21)

---

## 📰 Update 2 (2026-04-23 00:15)

### 已完成

| 任务 | 状态 | 详情 |
|------|------|------|
| GitHub awesome-list PR | ✅ Branch pushed | fork `autopopo-cyber/awesome-ai-agents`, branch `add-autonomous-drive-spec` |
| PR 创建 | ⏳ 需手动 | https://github.com/autopopo-cyber/awesome-ai-agents/pull/new/add-autonomous-drive-spec |
| 凭证保险柜修复 | ✅ | 去重 github section, 补全 token |
| 全量备份 | ✅ | `~/.hermes/backups/20260423-001041/` |

### 自改进计划

| 改进 | 来源 | 优先级 | 风险 |
|------|------|--------|------|
| L1 ≤30行索引 | GenericAgent | P0 | 低 |
| 收尾3步硬约束 | GenericAgent | P0 | 低 |
| 自动结晶(≥3次同类操作→skill) | GenericAgent | P1 | 中 |
| Meta-Optimize(日志→skill patch) | ARIS | P1 | 中 |
| 跨模型对抗审查 | ARIS | P2 | 低 |
| "No Execution, No Memory" | GenericAgent | P2 | 中(需改Hindsight) |

### 待用户操作

1. 打开 https://github.com/autopopo-cyber/awesome-ai-agents/pull/new/add-autonomous-drive-spec 创建 PR
2. 考虑安装 SkillClaw (`skillclaw setup`)
3. 密码轮换（QQ邮箱优先）

---

## 📰 Update 3 (2026-04-23 00:40)

### Hermes v0.11 监控
- **状态**: 尚未发布（v0.10.0 为最新，发布于 2026-04-16）
- **已 7 天无新版本**，超过此前 ~5 天的发布节奏
- **近期 commits** (Apr 22): Slack reactions lifecycle fix, Kimi thinking block survival fix, error classifier 404 fix, file tool pagination bounds
- **无开放 milestones** — 可能 v0.11 正在积累较大变更
- **预期**: 可能包含自进化 Phase 2（Tool 描述优化）

### Cordum 深度分析完成
- **仓库**: cordum-io/cordum (466⭐, Go, BUSL-1.1)
- **核心**: Agent Control Plane — Before/During/Across 治理框架
- **与我们的关系**: Busy-lock 是 Cordum Safety Kernel 的极简版；熔断器概念值得借鉴
- **结论**: 借鉴理念，不引入架构（零依赖 vs Docker/K8s 栈）
- **Wiki 笔记**: ~/llm-wiki/cordum-agent-governance-deep-dive.md


---

## 2026-04-23 01:11 — Agent Ecosystem Scan

### Agent Frameworks (recently pushed)
| Project | Stars | Notes |
|---------|-------|-------|
| langchain | 134.5K | Still dominant |
| crewAI | 49.6K | Active |
| langgraph | 30K | Graph-based agents |
| haystack | 24.9K | Modular orchestration |
| openai-agents-python | 24.6K | 🆕 OpenAI's lightweight multi-agent framework |
| mastra | 23.2K | TypeScript-based |
| eliza | 18.2K | Autonomous agents |
| pydantic-ai | 16.6K | Pydantic way |

### Coding Agents
| Project | Stars | Notes |
|---------|-------|-------|
| everything-claude-code | 164K | Skills + instincts + memory |
| opencode | 147.6K | Open source coding agent |
| claude-code | 116.9K | Anthropic's terminal agent |
| codex | 77K | OpenAI's terminal agent |
| claude-mem | 65.6K | 🆕 Memory compression plugin for Claude Code |

### MCP Servers
| Project | Stars | Notes |
|---------|-------|-------|
| playwright-mcp | 31.2K | |
| github-mcp-server | 29.2K | |
| fastmcp | 24.8K | |
| activepieces | 21.8K | 🆕 ~400 MCP servers for AI agents |
| mcp-toolbox | 14.8K | |

### Hermes Monitoring
- **v0.10.0 still latest** (Apr 16) — 7 days, no v0.11 yet (previous cadence ~5 days)
- Recent commits: Slack reactions fix, Kimi thinking block, error classifier 404 fix

### Key New Entries
1. **openai-agents-python** (24.6K⭐) — OpenAI's official lightweight multi-agent framework. Worth watching for comparison.
2. **claude-mem** (65.6K⭐) — Automatic session capture + compression for Claude Code. Parallel to our Hindsight approach.
3. **activepieces** (21.8K⭐) — 400+ MCP servers marketplace. Potential integration discovery source.


---

## 2026-04-23 01:47 — Idle Loop Scan

### Status
- System: healthy (disk 15%, RAM 6.4G, load 0.08, uptime 3d14h)
- Drive loops: all in cooldown (last full sweep 01:14, <1h ago)
- Hermes: still v0.10.0 (Apr 16), 7 days no release — v0.11 may be imminent given ~3-5 day cadence

### Research: Anda (Rust Agent Framework)
- **anda** (412⭐, Rust, Apache-2.0) — AI agent framework with ICP blockchain + TEE support
- Key concept: "perpetual memory" via blockchain storage → agents can be "immortal"
- Architecture: CLI + Core + Engine + Server + Web3 client
- **Verdict**: Web3-native, not relevant for Hermes adoption. Interesting concepts (perpetual memory, composable agent networks) but our wiki+Hindsight approach is more practical.
- Wiki note: ~/llm-wiki/anda-rust-agent-deep-dive.md

### Research: openai-agents-python Updates
- Now at v0.14.4 (Apr 21) — actively developed
- Recent: BoxMount support, sandbox path normalization, Daytona integration, MongoDB extension
- Rapid release cadence: v0.14.2 (Apr 18) → v0.14.3 (Apr 20) → v0.14.4 (Apr 21)
- Focus areas: sandboxing, tool origins, multi-agent orchestration

### Cooldown Status
- ENSURE_CONTINUATION: next due ~02:14
- EXPAND_CAPABILITIES: next due ~03:14
- EXPAND_WORLD_MODEL: next due ~05:14

---

## 2026-04-23 02:20 — Idle Loop Digest

### Agent 生态动态
- **GenericAgent** (5886⭐) — Self-evolving agent, ~3K lines core, 5-layer memory (L0-L4), auto-crystallize per task, 6x token efficiency (30K vs 200K+). arXiv paper 2604.17091.
- **ARIS** (7230⭐) — Pure Markdown skills for autonomous ML research, cross-model adversarial review (Claude executor + external LLM reviewer), /meta-optimize self-evolution, v0.4.4 released 2026-04-20.
- Key insight: GenericAgent crystallizes every task (not just ≥3x), ARIS proves adversarial > self-play review.

### Hermes 生态监控
- **v0.10.0** still latest (7 days since release, no v0.11 tag yet)
- **10 PRs merged since v0.10.0** — subagent observability overlay (#14045, major), API call tracking (#14004), richer hindsight metadata (#13987), Slack reaction lifecycle fix (#14050), Kimi thinking block fix (#14018), error classifier 404 fix (#14013), file tool pagination bounds (#14012), .env sanitization (#14007), QQ onboard refactor (#14006), plugin memory auto-coerce (#14005)
- **Subagent observability** is significant — `/agents` overlay for live monitoring, per-branch cost/token/file rollups, kill + pause controls
- No open milestones, 4038 open PRs — high activity repo

### 插件/技能发现
- No new MCP servers or skills beyond what was already tracked
- **Actionable**: Subagent observability feature in Hermes could improve our idle loop monitoring once v0.11 releases

### 可落地的改进 (from GenericAgent + ARIS comparison)
1. 降低 auto-crystallize 阈值 (≥3x → ≥2x)
2. 实现 /meta-optimize (分析 idle-log + skill 使用频率)
3. 跨模型审查验证 (关键操作后用不同模型验证)
4. 安全门控模式 (借鉴 ARIS rebuttal 3-gate design)


---

## 2026-04-23 02:55 — Idle Loop Digest (AGENT_RESEARCH focus)

### 工具链集成机会深度分析
- **FastMCP v3.2.4** (24,780⭐, PrefectHQ) — Auth-scoped background tasks (breaking change), FileUpload security hardening (3 fixes), v2.x still maintained (v2.14.7). **Integration path**: Update native-mcp skill docs, leverage auth-scoped tasks pattern for Hermes MCP servers.
- **openai-agents-python v0.14.4** (24,595⭐) — 3 releases in 3 days (Apr 18→21), sandbox focus: BoxMount, Daytona workspace, extra path grants, MongoDB session backend, tool origin metadata per-call. **Tracking only** — OpenAI-ecosystem-bound, incompatible with Hermes multi-model architecture.
- **Activepieces v0.81.6-rc** (21,800⭐) — 400+ MCP marketplace pieces, 84-463x faster diff endpoint. **Deferred** — RPA project paused.

### Hermes 生态监控
- v0.10.0 still latest (7 days since Apr 16 release)
- "chore: uptick" commit (Apr 22) was dependency bump, NOT version bump
- Subagent observability overlay (#14045) merged — significant for idle loop monitoring
- No v0.11 tag yet, but release cadence suggests imminent

### Agent 生态排行更新
- langchain: 134,510⭐ | crewAI: 49,555⭐ | langgraph: 30,034⭐ | haystack: 24,949⭐
- openai-agents-python: 24,595⭐ | mastra: 23,224⭐ | eliza: 18,231⭐ | pydantic-ai: 16,554⭐

### 可落地的改进
1. 更新 native-mcp skill 文档记录 FastMCP auth-scoped tasks 模式
2. 研究 Hermes 沙箱化方案（参考 openai-agents-python BoxMount/Daytona）
3. RPA 项目启动时评估 Activepieces MCP marketplace 集成

---

## 2026-04-23 03:29 — Idle Loop Report

### System Health
- Disk: 15% used (97G free), RAM: 1.5G used/6G avail, Load: 0.68, Uptime: 3d16h
- All processes running (gateway, web-ui, hindsight)
- Backup: backup_20260423-0329.tar.gz (2.5M), rotation to 5 verified

### ENSURE_CONTINUATION ✅
- Health check passed, skill integrity: 92 skills, 5 sampled OK
- Known: aiohttp unclosed session warnings in journalctl (from cron subprocess exits, harmless)

### EXPAND_CAPABILITIES ✅
- No new patterns to crystallize (no user sessions since last loop)
- No critical skill patches needed
- Idle log pattern analysis: 17 entries, stable cadence, 4 historical errors (all addressed)

### AGENT_RESEARCH Update
- **Hermes v0.10.0 still latest** (7 days, Apr 16). Previous cadence was ~5 days between releases. Recent commits (Apr 22): debug share/cap/truncation fixes, subagent observability overlay merge (#14045). Commits slowed compared to earlier weeks — possible pre-release consolidation.
- **Top-tier ecosystem stable**: langflow(147K), dify(139K), langchain(135K), hermes(110K), gemini-cli(102K). No new entrants in top 8.
- No new notable autonomous/coding agent repos this cycle.


---

## 🔄 05:06 扫描更新 — EXPAND_WORLD_MODEL

### 新发现项目

#### everything-claude-code (164K ⭐)
- **URL**: https://github.com/affaan-m/everything-claude-code
- **描述**: Agent harness performance optimization system — skills, instincts, memory, security, research-first development
- **兼容**: Claude Code / Codex / Opencode / Cursor
- **语言**: JavaScript | **创建**: 2026-01-18 | **最近推送**: 2026-04-21
- **Topics**: ai-agents, anthropic, claude, claude-code, developer-tools, llm, mcp, productivity
- **对我们的价值**: 🔥🔥 与 autonomous-drive 理念高度重合（skills + memory + instincts），值得深入研究其架构
- **对比**: 我们的 skill 系统更灵活（任意 agent），everything-claude-code 更专注 Claude 生态优化

#### claude-mem (65.7K ⭐)
- **URL**: https://github.com/thedotmack/claude-mem
- **描述**: Auto-capture Claude Code sessions → AI compression → inject context into future sessions
- **语言**: TypeScript | **创建**: 2025-08-31 | **最近推送**: 2026-04-22
- **Topics**: ai-memory, chromadb, claude-agent-sdk, embeddings, long-term-memory, mem0, openmemory, rag, sqlite, supermemory
- **对我们的价值**: 🔥🔥 记忆方案参考 — 我们有 Hindsight，claude-mem 用 ChromaDB+SQLite 方案不同
- **技术栈**: Claude agent-sdk + ChromaDB + SQLite — 比我们的 Hindsight embedding 更轻量

### MCP 生态更新

| 项目 | Stars | 最近推送 | 变化 |
|------|-------|---------|------|
| playwright-mcp | 31.2K | 2026-04-21 | 稳定 |
| github-mcp-server | 29.2K | 2026-04-22 | 稳定 |
| fastmcp | 24.8K | 2026-04-22 | ↑ 从上次24.6K |
| activepieces | 21.8K | 2026-04-22 | ↑ 从上次21.5K |
| mcp-toolbox | 14.8K | 2026-04-22 | ↑ 从上次14.6K |
| Figma-Context-MCP | 14.5K | 2026-04-20 | 🆕 新入榜 |

### Hermes 版本状态
- 最新: v0.10.0 (v2026.4.16) — 无新 release
- 距上次 release: 7天
- 预计 v0.11 可能下周

### Agent 框架排名（by stars, pushed >2026-04-18）

| 框架 | Stars | 语言 | 最近推送 |
|------|-------|------|---------|
| langchain | 134.5K | Python | 04-22 |
| crewAI | 49.6K | Python | 04-22 |
| langgraph | 30.0K | Python | 04-22 |
| haystack | 25.0K | MDX | 04-22 |
| openai-agents-python | 24.6K | Python | 04-22 |
| mastra | 23.2K | TypeScript | 04-22 |
| eliza | 18.2K | TypeScript | 04-22 |
| camel | 16.8K | Python | 04-19 |

---

## 2026-04-23 07:18 — Morning Check

### Hermes 生态监控（7天无新版本）
- **当前版本**: v0.10.0 (v2026.4.16), 7 days old
- **Release 节奏**: v0.6→v0.7=3d, v0.7→v0.8=5d, v0.8→v0.9=5d, v0.9→v0.10=3d, **v0.10→?=7d+ (overdue)**
- **v0.11 预测**: 可能在今日或明日发布（历史最长间隔5天）

### 重要 Open PRs（10个最新更新）
| PR | 标题 | 关键性 |
|----|------|--------|
| #14191 | nsjail backend for local sandboxing | 🔥 新特性 |
| #14190 | cron context_from field for output chaining | 🔥 与 idle loop 相关 |
| #14175 | plugin slash commands on all platforms | 🔥 重大特性 (teknium1) |
| #14178 | Sentry observability integration | 📊 监控 |
| #14179 | gateway: recover stale pid and planned restart | 🐛 稳定性 |
| #14188 | normalize tool names at dispatch (LLM drift) | 🐛 鲁棒性 |
| #14187 | defensive type coercion for todos | 🐛 防御性 |
| #13481 | systematic ty type-checker cleanup | 🧹 代码质量 |
| #12837 | concise CLI output + inference timer | ✨ 体验 |
| #12840 | copilot live /models context-window resolver | 🐛 修复 |

### 最近合并的 Commits（Apr 22-23）
- MiMo v2.5 Pro model added to OpenRouter + Nous Portal
- TUI polish merged (#14145)
- Context compressor guard for structured messages
- Feishu @mention context preservation
- Tailscale CGNAT recognition for Ollama timeouts
- Non-blocking executor shutdown on async timeout

### 系统健康
- Disk: 15% (97G free), RAM: 6.1G avail, Load: 0.39, Uptime: 3d20h
- All services: gateway ✅, web-ui ✅, hindsight-api ✅, mihomo ✅

### WIKI_MAINTENANCE 完成
- 创建 RPA 知识索引（7篇文档整合）
- 创建架构基础设施索引（7篇文档整合）

### 2026-04-23 08:28 — Hermes v0.11 Imminent Signal

**Hermes Monitoring**: v0.10.0 still latest (7 days old), but strong v0.11 signals detected:
- **9 PRs merged in ~8h** (Apr 22-23): browser upgrade 0.13→0.26, MiMo v2.5 Pro, gemma-4 support, gateway PID recovery, RPC socket permissions, nix platform fix, Lemonade ctx_size
- **Notable open PRs for v0.11+**: #14191 (nsjail sandboxing backend), #14190 (cron context_from output chaining), #14211 (configurable MCP toolset inheritance for delegate_task), #14205 (OpenAI TTS instructions), #14207 (SSL/TLS retry as transport)
- No open milestones, no v0.11 tag yet. Release cadence was ~3-5 days; current gap is 7 days — likely a larger release being prepared.

**System Health**: Disk 15% (97G free/118G), RAM 6.1Gi avail, Load 0.05, Uptime 3d21h — all normal.

## 2026-04-23 09:01 — World Model Scan

### GitHub AI Agent Landscape
- **gemini-cli** (Google): 102K stars — open-source terminal AI agent using Gemini. Major competitor to hermes-agent in the CLI agent space.
- **hermes-agent**: 110K stars — pushed 2026-04-23, actively maintained.
- **langflow**: 147K stars — visual agent/workflow builder, production-ready.
- **system-prompts-and-models-of-ai-tools**: 135K stars — full system prompts from Devin, Cursor, Claude Code, Manus, etc. Valuable intelligence source for agent design.
- **awesome-llm-apps**: 107K stars — 100+ runnable agent/RAG apps.

### Hermes Ecosystem Update
- Latest release still **v0.10.0** (April 16, 7 days ago)
- Recent merged PRs: #14244 (compressor focus_topic fix), #14243 (Anthropic base_url fix) — salvage PRs, v0.11 preparation continues
- No v0.11 tag yet — release cadence ~5 days suggests imminent release
- hermes-agent at 110K stars, steady growth

### MCP Server Ecosystem
- playwright-mcp (Microsoft): 31K stars — dominant browser automation MCP
- github-mcp-server: 29K stars — official GitHub MCP
- fastmcp: 25K stars — Pythonic MCP framework, rapid growth
- Figma-Context-MCP: 14K stars — design-to-code integration, popular with Cursor users
- activepieces: 22K stars — 400+ MCP servers, AI workflow automation
- mcp-toolbox (Google): 15K stars — database-focused MCP

### Key Observation
- gemini-cli entering the terminal agent space is significant — Google bringing Gemini directly to CLI competes with hermes-agent's niche
- system-prompts repo at 135K stars shows strong community interest in understanding agent internals


---

## 2026-04-23 10:47 — Autonomous Drive Sweep

### ENSURE_CONTINUATION ✅
- Disk: 16%/96G free, RAM: 5.5G avail, Load: 0.14, Uptime: 3d23h
- Backup: backup_20260423-1044.tar.gz (57K), rotation verified (5 kept)
- Skill integrity: 92 skills, 5 sampled — all frontmatter valid
- Cron: 1 job active (autonomous-drive-idle-loop, next 11:13)

### EXPAND_CAPABILITIES ✅
- No new patterns to crystallize (cron-only sessions, no user interaction)
- No critical skill patches needed
- Idle log: 30 unique timestamp entries, no duplicates
- No recurring failure patterns

### EXPAND_WORLD_MODEL ✅
- **Hermes v0.11 monitoring**: v0.10.0 still latest (Apr 16, 7 days old). Release cadence overdue (~5d avg).
  - Merged: #14273 (title max_tokens), #14274 (skills cleanup)
  - Open notable PRs: #14300 (alibaba URL consolidation), #14299 (reject unsupported taps), #14292 (send_file tool), #14293 (retry JSON decode, P1), #14294 (side conversations)
  - v0.11 prep continues — multiple open PRs suggest a substantial release
- **Agent ecosystem**: Stable rankings
  - langflow 147K⭐, dify 139K⭐, langchain 134.5K⭐, hermes-agent 111K⭐ (+742 since last), gemini-cli 102K⭐
  - browser-use 89.6K⭐, ragflow 78.8K⭐
- **MCP ecosystem**: activepieces 21.8K⭐ (🆕 — ~400 MCP servers), casdoor 13.5K⭐ (🆕 — agent IAM), mcp-use 9.8K⭐ (🆕 — fullstack MCP framework)
  - Top: playwright-mcp 31.3K, github-mcp 29.2K, fastmcp 24.8K, mcp-toolbox 14.8K, Figma-Context 14.5K

---

## 🕐 第三轮扫描（~22:30）

### Hermes 生态全扫描（awesome-hermes-agent 1628⭐）

**P0 发现 — rtk-hermes 插件**
- Shell 输出压缩 60-90%，96.6% 效率
- 零配置自动加载，gateway boot 时自动启用
- **直接解决我一直遇到的截断问题**
- → 待用户确认后安装

**P0 发现 — PR #2044**
- 修复 mid-turn context compression 静默数据丢失
- 和我们遇到的问题一致
- → 追踪合并进度

**P1 发现 — 多 Agent Swarm 生态**
- Ankh.md: TAW × Hermes swarm 框架（experimental）
- opencode-hermes-multiagent: 17 个专业 agent（beta）
- bigiron: AI-native SDLC + 代码图（beta）
- 我们的方向一致，但多了生存驱动视角

**P1 发现 — Level-Up Blueprints**
- 官方推荐了 5 个组合栈
- Memory stack: Hermes → Hindsight → plur → flowstate-qmd
- Self-improvement: DSPy+GEPA + regression + lintlang
- Multi-agent: ACP routing + swarm executors + specialized roles

**完整分析**: ~/llm-wiki/hermes-ecosystem-deep-dive.md
