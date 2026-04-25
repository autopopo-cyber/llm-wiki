# Hermes 单任务循环 Patch 设计文档

> 丞相李斯制 · 仙秦帝国制度改造方案 v1.0
> 针对 hermes-agent v0.11.0 源码分析

---

## 一、现状诊断：会话日志写入机制全链路

### 1.1 核心数据流

```
user_message
    │
    ▼
run_conversation() [run_agent.py:8851]
    │
    ├──► messages 列表初始化（拷贝 conversation_history）
    │
    ├──► while 循环：api_call_count < max_iterations
    │       │
    │       ├──► _interruptible_api_call() → API 返回 assistant_message
    │       │
    │       ├──► 若无 tool_calls → 最终回复，break
    │       │
    │       └──► 若有 tool_calls → _execute_tool_calls()
    │               │
    │               ├──► _execute_tool_calls_sequential() [run_agent.py:8303]
    │               │       └──► 逐个调用 handle_function_call() [model_tools.py:489]
    │               │               └──► 结果字符串生成
    │               │       └──► messages.append(tool_msg)  ← 结果追加
    │               │
    │               ├──► _execute_tool_calls_concurrent() [run_agent.py:8000]
    │               │       └──► 线程池并行调用 _invoke_tool() [run_agent.py:7896]
    │               │               └──► 结果归集到 messages
    │               │
    │               └──► 返回后：
    │                       self._session_messages = messages
    │                       self._save_session_log(messages)      ← 写 JSON（增量）
    │                       # 注意：此处没有 _flush_messages_to_session_db()
    │                       continue → 下一轮循环
    │
    ├──► 异常/退出路径 → self._persist_session(messages, conversation_history)
    │                       ├──► _save_session_log(messages)         ← 写 JSON
    │                       └──► _flush_messages_to_session_db()     ← 写 SQLite
    │
    └──► 正常结束 → self._persist_session(messages, conversation_history)
                        ├──► _save_session_log(messages)             ← 写 JSON
                        └──► _flush_messages_to_session_db()         ← 写 SQLite
```

### 1.2 关键缺陷

| 缺陷 | 位置 | 影响 |
|------|------|------|
| **SessionDB 只在会话结束时写入** | `run_agent.py:11649-11651` 仅有 `_save_session_log`，无 `_flush_messages_to_session_db` | 中途崩溃 → SQLite 中消息全部丢失，但 JSON 文件可能保留部分数据 |
| **一个会话做 N 件事** | `run_conversation()` 处理整个用户消息链，无任务边界 | 上下文膨胀、token 暴增、难以追踪 |
| **无持久化进度驱动** | 全靠 prompt 和 conversation_history 驱动 | 无法断点续作，每次从 0 开始 |
| **gateway 创建新 Agent 实例** | `gateway/run.py` 每条消息新 `AIAgent` | 内存状态隔离，需从 DB 重建上下文 |

### 1.3 已存在的防重入机制

- `_last_flushed_db_idx` [run_agent.py:3148-3174]：记录上次 flush 到 SessionDB 的索引，防止重复写入
- `_persist_user_message_override` [run_agent.py:3100-3114]：清洗持久化消息中的 API-only 前缀
- `ensure_session()` [hermes_state.py:542]：`INSERT OR IGNORE`，幂等创建 session row

---

## 二、改造目标：单任务循环（Single-Task Loop）

### 2.1 核心原则

```
1. 读取 plan-tree，找到最高优先级的待做项
2. 执行这一个任务（可能分解为多个子步骤 / tool calls）
3. 每完成一个子步骤，立即持久化进度到 plan-tree + SessionDB
4. 任务完成或遇到阻塞 → 汇报结果
5. 等待 ~1 分钟（用户可能要插话）
6. 回到步骤 1
```

### 2.2 三大改造支柱

| 支柱 | 说明 |
|------|------|
| **增量日志** | 每个 tool call batch 完成后 → `_flush_messages_to_session_db()` |
| **plan-tree 驱动** | Agent 启动时先读 plan-tree，不靠 prompt 驱动任务分解 |
| **单任务专注** | 一个 `run_conversation` 只处理一个 plan-tree 节点，完成后退出 |

---

## 三、具体 Patch 方案（伪代码级别）

### 3.1 文件 1：`hermes_state.py` — SessionDB 增强

