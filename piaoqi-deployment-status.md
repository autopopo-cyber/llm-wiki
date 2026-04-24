# 骠骑 (Piaoqi) 部署进度 — 2026-04-24

## ✅ 已完成

### 基础设施
- SSH: 公钥认证，Tailscale IP 100.67.214.106 可直连
- NVIDIA 驱动 535: RTX 2080 Ti 11GB, CUDA 12.2
- Tailscale: 开机自启，3 节点互通
- 基础工具: git, curl, wget, build-essential, python3-venv, tmux, htop, jq
- 磁盘: 1.9TB NVMe 挂载到 /data (开机自动挂载写入 fstab)

### Hermes Agent v0.11.0
- 安装方式: 从 qin-server 打包源码 + 清华 PyPI 镜像安装依赖
- 路径: /home/qin/.hermes/venv/bin/hermes
- 配置: provider=openrouter, model=glm-5.1
- API Key: 已从 qin-server 传入 (sk-or-...3357)
- Gateway: systemd user service, 绑定 0.0.0.0:8642
- Soul.md: 骠骑将军（具身智能工程师）

### MemOS (Reflect2Evolve V7)
- 仓库: ~/projects/MemOS/apps/memos-local-plugin
- Node.js: v20.20.2
- npm install: 完成 (505MB node_modules)
- Build: ✅ 成功（排除测试文件后编译通过）

### A2A 通信
- 云服务器 → piaoqi:8642 已验证通
- 骠骑能回复系统状态报告（GPU/RAM/Disk）

## ⏳ 进行中

1. MemOS 配置 — 需要配置到 Hermes 的 mcp_servers
2. Wiki 库同步 — ~/llm-wiki 需要部署到 piaoqi
3. 理念写入 — 仙秦帝国理念需要写入每个 agent 的记忆

## 🔧 关键配置文件

| 文件 | 位置 |
|------|------|
| soul.md | ~/.hermes/soul.md |
| config.yaml | ~/.hermes/config.yaml |
| .env | ~/.hermes/.env |
| Gateway service | ~/.config/systemd/user/hermes-gateway.service |

## 🐛 已知问题

- 代理: piaoqi 不需要 HTTP_PROXY（直连外网），但 .env 里曾有残留代理配置（已清理）
- Gateway systemd: 需 EnvironmentFile 加载 .env（已修复）
- MemOS build: 需排除 tests/ 目录才能编译通过
