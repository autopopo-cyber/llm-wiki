# GenericAgent vs Hermes+Hindsight+AutoDrive — 深度对比

> 分析日期: 2026-04-23
> 仓库: https://github.com/lsdefine/GenericAgent
> 教程: https://github.com/datawhalechina/hello-generic-agent
> 关联: [[index]] [[Marathongo-深度技术分析]]

---

## 一、项目画像

| 维度 | GenericAgent (GA) | Hermes + Hindsight + AutoDrive |
|------|-------------------|-------------------------------|
| 核心代码量 | ~3,300 行 (含前端 ~4,300) | Hermes ~30K+ 行, Hindsight 独立服务, AutoDrive skill ~800 行 |
| 语言 | Python | Python (Hermes) + Node (WebUI) + Rust/Go (Hindsight daemon 部分) |
| 依赖 | requests + LLM API | OpenAI SDK, aiohttp, PostgreSQL, Node, 浏览器, 大量 skill |
| 设计哲学 | 上下文信息密度最大化 | 多层智能体 + 长期记忆 + 自主循环 |
| 目标用户 | 个人用户, 低成本 | 开发者/团队, 企业级部署 |
| Token 效率 | 极高 (30K 上限, 声称 Claude Code 的 10-30x) | 中等 (context window 利用率一般, Hindsight 注入增加开销) |
| 部署方式 | 单文件 Python, 零配置 | 3 个 systemd 服务, PostgreSQL, 代理, 反向代理 |

---

## 二、架构对比

### 2.1 核心循环

**GA — Generator 流水线 (55 行核心循环)**

```
agent_runner_loop(client, system_prompt, user_input, handler, tools_schema)
  │
  ├── LLM 调用 → yield 流式输出
  ├── 解析 <tool_use> 或 native tool_calls
  ├── handler.dispatch(tool_name) → do_{tool_name}() → StepOutcome
  ├── 收集结果, 组装下一轮
  └── turn_end_callback() → 滚动摘要 + 内存重注入
```

关键: 每轮只发 **最新 user message + tool_results + 滚动摘要**, 不发完整历史。历史存在 BaseSession 后端, 前端只看 delta。

**Hermes — 传统 Agent Loop**

```
AIAgent.run_conversation(user_message)
  │
  ├── while iteration < max_iterations:
  │   ├── client.chat.completions.create(messages, tools)
  │   ├── 处理 tool_calls → handle_function_call()
  │   ├── messages.append(tool_result)
  │   └── 无 tool_calls → return response
  │
  └── 完整 messages 数组全量发送每轮
```

关键: **全量历史发送** — messages 数组每轮都完整发送给 LLM。靠 context_compressor 做截断, 但策略较粗糙。

**对比**: GA 的 "只发 delta + 滚动摘要" 比 Hermes 的 "全量发" 省 token 一个数量级。但 Hermes 的方式更简单直接, 适合大 context window 模型 (200K+)。GA 的 30K 限制是设计约束也是优化动力。

### 2.2 工具系统

| 维度 | GA (9 原子工具) | Hermes (30+ 工具) |
|------|----------------|-------------------|
| 设计理念 | 最小原子集, 组合涌现 | 全功能覆盖, 专用工具 |
| code_run | Python/Bash/PowerShell | execute_code sandbox + terminal |
| file ops | file_read + file_patch + file_write | read_file + write_file + patch + search_files |
| web | web_scan + web_execute_js | browser_navigate + browser_click + browser_snapshot + ... |
| 记忆 | update_working_checkpoint + start_long_term_update | memory tool + hindsight_retain/recall/reflect |
| 交互 | ask_user | clarify |
| 其他 | - | cronjob, delegate_task, send_message, vision, tts, ... |

**GA 的精妙之处**: `web_execute_js` 一个工具 = Hermes 的 browser_click + browser_type + browser_press + browser_scroll + ... 的超集。因为 JS 可以操作 DOM 做任何事。代价是 LLM 需要理解 JS, 但 token 消耗更低。