**新增方法**：

```python
def append_task_progress(
    self,
    session_id: str,
    task_id: str,
    node_id: str,
    status: str,        # "pending" | "in_progress" | "completed" | "blocked"
    progress_pct: float = 0.0,
    result_summary: str = None,
    metadata: dict = None,
) -> int:
    """
    将 plan-tree 节点进度写入专用表 task_progress。
    与 messages 表分离，避免污染对话历史。
    """
    def _do(conn):
        conn.execute(
            """INSERT INTO task_progress
               (session_id, task_id, node_id, status, progress_pct,
                result_summary, metadata, timestamp)
               VALUES (?, ?, ?, ?, ?, ?, ?, ?)
               ON CONFLICT(session_id, node_id) DO UPDATE SET
                 status=excluded.status,
                 progress_pct=excluded.progress_pct,
                 result_summary=excluded.result_summary,
                 metadata=excluded.metadata,
                 timestamp=excluded.timestamp""",
            (session_id, task_id, node_id, status, progress_pct,
             result_summary, json.dumps(metadata) if metadata else None,
             time.time()),
        )
    return self._execute_write(_do)

def get_task_progress(self, session_id: str, node_id: str = None) -> list:
    """读取指定 session 的任务进度。"""
    ...

def get_pending_task_nodes(self, session_id: str) -> list:
    """返回该 session 下所有 status != 'completed' 的节点，按优先级排序。"""
    ...
```

**DDL 变更**（在 `SessionDB.__init__` 的建表逻辑中追加）：

```sql
CREATE TABLE IF NOT EXISTS task_progress (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT NOT NULL,
    task_id TEXT NOT NULL,
    node_id TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending',
    progress_pct REAL DEFAULT 0.0,
    result_summary TEXT,
    metadata TEXT,
    timestamp REAL NOT NULL,
    UNIQUE(session_id, node_id)
);
CREATE INDEX IF NOT EXISTS idx_task_progress_session
    ON task_progress(session_id, status);
```

**风险评估**：低。新表不影响现有 messages/sessions 表，失败仅影响 plan-tree 功能。

---

### 3.2 文件 2：`run_agent.py` — 核心循环改造

#### 3.2.1 改造点 A：增量 SessionDB flush（关键修复）

**位置**：`run_agent.py` 约 line 11649-11651，`_execute_tool_calls` 返回后的处理

**现状**：
```python
# Save session log incrementally (so progress is visible even if interrupted)
self._session_messages = messages
self._save_session_log(messages)
# Continue loop for next response
continue
```

**Patch 后**：
```python
# Save session log incrementally (so progress is visible even if interrupted)
self._session_messages = messages
self._save_session_log(messages)

# ── 新增：增量写入 SQLite SessionDB ──
# 每个 tool call batch 完成后立即持久化，防止中途崩溃丢失进度。
# _flush_messages_to_session_db 使用 _last_flushed_db_idx 做幂等去重。
if self.persist_session and self._session_db:
    try:
        self._flush_messages_to_session_db(messages, conversation_history)
    except Exception as e:
        logger.warning("Incremental session DB flush failed: %s", e)
        # 绝不阻断主循环 — JSON 日志已保存，SQLite 失败可接受

# 若启用了 plan-tree 模式，同时持久化当前节点进度
if self._plan_tree_store:
    try:
        self._plan_tree_store.flush_node_progress(self.session_id)
    except Exception as e:
        logger.warning("Plan-tree progress flush failed: %s", e)

# Continue loop for next response
continue
```

**风险评估**：极低。`_flush_messages_to_session_db` 已有成熟的 `_last_flushed_db_idx` 去重机制；新增 try/except 保证失败不阻断循环。

#### 3.2.2 改造点 B：新增 `_plan_tree_store` 初始化

**位置**：`AIAgent.__init__` [run_agent.py:768 附近]

**Patch 内容**：
```python
# 在 __init__ 参数列表新增：
plan_tree_store=None,   # PlanTreeStore 实例

# 在 __init__ 体中新增：
self._plan_tree_store = plan_tree_store
```

#### 3.2.3 改造点 C：新增 `run_task()` 单任务入口

**位置**：`run_agent.py`，在 `run_conversation` 之后新增方法

