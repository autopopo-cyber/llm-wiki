# Hermes Agent v0.11.0 Release Notes (2026-04-23)

> The Interface Release
> Source: https://github.com/NousResearch/hermes-agent/releases/tag/v2026.4.23

## Highlights
1. **Ink-based TUI** — Full React/Ink rewrite of interactive CLI, JSON-RPC backend, subagent spawn observability
2. **Transport ABC + AWS Bedrock** — Pluggable transport layer (Anthropic/ChatCompletions/ResponsesApi/Bedrock)
3. **5 new inference paths** — NVIDIA NIM, Arcee AI, Step Plan, Gemini CLI OAuth, Vercel ai-gateway
4. **GPT-5.5 over Codex OAuth** — New reasoning model with live model discovery
5. **QQBot — 17th platform** — QQ Official API v2, QR scan setup
6. **Plugin surface expanded** — register_command, dispatch_tool, pre_tool_call veto, transform_tool_result, image_gen backends, dashboard tabs

## Impact on Our Setup
- **GPT-5.5**: New reasoning model available — consider for complex planning tasks
- **Plugin surface**: Can now register custom slash commands and veto tool calls — useful for safety in autonomous mode
- **AWS Bedrock**: Cloud inference option if needed
- **QQBot**: CN community engagement channel (if user wants)

## Stats
- 1,556 commits, 761 merged PRs, 1,314 files changed, 224K insertions, 29 community contributors since v0.9.0