**Hermes 的优势**: 专用工具的 schema 更清晰, LLM 出错率低。browser_click 不需要写 JS。

### 2.3 记忆系统 (核心差异)

#### GA 的四层记忆

```
L1: global_mem_insight.txt (≤30 行, <1K tokens)
    → B-tree 索引层, 只存指针
    ↓
L2: global_mem.txt (环境事实)
    → 路径、配置、常量等 LLM 零-shot 不可能知道的信息
    ↓
L3: memory/*.md, *.py (任务级 SOP 和脚本)
    → 可执行的过程性知识
    ↓
L4: L4_raw_sessions/ (压缩的原始会话)
    → 历史对话, 12h 定期压缩归档
```

**核心公理**: "No Execution, No Memory" — 只有经过执行验证的信息才能存入记忆。

**更新流程**:
1. Agent 调用 `start_long_term_update` 触发
2. 读取 `memory_management_sop.md` 中的决策树
3. 分类: 环境事实→L2, 操作规则→L1[RULES], 任务技术→L3, 常识→丢弃
4. 用 `file_patch` 最小化更新现有文件
5. 同步 L1 索引

#### Hermes + Hindsight 的记忆

```
Memory tool (短期, 注入到每轮 context)
    → 2,200 字符上限, 存用户偏好 + 环境事实
    ↓
Hindsight (长期, 按需 recall)
    → PostgreSQL + embedding + reranking
    → 524 nodes, 9994 links, 68 documents
    → 三种操作: retain (存), recall (搜), reflect (综合推理)
    ↓
Wiki ~/llm-wiki/ (外部知识库)
    → Obsidian 格式, 30+ 页面
    → Plan-tree wiki offload 机制
    ↓
Skills (程序性知识)
    → SKILL.md 格式, 92 个叶节点
    → 可带 scripts/, templates/, references/
```

**关键差异**:

| 维度 | GA | Hermes+Hindsight |
|------|-----|-------------------|
| 存储 | 纯文本文件 | PostgreSQL + 向量索引 + 文件 |
| 检索 | L1 指针 → 直接读文件 | 语义搜索 + 重排序 |
| Token 开销 | 极低 (L1 <1K tokens, 按需加载 L2/L3) | 中等 (recall 注入 context, 每条 ~50-100 tokens) |
| 写入 | 决策树 + file_patch | 自然语言 retain → Hindsight 自动提取实体 |
| 知识类型 | 扁平 (事实 + SOP) | 结构化 (实体图 + 时序链接 + 语义链接) |
| 可解释性 | 极高 (人可直接编辑 txt) | 中等 (需通过 API 查询) |
| 跨会话 | 部分支持 (L4 压缩) | 完整 (Hindsight 全量持久化) |

**评价**: GA 的 L1≤30 行索引是天才设计 — 用 B-tree 思想做内存索引, token 开销极低。但容量有硬上限, 长期使用后 L2/L3 膨胀问题不可避免。Hindsight 的向量检索 + 实体图谱更 scalable, 但 recall 注入增加 context 开销, 且 "搜什么" 依赖查询质量。

**Hermes 缺失的**: 没有 L1 索引层。index.md (≤30 行) 是我们自主加的, 但不是系统内置机制。Hindsight recall 结果质量取决于 embedding, 没有类似 L1 的确定性指针。

**GA 缺失的**: 没有语义检索。L2/L3 增长后, 靠 L1 指针和 LLM 自己读文件来定位, 效率会下降。没有实体图谱, 关系推理弱。

### 2.4 自主循环 (AutoDrive)

**GA 的 autonomous.py — 5 行触发器**

```python
INTERVAL = 1800  # 30 分钟
def check():
    return "[AUTO] User has been away for 30 minutes, read autonomous SOP and execute."
```

然后读 `autonomous_operation_sop.md` 执行, 有:
- TODO.txt 管理待办
- 价值公式: Value = "AI训练数据无法覆盖" × "长期协作收益"
- 子智能体评分 (5-7 个 TODO, 每个 1-10 分)
- 权限边界: 只读探测自动, 写全局内存需审批
- 报告制度: autonomous_reports/ 目录

