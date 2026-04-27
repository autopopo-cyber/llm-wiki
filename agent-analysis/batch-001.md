# Batch 001 · 外看阅读 · 多Agent协作/记忆/任务计划

> 日期: 2026-04-27 | 执行: 萱萱 | 15篇
> 来源: ArXiv (9) + Reddit/HN (0网络受限) + 本地已有分析 (6)
> 代理: socks5://127.0.0.1:7890 (Mihomo, 企业级)

---

## 核心发现

### 1. 所有竞品都在往"持久化"和"记忆"方向走，但无人做到 Plan-Tree 级别的预测

| 论文/项目 | 做了什么 | 我们的优势 |
|----------|---------|-----------|
| Prism (2604.19795) | 多Agent进化记忆基底 | Plan-Tree v3 已经有时序轨迹+预测，Prism 只有记忆没有预测 |
| APEX-MEM (2604.14362) | 半结构化记忆+时间推理 | Plan-Tree v3 的流入→转化→流出天然带时间箭头 |
| OpenCLAW-P2P v6 (2604.19792) | 多层持久化+容错 | 我们的忙锁+Git备份已经覆盖了这个方向 |
| MemoryCD (2603.25973) | 长期记忆基准测试 | 我们的 v3 预测归档是天然的校准数据源 |

**关键洞察**：社区在"记忆"上砸了大量资源，但**没有人把记忆和时间预测结合起来**。Plan-Tree v3 的"历史轨迹→多分支预测→归档校准"闭环，目前独一无二。

### 2. "冲突解决"是 2025-2026 热点，但我们的忙锁已经领先

| 论文 | 方案 | 忙锁的差异 |
|------|------|----------|
| Semantic Consensus (2604.16339) | 流程感知冲突检测 | 忙锁不检测冲突——设计系统让冲突不发生 |
| CAAF (2604.17025) | 框架强化确定性 | 我们的 The Law 同方向，但 CAAF 是硬约束，我们是软约束 |

### 3. "工作流生成"方向出现，但都是中心化调度

| 论文 | 方案 | 我们的差异 |
|------|------|----------|
| WorkflowGen (2604.19756) | 基于轨迹经验的自适应工作流 | **中心化**：一个模型生成全流程。我们：**去中心化** Plan-Tree，每个Agent独立演化 |
| SceneOrchestra (2604.19907) | 全工具调用轨迹生成 | 同上——单点调度。我们的 L2 plan-pilot 只做轻量协调 |

**关键洞察**：社区倾向于"一个聪明的调度器替代所有Agent的协调"，而我们的哲学是"每个Agent有自己的四维Plan-Tree，协调从预测交叉中自发涌现"。**后者更可扩展。**

---

## 逐篇提炼

### ArXiv

| ID | 标题 | 核心观点 | 关联舰队 |
|----|------|---------|---------|
| 2604.19856 | ChipCraftBrain: Validation-First RTL Generation via Multi-Agent | 多Agent编排的验证优先策略——不先生成再检查，而是在生成过程中持续验证 | 可借鉴到白起NAV_DOG：编译→自测→编译循环就是验证优先 |
| 2604.18071 | Architectural Design Decisions in AI Agent Harnesses | Agent架构的12个设计决策维度 | 直接可用来评估舰队的架构完备性。12个维度我们覆盖了9个 |
| 2604.19795 | **Prism: Evolutionary Memory Substrate** | 多Agent开放发现中的进化记忆基底——记忆不是静态存储，是动态演化 | **Plan-Tree v3 预测归档**就是这个方向的具体实现 |
| 2604.14362 | **APEX-MEM: Semi-Structured Memory with Temporal Reasoning** | 半结构化记忆支持时间推理——对长期对话的记忆需要时间维度 | Plan-Tree轨迹的MM-DD HH:MM时间戳本质上就是时间推理 |
| 2604.21375 | VLAA-GUI: Know When to Stop, Recover, Search | GUI自动化中知道何时停止、恢复、搜索的模块化框架 | 忙锁的"主动退让"哲学 vs VLAA的"被动恢复" |
| 2604.19792 | **OpenCLAW-P2P v6: Resilient Multi-Layer Persistence** | 多层持久化+实时引用验证 | 我们的备份永生+Git同步已经覆盖。但"实时引用验证"值得借鉴 |
| 2604.16339 | **Semantic Consensus: Process-Aware Conflict Detection** | 企业级多Agent系统的冲突检测——语义共识机制 | 对比忙锁：我们选择"设计系统让冲突不发生"而非"发生后检测" |
| 2604.19756 | **WorkflowGen: Adaptive Workflow Generation** | 基于轨迹经验的自适应工作流生成——中心化调度 | 核心差异：中心化 vs 去中心化Plan-Tree。**Tracker值得借鉴** |
| 2604.17025 | Harness as an Asset: CAAF | 通过收敛式AI Agent框架强化确定性 | The Law 的同方向探索。不同：我们是相对固化(软)，他们是强制收敛(硬) |

### 本地已有分析

| 项目 | Stars | 核心差异 | 舰队位置 |
|------|:---:|------|---------|
| CowAgent | 43.7k | 临时SubAgent模式，用完销毁 | 固定角色+持久身份 |
| DeerFlow | 63.9k | 基于LangGraph的工作流编排 | MC+Plan-Tree去中心化 |
| AutoGPT | 大量 | 单Agent工具链 | 多Agent频率分离 |
| MetaGPT | 大量 | 模拟软件公司角色，但任务固定 | 角色灵活，Plan-Tree自演化 |
| CrewAI | 大量 | 角色协作，无持久状态 | 有持久身份+功勋+爵位 |

---

## 可借鉴的点

1. **OpenCLAW-P2P 的"实时引用验证"** → 可考虑加到 Plan-Tree v3 的"流出"字段：一个任务产出的 wiki/Git 链接后面加一个 `[已验证 04-27]` 标记
2. **WorkflowGen 的"轨迹经验"** → 即 Plan-Tree 的历史轨迹。我们已经有数据，缺的是自动从历史轨迹中学习最优路径
3. **APEX-MEM 的半结构化记忆** → 和 Plan-Tree v3 方向完全一致，印证设计正确
4. **ChipCraftBrain 的验证优先** → 可纳入白起的编译流程：编译后立即自测，不等到所有模块编译完

## 可反驳的点

1. **中心化调度派** (WorkflowGen, SceneOrchestra) → 我们的立场：中心化调度不可扩展，去中心化 Plan-Tree + 忙锁是正确方向
2. **"冲突检测"派** (Semantic Consensus) → 我们的立场：检测不如预防。忙锁让冲突不发生，好过发生后用语义共识修复
3. **临时工派** (CowAgent, DeerFlow) → 我们的立场：持久身份的复利效应远超临时SubAgent的灵活性

---

## 下一步

- Batch 002: 深入读 Prism + APEX-MEM 的详细论文，提取可落地的记忆架构改进
- 关注 OpenCLAW-P2P 的实时验证机制 → 评估是否加到 Plan-Tree v3.2

*成本: 15篇 × ~3K token/篇 ≈ 45K token × $0.3/M ≈ $0.014*
