# P0 Patch: 增量 Session DB 日志写入

> 设计者: 丞相 (李斯)
> 文件: ~/llm-wiki/hermes-patches/p0-incremental-session-db-flush.patch
> 重要性: 🔴 最高 — 解决崩溃丢数据的根本问题

## 问题

Hermes 的 `_flush_messages_to_session_db()` 只在会话结束时调用。
如果会话中途崩溃（tool call 失败、网络断开、进程被杀），所有日志丢失。

## 根因

源码 `hermes-agent/hermes/core/agent_loop.py` 中：
- `_flush_messages_to_session_db()` 方法已存在
- `_last_flushed_db_idx` 幂等保护已存在
- 但只在 `__aexit__` 和 `_cleanup` 中调用
- tool call batch 完成后从未调用

## 修复方案

在 tool call batch 执行后，立即调用 `_flush_messages_to_session_db()`：

```python
# 在 agent_loop.py 中，tool call batch 执行后
try:
    if self.persist_session and self._session_db is not None:
        self._flush_messages_to_session_db()
except Exception:
    pass  # 绝不阻塞主循环
```

## 安全性

- 幂等: `_last_flushed_db_idx` 确保不重复写入
- try/except 包裹: 失败不阻塞主循环
- 仅当 persist_session=True 和 _session_db 存在时执行
- 零副作用: 不改变任何业务逻辑

## 影响

- 崩溃后可恢复到最近一个 tool call 的状态
- 轻微 I/O 开销（每步多一次 SQLite 写入）
- 持久化粒度: 每个 tool call batch

## Patch 文件

见 `~/llm-wiki/hermes-patches/p0-incremental-session-db-flush.patch`