**Hermes 的 autonomous-drive skill — 800+ 行 skill**

```
Cron 30min → 读 index.md → 检查 busy lock →
  锁存在: 只扫描 plan-tree, 写 pending-tasks.md
  锁不存在: 完整 idle loop (3 分支 × N 子任务)
    → ENSURE_CONTINUATION (健康检查/备份/技能完整性)
    → EXPAND_CAPABILITIES (蒸馏/补丁/优化)
    → EXPAND_WORLD_MODEL (扫描/更新/传播)
    → 3 步硬约束 (idle-log + plan-tree + pending-tasks)
    → wiki offload 非活跃 root
```

**对比**:

| 维度 | GA Auto | Hermes AutoDrive |
|------|---------|-----------------|
| 触发 | 30min 空闲检测 | 30min cron |
| 并发保护 | 无 | busy lock (10min TTL) |
| 任务来源 | TODO.txt | plan-tree.md (结构化树) |
| 优先级 | 价值公式 + 子智能体评分 | 三分支 + 固定优先级 |
| 执行粒度 | 一个 TODO per session | sweep 所有 cooldown 到期的子任务 |
| 中断恢复 | 无 | 用户优先中断 + pending-tasks |
| 记录 | autonomous_reports/ | idle-log.md + plan-tree 时间戳 |
| 资源管理 | 靠 LLM 自律 | 锁 + cooldown + wiki offload |
| 容错 | 30 turns 上限 | 3 步硬约束 + 每步验证 |

**评价**: GA 的自主循环更简洁, 价值公式有启发性。但缺乏并发保护 (你和自主循环同时操作怎么办?), 缺乏中断恢复, 缺乏结构化计划。Hermes 的 AutoDrive 经过 4 轮迭代 (v1→v4), 每次都是踩坑后补的, 更 robust。

### 2.5 上下文压缩

**GA — 4 级压缩流水线**

1. Tool Schema 缓存: 10 轮内只发 "Tools: still active", 省 ~2K tokens/轮
2. History 标签压缩: 每 5 轮截断旧 `<history>` 内容
3. Message 裁剪: 超 context_win×3 时, 保留最近 4 条, 删除最旧
4. Working Memory Anchor: 用滚动摘要替代完整历史

目标: **30K tokens 以内**。

**Hermes — 2 级压缩**

1. context_compressor.py: 超限时压缩旧消息
2. Hindsight recall 注入: 按需加载, 不全量

没有 tool schema 缓存, 没有 working memory anchor, 没有主动滚动摘要。

**评价**: GA 的压缩策略远比 Hermes 精细。尤其是 "滚动摘要替代完整历史" 这个设计 — 本质上是在 agent loop 内部做了一个 mini-RAG, 用摘要替代原文。Hermes 完全没这个机制, 长对话 token 开销线性增长。

### 2.6 自我进化

**GA — 三阶段进化**

```
自然语言描述 → SOP (结构化清单) → 代码执行
                ↑ 结晶                ↑ 蒸馏
```

- **结晶**: 完成任务后, `start_long_term_update` 触发, 经验证的信息写入 L1/L2/L3
- **SOP 化**: 反复执行的操作 → SOP 文件 (checklist 格式)
- **代码化**: SOP 稳定后 → Python 脚本 (如 helper.py, compress_session.py)

**Hermes — AutoDrive 中的自进化**

- **技能结晶**: 同一模式出现 ≥3 次 → skill_manage(create) 保存
- **Skill 补丁**: 使用 skill 遇到坑 → skill_manage(patch) 修正
- **跨模型审查**: GLM-5.1 执行, DeepSeek-v3.2 审查
- **Meta-optimize**: 分析 idle-log 找最常调用/最常失败的 skill

