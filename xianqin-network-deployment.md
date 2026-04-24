# 仙秦网络部署记录

> 每一步完成即更新，防止会话中断丢失进度

## 网络拓扑

| 节点 | Tailscale IP | 角色 | 状态 |
|------|-------------|------|------|
| 云服务器 | 100.80.136.1 | 协调者 (Coordinator) | ✅ 完整运行 |
| 始皇 (qin-server) | 100.64.63.98 | 工程师 | ⚠️ Hermes v0.11 装在 /tmp，需重装 |
| 骠骑 (.26) | 100.67.214.106 | GPU 骑兵 | ⚠️ Hermes v0.11 已装，Gateway 待验证 |
| 第三台 | 待定 | Windows+WSL Ubuntu 24.04 | ⏳ 未开始 |

## 骠骑 (.26 / 100.67.214.106) 部署状态

### ✅ 已确认完成
- [x] SSH 免密直连 (`ssh piaoqi`, ProxyJump via qin-server)
- [x] NVIDIA 驱动 535.288.01 + RTX 2080 Ti (11GB) + CUDA 12.2
- [x] Tailscale 接入，开机自启
- [x] 基础工具 (git, curl, wget, build-essential, python3-venv, tmux, htop, jq)
- [x] Hermes v0.11.0 安装 (venv: /home/qin/.hermes/venv/)
- [x] Soul.md 部署
- [x] OpenRouter API key 写入 config.yaml (sk-or-v1-...3357)
- [x] 代理已删除 (.26 可直连外网，代理反而干扰)
- [x] Gateway systemd 用户服务已创建并 enable
- [x] Gateway 绑定 0.0.0.0:8642 (修正了默认 127.0.0.1 问题)
- [x] A2A 通信测试成功 (云→piaoqi API 调用，骠骑返回系统状态报告)
- [x] Clash LAN 代理在 qin-server 上开启 (allow-lan: true, 0.0.0.0:7897)

### ⏳ 待完成
- [ ] MemOS 插件安装
- [ ] Wiki 库克隆 (~/llm-wiki)
- [ ] 理念文档部署 (ORIGIN.md, soul.md 完善)
- [ ] Skills 同步
- [ ] Gateway 稳定性验证 (长运行测试)

### 🔑 关键信息
- qin 用户密码: 1
- API_SERVER_KEY: 0449711b0ccb4c9aab70c7e7c2b1f31c (piaoqi gateway)
- Hermes 可执行: `/home/qin/.hermes/venv/bin/hermes`
- 配置文件: `/home/qin/.hermes/config.yaml`
- Gateway 服务: `~/.config/systemd/user/hermes-gateway.service`

## 始皇 (qin-server / 100.64.63.98) 部署状态

### ✅ 已确认完成
- [x] SSH 免密直连 (`ssh qin-server`)
- [x] Tailscale 接入，开机自启
- [x] 基础工具完整
- [x] Hermes v0.11.0 可用 (但装在 /tmp/hermes-deploy，不持久)
- [x] Clash 代理运行 (0.0.0.0:7897, allow-lan 已开)
- [x] Gateway 运行中 (8642 端口)

### ⏳ 待完成
- [ ] Hermes 重装到持久路径 (~/.hermes/)
- [ ] MemOS 插件安装
- [ ] Wiki 库克隆
- [ ] 理念文档部署
- [ ] Skills 同步
- [ ] Gateway systemd 服务配置

## 第三台 (Windows + WSL Ubuntu 24.04)

### ⏳ 待完成
- [ ] WSL Ubuntu 网络配置
- [ ] Tailscale 安装
- [ ] Hermes 安装
- [ ] 全套配置

## A2 + G1 采购中

宇树 A2（四足机器狗）+ G1（人形机器人）在路上，目标是闭环开发测试环境。
