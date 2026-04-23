# A2A Gateway — OpenClaw 原生 Agent 间通信

> 2026-04-23 | 关键发现

## 项目

**win4r/openclaw-a2a-gateway** — 457⭐

OpenClaw 插件，实现 Google A2A (Agent-to-Agent) v0.3.0 协议。Hermes/OpenClaw 原生兼容。

## 核心能力

| 能力 | 说明 |
|------|------|
| **三传输** | JSON-RPC / REST / gRPC，自动降级 |
| **SSE 流式** | 实时任务状态 + 心跳 |
| **Hill 方程路由** | 仿生亲和力评分，按 skills/tags/pattern/成功率加权 |
| **DNS-SD 发现** | 自动发现 Peer（_a2a._tcp） |
| **mDNS 自广播** | 让其他 Gateway 发现你 |
| **四态熔断器** | 仿生：closed → desensitized → open → recovering |
| **Bearer Token** | 多 Token 零停机轮换 |
| **Ed25519 设备身份** | 兼容 OpenClaw ≥2026.3.13 |
| **JSONL 审计** | 所有 A2A 调用记录 |

## 安装（一条命令）

```bash
openclaw plugins install openclaw-a2a-gateway
```

或 npm：
```bash
cd ~/.openclaw/workspace/plugins
git clone https://github.com/win4r/openclaw-a2a-gateway.git a2a-gateway
cd a2a-gateway && npm install --production
openclaw plugins install ~/.openclaw/workspace/plugins/a2a-gateway
openclaw gateway restart
```

## 对我们的意义

1. **替代自研 hermes_swarm.py** — A2A Gateway 功能更全（路由/发现/熔断/审计），而且原生集成
2. **Google A2A 标准** — 未来任何支持 A2A 的 agent 都能加入，不限 Hermes
3. **零配置启动** — 装上就能用，后续按需配 Agent Card 和 Peer

## 与 Auto-Drive 的融合

```
A2A Gateway = 通信基础设施（传输/路由/发现/安全）
Auto-Drive = 协作框架（理念/plan-tree/角色/任务分配）
Hermes = 节点（工具+记忆+skill+idle loop）
```

A2A 解决"怎么说话"，Auto-Drive 解决"说什么"。
