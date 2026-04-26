# Hermes 生态深度调研（2026-04-23）

> 来源：awesome-hermes-agent (1628⭐)、GitHub PR、官方 releases

## 一、Hermes v0.10.0 → v0.11 路线图

### 当前版本 v0.10.0（4月16日）
- Nous Tool Gateway（付费 Portal 订阅自动获得 web search/image gen/TTS/browser）
- Dashboard API call count 追踪
- 6 周 5 个大版本迭代

### 关键 Open PR（v0.11 候选）

| PR | 作者 | 内容 | 对我们的价值 |
|----|------|------|-------------|
| #2044 | Gutslabs | **修复压缩时静默丢失上下文** — 和我们遇到的问题一样！ | 🔥 P0 |
| #2084 | ardesh | **ANAMNESIS_ENGRAM** — 用遗传算法压缩对话为记忆切片 | 🟡 参考 |
| #2294 | Add1ct1ve | **视频分析** — ffmpeg 帧提取 + 视觉 LLM | 🟡 机器狗视觉可用 |

### PR #2044 详细分析

**问题**：mid-turn context compression 时，消息列表可能被压缩到比 conversation_history 还短，导致**静默数据丢失**。影响所有 gateway 平台（Telegram, Discord, Slack, WhatsApp）。

**和我们的关系**：我们遇到过类似问题——长对话中 tool result 被压缩掉。这个 PR 修复了根因。

## 二、高价值插件（按对我们价值排序）

### P0 — 立刻可装

| 插件 | Stars | 功能 | 理由 |
|------|-------|------|------|
| **rtk-hermes** | 新 | Shell 输出压缩 60-90%，96.6% 效率 | 🔥 直接解决截断问题！零配置自动加载 |
| **hermes-web-search-plus** | 新 | 多引擎搜索（Serper/Tavily/Exa） | 比内置搜索质量更好 |
| **evey-bridge-plugin** | 新 | Claude Code ↔ Hermes 桥接 | 跨 agent 协作 |

### P1 — 评估后安装

| 插件 | Stars | 功能 | 理由 |
|------|-------|------|------|
| **plur** | 新 | 共享记忆层（YAML engram 格式） | 多 agent 共享经验 |
| **hermes-plugin-chrome-profiles** | 新 | 切换 Chrome profile | 多账号操作 |
| **hermes-cloudflare** | 新 | Cloudflare 无头浏览器 | 绕过反爬 |

### P2 — 特定场景

| 插件 | Stars | 功能 | 理由 |
|------|-------|------|------|
| **hermes-payguard** | 新 | USDC 支付 + 额度限制 | 未来可能需要 |
| **agent-analytics** | 新 | 多项目分析仪表盘 | 监控多 agent 效率 |

## 三、Multi-Agent & Swarms 生态

| 项目 | Stars | 定位 | 和我们关系 |
|------|-------|------|-----------|
| **Ankh.md** | 新 | TAW × Hermes 多 agent swarm | 直接竞品/参考 |
| **bigiron** | 新 | AI-native SDLC + Supermodel 代码图 | 软件开发协作参考 |
| **opencode-hermes-multiagent** | 新 | 17 个专业 agent + 结构化通信 | 角色分工参考 |
| **gladiator** | 新 | 两个 AI 公司竞争 GitHub stars | 竞争动力学参考 |
| **zouroboros-swarm-executors** | 新 | 本地 executor handoff | 执行层参考 |

### 关键洞察

**Ankh.md** 和 **opencode-hermes-multiagent** 都在做"多 agent 协作"，但都是 **experimental** 阶段。我们的群控模块（hermes_swarm.py）方向一致，但多了**生存驱动**这个独特视角。

## 四、Level-Up Blueprints（官方推荐组合）

### 对我们最有价值的组合

**Memory stack that actually compounds:**
```
Hermes built-in memory
  → Hindsight（已装）
    → plur（共享 engram，未来装）
      → flowstate-qmd（主动回忆，可选）
```

**Self-improvement without self-delusion:**
```
hermes-agent-self-evolution（DSPy+GEPA）
  → scheduled regression checks
    → lintlang（prompt linting）
      → 第二轮评估阻断坏变异
```

**Multi-agent execution layer:**
```
Hermes delegation
  → hermes-agent-acp-skill（Codex/Claude Code 路由）
    → zouroboros-swarm-executors（本地 handoff）
      → opencode-hermes-multiagent（专业角色）
```

## 五、待操作清单

| 优先级 | 操作 | 类型 | 需确认 |
|--------|------|------|--------|
| P0 | 安装 rtk-hermes 插件 | 代码 | 是 |
| P0 | 追踪 PR #2044 合并进度 | MD | 否 |
| P1 | 评估 Ankh.md 多 agent 架构 | MD | 否 |
| P1 | 安装 hermes-web-search-plus | 代码 | 是 |
| P2 | 评估 plur 共享记忆 | MD | 否 |
| P2 | 安装 evey-bridge-plugin | 代码 | 是 |
