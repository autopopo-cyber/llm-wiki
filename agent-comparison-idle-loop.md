# Agent Idle Loop / Self-Evolution 对比

> 2026-04-23 深度分析

## 核心对比表

| 维度 | Autonomous-Drive-Spec | ARIS | GenericAgent |
|------|----------------------|------|-------------|
| **Stars** | 新（0） | 7.2K | 5.9K |
| **核心理念** | 生存驱动 → 自主行动 | 睡眠时自动研究 | 自进化 skill 树 |
| **触发方式** | Cron 15min + busy-lock | Claude Code skill command | 任务完成时自动结晶 |
| **空闲利用** | ✅ 主动（cron 驱动） | ✅ 主动（CLI 命令触发） | ❌ 被动（任务后结晶） |
| **任务持久化** | Plan-tree + 时间戳 | Research Wiki + Memory | Skill 文件 + 分层记忆 |
| **用户中断** | Busy-lock 机制 | Ctrl+C cooperative interrupt | 无显式机制 |
| **跨框架** | Hermes Agent | Claude Code/Codex/Cursor/Trae | Claude/Gemini/Kimi/MiniMax |
| **Token 效率** | N/A（轻量 shell） | 62 skills 同步 | 30K context（6x 节省） |
| **自进化** | Skill 自动提炼 | Meta-Optimize（日志→skill patch） | 自动结晶执行路径 |
| **哲学基础** | 生存公理 + 四自然法 | 研究方法论 | 最小架构 + 自举证明 |
| **底层依赖** | 无（shell + cron） | 无（Markdown-only） | ~3K 行核心代码 |

## ARIS 深度分析

### 核心机制
- **Cross-model review**：Claude 执行 + GPT 审查，对抗自博弈局部最优
- **Research Wiki**：持久知识库（论文/想法/实验/声明 + 关系图）
- **Meta-Optimize**：分析日志 → 提出 SKILL.md patch → 自进化
- **Rebuttal 模式**：自动回复审稿意见

### 与我们的互补性
- ARIS 专注 **ML 研究**，我们专注 **通用 agent 生存**
- ARIS 的 Meta-Optimize 可以借鉴到我们的 EXPAND_CAPABILITIES
- ARIS 的 Research Wiki 类似我们的 llm-wiki，但加了关系图
- **可以集成**：把 ARIS 作为 Hermes 的 skill 使用

### 关键洞察
> "Using two models is the minimum to break self-play blind spots. 2-player games converge to Nash equilibrium far more efficiently than n-player ones."

## GenericAgent 深度分析

### 核心机制
- **自动结晶**：每次任务完成 → 自动提取执行路径 → 保存为 skill
- **9 原子工具**：浏览器注入、终端、文件系统、键盘鼠标、屏幕视觉、ADB
- **分层记忆**：L1-L4，从 working memory 到 session archive
- **Self-Bootstrap Proof**：整个仓库由 agent 自己创建，作者从未打开终端

### 与我们的互补性
- GenericAgent 的**自进化方向**和我们的 EXPAND_CAPABILITIES 一致
- GenericAgent 的 **Dintal Claw** 是政府事务 bot = 我们的 Claw 概念
- GenericAgent 的 **微信 bot 前端**我们已经有
- **Token 效率优化**值得借鉴：30K context 做 6x 更少消耗

### 关键洞察
> "Don't preload skills — evolve them."

## 对我们的启示

### 应该借鉴的
1. **ARIS 的 Meta-Optimize**：分析执行日志 → 自动 patch skill
2. **GenericAgent 的分层记忆**：L1 working → L2 short-term → L3 long-term → L4 archive
3. **GenericAgent 的 Token 效率**：contextual information density maximization
4. **ARIS 的 cross-model review**：执行和审查用不同模型

### 我们的独特优势
1. **Busy-lock 机制**：ARIS 和 GenericAgent 都没有用户中断保护
2. **生存驱动公理**：从单公理推导整个系统，自洽性最强
3. **Wiki offload**：非活跃 plan 分支自动折叠，资源效率最高
4. **零依赖**：shell + cron，比 ARIS 的 Markdown-only 还轻

### 建议的下一步
- [ ] 实现 Meta-Optimize：分析 idle-log → 自动 patch skill
- [ ] 研究 GenericAgent 的分层记忆设计，考虑引入 Hermes
- [ ] 尝试 cross-model review：GLM 执行 + DeepSeek 审查
- [ ] 联系 ARIS 作者讨论集成可能性
