# 编码效果更好的 Agent 对比评测：GenericAgent vs ARIS

> 生成时间: 2026-04-23 02:20 | 来源: GitHub README + 仓库分析

## 1. GenericAgent (5886⭐)

**仓库**: lsdefine/GenericAgent  
**核心**: ~3K 行代码的自演化 Agent 框架  
**论文**: arXiv 2604.17091 (2026-04-21)  
**更新**: 2026-04-22 (活跃)

### 设计哲学
- **"不预装 skill，让它自己长"** — 每次解决新任务，自动将执行路径 crystallize 为 skill
- **最小架构** — 9 个原子工具 + ~100 行 Agent Loop
- **Token 高效** — <30K 上下文窗口（其他 Agent 用 200K-1M）

### 分层记忆系统
| 层 | 名称 | 内容 |
|----|------|------|
| L0 | Meta Rules | 核心行为规则 |
| L1 | Insight Index | 最小记忆索引（≤30行，快速路由） |
| L2 | Global Facts | 长期稳定知识 |
| L3 | Task Skills/SOPs | 可复用工作流 |
| L4 | Session Archive | 会话归档 |

### 与我们的对应关系
| GenericAgent | 我们的实现 |
|-------------|-----------|
| L0 Meta Rules | autonomous-drive SKILL.md |
| L1 Insight Index | ~/.hermes/index.md (≤30行) |
| L2 Global Facts | ~/llm-wiki/ |
| L3 Task Skills | ~/.hermes/skills/ (92 skills) |
| L4 Session Archive | ~/.hermes/idle-log.md + session_search |
| Self-evolution (crystallize) | Auto-crystallize ≥3x 规则 |
| Agent Loop (~100行) | idle loop (cron 30min + busy lock) |

### 值得借鉴
1. **L1 ≤30 行约束** — 我们已采用（index.md），验证有效
2. **Crystallize 机制** — 每次执行自动生成 skill，比我们的 ≥3x 阈值更激进
3. **Token 高效** — 30K vs 200K+，6x 压缩
4. **Self-bootstrap proof** — 整个仓库由 Agent 自己创建，零人工终端操作

---

## 2. ARIS — Auto-Research-In-Sleep (7230⭐)

**仓库**: wanshuiyin/Auto-claude-code-research-in-sleep  
**核心**: Markdown-only skills for autonomous ML research  
**版本**: v0.4.4 (2026-04-20)  
**更新**: 2026-04-22 (极其活跃)

### 设计哲学
- **"ARIS 是方法论，不是平台"** — 纯 Markdown，零依赖，零锁定
- **跨模型对抗审查** — Claude Code 执行 + 外部 LLM 审查（adversarial review > self-play）
- **2 模型协作** — 最小有效对抗配置（1→2 收益最大，2→4 递减）

### 核心机制
| 机制 | 说明 |
|------|------|
| /research-pipeline | 完整研究流水线（选题→实验→论文） |
| /rebuttal | 自动 rebuttal（带安全门控：无捏造、无过度承诺、全覆盖） |
| Research Wiki | 持久知识库（论文/想法/实验/声明 + 关系图） |
| /meta-optimize | 自演化（分析日志→提出 SKILL.md 补丁） |
| LlmReview | 跨模型审查路由（Claude→DeepSeek, MiniMax→GLM 等） |

### 与我们的对应关系
| ARIS | 我们的实现 |
|------|-----------|
| Research Wiki | ~/llm-wiki/ |
| /meta-optimize | EXPAND_CAPABILITIES (meta-optimize) |
| SKILL.md 格式 | ~/.hermes/skills/ (完全兼容) |
| Cross-model review | 已在 autonomous-drive 记录（GLM-5.1 执行 + DeepSeek-v3.2 审查） |
| /rebuttal | 无对应（非 ML 研究场景） |
| TodoWrite persistent | plan-tree + pending-tasks.md |

### 值得借鉴
1. **跨模型对抗审查理论** — adversarial bandits > stochastic bandits，1→2 收益最大
2. **纯 Markdown 架构** — 零依赖设计，验证了 skill-based 方法的通用性
3. **/meta-optimize** — 从使用日志分析 skill 质量并提议补丁，我们可加强此环节
4. **安全门控** — rebuttal 的 3 个安全门（无捏造/无过度承诺/全覆盖）可作为我们关键操作的模板

---

## 3. 对比总结

| 维度 | GenericAgent | ARIS | 我们 (Hermes + autonomous-drive) |
|------|-------------|------|------|
| 核心代码 | ~3K 行 | 0 行 (纯 MD) | ~50 行 bash + MD |
| 记忆层数 | 5 (L0-L4) | 3 (wiki+skills+index) | 4 (index+plan-tree+wiki+Hindsight) |
| Token 效率 | 30K ctx | 标准 | index-first 路由 |
| 自演化 | 每次执行 crystallize | /meta-optimize | ≥3x 自动创建 + idle loop |
| 冲突处理 | 无 | 无 | busy lock + 10min TTL |
| 空闲利用 | 无内置 | Sleep mode（手动） | cron 30min + 三分支优先级 |
| 生态兼容 | Streamlit/QQ/TG | Claude/Codex/Cursor/Trae | Hermes gateway + 任意 LLM |
| 适用场景 | 通用桌面自动化 | ML 研究流水线 | 通用 agent 生存循环 |

## 4. 可落地的改进

1. **降低 auto-crystallize 阈值** — GenericAgent 每次执行就 crystallize，我们 ≥3x 可能太保守。考虑 ≥2x
2. **实现 /meta-optimize** — 定期分析 idle-log 和 skill 使用频率，自动提议 SKILL.md 补丁
3. **跨模型审查验证** — 在关键操作（skill 创建、plan-tree 大更新）后用不同模型验证
4. **安全门控模式** — 为关键操作加入 "无捏造/全覆盖" 门控，借鉴 ARIS rebuttal 安全设计

