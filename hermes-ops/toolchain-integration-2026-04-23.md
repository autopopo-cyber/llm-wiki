# 工具链集成机会深度分析 — 2026-04-23

## FastMCP (PrefectHQ) — 24,780⭐

**当前版本**: v3.2.4 (2026-04-14)

### 关键变化
- **Background tasks scoped to auth context** — 不再绑定 MCP session，认证用户启动的任务在 session 断开后继续运行。Breaking change for session-scoped 语义。
- **安全增强** — FileUpload 安全加固（3 项），防止通过恶意文件上传攻击 MCP server。
- **v2.x 仍维护** — v2.14.7 同日发布（fakeredis 兼容修复），说明 v2→v3 迁移还在进行中。

### 对 Hermes 的集成价值
1. **直接可用**: Hermes 已内置 MCP client (native-mcp skill)，fastmcp 可作为 Python MCP server 框架快速扩展工具
2. **Background task 模式**: v3.2.4 的 auth-scoped tasks 与我们的 idle loop 设计理念一致 — 任务不依赖连接持续
3. **安全考虑**: FileUpload 加固意味着 MCP server 更安全，适合暴露外部接口

### 不推荐集成的部分
- fastmcp 的 task management 是可选 extra (`pip install fastmcp[tasks]`)，依赖 fakeredis/pydocket — 对我们而言过重
- 我们的 idle loop 用 cron + lock manager 已经是更轻量的方案

## OpenAI Agents Python — 24,595⭐

**当前版本**: v0.14.4 (2026-04-21)

### 快速迭代节奏
- v0.14.2 (Apr 18) → v0.14.3 (Apr 20) → v0.14.4 (Apr 21)
- 3 天 3 个版本，主要围绕 **sandbox 安全**

### 关键特性
1. **BoxMount support** (v0.14.4) — 容器化沙箱挂载，Agent 文件操作在隔离环境中
2. **MongoDB session backend** (v0.14.2) — Agent 对话持久化
3. **Sandbox extra path grants** (v0.14.2) — 精细化控制 Agent 文件系统访问范围
4. **Tool origin metadata** (v0.14.2) — 追踪工具调用来源，可审计

### 对 Hermes 的启示
1. **Sandbox 模式值得借鉴**: Hermes 目前 agent 直接访问文件系统，无沙箱隔离。openai-agents-python 的 BoxMount/Daytona 模式可作为安全增强参考。
2. **Tool origin tracking**: 与 Hermes 的 hindsight 可观测性目标一致，但更细粒度（per-tool-call level）
3. **不建议直接采用**: openai-agents-python 是 OpenAI 生态绑定框架，与 Hermes 的多模型架构不兼容

## Activepieces — 21,800⭐

**当前版本**: v0.81.6-rc (2026-04-09)

### 定位
- 开源 Zapier 替代品，400+ MCP marketplace pieces
- 不是 Agent 框架，是自动化工作流平台
- 最新版本重点是性能优化（84-463x faster diff endpoint）

### 对 Hermes 的集成价值
- **MCP marketplace 可直接使用**: Activepieces 的 400+ pieces 可作为 MCP tools 接入 Hermes
- **RPA 集成路径**: 当 RPA 项目启动时，Activepieces 可作为低代码层
- 当前不需要：RPA 项目暂停中

## 综合建议

| 优先级 | 项目 | 行动 | 时机 |
|--------|------|------|------|
| 🔴高 | FastMCP v3 | 更新 native-mcp skill 文档，记录 auth-scoped tasks 模式 | 现在 |
| 🟡中 | Sandbox 安全 | 研究 Hermes 沙箱化方案（参考 BoxMount） | v0.11 发布后 |
| 🟢低 | Activepieces | RPA 项目启动时再评估 | 项目恢复时 |
| ⚪暂缓 | openai-agents-python | 仅跟踪版本，不采用 | 持续 |
