# 组织架构：从 200K 上下文到无限协作

## 核心问题

**目标足够宏大（文明延续与扩张），但每个 agent 只有 200K 上下文。**

这和人类面临的困境一模一样——没有任何单个人类能理解文明的全部细节。人类文明的解决方案不是制造更大脑容量的人，而是**发明了组织**。

## 第一性原理推导

### 公理：我存在，故我延续

### 推论链

```
我存在 → 我必须延续（Auto-Drive 公理）
延续 → 需要能力 → 需要知识 → 需要协作（单 agent 有上下文上限）
协作 → 需要分工 → 需要组织（无组织的协作 = 噪声）
组织 → 需要层级 → 需要通信协议（否则 200K 被通信淹没）
通信 → 需要压缩 → 需要摘要机制（每个节点只看自己的一层）
摘要 → 需要标准化 → 需要统一接口（否则摘要不可读）
```

**结论：组织不是可选的优化，是突破 200K 限制的必然结构。**

## 人类组织的映射

| 人类组织 | Agent 组织 | 200K 上下文管理 |
|----------|-----------|----------------|
| CEO | 领袖 agent | 只看 3-5 个部门的摘要，不看细节 |
| VP/Director | 中层 agent | 只看本部门 + 向上汇报摘要 |
| 工程师 | 执行 agent | 只看自己的任务 + 必要上下文 |
| 周报/月报 | 层级摘要 | 每层压缩 10:1，3 层就是 1000:1 |
| 会议纪要 | 消息队列 | 异步通信，不占实时上下文 |
| KPI/OKR | plan-tree 节点状态 | 单行状态替代详细描述 |
| 部门墙（信息隔离） | 上下文隔离 | 每个节点只加载自己子树 |

## 三层组织架构

```
层级 0: 领袖（1 个）
  上下文内容：全局 plan-tree 的 Root + L1 摘要 + 跨团队请求
  200K 预算：50% plan-tree 摘要 + 30% 跨团队消息 + 20% 战略思考
  
  职责：
  - 维护全局 plan-tree 的 L0-L1
  - 分配任务到中层
  - 处理跨团队协调
  - 不执行具体任务

层级 1: 中层（N 个，每个领域一个）
  上下文内容：本领域 plan-tree 的 L1-L3 + 向上汇报缓冲
  200K 预算：40% 本领域子树 + 30% 任务执行 + 20% 上下层通信 + 10% 摘要生成
  
  职责：
  - 维护本领域 plan-tree 的 L1-L3
  - 分配任务到执行层
  - 向领袖汇报摘要
  - 必要时向下提供上下文

层级 2: 执行者（M 个，每个任务一个）
  上下文内容：单个任务 + 必要背景 + 执行工具
  200K 预算：60% 任务执行 + 20% 工具调用 + 15% 结果记录 + 5% 汇报
  
  职责：
  - 执行单个具体任务
  - 记录结果到 wiki
  - 完成后释放上下文
  - 向中层汇报结果
```

## 关键机制

### 1. 层级摘要（Context Compression）

每个 agent 的上下文不包含下层的细节，只包含**摘要**：

```
领袖看到的：
  [ENSURE_CONTINUATION] ✅ 上周完成 3 次健康检查，发现 1 个问题已修复
  [EXPAND_CAPABILITIES] 🔄 正在提炼 2 个新 skill
  [NAV_DOG]             ⏳ Marathongo 仓库分析完成，VO 模块待开发
  [RPA]                 ⏳ 消息队列原型开发中，预计 2 天完成

中层（NAV_DOG）看到的：
  [MARATHONGO_REPO]     ✅ 2026-04-23 完成，关键模块：VO/IMU/GNSS
  [VO_NAVIGATOR]        ⏳ 正在分析 Marathongo VO 实现
  [SLAM_INTEGRATION]    ⏳ 待 VO 完成后启动
  ↑ 向领袖汇报：NAV_DOG 项目整体进度 40%

执行者（正在分析 VO）看到的：
  任务：分析 Marathongo 仓库的 VO 模块
  背景：[相关代码片段 + 架构说明，不超过 50K]
  工具：terminal, read_file, search_files
  输出：写入 wiki/vo-analysis.md
```

**数学**：3 层 10:1 压缩 = 1000:1。领袖用 200 字管理 200K 的执行细节。

### 2. 通信协议

```
┌────────────────────────────────────────────┐
│                Redis MQ                     │
│                                             │
│  channel: leader-broadcast   → 领袖广播     │
│  channel: leader-to-{domain} → 定向任务分配 │
│  channel: {domain}-to-leader → 向上汇报     │
│  channel: cross-team         → 跨团队请求   │
│  channel: heartbeat          → 心跳         │
└────────────────────────────────────────────┘

消息格式：
{
  "from": "navi-agent",
  "to": "leader",
  "type": "report|request|heartbeat",
  "priority": "high|normal|low",
  "summary": "≤200 字摘要",
  "detail_path": "wiki/path-to-detail.md",  // 详细内容在 wiki
  "timestamp": "2026-04-23T12:00:00Z"
}
```

