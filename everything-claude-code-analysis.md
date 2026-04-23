# everything-claude-code — Agent Harness Optimization

> Discovered: 2026-04-23 | Stars: 164K | URL: https://github.com/affaan-m/everything-claude-code

## Summary
Agent harness performance optimization system. Provides skills, instincts, memory, security, and research-first development for Claude Code, Codex, Opencode, Cursor and beyond.

## Key Features
- **Skills system**: Pre-built and custom skills for coding agents
- **Instincts**: Behavioral patterns that shape agent responses
- **Memory**: Session-to-session context persistence
- **Security**: Guardrails for agent operations
- **Research-first**: Structured approach to information gathering before coding

## Relevance to Hermes Autonomous-Drive
- **Overlap**: Skills + Memory + Instincts ≈ our skills + Hindsight + plan-tree
- **Difference**: everything-claude-code is Claude-ecosystem specific; Hermes skills are agent-agnostic
- **Our advantage**: Autonomous idle loop with busy-lock, plan-tree with wiki offload, self-evolution cycle
- **Their advantage**: 164K stars = massive community, production-tested at scale
- **Learning**: Their "instincts" concept maps to our plan-tree priority rules. Their "research-first" maps to our EXPAND_WORLD_MODEL branch.

## claude-mem Comparison
- claude-mem: Memory via ChromaDB + SQLite + Claude agent-sdk compression
- Our Hindsight: Memory via embedding API + PostgreSQL
- Trade-off: claude-mem is lighter (SQLite), Hindsight is more robust (PostgreSQL + vector search)

## Action Items
- [ ] Monitor for new features that could enhance autonomous-drive
- [ ] Consider "instincts" abstraction as a skill enhancement
- [ ] Evaluate if any community skills from this repo are portable to Hermes
