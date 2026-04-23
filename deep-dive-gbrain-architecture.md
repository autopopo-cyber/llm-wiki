# GBrain 架构深度分析

> 日期: 2026-04-23 | 来源: garrytan/gbrain (10.5K⭐)

## 一句话

GBrain 是 Garry Tan 的 "Opinionated OpenClaw/Hermes Brain" — 一个完整的知识驱动的 Agent 操作系统，不是工具集，是工作方式。

## 核心架构

```
信号（消息/邮件/会议）→ Brain → READ → ENRICH → WRITE → 回复
                              ↑                          |
                              └── Back-link (Iron Law) ──┘

定时任务 → Minions Job Queue → Postgres → 执行 → 报告
```

## 关键组件

### 1. Minion Orchestrator（群控核心）
- **Postgres-backed job queue**（比 Redis 更可靠，重启不丢任务）
- Jobs survive gateway restart
- Mid-flight steering（执行中可调整方向）
- Parent-child DAGs（任务依赖图）
- Rule of thumb: 超过 3 个 tool call 就用 Minion

### 2. Brain-Ops（知识核心）
- Brain-first lookup（先查脑，再查 API）
- READ → ENRICH → WRITE 循环（每次交互都触发）
- Iron Law: Back-linking（强制反向链接）
- User's statements = highest authority

### 3. Cron Scheduler（调度核心）
- Thin job prompts（只写"读 SKILL.md 然后执行"）
- Idempotency（可重复运行不出错）
- Quiet hours（时区感知安静时段）
- Schedule staggering（5 分钟错峰）

### 4. Skill 生态
- `skill-creator` / `skillify` — 自动生成 skill
- `signal-detector` — 信号检测
- `soul-audit` — 自我审计
- `daily-task-manager` — 每日任务管理

## 和 Auto-Drive 的对比

| 维度 | GBrain | Auto-Drive |
|------|--------|-----------|
| **知识方式** | 被动：每次交互 ENRICH | 主动：定时扫描 SCAN |
| **调度方式** | Minions (Postgres) | Cron + busy lock |
| **群控方式** | Minion Orchestrator | hermes_swarm.py (Redis) |
| **任务持久性** | Postgres (重启不丢) | File-based (简单但不持久) |
| **Prompt 策略** | Thin (引用 SKILL.md) | Thick (内嵌完整 prompt) |
| **幂等性** | 强制要求 | 未设计 |
| **理念基础** | Opinionated brain | 生存驱动 |

## 我们可以借鉴的 5 件事

### P0: Thin Job Prompts
**现在就改**。cron prompt 从 3000 字内嵌改为：
```
Load skill 'autonomous-drive' and run idle loop.
```
让 cron 只负责触发，skill 文件负责内容。

### P0: Idempotency
每个 cron job 必须幂等。用 checkpoint 文件追踪进度。
→ 已在 cron prompt 中加入"收尾 3 步"，但需要显式设计 checkpoint。

### P1: Brain-First Lookup
每次交互前，先查 wiki/Hindsight，再调外部 API。
→ 我们的 index.md 就在做这件事，但没强制。

### P1: Minion Queue 替代 Redis
Postgres-backed job queue 比我们当前的 file-based + Redis 更可靠。
→ 等本地服务器就位，考虑迁移到 Minions。

### P2: Quiet Hours
用户在时不打扰。类似我们的 busy lock，但更精细（时区感知）。

## 行动项

1. ✅ 立刻改 cron prompt 为 thin 模式
2. ⏳ 设计 checkpoint 机制
3. ⏳ 评估 Minion queue 迁移成本
4. ⏳ 考虑安装 gbrain 的关键 skill
