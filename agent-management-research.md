# Agent 管理系统调研

## 调研结论：无现成方案，需自建轻量系统

GitHub 上没有单一项目满足全部 6 项需求（任务追踪 + 心跳 + 时间预估 + 关键路径 + A2A 日志 + 轻量agent专用）。

| 项目 | Stars | 任务追踪 | 心跳 | 时间预估 | 关键路径 | A2A日志 | 轻量 | 适配度 |
|------|-------|---------|------|---------|---------|--------|------|--------|
| CrewAI | ~30K | 基础 | ❌ | ❌ | ❌ | ❌ | 中 | 差 |
| AutoGen | ~40K | ❌ | ❌ | ❌ | ❌ | ✅对话 | 重 | 差 |
| LangGraph | ~10K | ✅状态+检查点 | ❌ | ❌ | ⚠️图可视化 | ❌ | 重 | 部分 |
| AgentOps | ~2K | ⚠️事件 | ❌ | ❌ | ❌ | ✅事件 | 轻 | 部分 |
| Agent Protocol | ~1.5K | ✅规范 | ❌ | ❌ | ❌ | ❌ | 极轻 | 部分 |

## 推荐方案：基于 Agent Protocol 规范自建

### 架构
```
协调者 (云服务器)
├── Task Manager (SQLite/JSON)
├── Heartbeat Monitor (Tailscale 网络 TCP 探测)
├── Communication Logger (写入 MemOS)
└── Dashboard (Mermaid.js in wiki)
```

### 核心组件

1. **任务追踪** — 采用 Agent Protocol 的 task/step 模型
   - Task: {id, title, assignee, status, created, deadline, priority}
   - Step: {id, task_id, title, status, started, completed, estimated_min}

2. **心跳监控** — 每个下属 agent 暴露 /health 端点
   - 协调者每 30s ping 一次（cron）
   - 心跳响应: {status, current_task, progress%, last_step, uptime}
   - 超时 3 次 → 标记离线 + 告警

3. **时间预估 + 截止** — 任务模型加 estimated_duration + deadline
   - 下属接到任务时先调研分解，返回时间表
   - 协调者对比实际 vs 预估，超时主动问询

4. **关键路径** — Mermaid.js 甘特图（在 wiki 渲染）
   - 从任务依赖关系自动生成
   - 标注关键节点（blockers）

5. **A2A 通信日志** — 所有 inter-agent 消息经过协调者路由
   - 写入 MemOS，带 metadata（sender/recipient/type/timestamp）

6. **Hermes 集成** — 每个 agent 薄层 AgentManager 模块
   - 暴露心跳端点
   - 接收任务分配
   - 汇报进度
   - 记录通信

### 预计工作量：2-3 天