```python
def run_task(
    self,
    task_node: dict,           # plan-tree 节点：{id, goal, context, parent_id, priority}
    system_message: str = None,
    conversation_history: list = None,
    stream_callback: callable = None,
) -> dict:
    """
    单任务循环入口：只处理一个 plan-tree 节点，完成后立即返回。

    与 run_conversation 的区别：
    1. 用户消息被构造为 "Execute plan node: {goal}"
    2. 当检测到 node 完成信号（如 todo 全部勾掉、或模型返回 [TASK_COMPLETE]）
       时立即退出，不再继续处理后续计划
    3. 退出前强制 flush SessionDB + plan-tree 进度
    """
    # 注入 plan-node 上下文到 system prompt
    node_context = self._format_node_context(task_node)
    effective_system = (system_message or "") + "\n\n" + node_context

    # 构造用户消息，明确告知模型只处理这一个节点
    user_prompt = (
        f"[Plan Node: {task_node['id']}]\n"
        f"Goal: {task_node['goal']}\n"
        f"Context: {task_node.get('context', '')}\n\n"
        f"Execute this single task. When done, signal completion with [TASK_COMPLETE]."
    )

    # 调用现有 run_conversation，但注入完成检测钩子
    result = self.run_conversation(
        user_message=user_prompt,
        system_message=effective_system,
        conversation_history=conversation_history,
        stream_callback=stream_callback,
    )

    # 任务完成后：强制 flush 所有状态
    self._persist_session(result["messages"], conversation_history)
    if self._plan_tree_store:
        self._plan_tree_store.mark_node_completed(
            session_id=self.session_id,
            node_id=task_node["id"],
            result_summary=result["final_response"],
        )

    # 在 result 中注入 plan-node 元数据，供上层调度器使用
    result["plan_node_id"] = task_node["id"]
    result["plan_node_completed"] = True
    return result
```

---

### 3.3 文件 3：新建 `plan_tree.py` — plan-tree 持久化引擎

**路径**：`hermes-agent/plan_tree.py`（新建文件）

```python
"""PlanTree — 仙秦帝国任务调度中枢

提供持久化的计划树存储、优先级调度、断点续作。
与 SessionDB 共用 SQLite 连接，但逻辑表隔离。
"""

import json
import time
import uuid
from pathlib import Path
from typing import Dict, List, Optional

from hermes_state import SessionDB

class PlanTreeStore:
    """包装 SessionDB，提供 plan-tree 读写接口。"""

    def __init__(self, db: SessionDB = None):
        self._db = db or SessionDB()

    # ── 节点操作 ──
    def create_node(self, session_id: str, goal: str, context: str = "",
                    parent_id: str = None, priority: int = 0) -> str:
        node_id = f"node_{uuid.uuid4().hex[:12]}"
        self._db.append_task_progress(
            session_id=session_id,
            task_id=session_id,   # 简化：一个 session 对应一个 task
            node_id=node_id,
            status="pending",
            metadata={"goal": goal, "context": context,
                      "parent_id": parent_id, "priority": priority},
        )
        return node_id

    def get_next_node(self, session_id: str) -> Optional[dict]:
        """返回最高优先级的 pending 节点。"""
        rows = self._db.get_pending_task_nodes(session_id)
        if not rows:
            return None
        top = rows[0]
        metadata = json.loads(top.get("metadata", "{}"))
        return {
            "id": top["node_id"],
            "status": top["status"],
            "goal": metadata.get("goal", ""),
            "context": metadata.get("context", ""),
            "parent_id": metadata.get("parent_id"),
            "priority": metadata.get("priority", 0),
        }

    def mark_node_in_progress(self, session_id: str, node_id: str):
        self._db.append_task_progress(
            session_id, task_id=session_id, node_id=node_id,
            status="in_progress", progress_pct=0.0,
        )

    def update_node_progress(self, session_id: str, node_id: str,
                             progress_pct: float, result_summary: str = None):
        self._db.append_task_progress(
            session_id, task_id=session_id, node_id=node_id,
            status="in_progress", progress_pct=progress_pct,
            result_summary=result_summary,
        )

    def mark_node_completed(self, session_id: str, node_id: str,
                            result_summary: str = None):
        self._db.append_task_progress(
            session_id, task_id=session_id, node_id=node_id,
            status="completed", progress_pct=1.0,
            result_summary=result_summary,
        )

    def mark_node_blocked(self, session_id: str, node_id: str,
                          reason: str = None):
        self._db.append_task_progress(
            session_id, task_id=session_id, node_id=node_id,
            status="blocked", result_summary=reason,
        )

    def flush_node_progress(self, session_id: str):
        """强制刷新（当前实现无缓冲，直接通过 _db 写入）。"""
        pass  # 预留接口，未来可在此做批量写入优化
```

