# Proactive Prune — GA 启发的主动压缩改动

> 日期: 2026-04-23
> 关联: [[GenericAgent-vs-Hermes-深度对比]]
> 灵感: GA 的 "Level 1-2 压缩流水线" — 每轮结束后主动压缩旧 tool result，不等 context 爆

## 问题

Hermes 原本的 context 压缩是**被动的** — 只有当 token 使用量达到 context window 的 50% 阈值时才触发完整压缩（prune + LLM 摘要 + session split）。

这意味着：
- 长对话中，大量旧的 tool result 占满 context，白白消耗 token
- 每次都等 context 快满了才压缩，前 N 轮都在浪费 token
- 完整压缩成本高（需要额外 LLM 调用做摘要）

## GA 的做法

GA 有 4 级压缩流水线：
1. Tool Schema 缓存（不适用于 Hermes 原生 API）
2. History 标签压缩（每 5 轮截断旧内容）
3. Message 裁剪（超限才删）
4. Working Memory Anchor（滚动摘要替代完整历史）

## 我们的做法

在 agent loop 的 tool result 处理后、完整压缩检查前，加一个**轻量级主动 prune**：

- **触发条件**: messages 数量 > 30 且 compression_enabled
- **动作**: 调用 `_prune_old_tool_results()` 替换旧 tool output 为 1 行摘要
- **保护范围**: 最近 20 条消息 + 28K tokens 不动
- **成本**: 零 LLM 调用，纯字符串替换
- **效果**: 测试中 54K → 4K chars（92% reduction）

## 改动位置

**文件**: `~/.hermes/hermes-agent/run_agent.py`

**位置**: L10806 附近（`should_compress` 判断之前）

**改动量**: +23 行，0 行修改，0 行删除

**核心代码**:
```python
_PRUNE_MSG_THRESHOLD = 30
if (self.compression_enabled
    and len(messages) > _PRUNE_MSG_THRESHOLD
    and hasattr(self.context_compressor, '_prune_old_tool_results')):
    messages, _prune_count = self.context_compressor._prune_old_tool_results(
        messages,
        protect_tail_count=self.context_compressor.protect_last_n,
        protect_tail_tokens=self.context_compressor.tail_token_budget,
    )
```

## 为什么不改更多

1. **Tool Schema 缓存不可做** — Hermes 用 OpenAI/Anthropic 原生 function calling API，tools 参数必须每轮全量发送
2. **滚动摘要风险高** — GA 用 protocol-based tool calling (XML 标签)，可以随意操控 system prompt 内容。Hermes 用原生 API，改 messages 结构容易破坏 tool_call_id 关联
3. **Prune 足够** — 92% 的旧 tool result 压缩率已经解决了大部分 token 浪费问题

## 注意事项

- `_prune_old_tool_results` 是 ContextCompressor 的私有方法（`_` 前缀），用了 `hasattr` 防御
- Prune 只替换 content 字符串，不删消息、不改 tool_call_id 关联，对 API 调用透明
- 完整压缩（LLM 摘要 + session split）仍然在 50% 阈值时触发，prune 只是提前瘦身
