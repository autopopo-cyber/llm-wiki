---
title: Hermes Agent 维护知识
created: 2026-04-19
updated: 2026-04-24
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

## Gateway 频繁崩溃与 WebUI 不可用分析 (2026-04-24)

> 症状：WebUI 间歇性报"gateway 不可用"，刷新后有时恢复。
> 根因：gateway 一天内重启 10 次，重启期间 WebUI 连接全部中断。

### 崩溃时间线

```
11:18  TEMPFAIL (exit 75) — 启动时端口被旧进程占用
12:07  FAILURE (exit 1)    — 主进程异常退出
12:10  手动重启
12:13  FAILURE (exit 1)    — 主进程异常退出
12:29  SIGKILL (python+bash+sleep) — systemd 超时强杀
12:37  SIGKILL (timeout, 含1个node子进程) — 优雅退出失败
13:14  FAILURE (exit 1, 杀3个node进程)
13:46  FAILURE (exit 1, 杀8个node进程!)
14:40  SIGKILL (timeout, 杀6个node进程)
15:05  SIGKILL (timeout, 杀1个python进程)
```

### 三个叠加的根因

**1. MemOS bridge.cjs 子进程泄漏（最严重）**

- 每次 cron job（idle loop 每30分钟）或 API 请求触发 MemOS 插件时，fork 新 bridge.cjs 子进程
- 用完后不回收，进程持续累积
- 当前积压 **26 个 bridge.cjs 进程，占约 2.3GB 内存**
- 崩溃时 systemd 杀死的 node 子进程数量随时间递增（1→3→8→6），说明泄漏持续
- 内存压力最终导致 gateway 主进程卡死或 OOM

**2. session_search summarization 模型 403 错误**

- 今天 17 次 "Session summarization failed after 3 attempts: Error code: 403 — This model is not available in your region"
- summarization 用的模型有地区限制（可能是 deepseek-v3.2 或其他模型）
- 每次失败重试 3 次，期间可能阻塞 event loop

**3. Gateway 无法优雅退出**

- 多次 "stop-sigterm timed out" → SIGKILL
- bridge.cjs 子进程不响应 SIGTERM
- pending 的 aiohttp session 未关闭
- 导致 systemd 等待超时后强杀，加剧重启延迟

### WebUI 报错的直接原因

Gateway 重启期间（通常 30s 内）：
1. WebUI 的所有 HTTP 长连接被 reset → ECONNRESET
2. Gateway 重启后需重新初始化（加载配置、连接插件、启动 bridge），新请求会超时
3. 恰好在重启窗口内访问 WebUI → 看到"gateway 不可用"

### 待修复方向

| 优先级 | 修复 | 说明 |
|--------|------|------|
| P0 | bridge.cjs 进程回收 | MemOS 插件请求完成后主动关闭子进程，或 gateway 侧加子进程生命周期管理 |
| P1 | summarization 模型替换 | 换无地区限制的模型（如 qwen 系列）做 session_search summarization |
| P1 | gateway 优雅退出 | SIGTERM handler 先杀所有子进程；增大 TimeoutStopSec |
| P2 | WebUI 侧重试 | 对 gateway 请求加短暂重试（1-2次，间隔1s），掩盖重启窗口 |

### 快速诊断命令

```bash
# 检查 bridge.cjs 进程泄漏
ps aux | grep bridge.cjs | grep -v grep | wc -l
# 如果 > 5，说明有泄漏，需手动清理：pkill -f bridge.cjs

# 检查 gateway 今日重启次数
journalctl --user -u hermes-gateway --since today | grep 'Started hermes-gateway' | wc -l

# 检查 summarization 403 错误
journalctl --user -u hermes-gateway --since today | grep 'summarization failed' | wc -l

# 紧急清理所有泄漏的 bridge 进程
pkill -f bridge.cjs && systemctl --user restart hermes-gateway
```

## 相关页面

- [[deploy-guide]] — 完整部署流程
- [[unitree]] — 当前主要使用的机器人平台


---

## 相关链接

- [[deploy-guide.md|云服务器部署指南]]