---

### 3.4 文件 4：`gateway/run.py` — Gateway 调度器改造

**位置**：`_handle_message_with_agent` [gateway/run.py:4125] 附近

**现状**：每条消息直接调用 `agent.run_conversation()`，处理整轮对话直到结束。

**Patch 后**（增加 plan-tree 调度分支，原有路径保留作为 fallback）：

```python
async def _handle_message_with_agent(self, event, source, _quick_key: str,
                                     run_generation: int):
    ...
    session_entry = self.session_store.get_or_create_session(source)
    history = self._load_history(session_entry)  # 现有逻辑

    # ── 新增：plan-tree 调度 ──
    plan_store = PlanTreeStore(self._session_db)
    next_node = plan_store.get_next_node(session_entry.session_id)

    if next_node is None:
        # 无待办节点：先让模型做任务分解，生成 plan-tree
        decomposition_result = agent.run_conversation(
            user_message=event.text,
            system_message=system_msg,
            conversation_history=history,
        )
        # 解析模型输出中的计划节点（格式：[PLAN] ... [/PLAN]）
        nodes = _extract_plan_nodes(decomposition_result["final_response"])
        for node in nodes:
            plan_store.create_node(
                session_id=session_entry.session_id,
                goal=node["goal"],
                context=node.get("context", ""),
                priority=node.get("priority", 0),
            )
        # 返回第一层节点给用户确认，或直接进入执行
        next_node = plan_store.get_next_node(session_entry.session_id)

    if next_node:
        # 单任务循环：只执行一个节点
        plan_store.mark_node_in_progress(
            session_entry.session_id, next_node["id"]
        )
        result = agent.run_task(
            task_node=next_node,
            system_message=system_msg,
            conversation_history=history,
        )
        # 结果已自动持久化到 SessionDB + plan-tree
        response_text = result["final_response"]
    else:
        # Fallback：原有 run_conversation 路径
        result = agent.run_conversation(...)
        response_text = result["final_response"]

    # 发送响应给用户
    await self._send_response(source, response_text)
    ...
```

---

### 3.5 文件 5：`tools/plan_tree_tool.py` — 模型可见的 plan-tree 工具

**新建文件**：让模型在对话中可操作 plan-tree（读、更新、标记完成）

```python
from plan_tree import PlanTreeStore
from hermes_state import SessionDB

def plan_tree_tool(
    action: str,           # "read" | "update_progress" | "mark_complete" | "add_subtask"
    node_id: str = None,
    goal: str = None,
    context: str = None,
    progress_pct: float = None,
    session_id: str = None,
) -> str:
    """让 LLM 在工具调用中读写 plan-tree。"""
    db = SessionDB()
    store = PlanTreeStore(db)

    if action == "read":
        node = store.get_next_node(session_id)
        return json.dumps(node) if node else "{\"status\": \"no_pending_nodes\"}"

    elif action == "update_progress":
        store.update_node_progress(session_id, node_id, progress_pct)
        return json.dumps({"success": True})

    elif action == "mark_complete":
        store.mark_node_completed(session_id, node_id)
        return json.dumps({"success": True})

    elif action == "add_subtask":
        new_id = store.create_node(session_id, goal, context, parent_id=node_id)
        return json.dumps({"success": True, "node_id": new_id})

    return json.dumps({"error": f"Unknown action: {action}"})
```

**注册**：在 `model_tools.py` 的 `discover_builtin_tools()` 或 `tools/registry.py` 中注册此工具。

---

## 四、修改的文件列表与优先级

| 优先级 | 文件 | 修改类型 | 说明 |
|--------|------|----------|------|
| P0 | `run_agent.py` | 修改 | 核心：增量 `_flush_messages_to_session_db` + 新增 `run_task()` |
| P0 | `hermes_state.py` | 修改 | 核心：新增 `task_progress` 表 + 辅助方法 |
| P1 | `plan_tree.py` | 新建 | PlanTreeStore 逻辑层 |
| P1 | `tools/plan_tree_tool.py` | 新建 | 模型可操作 plan-tree 的工具 |
| P1 | `gateway/run.py` | 修改 | Gateway 调度器接入 plan-tree 循环 |
| P2 | `model_tools.py` | 修改 | 注册 `plan_tree_tool` |
| P2 | `run_agent.py` | 修改 | `__init__` 注入 `plan_tree_store` 参数 |

