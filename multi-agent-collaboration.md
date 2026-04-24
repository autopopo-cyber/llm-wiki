---
title: 多Agent协作方案调研
created: 2026-04-24
updated: 2026-04-24
type: concept
tags: [agent, collaboration, research]
---

# 多Agent协作方案调研

## 当前架构

```
云服务器（上级 Hermes）
    ↕ Tailscale 虚拟网络
本地服务器 qin-Super-Server（下属 Hermes）
    - 48核 / 62GB / Ubuntu 24.04.4
    - Gateway: http://100.64.63.98:8642
    - API Token: 956592daddb3bec632cf2a3aafe87c06
```

## 社区现有方案

### 1. brain-mcp（⭐7）— 最轻量
- **GitHub**: https://github.com/DevvGwardo/brain-mcp
- SQLite 支持的协调层，MCP 兼容
- 零 token 开销的多 agent 编排
- 适合我们的场景：少量 agent 协作

### 2. Hermes-Studio（⭐46）— 最成熟
- **GitHub**: https://github.com/JPeetz/Hermes-Studio
- Web UI + 多 agent 编排面板
- 聊天、记忆、技能、终端、审批
- 可视化的 agent 管理

### 3. oh-my-hermes（⭐5）— 技能驱动
- **GitHub**: https://github.com/witt3rd/oh-my-hermes
- 受 oh-my-claudecode 启发
- 技能驱动的多 agent 编排

### 4. convergence（⭐6）— 全自动公司
- **GitHub**: https://github.com/t4tarzan/convergence
- 自演化 CEO agent + Paperclip 面板
- Hermes 大脑 + Karpathy 循环
- 野心大，但思路值得借鉴

### 5. zouroboros-swarm（⭐6）— 执行器桥
- **GitHub**: https://github.com/marlandoj/zouroboros-swarm-executors
- Claude Code + Hermes Agent 集成
- 本地执行器桥接系统

### 6. Google A2A 协议（⭐23406）— 行业标准
- **GitHub**: https://github.com/a2aproject/A2A
- Agent-to-Agent 开放协议
- 支持 JSON-RPC / REST / gRPC
- 我们之前调研的 openclaw-a2a-gateway 就是实现之一

### 7. IBM mcp-context-forge（⭐3611）— 企业级网关
- **GitHub**: https://github.com/IBM/mcp-context-forge
- MCP + A2A + REST/gRPC 统一端点
- AI Gateway + 注册中心 + 代理

## 我们的选择

### 短期（现在）：SSH + API 直连
- 上级通过 SSH 控制下属
- 通过 Gateway API 发送任务
- 简单直接，无需额外组件

### 中期（1-2周）：brain-mcp
- SQLite 协调层
- MCP 协议兼容
- 任务队列 + 状态追踪
- 最小化额外依赖

### 长期：A2A 协议
- Google A2A 标准协议
- openclaw-a2a-gateway 实现
- 支持多 agent 热插拔
- 适合扩展到 3+ agent

## 下属 Hermes 部署状态

| 项目 | 状态 |
|------|------|
| Hermes 安装 | ✅ v0.11.0 |
| Gateway 运行 | ✅ 0.0.0.0:8642 |
| API 可用 | ✅ 返回模型列表 |
| API Key | ❌ 需要用户手动输入 OpenRouter key |
| 对话测试 | ⏳ 等 API key 配好 |

### 待用户操作

在本地服务器上执行：
```bash
bash /tmp/setup_hermes_key.sh
```
输入 OpenRouter API Key 即可完成配置。
