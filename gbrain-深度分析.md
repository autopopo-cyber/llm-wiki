# GBrain 深度分析

> 仓库: https://github.com/garrytan/gbrain
> 作者: Garry Tan (YC 总裁兼 CEO)
> 分析日期: 2026-04-23
> 关联: [[deep-dive-abot-claw]]、[[deep-dive-abot-claw-reproduction]]

## 一、项目概览

GBrain 是给 AI Agent 装的**长期记忆系统**。YC 总裁 Garry Tan 为自己的 OpenClaw/Hermes 部署亲手写的，生产级数据：**17,888 pages、4,383 人、723 公司**，21 个 cron 全自动运转，12 天搭完。

**一句话**：Agent 的金鱼脑 → 每天自动变聪明的长期记忆。

**与 GStack 关系**：GStack = 管手（编码 Skill），GBrain = 管脑（记忆+运营 Skill），`hosts/gbrain.ts` = 桥。

## 二、核心设计哲学：Thin Harness, Fat Skills

这是 GBrain 最值得借鉴的**不是代码，而是哲学**：

| 层 | 职责 | 占比 |
|---|---|---|
| **Fat Skills**（顶层） | Markdown 过程编码判断、流程、领域知识 | 90% 价值 |
| **Thin CLI Harness**（中层） | ~200 行，JSON in/text out，只读优先 | 薄 |
| **Deterministic App**（底层） | SQL、搜索、timeline、图遍历 | 信任基础 |

**五条定义**：
1. **Skill File** = 可复用 Markdown 过程（像方法调用，参数不同能力不同）
2. **Harness** = 只做四件事：循环跑模型、读写文件、管理 context、安全约束
3. **Resolver** = 路由表：任务类型 X → 先加载文档 Y
4. **Latent vs Deterministic** = 判断力放 LLM，信任放代码
5. **Diarization** = 读完 50 份文档写出 1 页结构化判断（非 SQL/RAG 能做到）

**对我们的意义**：Hermes 本身就是 Thin Harness，我们的 skill 体系 = Fat Skills。这条哲学验证了我们的架构选择。

## 三、知识模型：Compiled Truth + Timeline

每个 brain page 分两层：

```
上面 = Compiled Truth（当前最佳理解，可改写）
--- 分隔线 ---
下面 = Timeline（只追加不删除，原始证据链）
```

**为什么要分**：覆盖式更新丢历史，纯追加查的时候乱。分层两全其美。

**对比 Hindsight**：Hindsight 的 retain 是纯追加。Compiled Truth 模式更适合机器人场景——机器人对环境的认知需要不断刷新（地图、障碍物状态），但也需要历史轨迹做回溯。

## 四、知识图谱：Self-Wiring Graph

**核心**：每次写页面自动提取实体引用，创建类型化链接，**零 LLM 调用**。

链接类型：`attended`、`works_at`、`invested_in`、`founded`、`advises`

**实体自动升级**：
- 提到 1 次 → stub 页面（Tier 3）
- 提到 3 次 → 自动联网补料（Tier 2）
- 提到 8 次 / 开过会 → 完整 dossier（Tier 1）

**搜索基准**：
- Recall@5: 83% → 95%（+12 pts）
- Precision@5: 39% → 45%（+5 pts）
- Graph-only F1: 86.6% vs grep 57.8%（+28.8 pts）

**对机器狗的启发**：实体图 → 环境拓扑图。机器狗的"实体"不是人/公司，而是地点/路径/障碍物。同样的 self-wiring 思路可以用于自动构建环境语义图。

## 五、Minions：Postgres 原生任务队列

**这是 GBrain 对 Hermes/OpenClaw 生态最有工程价值的贡献**。

### 痛点
OpenClaw 的 `sessions_spawn` 在生产环境 6 大痛：
1. Spawn storm（风暴式启动）
2. Agent 无响应
3. 遗忘派发
4. Gateway 崩溃丢任务
5. 失控子进程
6. 调试一团乱

### Minions 方案
Postgres-native job queue，核心保证：
- 任务存 Postgres，Gateway 重启不丢
- 结构化进度 + token 记账 + 会话转录
- 运行中可通过 inbox 消息**转向**
- 暂停/恢复/取消随时
- 父子 DAG + 可配失败策略

### 生产基准

| | Minions | sessions_spawn |
|---|---|---|
| Wall time | **753ms** | >10,000ms（超时） |
| Token cost | **$0.00** | ~$0.03/run |
| Success rate | **100%** | 0%（spawn 都失败） |
| Memory/job | ~2 MB | ~80 MB |

### 路由规则
> **确定性工作**（同入→同出） → **Minions**（$0 token）
> **判断性工作**（需要评估/决策） → **Sub-agents**（LLM 推理）

### 对我们的意义
Hermes 的 cron + delegate_task 目前没有持久化。如果 gateway 重启，正在跑的 subagent 全丢。Minions 的思路——用 Postgres 做持久化 job queue——可以直接嫁接到我们的架构：
- `hermes_swarm` 的多机任务分发需要这种持久化保证
- 机器狗长距离导航的 checkpoint/recovery 也需要

## 六、Skillify：技能质量保证体系

**问题**：Agent 自动创建 skill，6 个月后变成没人读、没人测、不确定是否工作的黑盒。

**GBrain 解法**：10 项强制检查清单
1. SKILL.md（合约）
2. 确定性脚本
3. 单元测试
4. 集成测试
5. LLM eval
6. Resolver trigger
7. Resolver trigger eval
8. E2E smoke
9. Brain filing
10. 每项必须通过

工具：
- `gbrain check-resolvable` — 全树扫描：可达性、MECE、DRY、孤立 skill
- `scripts/skillify-check.ts` — CI 友好审计

