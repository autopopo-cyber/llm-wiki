# 深度对比：GenericAgent vs ARIS vs Autonomous-Drive-Spec

> 2026-04-23 | 三套"自进化 Agent"方案的架构对比与借鉴要点

---

## 一、定位对比

| 维度 | GenericAgent | ARIS | Autonomous-Drive-Spec |
|------|-------------|------|----------------------|
| **核心主张** | 从 3K 行种子自生长技能树 | 睡觉时自动做 ML 研究 | 给 Agent 装上生存本能 |
| **目标用户** | 通用自动化（点外卖、炒股、微信） | ML 研究员（论文、实验、综述） | 任何 Hermes Agent 用户 |
| **框架依赖** | 自建（Streamlit/Qt） | Claude Code / Codex / 任意 LLM | Hermes Agent |
| **代码量** | ~3K 行核心 | 纯 Markdown skill（62+ skills） | ~1K 行 skill 定义 |
| **Stars** | 5.8K | 7.2K | 新发布 |

---

## 二、核心机制对比

### 2.1 自进化方式

| | GenericAgent | ARIS | 我们 |
|---|---|---|---|
| **如何进化** | 每次任务完成后自动"结晶"执行路径为 skill | `/meta-optimize` 分析日志 → 生成 SKILL.md patch | idle loop 扫描 + 提炼可复用模式 |
| **触发条件** | 每个任务完成后自动 | 用户手动 `/meta-optimize` | cron 30min 自动 |
| **存储形式** | L3 SOP 文件（.md） | SKILL.md（Markdown） | Hermes skill（SKILL.md + scripts/） |
| **复用方式** | L1 索引 → L2 事实 → L3 SOP 直接调用 | slash command 直接调用 | `skill_view` 加载 |

**关键差异**：
- GenericAgent 的结晶是**自动的、零干预**——每次任务完成就写 SOP
- ARIS 的进化是**数据驱动的**——需要 ≥5 次调用日志才能提出优化
- 我们目前是**手动的**——我观察到模式后手动 `skill_manage(create)`

### 2.2 记忆架构

| | GenericAgent | ARIS | 我们 |
|---|---|---|---|
| **层级** | L0→L1→L2→L3→L4（5 层） | research-wiki（4 实体 + 关系图） | plan-tree + wiki + Hindsight |
| **L1 索引** | ≤30 行极简索引（硬约束） | index.md（分类索引） | 无（靠 Hindsight 语义搜索） |
| **事实库** | L2 global_mem.txt | wiki papers/ideas/experiments/claims | wiki（Obsidian） |
| **关系图** | 无 | edges.jsonl（typed relationships） | 无 |
| **历史会话** | L4 raw_sessions | log.md（append-only timeline） | session_search |

**GenericAgent 最强的一点**：L1 的 ≤30 行硬约束 + "最小充分指针"原则。上层只留能定位下层的最短标识，多一词即冗余。这确保了 token 效率——<30K context window，是其他 agent 的 1/6。

### 2.3 空闲时间利用

| | GenericAgent | ARIS | 我们 |
|---|---|---|---|
| **idle 触发** | autonomous_operation_sop（手动授权） | 用户睡觉时 Claude Code 自动跑 | cron 30min 自动 |
| **任务选择** | 价值公式：「AI训练数据无法覆盖」×「对未来协作有持久收益」 | `/research-pipeline` 全自动 | ENSURE→CAPABILITIES→WORLD_MODEL 优先级 |
| **收尾机制** | 3 步：写报告 + complete_task + set_todo | 无（任务完成即结束） | 更新 plan-tree 时间戳 |
| **权限边界** | 只读自由，写操作需报告待审 | 无特殊限制 | 用户任务抢占 |

**GenericAgent 最强的一点**：收尾 SOP 是 3 步硬约束——**缺一不可**。报告 + history + todo 三者联动，确保不会丢失进度。

---

## 三、可借鉴的具体机制

### 🔥 P0：立即借鉴

#### 1. GenericAgent 的 L1 ≤30 行索引
**问题**：我们的 plan-tree 越来越长，每次 cron 读全树浪费 token。
**借鉴**：创建 `~/.hermes/index.md`，≤30 行，只存关键词→定位指针。

```markdown
# Hermes Agent Index (≤30 行)
## 高频
idle-loop → skill:autonomous-drive
plan-tree → ~/.hermes/plan-tree.md
credentials → ~/.hermes/credentials/credentials.toml
## 低频
wiki:agent-comparison → ~/llm-wiki/agent-comparison-*.md
wiki:daily-digest → ~/llm-wiki/daily-digest.md
## RULES
锁10min过期 | cron 30min | 用户任务永远抢占 | GitHub token仅autopopo-cyber
```

#### 2. GenericAgent 的自动结晶
**问题**：我们现在手动创建 skill，效率低。
**借鉴**：每次成功完成一个复杂任务后，自动检查是否值得结晶为 skill。规则：
- 同类操作出现 ≥3 次 → 自动 `skill_manage(create)`
- 模式：观察 → 计数 → 结晶

#### 3. ARIS 的 Meta-Optimize 机制
**问题**：skill 写了就忘，不知道哪些好用哪些需要修。
**借鉴**：加一个 `/meta-optimize` 能力——分析 idle-log 和 session 历史，找出：
- 哪些 skill 被调用最多/最少
- 哪些 skill 执行时出错最多
- 哪些 skill 的 prompt 需要更新

### 🔥 P1：中期借鉴

#### 4. GenericAgent 的"行动验证原则"
**问题**：Hindsight 会存入未验证的推理/猜测。
**借鉴**：给 Hindsight retain 加一条规则——**No Execution, No Memory**。只有经过工具调用验证的信息才存入长期记忆。

#### 5. ARIS 的关系图
**问题**：wiki 文章之间没有显式关系，发现关联靠语义搜索。
**借鉴**：在 wiki 加 `edges.jsonl`，显式记录 extends/contradicts/inspired_by 关系。

#### 6. GenericAgent 的收尾 3 步硬约束
**问题**：idle loop 有时做到一半被打断，进度丢失。
**借鉴**：每个 idle 子任务完成时必须执行：
1. 写 idle-log 条目
2. 更新 plan-tree 时间戳
3. 检查 pending-tasks 是否有新项

### 🔥 P2：远期借鉴

#### 7. GenericAgent 的 L4 历史会话
自动收集过去的会话摘要，用于未来决策参考。

#### 8. ARIS 的跨模型对抗审查
用不同模型互相审查——执行用 GLM-5.1，审查用 DeepSeek-v3.2。避免单一模型的盲点。

---

## 四、行动项

| 优先级 | 行动 | 预估时间 |
|--------|------|----------|
| P0-1 | 创建 `~/.hermes/index.md`（≤30 行） | 5 min |
| P0-2 | 给 idle loop 加"自动结晶"逻辑 | 15 min |
| P0-3 | 实现 `/meta-optimize` 分析 | 30 min |
| P1-1 | Hindsight "No Execution, No Memory" 规则 | 需改代码 |
| P1-2 | Wiki edges.jsonl | 10 min |
| P1-3 | Idle 子任务收尾 3 步硬约束 | 10 min |

---

## 五、一句话总结

> **GenericAgent 教我们"记忆要分层、索引要极简、结晶要自动"；ARIS 教我们"进化要数据驱动、知识要显式关联、审查要跨模型"。我们该做的是：把 GenericAgent 的记忆架构和 ARIS 的元优化机制，嫁接到 Hermes 的 skill + plan-tree + Hindsight 体系上。**
