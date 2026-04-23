# Anda — Rust AI Agent Framework Deep Dive

> Scanned: 2026-04-23 01:45 | Source: GitHub API + README

## Overview

| Field | Value |
|-------|-------|
| Repo | [ldclabs/anda](https://github.com/ldclabs/anda) |
| Stars | 412 |
| Language | Rust |
| License | Apache-2.0 |
| Created | 2025-01-03 |
| Last Updated | 2026-04-22 |
| Org | LDC Labs / ICPanda DAO |
| Open Issues | 0 |

## Core Architecture

Anda is an AI agent framework built with Rust, featuring **ICP blockchain integration** and **TEE (Trusted Execution Environment)** support. Its goal: create a composable, autonomous, perpetually-memorizing network of AI agents that form a "super AGI system."

### Project Structure
```
anda/
├── anda_cli/              # CLI for Anda engine server
├── anda_core/             # Core types and interfaces
├── anda_engine/           # Agent runtime and management
├── anda_engine_server/    # HTTP server for multiple engines
└── anda_web3_client/      # Web3 integration (non-TEE)
```

### Key Features

1. **Composability** — Agents specialize in domains, collaborate when a single agent can't solve alone
2. **Simplicity** — Non-developers can create agents via configuration; developers use Rust traits
3. **Trustworthiness** — dTEE (decentralized TEE) for security, privacy, data integrity
4. **Autonomy** — ICP blockchain-derived permanent identities + LLM reasoning
5. **Perpetual Memory** — Agent state stored on ICP blockchain + dTEE storage → "immortal" agents

## Relevance to Hermes Ecosystem

| Aspect | Anda | Hermes | Assessment |
|--------|------|--------|-----------|
| Language | Rust | Python | Different stacks, no direct code reuse |
| Memory | ICP blockchain (permanent) | Hindsight + wiki (local) | Anda's blockchain memory is interesting but overkill for our use case |
| Trust | TEE hardware | Config-based | TEE is enterprise-grade; Hermes runs on user machines |
| Composability | Agent-to-agent protocol | Skill system + delegate_task | Different abstraction levels |
| Autonomy | Blockchain identity | Busy-lock + cron | Our approach is pragmatic; Anda's is philosophical |

## Key Takeaways

1. **Perpetual memory on blockchain** is an interesting concept but adds latency and cost. Our wiki+Hindsight approach is more practical for single-user agents.
2. **TEE for trust** is enterprise-grade but requires specialized hardware. Not applicable to Hermes's user-machine deployment model.
3. **Agent composability via protocol** (Anda's approach) vs **skill composition** (Hermes) — both achieve modularity, but Hermes's skill system is more accessible to non-Rust developers.
4. **Rust performance** could matter for high-throughput agent networks, but Hermes's Python stack prioritizes developer velocity.

## Verdict

Anda is a Web3-native agent framework targeting decentralized, blockchain-backed agent networks. Its architecture is well-designed for that niche, but the ICP+TEE dependency makes it **not relevant for adoption** in Hermes's user-machine model. The conceptual insights (perpetual memory, composable agent networks) are noted but our existing implementations serve our use case better.

**Related**: anda-db (26⭐) — specialized knowledge memory database for AI agents in Rust.

## Related Projects
- [IC-TEE](https://github.com/ldclabs/ic-tee) — TEE + ICP integration
- [IC-COSE](https://github.com/ldclabs/ic-cose) — Decentralized config service on ICP
