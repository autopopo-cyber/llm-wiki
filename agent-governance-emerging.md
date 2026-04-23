# Agent Governance — Emerging Category (2026-04-22)

## Why This Matters

As AI agents become more autonomous (like our own autonomous-drive), the need for **pre-execution policy enforcement** and **approval gates** becomes critical. This is no longer theoretical — real projects are shipping.

## Key Projects

### cordum (cordum-io/cordum) — ⭐466
- **Tagline**: "The open agent control plane"
- **Core concept**: Govern autonomous AI agents with pre-execution policy enforcement, approval gates, and audit trails
- **Relevance**: Directly applicable to our autonomous-drive's lock mechanism. Could formalize what we do with `agent-busy.lock`
- **Watch level**: HIGH — may provide patterns for safety improvements

### casdoor (casdoor/casdoor) — ⭐13K
- **Tagline**: "Agent-first Identity and Access Management (IAM) / LLM MCP & agent gateway"
- **Core concept**: Auth server with MCP gateway — who can call which agent tools
- **Relevance**: If Hermes agents need multi-user access control, this pattern matters
- **Watch level**: MEDIUM — more enterprise-oriented

### AIOpsLab (microsoft/AIOpsLab) — ⭐860
- **Tagline**: "Holistic framework for design, development, and evaluation of autonomous AIOps agents"
- **Core concept**: Microsoft's approach to safe autonomous agents in ops
- **Relevance**: Evaluation framework for agent reliability — could inform our health checks
- **Watch level**: MEDIUM

## Patterns Observed

1. **Pre-execution gates** — All governance tools intercept agent actions BEFORE execution
2. **Audit trails** — Every action logged with full context (who, what, when, why)
3. **Policy-as-code** — Rules defined in config/DSL, not hardcoded
4. **Granular permissions** — Different trust levels for different tools/actions

## Application to Autonomous Drive

Our `agent-busy.lock` is a primitive form of governance. Could evolve to:
- Policy file defining what idle-loop can/cannot do without user approval
- Audit log of all autonomous actions (we have idle-log.md, but not structured)
- Approval gates for high-impact actions (e.g., writing to production, spending money)

## Update Trigger
- Revisit when cordum reaches 1K stars or publishes API docs
- Monitor casdoor for MCP gateway features