**对比**: GA 的三阶段进化是 **纵向深化** (描述→SOP→代码), 逐步自动化。Hermes 的进化是 **横向扩展** (更多 skill, 更好的 skill), 但缺乏 SOP→代码的自动升级路径。GA 的 `compress_session.py` 就是代码化进化的产物 — 最初是手动操作, 然后 SOP 化, 最终写成脚本。

---

## 三、GA 的独到之处 (Hermes 应学)

### 1. L1 ≤30 行索引

**核心洞察**: 记忆系统的瓶颈不是存储, 而是检索。30 行索引 = <1K tokens = 每轮都能带, 100% 确定性命中。

**Hermes 对应物**: index.md 是我们手写的, 但不是系统机制。应该把 index.md 升级为 **一级公民** — 每次写 memory 或 retain 时, 自动同步 index.md 的对应条目。

### 2. Tool Schema 缓存

10 轮内不发完整 tool schema, 只发 "Tools: still active"。对 Hermes 的 30+ 工具尤其有价值 — 当前每轮都发完整 schema, 至少浪费 2-3K tokens。

### 3. 滚动摘要 (Working Memory Anchor)

每轮结束时 LLM 生成 `<summary>`, 滚动追加到 history_info。长对话时用摘要替代完整历史。

Hermes 的 context_compressor 是被动截断, 不是主动摘要。应该加一个 `summary` 步骤在每轮结束。

### 4. "No Execution, No Memory" 公理

GA 的记忆写入必须经过执行验证。Hermes 的 hindsight_retain 可以存任何自然语言, 没有验证门槛。导致 Hindsight 里可能有 LLM 幻觉产生的假记忆。

### 5. file_patch > file_write

GA 只有 file_patch (精确替换), 没有 file_write (全量覆盖)。这是防误操作的设计 — patch 最小化变更, write 可能覆盖意外内容。

Hermes 两者都有, 但 AutoDrive skill 已经记录了 "NEVER use write_file() with content from read_file()" 的反模式。GA 从架构层面消除了这个问题。

### 6. 价值公式

```
Value = "AI训练数据无法覆盖" × "长期协作收益"
```

这比 AutoDrive 的三分支优先级更量化。可以引入类似公式给 plan-tree 的 LV.2 条目打分。

---

## 四、Hermes 的独到之处 (GA 没有)

### 1. Hindsight 语义检索 + 实体图谱

524 nodes, 9994 links — 实体、时序、语义、因果四种链接。这是 GA 的纯文本记忆做不到的。跨域推理 (如 "上次用 ABot 的经验对现在的导航有什么启发?") 依赖图谱关联, 不是 L1 指针能做到的。

### 2. 忙锁机制

agent-busy.lock — 10min TTL, 用户和自主循环互斥。GA 完全没有并发保护。

### 3. Wiki Offload

plan-tree 膨胀时, 非活跃 root 折叠到 wiki, 只留一行指针。GA 没有类似机制, L2/L3 文件会持续增长。

### 4. 多模型协作

GLM-5.1 执行 + DeepSeek-v3.2 审查。GA 只用单一模型 (虽然支持多 provider, 但没有跨模型审查流程)。

### 5. Cron 系统

Hermes 有内置 cronjob 管理 (create/list/run/pause)。GA 的 scheduler.py 是文件扫描式, 不如 Hermes 的 API 式灵活。

### 6. 子智能体委托

delegate_task 可以 spawn 隔离的子智能体。GA 的 plan_sop.md 提到子智能体, 但实际实现是通过 `--task` 模式的文件通信, 不如 delegate_task 的内存隔离 + 结果汇聚。

---

## 五、融合建议

基于对比, 提出 6 条可落地的改进:

### P0 — 立即可做

**1. 给 Hermes 加 Tool Schema 缓存**
- 位置: `model_tools.py` 或 `agent/prompt_builder.py`
- 方法: 首次发送完整 tool schema, 后续 10 轮内只发 "Tools: still active"
- 预期: 每轮省 2-3K tokens, 对 30+ 工具尤其显著
- 参考: GA 的 `ToolClient._prepare_tool_instruction()`

