---
title: 多Agent协作框架
created: 2026-04-24
updated: 2026-04-24
type: concept
tags: [agent, collaboration, architecture]
---

# 多Agent协作框架

> 当前部署：云服务器（协调者）+ 本地服务器（工程师），通过 Tailscale + SSH + A2A 通信

## 架构设计

```
┌──────────────────────────────────────────────────┐
│  云服务器 (100.80.136.1) — 协调者角色              │
│  ├── Hermes Agent (协调模式)                      │
│  ├── Plan-Tree (主副本，协调全局任务)               │
│  ├── Wiki (主仓库，git push/pull 同步)            │
│  ├── A2A Gateway (待部署)                         │
│  └── 职责：策略、规划、任务分配、进度监控           │
├──────────────────────────────────────────────────┤
│  本地服务器 (100.64.63.98) — 工程师角色            │
│  ├── Hermes Agent (执行模式)                      │
│  ├── Plan-Tree (本地副本，执行分配的任务)           │
│  ├── Wiki (从节点，git pull/push 同步)            │
│  ├── GPU/CUDA (48核CPU, 62G内存)                 │
│  └── 职责：开发、测试、部署、数据处理              │
└──────────────────────────────────────────────────┘
```

## 通信层（3层）

| 层级 | 方式 | 当前状态 | 用途 |
|------|------|----------|------|
| L1 | Tailscale + SSH | ✅ 已通 | 远程执行命令、文件传输 |
| L2 | Wiki Git 同步 | ✅ 已通 | 知识共享、任务下发 |
| L3 | A2A Gateway | 📋 待部署 | 实时消息、任务协调 |

## 任务协调流程

```
用户 → 协调者：接任务
  ↓
协调者：分解任务 → 写入 wiki/plan-tree → SSH 通知工程师
  ↓
工程师：拉取 wiki → 读取任务 → 执行 → 结果写回 wiki
  ↓
协调者：检查结果 → 更新 plan-tree → 反馈用户
```

## 关键参考项目

### 1. openclaw-a2a-gateway (457⭐)
- Google A2A v0.3.0 协议
- JSON-RPC / REST / gRPC 三种传输
- DNS-SD + mDNS 自动发现
- Hill Equation 仿生路由

### 2. GBrain (10.5K⭐)
- Postgres 后端任务队列（重启安全）
- thin prompt + 幂等性
- brain-ops：READ→ENRICH→WRITE 模式

### 3. ABot-Claw (116⭐)
- VLAC 闭环（视觉→语言→动作→评估）
- 多机器人热插拔
- 与 Hermes 直接兼容

## 下一步行动

- [ ] 部署 A2A Gateway 到两台机器
- [ ] 配置 Postgres 任务队列
- [ ] 建立工程师角色的 plan-tree 模板
- [ ] 验证端到端任务分配流程
