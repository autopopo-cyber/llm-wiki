# 仙秦帝国部署状态 — 2026-04-24 20:00

## 三节点 A2A 网络

| 节点 | Tailscale IP | 角色 | Hermes | Gateway | MemOS | Wiki | Soul |
|------|-------------|------|--------|---------|-------|------|------|
| 云服务器 | 100.80.136.1 | 协调者 | v0.11.0 ✅ | 8642 ✅ | ✅ | 105篇 ✅ | ✅ |
| 始皇 (qin-server) | 100.64.63.98 | 工程师 | v0.11.0 ✅ | 待配 | ✅ | 97篇 ✅ | ✅ |
| 骠骑 (.26) | 100.67.214.106 | GPU骑兵 | v0.11.0 ✅ | 0.0.0.0:8642 ✅ | ✅ | 97篇 ✅ | ✅ |
| Win-WSL | 待连 | ? | - | - | - | - | - |

## 硬件

| 节点 | CPU | RAM | GPU | 磁盘 |
|------|-----|-----|-----|------|
| 云 | 2核 | 4GB | 无 | 50GB |
| 始皇 | 48核 | 62GB | 无 | 223GB |
| 骠骑 | 48核 | 62GB | RTX 2080 Ti 11GB | 228GB + 1.9TB NVMe (/data) |

## A2A 通信验证
- ✅ 云 → 骠骑: API 调用成功，任务下发+回复确认
- ✅ SSH 免密: 三节点互通
- ⏳ 始皇 Gateway: 需要配置 0.0.0.0 绑定 + API key

## 核心理念传播
- 两台 subordinate agent 已写入 7 条仙秦核心理念
- Wiki 章程: ~/llm-wiki/xianqin-charter.md
- ABot-Claw 集成路径文档: ~/llm-wiki/agent-collaboration-monitoring.md

## 待采购
- 宇树 A2 (四足) — 采购中
- 宇树 G1 (人形) — 采购中

## 下一步
1. 始皇 Gateway 配置（0.0.0.0 绑定 + systemd 服务）
2. Win-WSL 接入 Tailscale + Hermes
3. MemOS bridge 启动验证（两台）
4. 安装 AutoGen Studio 或 AgentScope 做 agent 监控面板
5. A2/G1 到货后：ISAAC 仿真 → 实机部署