**对我们的意义**：我们的 skill 体系已经 30+，但缺系统性质量保证。Skillify 的 10 项清单 + CI 集成思路值得移植。

## 七、Fail-Improve 循环

意图分类器从第一周 40% 确定性涨到 87%：
- 每次 LLM 兜底分类都被记录
- 系统自动从失败记录生成更好的正则
- 分类器越用越准、越用越便宜

**对机器狗的启发**：导航决策分类器可以同样进化——每次 LLM 介入的异常情况都被记录，自动提炼规则，减少 LLM 调用。

## 八、搜索架构

```
Query → Intent classifier → Multi-query expansion (Haiku)
  → Vector search (HNSW cosine) + Keyword search (tsvector)
  → RRF fusion: score = sum(1/(60 + rank))
  → Cosine re-scoring + Compiled truth boost + Backlink boost
  → 4-layer dedup → Results
```

**20 种技术叠加**，没有单一银弹，靠组合覆盖盲区。

对比我们 Hindsight：目前只有向量搜索。GBrain 的混合搜索 + 知识图谱遍历是明显更强的方案。

## 九、部署架构

```
CLI / MCP Server（薄封装，相同操作）
        |
  BrainEngine interface（可插拔）
        |
  PGLiteEngine ←→ PostgresEngine
  (默认,零配置)    (Supabase, $25/mo)
        |
  ~/.gbrain/brain.pglite  ↔  Supabase Pro
```

- **PGLite**：嵌入式 PG 17.5，2 秒就绪，无需服务器
- 超过 1000 页或多设备同步 → `gbrain migrate --to supabase`
- 双向迁移

**技术栈**：TypeScript + Bun + Postgres/pgvector + PGLite

## 十、与我们架构的映射

| GBrain 概念 | Hermes 对应 | 差距 | 借鉴优先级 |
|---|---|---|---|
| Thin Harness, Fat Skills | ✅ Hermes = Thin Harness, Skills = Fat | 架构已对齐 | 验证价值 |
| Compiled Truth + Timeline | Hindsight retain (纯追加) | ❌ 无覆盖更新机制 | 🔴 高 |
| Self-Wiring Graph | 无 | ❌ 无知识图谱 | 🟡 中 |
| Minions job queue | cron + delegate_task | ❌ 无持久化 | 🔴 高 |
| Skillify QA | skill_manage | ❌ 无质量保证体系 | 🔴 高 |
| Fail-Improve | 无 | ❌ 分类器不进化 | 🟡 中 |
| Hybrid Search (Vector+Keyword+RRF) | Hindsight 向量搜索 | ❌ 无关键词/混合 | 🟡 中 |
| Signal Detector (always-on) | autonomous-drive idle loop | ⚠️ 机制类似，应用不同 | 🟢 低 |
| Entity Auto-Upgrade | 无 | ❌ 无 | 🟡 中 |
| Resolver (路由表) | skill 管理 + LLM 匹配 | ⚠️ 隐式 vs 显式 | 🟢 低 |

## 十一、对四足导航 + 分布式 RPA 的具体借鉴

### 导航场景
1. **Compiled Truth → 环境认知**：机器人对环境的理解需要不断刷新（Compiled Truth），但历史感知数据需要保留（Timeline）。例如：某走廊当前畅通/阻塞 = Compiled Truth，过去 7 天的通行记录 = Timeline。
2. **Self-Wiring Graph → 环境拓扑**：自动提取地点/路径/障碍物关系，构建导航语义图。
3. **Fail-Improve → 决策进化**：每次导航异常被记录，自动提炼规则减少 LLM 介入。

### RPA 场景
1. **Minions → 多机任务分发**：Postgres 持久化 job queue 保证任务不丢，多机器狗/机器人共享任务队列。
2. **Skillify → Playbook 质量**：RPA playbook 需要同样的 10 项质量保证。
3. **Entity Auto-Upgrade → 机器人能力自动发现**：某台机器人被调度 3 次以上，自动补全其能力档案。

## 十二、风险与局限

| 问题 | 影响 |
|---|---|
| TypeScript/Bun 技术栈 | 我们 Python 为主，直接复用代码需改写 |
| 面向个人知识管理 | 机器人场景的实时性/嵌入式需求未考虑 |
| 需要 Postgres | 机器狗端算力有限，嵌入式 PG 方案需验证 |
| Supabase 依赖 | 国内网络 + 数据主权问题 |
| 无 ROS 集成 | 机器人场景需自建桥接层 |
| 搜索依赖 OpenAI embedding | 我们用 OpenRouter + bge-m3，需适配 |

## 十三、总结

**GBrain 最值得借鉴的不是代码，而是设计哲学和工程模式**：

1. 🔴 **Minions 持久化 job queue** — 对我们的多机协作和任务可靠性最关键
2. 🔴 **Compiled Truth + Timeline** — 环境认知的正确模型
3. 🔴 **Skillify 质量体系** — skill 从 30 个涨到 100 个时的生存保证
4. 🟡 **Self-Wiring Graph** — 环境语义图的自动构建思路
5. 🟡 **Hybrid Search** — 比 Hindsight 纯向量搜索强得多的检索方案
6. 🟢 **Thin Harness, Fat Skills** — 验证了我们架构选择的正确性

**建议行动**：优先实现 Minions 式持久化 job queue（用 SQLite 做嵌入版），其次给 Hindsight 加 Compiled Truth 覆盖更新能力。

---

> 相关链接：[[deep-dive-abot-claw]]、[[deep-dive-abot-claw-reproduction]]、[[刚刚，高德ABot-Claw亦庄半马封神！具身智能的Harness来了]]、[[高德ABot-Claw：基于OpenClaw的机器人智能体进化框架]]