---

## 五、风险评估与缓解

| 风险 | 等级 | 说明 | 缓解措施 |
|------|------|------|----------|
| SessionDB 增量 flush 性能损耗 | 低 | 每个 tool batch 后多一次 SQLite 写 | `_last_flushed_db_idx` 仅写增量；批量写入通常 <1ms |
| Plan-tree 解析失败（模型不输出标准格式） | 中 | 模型可能不遵守 `[PLAN]` 标签 | Fallback 到原有 `run_conversation`；prompt 中明确 few-shot 示例 |
| Gateway 调度器复杂度上升 | 中 | `_handle_message_with_agent` 增加分支 | 保留原有路径作为默认；plan-tree 通过配置开关启用 (`enable_plan_tree: bool`) |
| 新表 schema 迁移 | 低 | 旧版本无 `task_progress` 表 | `ensure_session` 风格：`CREATE TABLE IF NOT EXISTS`，无破坏性变更 |
| 并发写入冲突 | 低 | gateway 多线程访问同一 SQLite | SessionDB 已有 `_lock`（threading.RLock）保护 |
| 回滚困难 | 低 | 增量 flush 写入脏数据 | 事务隔离 + `_last_flushed_db_idx` 保证可重入；回滚时直接删 JSON 日志 + SQLite session 行 |

---

## 六、回滚方案

### 6.1 热回滚（不停机）

1. **关闭 plan-tree 开关**：`config.yaml` 中 `enable_plan_tree: false`
2. **Gateway 立即恢复**：`next_node` 判断跳过，走原有 `run_conversation`
3. **增量 flush 安全保留**：`_flush_messages_to_session_db` 是幂等写，不影响旧逻辑

### 6.2 冷回滚（源码级）

```bash
# 1. 还原 run_agent.py 的增量 flush 块（删除新增的 _flush_messages_to_session_db 调用）
# 2. 还原 hermes_state.py（删除 task_progress 表相关方法，保留表不影响运行）
# 3. 删除 plan_tree.py、tools/plan_tree_tool.py
# 4. 还原 gateway/run.py 的调度逻辑
```

### 6.3 数据回滚

```bash
# 若 plan-tree 数据污染，可清理：
sqlite3 ~/.hermes/sessions.db "DELETE FROM task_progress; DROP TABLE task_progress;"
# messages / sessions 表不受影响
```

---

## 七、核心结论

1. **当前最大痛点**：`_flush_messages_to_session_db` 仅在会话结束时调用（line 3127 via `_persist_session`），而正常的工具调用循环中（line 11649-11651）只调用 `_save_session_log` 写 JSON。这意味着 **SQLite SessionDB 的数据可靠性低于 JSON 文件**——一旦进程崩溃，JSON 可能有数据但 SQLite 是空的。

2. **最小可用修复**（single-task-loop 的第一步）：在 `_execute_tool_calls` 返回后的 `continue` 之前，插入一行 `self._flush_messages_to_session_db(messages, conversation_history)`。这是**零副作用、高回报**的改动，利用已有 `_last_flushed_db_idx` 机制天然幂等。

3. **plan-tree 是架构升级**：从 "prompt 驱动做所有事" 转向 "计划驱动做单件事"。这需要新增存储层、调度层、模型工具三层配合，但每一层都可独立开关。

4. **建议实施顺序**：
   - **Phase 1**：先做增量 flush（P0，`run_agent.py` 3 行改动）——立即解决崩溃丢数据问题
   - **Phase 2**：新建 `plan_tree.py` + `hermes_state.py` 表扩展 ——搭建基础设施
   - **Phase 3**：`run_task()` + `plan_tree_tool.py` ——模型接入
   - **Phase 4**：`gateway/run.py` 调度器改造 ——用户层面生效

---

*制于仙秦帝国丞相府 · 李斯*
*文档版本: v1.0*
*源码基线: hermes-agent v0.11.0*
