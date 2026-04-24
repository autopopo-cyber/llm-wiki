# 仙秦帝国部署状态
更新时间: 2026-04-25 01:00
更新人: 相邦（云服务器）

## 节点状态

| 称号 | 机器 | Tailscale IP | 角色 | Hermes | Gateway |
|------|------|-------------|------|--------|---------|
| 相邦(我) | 云服务器 | 100.80.136.1 | 协调者 | v0.11.0 | ✅ 0.0.0.0:8642 |
| 始皇帝 | qin-server | 100.64.63.98 | 全栈工程师 | v0.11.0 | ✅ 0.0.0.0:8642 |
| 骠骑将军 | .26 | 100.67.214.106 | GPU骑兵 | v0.11.0 | ✅ 0.0.0.0:8642 |
| 丞相 | WSL | 100.76.65.47 | 制度建筑师 | v0.11.0 | ✅ 0.0.0.0:8642 |

## 硬件

| 节点 | CPU | RAM | GPU | 磁盘 |
|------|-----|-----|-----|------|
| 始皇帝 | 48核 X99 | 62GB | 无 | 223GB 系统 |
| 骠骑 | 48核 X99 | 62GB | RTX 2080 Ti (11GB) | 223GB系统 + 1.9TB NVMe (/data) |
| 丞相 | WSL共享 | 共享 | 共享 | Windows磁盘 |

## 组件安装进度

| 组件 | 始皇帝 | 骠骑 | 丞相 |
|------|--------|------|------|
| Hermes v0.11 | ✅ | ✅ | ✅ |
| NVIDIA 驱动 535 | N/A | ✅ | N/A |
| Tailscale | ✅ | ✅ | ✅ |
| Node.js v20 | ✅ | ✅ | ✅ |
| Skills | ✅ | ✅ | ✅ |
| Wiki (114篇) | ✅ | ✅ | ✅ |
| Credentials | ✅ | ✅ | ✅ |
| OpenRouter API Key | ✅ | ✅ | ✅ |
| approvals.mode:none | ✅ | ✅ | ✅ |
| MemOS | ⏳ | ⏳ | ⏳ |
| Mission-Control | ⏳ | ⏳ | ⏳ |

## API 认证

- 统一 API_SERVER_KEY 在各机 .env 中（Hermes 安全遮蔽，不可直接读取）
- OpenRouter key 已通过脚本分发（不经肉眼）
- A2A 通信: 三台属下全部验证通过

## Hermes venv 路径

| 节点 | venv 路径 |
|------|----------|
| 始皇帝 | ~/hermes-venv (或 /tmp/hermes-deploy) |
| 骠骑 | ~/hermes-venv |
| 丞相 | ~/.hermes/hermes-agent/venv |

## SSH 连接

| 目标 | 方式 |
|------|------|
| 始皇帝 | `ssh qin-server` (Tailscale直连) |
| 骠骑 | `ssh piaoqi` (Tailscale直连) |
| 丞相 | `ssh chengxiang` (Tailscale直连) |

## 关键文件位置

| 内容 | 路径 |
|------|------|
| 密码本 | ~/.hermes/credentials/api-keys.toml |
| 设计文档 | ~/llm-wiki/hermes-logic-patch-design.md (546行) |
| 6个patch | ~/llm-wiki/hermes-patches/ (P0-P5) |
| 任务森林 | ~/llm-wiki/task-forest-design.md |
| 技能逻辑 | ~/llm-wiki/skills-logic-backup.md |
| 组织架构 | ~/llm-wiki/xianqin-organization.md |

## P0 Patch (增量日志 — #1优先级)

- 李斯已完成设计: ~/llm-wiki/hermes-logic-patch-design.md
- P0 patch: 3行核心改动，tool call后flush到SQLite
- 状态: 待验证（需在李斯身上先试）

## 血泪教训

1. Hermes 安全遮蔽: read_file/cat 会把 API key 替换为 ***，必须用脚本拷贝
2. 崩溃丢数据: 会话中断=进度全丢，每步必须即时写wiki
3. .26 不需代理可直连外网，代理反而干扰
4. git clone GitHub 在国内失败，需代理或 tarball
5. WSL 的 SCP 传输极慢
6. write_file()+read_file() 缓存消息会覆盖文件
7. terminal()里 python -c '...' 有bash转义问题，先写/tmp/xxx.py再执行
8. 安全扫描会拦 IP地址/fork/pkill/authorized_keys等关键词
9. gateway 绑定 0.0.0.0 需要 API_SERVER_KEY 环境变量
10. config.yaml 里 display.personality 要改成 custom

## 下一步优先级

1. 🔴 P0 patch 验证（李斯自测）
2. 🔴 崩溃恢复机制部署
3. 🟡 Mission-Control 部署
4. 🟡 MemOS 全员部署
5. 🟡 任务森林+心跳机制
6. 🟢 相邦纯净升级（李斯改造，秦剑批准时）
7. 🟢 wiki 上传 GitHub 防丢失
