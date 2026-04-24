# Agent 协作管理系统调研

## 🏆 推荐：Mission-Control (4333⭐)

**GitHub**: builderz-labs/mission-control
**描述**: Self-hosted AI agent orchestration platform: dispatch tasks, run multi-agent workflows, monitor spend, and govern operations from one mission control dashboard.
**技术栈**: TypeScript + Next.js + SQLite
**许可证**: MIT
**特点**:
- ✅ 自部署（SQLite，无外部依赖）
- ✅ 任务分发和编排
- ✅ 多 agent 工作流
- ✅ 监控 dashboard
- ✅ 支持 OpenClaw
- ✅ MCP 协议支持
- ✅ 费用追踪

## 对比表

| 项目 | Stars | 语言 | 能看agent对话 | 自部署 | 轻量 | 与Hermes兼容 |
|------|-------|------|-------------|--------|------|-------------|
| **Mission-Control** | 4333 | TS | ✅ | ✅ | 中 | ✅ (MCP+OpenClaw) |
| CrewAI | 49778 | Python | 需+Langfuse | ✅ | 重 | 需适配 |
| AutoGen Studio | 57396 | Python | ✅ 内置 | ✅ | 中 | 需适配 |
| AgentScope (阿里) | ~5000 | Python | ✅ 内置Web UI | ✅ | 中 | 需适配 |
| LangGraph Studio | 30263 | Python | ✅ 图形化 | ✅ | 中 | 需适配 |
| RaccoonClaw | 17 | Python | ✅ | ✅ | 轻 | ✅ (OpenClaw) |
| pi-grove | 5 | TS | ✅ | ✅ | 轻 | 需适配 |

## 决策

**Mission-Control** 是最佳选择：
1. 自部署 + SQLite = 零外部依赖
2. 原生支持 OpenClaw/Hermes
3. MCP 协议 = 直接与 Hermes agent 集成
4. Dashboard = 可视化所有 agent 的任务和状态
5. MIT 许可证

**部署计划**:
1. 在始皇或骠骑上 Docker 部署 Mission-Control
2. 配置 MCP 连接到各 agent 的 Hermes gateway
3. 协调者通过 Mission-Control 分发任务和监控进度