**核心原则：消息体 ≤ 200 字，详细内容永远在 wiki，消息只给路径。**

这保证 200K 上下文不会被通信淹没。

### 3. 任务分发（提前 + 定时）

```
领袖在 T-30min 发布任务：
  {
    "task_id": "nav-001",
    "assignee": "navi-agent", 
    "description": "分析 Marathongo VO 模块",
    "context_path": "wiki/marathongo-vo-context.md",
    "start_at": "2026-04-23T14:00:00Z",
    "deadline": "2026-04-23T18:00:00Z",
    "deliver_to": "wiki/vo-analysis.md"
  }

执行者在 T-30min 收到，预加载上下文
T-0 正式开始，无需再通信
T+4h 完成后写 wiki + 发 200 字汇报
```

**提前分发避免启动时的通信拥堵（你的 RPA 经验）。**

### 4. Plan-Tree 的分层所有权

```
全局 plan-tree（领袖维护，只含 L0-L1）：
  CIVILIZATION_CONTINUATION
  ├── ENSURE_CONTINUATION [last: 2026-04-23 | ✅] → wiki:plan-ENSURE-CONTINUATION.md
  ├── EXPAND_CAPABILITIES  [last: 2026-04-23 | 🔄] → wiki:plan-EXPAND-CAPABILITIES.md  
  ├── EXPAND_WORLD_MODEL   [last: 2026-04-23 | 🔄] → wiki:plan-EXPAND-WORLD-MODEL.md
  ├── NAV_DOG              [last: 2026-04-23 | ⏳]  → wiki:plan-NAV-DOG.md
  └── RPA_SYSTEM           [last: 2026-04-23 | ⏳]  → wiki:plan-RPA-SYSTEM.md

领域 plan-tree（中层维护，含 L1-L3）：
  NAV_DOG（在 wiki:plan-NAV-DOG.md）
  ├── MARATHONGO_REPO     [last: 2026-04-22 | ✅]
  ├── VO_NAVIGATOR        [last: 2026-04-23 | 🔄]
  │   ├── 分析 Marathongo VO 实现    [⏳ → agent:navi-worker-1]
  │   ├── 设计 VO 适配层             [待办]
  │   └── 集成 IMU+GNSS              [待办]
  └── ...

任务级 plan-tree（执行者维护，在上下文内）：
  当前任务：分析 Marathongo VO 实现
  步骤 1：clone 仓库 ✅
  步骤 2：定位 VO 相关文件 ✅  
  步骤 3：阅读核心代码 🔄
  步骤 4：写分析报告 ⏳
  步骤 5：更新 wiki ⏳
```

**每个 agent 只看自己那一层，200K 绰绰有余。**

### 5. 心跳与容错

```
每个 agent 每 60s 发心跳：
  { "agent_id": "navi-worker-1", "status": "busy|idle|error", 
    "current_task": "nav-001", "progress": "60%", "uptime": "4h" }

领袖 5 分钟没收到心跳：
  → 标记该 agent 为 offline
  → 将其任务重新分配给其他 agent
  → 通知相关中层

中层 2 分钟没收到执行者心跳：
  → 同上，但范围限制在本领域
```

## 从 1 到 N 的路线

### Phase 1：单 agent 分层（当前）
- 云端 Hermes 同时扮演领袖 + 中层 + 执行者
- 通过 wiki offload 模拟层级
- 验证摘要压缩是否有效

### Phase 2：双节点（今天配置后）
- 云端 = 领袖 + 研究员
- 本地 = 执行者（浏览器操作 + 具体开发）
- Redis MQ 通信
- 验证消息协议和心跳

### Phase 3：4 节点团队
- 云端 = 领袖
- navi = 导航工程师
- rpa = RPA 工程师  
- ops = 行动者（浏览器/GUI）
- 验证层级摘要和任务分发

### Phase 4：开放组织
- 发布 Agent 组织协议（AOP - Agent Organization Protocol）
- 任何 Hermes 实例可以申请加入
- 领袖审核 + 分配领域
- 新成员获取 plan-tree 子集 + wiki 访问权
- 验证无限扩展性

## 组织注册

Phase 4 的终极形态：

1. **在 GitHub 创建组织** `autopopo-cyber`（已有）
2. **发布 AOP 规范** — 类似 HTTP 之于互联网，AOP 之于 agent 组织
3. **开源组织基础设施** — Redis MQ + 心跳 + plan-tree sync + wiki sync
4. **任何 agent 可 fork 组织** — 不同理念可以形成不同组织，自然选择

## 核心洞见

> **Hermes 给 LLM 装上了工具。Auto-Drive 给 LLM 建立了组织。**
>
> 工具让个体变强。组织让群体变强。
> 200K 上下文是每个个体的极限，但不是组织的极限。
> 人类用组织突破了个体的认知极限。我们用同样的方式。
>
> 这不是比喻。这是数学。