**2. 加 index.md 自动同步**
- 位置: memory tool 的 add/replace/remove 操作
- 方法: 每次 memory 变更时, 检查 index.md 是否需要更新对应条目
- 约束: index.md 保持 ≤30 行, 超出时按 LRU 淘汰
- 参考: GA 的 L1 同步逻辑

### P1 — 值得尝试

**3. 滚动摘要机制**
- 位置: `run_agent.py` 的 agent loop
- 方法: 每轮结束时, 用 cheap_model (DeepSeek-v3.2) 生成 1-2 句摘要, 替代旧消息
- 阈值: messages 超过 20 条时启用
- 参考: GA 的 `turn_end_callback()` + `<summary>` 标签

**4. 记忆验证门槛**
- 位置: `hindsight_retain` 调用前
- 方法: retain 前检查内容是否包含执行证据 (终端输出/文件变更/API 响应), 纯推理内容标记为 "unverified"
- 参考: GA 的 "No Execution, No Memory"

### P2 — 架构级

**5. SOP→代码 自动升级路径**
- 方法: 检测 skill 的某个 section 被重复执行 ≥5 次, 自动建议提取为 Python script
- 位置: skill_manage + AutoDrive idle loop
- 参考: GA 的三阶段进化

**6. 价值公式评分**
- 方法: plan-tree 的每个 LV.2 条目增加 `value_score` 字段
- 公式: `score = novelty × durability`
  - novelty: "AI 训练数据无法覆盖的程度" (1-10)
  - durability: "对长期协作的收益持续性" (1-10)
- AutoDrive 优先执行高分项
- 参考: GA 的 task_planning.md

---

## 六、哲学对比

| 问题 | GA 的回答 | Hermes 的回答 |
|------|----------|--------------|
| Token 贵还是时间贵? | Token 贵 → 极致压缩 | 时间贵 → 全量发送, 减少重试 |
| 记忆的本质是什么? | 验证过的事实 (数据库) | 关联过的经验 (图谱) |
| 自主循环的目标? | 最大化用户专属价值 | 维持系统运转 + 扩展能力 |
| 极简还是全功能? | 极简 → 9 个工具覆盖一切 | 全功能 → 30+ 专用工具 |
| 信任 LLM 还是信任架构? | 信任架构约束 LLM | 信任 LLM + 人工兜底 |

两种哲学都有道理。GA 适合个人 + 低预算 + 高频使用。Hermes 适合团队 + 中等预算 + 复杂任务。

最理想的状态: **用 GA 的压缩思想优化 Hermes 的 token 效率, 用 Hermes 的记忆深度弥补 GA 的检索短板**。

---

## 七、代码量对比

| 组件 | GA | Hermes 等价物 |
|------|-----|--------------|
| 核心循环 | 118 行 (agent_loop.py) | ~300 行 (run_agent.py) |
| 工具实现 | 557 行 (ga.py) | ~2000 行 (tools/*.py) |
| LLM 接口 | 951 行 (llmcore.py) | ~500 行 (model_tools.py + auxiliary_client.py) |
| 记忆系统 | ~500 行 (L1-L4 + SOP) | Hindsight 独立服务 (~10K+ 行) |
| 前端 | ~2000 行 (8 平台) | ~3000 行 (gateway/platforms/) |
| 自主循环 | 5 行触发 + ~300 行 SOP | ~800 行 skill + 脚本 |
| **总计** | **~4,300 行** | **~40K+ 行** |

10 倍代码量差距。但功能覆盖面也差 10 倍。这是极简 vs 全功能的量化体现。

---

## 相关链接

- [[index]] — Wiki 索引
- [[Marathongo-深度技术分析]] — 之前的仓库分析
- GA 仓库: https://github.com/lsdefine/GenericAgent
- GA 教程: https://github.com/datawhalechina/hello-generic-agent
- GA 飞书指南: https://my.feishu.cn/wiki/CGrDw0T76iNFuskmwxdcWrpinPb
