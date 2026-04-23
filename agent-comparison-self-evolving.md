# 自进化 Agent 对比研究

> 与 autonomous-drive-spec 相关的同类项目深度对比

---

## 1. GenericAgent（5.8K ⭐）
- **GitHub**: lsdefine/GenericAgent
- **核心理念**：从 3.3K 行种子代码自生长出技能树，6x 更少 token 实现完整系统控制
- **与我们的关系**：高度同频
  - 他们的"技能树自生长" = 我们的 plan-tree + EXPAND_CAPABILITIES
  - 他们的"6x 更少 token" = 我们的目标之一（省钱）
- **差异**：
  - GenericAgent 从代码层面自进化，我们从行为层面（skill 提炼）
  - GenericAgent 关注系统控制，我们关注生存驱动
- **可借鉴**：技能树的"种子"概念——不是预定义所有技能，而是给一个最小内核

## 2. ARIS — Auto-Research-In-Sleep（7.2K ⭐）
- **GitHub**: wanshuiyin/Auto-claude-code-research-in-sleep
- **核心理念**：轻量 Markdown-only skills，让 Agent 在人睡觉时自动做 ML 研究
- **与我们的关系**：几乎相同
  - ARIS = Claude Code 版本的 idle loop
  - 我们的 idle loop = Hermes 版本的 ARIS
- **差异**：
  - ARIS 专注 ML 研究，我们的循环更通用（健康/技能/知识）
  - ARIS 用 Markdown skills，我们用 Hermes skill 框架
- **可借鉴**：他们的"cross-session"研究能力——跨多个 Claude Code session 协调

## 3. nanobot（40K ⭐）
- **GitHub**: HKUDS/nanobot
- **核心理念**：超轻量个人 AI Agent
- **与我们的关系**：替代方案/互补
  - 如果 Hermes 太重，nanobot 可能更适合某些场景
- **待研究**：实际资源消耗对比，功能对比

## 4. everything-claude-code（163K ⭐）
- **GitHub**: affaan-m/everything-claude-code
- **核心理念**：Agent harness 性能优化——Skills, Instincts, Memory, Security, Research
- **与我们的关系**：最接近的项目
  - "Instincts" = 我们的 survival drive
  - "Memory" = 我们的 Hindsight
  - "Skills" = 我们的 skill 框架
- **差异**：
  - 163K star，社区巨大，但绑定 Claude Code
  - 我们绑定 Hermes，更开放
- **可借鉴**：他们的 Instincts 实现细节，Memory 方案对比

## 5. deer-flow（字节，63K ⭐）
- **核心理念**：长周期 SuperAgent，研究+编码+创作
- **与我们的关系**：互补
  - deer-flow 是"长周期任务"的解决方案
  - 我们是"空闲时间利用"的解决方案
  - 两者可以叠加：deer-flow 跑长任务，idle loop 在任务间填充
