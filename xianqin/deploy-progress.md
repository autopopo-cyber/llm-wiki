# 仙秦帝国 · 部署进度
> 更新: 2026-04-24 22:22

## 三节点状态

| 节点 | Tailscale IP | 角色 | Hermes | MemOS | Wiki | Gateway |
|------|-------------|------|--------|-------|------|---------|
| 云服务器 | 100.80.136.1 | 协调者 | v0.11.0 ✅ | ✅ | ✅ | ✅ |
| 始皇 (qin-server) | 100.64.63.98 | 工程师 | v0.11.0 ✅ | 🔧 npm build中 | ✅ | ✅ 0.0.0.0:8642 |
| 骠骑 (.26) | 100.67.214.106 | GPU骑兵 | v0.11.0 ✅ | ✅ 待配API key | ✅ | ✅ 0.0.0.0:8642 |

## 已完成
- SSH 全链路打通（云→始皇→骠骑，Tailscale直连）
- NVIDIA 驱动 535 (RTX 2080 Ti 11GB CUDA 12.2)
- Tailscale 开机自启
- Hermes v0.11.0 三节点全部安装
- Soul.md 部署（始皇+骠骑）
- Wiki 知识库初始化（始皇+骠骑）
- MemOS 插件安装（骠骑完成，始皇 npm build 中）
- A2A 通信测试成功（云→骠骑）

## 待完成
- [ ] 始皇 MemOS npm build 完成
- [ ] 骠骑 MemOS 配置 API key 并重启 gateway
- [ ] 始皇 MemOS 配置 API key 并重启 gateway
- [ ] Windows-WSL 第三节点接入
- [ ] 向 MemOS 写入仙秦理念（ORIGIN.md 核心内容）
- [ ] A2+G1 机器人闭环测试环境准备

