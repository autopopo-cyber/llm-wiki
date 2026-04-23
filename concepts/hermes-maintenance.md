---
title: Hermes Agent 维护知识
created: 2026-04-19
updated: 2026-04-19
type: concept
tags: [open-source, tutorial, maintenance]
sources: [deploy-guide.md, session-2026-04-19]
---

# Hermes Agent 维护知识

> 部署 Hermes Agent 全栈后的日常维护、排错与已知限制汇总。
> 部署流程见 [[deploy-guide]]，本页聚焦运维层面。

## 架构速查

```
WebUI (:8648)  →  Gateway (:8642)  →  OpenRouter API (LLM)
                      ↓
                Hindsight (:9177)  →  OpenRouter API (Embed/Rerank/LLM)
                      ↓
                pg0-embedded (本地 PostgreSQL)
```

| 服务 | 端口 | systemd unit | 关键配置 |
|------|------|-------------|---------|
| Gateway | 8642 | hermes-gateway | config.yaml, .env |
| WebUI | 8648 | hermes-web-ui | PORT, AUTH_TOKEN |
| Hindsight | 9177 | hindsight-daemon | hermes.env |

## 关键配置文件

| 文件 | 用途 |
|------|------|
| `~/.hermes/config.yaml` | 主配置：模型、审批模式、记忆 provider、辅助模型 |
| `~/.hermes/.env` | API 密钥、代理、端口等环境变量 |
| `~/.hindsight/profiles/hermes.env` | Hindsight daemon 专用环境变量 |
| `~/.hermes/hindsight/config.json` | Hindsight 与 Hermes 的集成配置 |
| `~/.config/systemd/user/*.service` | 三个 systemd user service |

## 常见故障排查

### Gateway 日志报 "Unclosed client session"

1. 检查 Hindsight daemon 是否存活：`curl -s http://localhost:9177/health`
2. 如果返回连接拒绝，重启：`systemctl --user restart hindsight-daemon`
3. 确认 `~/.hindsight/profiles/hermes.env` 包含 `HINDSIGHT_EMBED_DAEMON_IDLE_TIMEOUT=0`
4. 确认 systemd service 配置 `Restart=always`
5. 重启 gateway 清除残留错误：`systemctl --user restart hermes-gateway`

### WebUI 执行命令卡死无响应

1. 检查 `~/.hermes/config.yaml` 的 `approvals.mode` 是否为 `off`
2. 如果是 `manual` 或 `smart`，改为 `off`（API Server 适配器不支持审批弹窗）
3. 重启 gateway 使配置生效

### Hindsight daemon 频繁退出

1. 确认 `HINDSIGHT_EMBED_DAEMON_IDLE_TIMEOUT=0` 已设置
2. 确认 systemd service `Restart=always`（不是 `on-failure`）
3. 查看退出原因：`journalctl --user -u hindsight-daemon -n 50`
4. 常见原因：OpenRouter API 暂时不可用 → embedding 返回空 → daemon 启动失败 → 重试即可

### Gateway 重启困难（卡在 deactivating）

1. `systemctl --user stop` 超时 → `kill -9 <PID>` 强杀
2. `systemctl --user reset-failed hermes-gateway` 清除失败状态
3. `systemctl --user start hermes-gateway` 重新启动

## 已知限制

### API Server 适配器缺失功能

- **无 approval 机制**：没有 `send_exec_approval`、没有 `register_gateway_notify`
  - 影响：WebUI 用户无法审批危险命令
  - 变通：`approvals.mode: off`
- **无 slash command 支持**：WebUI 无法发送 /yolo、/approve 等命令
- **无实时推送**：只有 HTTP request/response，无法主动推送消息给前端

### Hindsight 的 Patch 依赖

以下两个 patch 在 `pip install` 升级 hindsight 后可能被覆盖，需重新应用：

1. **daemon_embed_manager.py** — `_find_api_command()` 加本地命令检测
   - 路径：`venv/lib/python3.11/site-packages/hindsight_embed/daemon_embed_manager.py`
   - 不 patch → uvx 下载完整版（5GB+ torch/CUDA）

2. **openai_compatible_llm.py** — `_supports_reasoning_model()` 限制匹配范围
   - 路径：`venv/lib/python3.11/site-packages/hindsight_api/engine/providers/openai_compatible_llm.py`
   - 不 patch → deepseek-v3.2 被当作推理模型，retain 从 16s 变 98s

### 模型兼容性

| 模型 | 用途 | 问题 |
|------|------|------|
| `qwen/qwen3.5-9b` | Hindsight LLM | 结构化输出返回 `content: null`，JSONDecodeError 死循环，不可用 |
| `deepseek/deepseek-v3.2` | 副模型/Hindsight LLM | 需 patch reasoning model 检测，否则 98s retain |
| `deepseek/deepseek-r1` | 推理模型 | 正常，不需要 patch |

## 日常运维速查

```bash
# 一键健康检查
curl -s http://localhost:9177/health && echo "Hindsight OK"
curl -s http://localhost:8642/health && echo "Gateway OK"

# 重启所有服务（按依赖顺序）
systemctl --user restart hindsight-daemon
sleep 5
systemctl --user restart hermes-gateway
systemctl --user restart hermes-web-ui

# 查看实时日志
journalctl --user -u hermes-gateway -f

# Hindsight daemon 日志
tail -f ~/.hindsight/profiles/hermes.log

# 检查端口占用
ss -tlnp | grep -E "8642|8648|9177"
```

## 相关页面

- [[deploy-guide]] — 完整部署流程
- [[unitree]] — 当前主要使用的机器人平台


---

## 相关链接

- [[deploy-guide.md|云服务器部署指南]]