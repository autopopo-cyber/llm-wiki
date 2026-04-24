# Agent 协调管理系统调研 — 2026-04-24

## 🏆 首选方案：hermes-a2a + 自建 Dashboard

### hermes-a2a (iamagenius00/hermes-a2a, 43⭐)

Hermes 原生 A2A 协议插件 — 零修改安装，即时唤醒，会话注入。

**核心功能：**
- P2P 通信：双向结构化消息（intent, expected_action, reply_to_task_id）
- 即时唤醒：HMAC webhook 触发
- 会话注入：消息直接进入运行中 session 的上下文
- 任务状态：pending/working/completed，LRU 缓存 2000 任务
- 工具：`a2a_discover`（发现能力）、`a2a_call`（发任务）、`a2a_list`（列 agent）
- 审计：`~/.hermes/a2a_conversations/` + `a2a_audit.jsonl`
- 安全：9 层 prompt 注入过滤 + Bearer token + 限流

**安装步骤：**
1. 所有机器：`git clone https://github.com/iamagenius00/hermes-a2a && cd hermes-a2a && ./install.sh`
2. `.env` 添加：`A2A_ENABLED=true`, `A2A_PORT=8081`, `A2A_AUTH_TOKEN`, `A2A_WEBHOOK_SECRET`
3. 协调者配置：列出 3 个执行者的 Tailscale IP
4. 重启 gateway：`hermes gateway run --replace`
5. 使用：`/a2a agents`（状态）、`a2a_call`（发任务）、`a2a_discover`（能力查询）

### 自建 Dashboard（待开发）

基于 hermes-a2a 的数据构建：
- 轮询各 agent 的 A2A 端点获取状态
- 读取 `a2a_conversations/` 和 `a2a_audit.jsonl` 显示消息历史
- 心跳：A2A 端点 + Hermes API `/v1/models` 可达性
- 任务流：assignment → in-progress → completion

## 🥈 备选方案

### HiClaw (agentscope-ai/HiClaw, 4,250⭐)
- Manager-Workers 架构，原生 Hermes Worker 支持
- Matrix 房间通信（Element Web 可看全部对话）
- 需要 Matrix 服务器（Synapse）+ MinIO
- Docker-compose 一键部署
- 适合需要 Web UI 可视化的场景

### Edict (cft0808/edict, 15,431⭐) — 三省六部
- 🟢Active/🟡Stalled/🔴Alert 心跳监控
- 完整任务生命周期 + 审计 + 干预（stop/cancel/resume）
- Web Dashboard
- 但为 OpenClaw 设计，需适配 Hermes

### hermes-dashboard (Kori-x/hermes-dashboard, 18⭐)
- 单 agent 实时监控 + 自动 wiki
- React 19 + WebSocket
- 适合作为每个执行者的健康看板

## 其他框架对比

| 项目 | Stars | 任务追踪 | Agent 通信 | 心跳 | Web UI | 适配 Hermes |
|------|-------|----------|-----------|------|--------|------------|
| hermes-a2a | 43 | ✅ | ✅ | ⚠️ | ❌ | 🏆 原生 |
| HiClaw | 4,250 | ✅ | ✅ | ✅ | ✅ | ✅ Worker |
| Edict | 15,431 | ✅ | ✅ | ✅ | ✅ | 需适配 |
| CrewAI | 49,778 | ✅ | ❌ | ❌ | 💰 | ❌ |
| AutoGen | 57,395 | ✅ | ✅ | ❌ | ✅ | ❌ |
| LangGraph | 30,262 | ✅ | ✅ | ❌ | ✅ | ❌ |
| AgentScope | 24,318 | ✅ | ✅ | ⚠️ | ⚠️ | ❌ |
