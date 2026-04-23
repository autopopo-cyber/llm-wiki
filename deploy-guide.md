# 云服务器部署 Hermes Agent 全栈指南

> 在公网云服务器（Ubuntu 24.04）上部署完整的 Hermes Agent + Hindsight + WebUI + Obsidian Wiki 知识系统

---

## 架构总览

```
                        ┌──────────────┐
                        │   Internet   │
                        └──────┬───────┘
                               │
                    ┌──────────▼──────────┐
                    │  WebUI  (:8648)     │  ← 用户浏览器访问
                    │  systemd: hermes-web-ui │
                    └──────────┬──────────┘
                               │
                    ┌──────────▼──────────┐
                    │  Gateway  (:8642)   │  ← OpenAI 兼容 API
                    │  systemd: hermes-gateway │
                    └──────────┬──────────┘
                               │
              ┌────────────────┼────────────────┐
              │                │                 │
    ┌─────────▼──────┐ ┌──────▼────────┐ ┌─────▼──────────┐
    │ Hindsight      │ │ OpenRouter    │ │ llm-wiki/      │
    │ (:9177)         │ │ (远程API)     │ │ Obsidian Vault │
    │ systemd:        │ │               │ │ ~/llm-wiki/    │
    │ hindsight-daemon│ │ Embedding:    │ │ SCHEMA.md      │
    └────────────────┘ │ baai/bge-m3   │ └────────────────┘
                       │ Reranker:     │
                       │ cohere/rerank │
                       │ LLM: 各种模型 │
                       └───────────────┘
```

### 三个 systemd user service

| 服务 | 端口 | 启动命令 | 功能 |
|------|------|---------|------|
| `hermes-gateway` | 8642 | `python -m hermes_cli.main gateway run --replace` | 消息平台网关 + OpenAI 兼容 API |
| `hermes-web-ui` | 8648 | `node /usr/lib/node_modules/hermes-web-ui/dist/server/index.js` | Web 管理界面 |
| `hindsight-daemon` | 9177 | `python -m hindsight_embed.cli daemon start --profile hermes` | 长期记忆后端 |

### 依赖关系

```
hermes-web-ui → hermes-gateway (先启动 gateway)
hermes-web-ui → hindsight-daemon (先启动 hindsight)
hermes-gateway → 无依赖
hindsight-daemon → 无依赖
```

---

## Step 1: 系统准备

### 1.1 更换国内镜像源（加速下载）

```bash
# apt 换清华源
sudo sed -i 's|http://archive.ubuntu.com|https://mirrors.tuna.tsinghua.edu.cn|g' /etc/apt/sources.list.d/ubuntu.sources
sudo sed -i 's|http://security.ubuntu.com|https://mirrors.tuna.tsinghua.edu.cn|g' /etc/apt/sources.list.d/ubuntu.sources
sudo apt update

# pip/uv 换清华源
mkdir -p ~/.config/pip
cat > ~/.config/pip/pip.conf << 'EOF'
[global]
index-url = https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple
trusted-host = mirrors.tuna.tsinghua.edu.cn
EOF
```

### 1.2 安装代理（访问外网必须）

```bash
# 安装 mihomo (Clash.Meta)
# 详见 skill: mihomo-proxy-setup
# 默认监听 socks5://127.0.0.1:7890

# 验证代理
curl -x http://127.0.0.1:7890 --max-time 5 https://www.google.com -o /dev/null -w "%{http_code}"
# 应返回 200
```

### 1.3 安装基础依赖

```bash
sudo apt install -y python3 python3-venv nodejs npm
```

---

## Step 2: 安装 Hermes Agent

```bash
# Hermes 自动安装到 ~/.hermes/hermes-agent/
# 安装过程中会创建 venv 和下载依赖
# 需要设置代理环境变量
export http_proxy=http://127.0.0.1:7890
export https_proxy=http://127.0.0.1:7890

# 通过官方安装脚本或 pip 安装
pip install hermes-agent
```

---

## Step 3: 配置 Hermes

### 3.1 主配置 `~/.hermes/config.yaml`

关键配置项：

```yaml
model: z-ai/glm-5.1          # 主模型 (via OpenRouter)
cheap_model: deepseek/deepseek-v3.2  # 副模型 (via OpenRouter)

provider: openrouter
api_key: sk-or-xxx           # OpenRouter API Key

auxiliary:
  vision:
    model: qwen/qwen2.5-vl-72b-instruct
  web_extract:
    model: deepseek/deepseek-v3.2
  compression:
    model: deepseek/deepseek-v3.2
  session_search:
    model: deepseek/deepseek-v3.2
  skills_hub:
    model: deepseek/deepseek-v3.2
  approval:
    model: deepseek/deepseek-v3.2
  mcp:
    model: deepseek/deepseek-v3.2
  flush_memories:
    model: deepseek/deepseek-v3.2

memory:
  provider: hindsight
```

### 3.2 环境变量 `~/.hermes/.env`

```
API_SERVER_HOST=0.0.0.0
API_SERVER_PORT=8642
API_SERVER_KEY=<your-api-key>
API_SERVER_CORS_ORIGINS=*

# OpenRouter API Key
OPENROUTER_API_KEY=sk-or-xxx

# 代理
http_proxy=http://127.0.0.1:7890
https_proxy=http://127.0.0.1:7890

# Wiki 路径
WIKI_PATH=/home/agentuser/llm-wiki
```

---

## Step 4: 配置 Hindsight 记忆系统

### 4.1 安装 Hindsight（避免下载本地大模型！）

```bash
VENV_PYTHON=~/.hermes/hermes-agent/venv/bin/python

# 安装 slim 版本 + 客户端 + embed 管理器
uv pip install --python $VENV_PYTHON \
  "hindsight-api-slim[embedded-db]" \
  hindsight-client \
  hindsight-embed
```

**⚠️ 关键：使用 `hindsight-api-slim` 而不是 `hindsight-api`！**
- `hindsight-api` = 完整版，会拉 torch/CUDA（5GB+）
- `hindsight-api-slim[embedded-db]` = 轻量版，只含 pg0-embedded 数据库

### 4.2 修复 daemon 启动逻辑（重要 patch）

**问题**：`hindsight-embed` 默认用 `uvx hindsight-api@{version}` 启动 daemon，这会下载完整版（含 torch/CUDA）。

**修复**：修改 `~/.hermes/hermes-agent/venv/lib/python3.11/site-packages/hindsight_embed/daemon_embed_manager.py`

找到 `_find_api_command` 方法，在方法开头添加本地命令检测：

```python
def _find_api_command(self) -> list[str]:
    """Find the command to run hindsight-api."""
    # 【PATCH】Check if hindsight-api is already installed in the current venv
    import shutil
    local_cmd = shutil.which("hindsight-api")
    if local_cmd:
        return [local_cmd]

    # ... 后面原有的逻辑不变
```

### 4.3 修复 reasoning model 检测（重要 patch）

**问题**：Hindsight 的 `_supports_reasoning_model()` 原来匹配所有 `deepseek` 开头的模型，导致 `deepseek-v3.2` 这种聊天模型被当作推理模型，retain 操作从 16 秒变成 98 秒。

**修复**：修改 `~/.hermes/hermes-agent/venv/lib/python3.11/site-packages/hindsight_api/engine/providers/openai_compatible_llm.py`

```python
def _supports_reasoning_model(self) -> bool:
    """Check if the current model is a reasoning model (o1, o3, GPT-5, DeepSeek-R1)."""
    model_lower = self.model.lower()
    # Only match deepseek-r1/reasoner, not deepseek-chat/v3.2
    return any(x in model_lower for x in ["gpt-5", "o1", "o3", "deepseek-r1", "deepseek-reasoner"])
```

### 4.4 Hindsight 集成配置 `~/.hermes/hindsight/config.json`

```json
{
  "mode": "local_external",
  "api_url": "http://localhost:9177",
  "bank_id": "hermes",
  "recall_budget": "mid",
  "memory_mode": "hybrid",
  "recall_prefetch_method": "recall",
  "auto_recall": true,
  "auto_retain": true,
  "retain_every_n_turns": 1,
  "retain_async": true,
  "retain_context": "conversation between Hermes Agent and the User",
  "recall_max_tokens": 4096,
  "recall_max_input_chars": 800
}
```

### 4.5 Hindsight Daemon Profile `~/.hindsight/profiles/hermes.env`

```bash
# LLM 配置（通过 OpenRouter，OpenAI 兼容格式）
HINDSIGHT_API_LLM_PROVIDER=openai
HINDSIGHT_API_LLM_API_KEY=sk-or-xxx
HINDSIGHT_API_LLM_MODEL=deepseek/deepseek-v3.2
HINDSIGHT_API_LLM_BASE_URL=https://openrouter.ai/api/v1

# Embedding 配置（通过 OpenRouter）
HINDSIGHT_API_EMBEDDINGS_PROVIDER=openrouter
HINDSIGHT_API_EMBEDDINGS_OPENROUTER_API_KEY=sk-or-xxx
HINDSIGHT_API_EMBEDDINGS_OPENROUTER_MODEL=baai/bge-m3

# Reranker 配置（通过 OpenRouter）
HINDSIGHT_API_RERANKER_PROVIDER=openrouter
HINDSIGHT_API_RERANKER_OPENROUTER_API_KEY=sk-or-xxx
HINDSIGHT_API_RERANKER_OPENROUTER_MODEL=cohere/rerank-v3.5

# 禁用空闲超时（否则 5 分钟没人用就自动关了）
HINDSIGHT_EMBED_DAEMON_IDLE_TIMEOUT=0

# 限制 retain 输出 token 数
HINDSIGHT_API_RETAIN_MAX_COMPLETION_TOKENS=4096
```

**⚠️ 关键**：`HINDSIGHT_EMBED_DAEMON_IDLE_TIMEOUT=0` 必须设置！否则 daemon 5 分钟无请求自动退出，而 systemd 的 `Restart=on-failure` 不会重启正常退出（exit code 0）的进程。

---

## Step 5: 创建 systemd User Services

### 5.1 启用 user lingering（确保用户未登录时服务也运行）

```bash
sudo loginctl enable-linger agentuser
```

### 5.2 Gateway Service

`~/.config/systemd/user/hermes-gateway.service`：

```ini
[Unit]
Description=Hermes Agent Gateway - Messaging Platform Integration
After=network.target
StartLimitIntervalSec=600
StartLimitBurst=5

[Service]
Type=simple
ExecStart=/home/agentuser/.hermes/hermes-agent/venv/bin/python -m hermes_cli.main gateway run --replace
WorkingDirectory=/home/agentuser/.hermes/hermes-agent
Environment="PATH=/home/agentuser/.hermes/hermes-agent/venv/bin:/home/agentuser/.hermes/hermes-agent/node_modules/.bin:/usr/bin:/home/agentuser/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
Environment="VIRTUAL_ENV=/home/agentuser/.hermes/hermes-agent/venv"
Environment="HERMES_HOME=/home/agentuser/.hermes"
Restart=on-failure
RestartSec=30
RestartForceExitStatus=75
KillMode=mixed
KillSignal=SIGTERM
ExecReload=/bin/kill -USR1 $MAINPID
TimeoutStopSec=60
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=default.target
```

### 5.3 WebUI Service

`~/.config/systemd/user/hermes-web-ui.service`：

```ini
[Unit]
Description=Hermes Web UI - Dashboard for Hermes Agent
After=network.target hermes-gateway.service hindsight-daemon.service
Wants=hermes-gateway.service hindsight-daemon.service
StartLimitIntervalSec=600
StartLimitBurst=5

[Service]
Type=simple
ExecStart=/usr/bin/node /usr/lib/node_modules/hermes-web-ui/dist/server/index.js
WorkingDirectory=/home/agentuser/.hermes/hermes-agent
Environment="PATH=/home/agentuser/.hermes/hermes-agent/venv/bin:/home/agentuser/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
Environment="HERMES_HOME=/home/agentuser/.hermes"
Environment="PORT=8648"
Environment="AUTH_TOKEN=<your-webui-auth-token>"
Environment="http_proxy=http://127.0.0.1:7890"
Environment="https_proxy=http://127.0.0.1:7890"
Environment="all_proxy=socks5://127.0.0.1:7890"
Environment="no_proxy=localhost,127.0.0.1,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16"
Restart=on-failure
RestartSec=10
KillMode=mixed
KillSignal=SIGTERM
TimeoutStopSec=30
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=default.target
```

**注意**：WebUI 启动时会自动检测 gateway 状态。如果 gateway 已在运行（PID 文件存在 + 健康检查通过），**不会重复启动 gateway**。

### 5.4 Hindsight Daemon Service

`~/.config/systemd/user/hindsight-daemon.service`：

```ini
[Unit]
Description=Hindsight Embedded Daemon - Long-term Memory for Hermes
After=network.target
StartLimitIntervalSec=600
StartLimitBurst=5

[Service]
Type=forking
ExecStart=/home/agentuser/.hermes/hermes-agent/venv/bin/python -m hindsight_embed.cli daemon start --profile hermes
ExecStop=/home/agentuser/.hermes/hermes-agent/venv/bin/python -m hindsight_embed.cli daemon stop --profile hermes
WorkingDirectory=/home/agentuser/.hermes/hermes-agent
Environment="PATH=/home/agentuser/.hermes/hermes-agent/venv/bin:/home/agentuser/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
Environment="VIRTUAL_ENV=/home/agentuser/.hermes/hermes-agent/venv"
Environment="HERMES_HOME=/home/agentuser/.hermes"
EnvironmentFile=/home/agentuser/.hindsight/profiles/hermes.env
Restart=always
RestartSec=30
KillMode=mixed
KillSignal=SIGTERM
TimeoutStopSec=60
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=default.target
```

**注意**：`Restart=always`（不是 `on-failure`）+ `HINDSIGHT_EMBED_DAEMON_IDLE_TIMEOUT=0`，确保 daemon 不会因空闲退出后无法自动恢复。

### 5.5 启用所有服务

```bash
systemctl --user daemon-reload
systemctl --user enable hermes-gateway hermes-web-ui hindsight-daemon

# 按依赖顺序启动
systemctl --user start hermes-gateway
systemctl --user start hindsight-daemon
systemctl --user start hermes-web-ui

# 验证
systemctl --user status hermes-gateway hermes-web-ui hindsight-daemon
```

---

## Step 6: 安装 Obsidian + 创建知识库

### 6.1 安装 Obsidian

```bash
# 下载 AppImage（需要代理）
wget -O ~/obsidian.AppImage https://github.com/obsidianmd/obsidian-releases/releases/latest/download/obsidian-1.8.10-arm64.AppImage

# 安装
chmod +x ~/obsidian.AppImage
sudo mv ~/obsidian.AppImage /usr/bin/obsidian

# 验证
obsidian --version
```

**注意**：Obsidian 在无头服务器上无法运行 GUI，但 vault 是纯 markdown 文件目录，可以直接用文件系统操作。Obsidian GUI 只在你本地电脑打开 vault 目录时才需要。

### 6.2 创建 Wiki Vault

使用 `llm-wiki` skill 创建结构化知识库：

```bash
# 依赖环境变量
export WIKI_PATH=~/llm-wiki

# 手动创建目录结构
mkdir -p ~/llm-wiki/{raw/{articles,papers,notes,meetings,assets},entities,concepts,comparisons,queries,_archive}
```

然后让 Hermes 加载 `llm-wiki` skill，按 Phase 1 流程初始化 vault：
1. 确定领域和标签体系 → 写入 `SCHEMA.md`
2. 创建 `index.md`（内容目录）
3. 创建 `log.md`（操作日志）

### 6.3 定制 SCHEMA.md（具身智能领域示例）

```markdown
# SCHEMA.md — 具身智能 LLM Wiki

## Domain
embodied-intelligence (robotics, quadruped, hw/sw development)

## Tags (6 categories, 26 tags)

### 🔧 Hardware
- `actuator` — Motor, servo, hydraulic
- `sensor` — IMU, LiDAR, camera, force/torque
- `embedded` — MCU, SoC, compute module
- `pcb` — PCB design, routing, EDA
- `mechanical` — CAD, structural, linkage
- `manufacturing` — 3D print, CNC, injection

### 🐕 Quadruped
- `quadruped` — Dog robot specific
- `gait` — Walk, trot, gallop
- `sim2real` — Sim-to-real transfer

### 💻 Software Stack
- `ros` — ROS/ROS2
- `control` — PID, MPC, whole-body
- `perception` — Vision, SLAM
- `planning` — Path, task
- `simulation` — Isaac Sim, MuJoCo

### 🧠 AI
- `rl` — Reinforcement learning
- `imitation` — Imitation / demo learning
- `end2end` — End-to-end policy
- `foundation-model` — VLM, world model

### 🏭 Industry
- `company` — Company profiles
- `product` — Product specs
- `open-source` — OSS projects
- `paper` — Academic papers
- `benchmark` — Benchmarks

### 📋 Meta
- `comparison` — Head-to-head
- `timeline` — Chronology
- `controversy` — Debate
- `tutorial` — How-to
- `supply-chain` — Components sourcing
```

---

## Step 7: 防火墙 & 外网访问

```bash
# 开放端口
sudo ufw allow 8648/tcp  # WebUI
sudo ufw allow 8642/tcp  # API Server (如需外网 API 访问)

# 或使用云服务器安全组规则
```

**外网访问地址**：
- WebUI: `http://<公网IP>:8648`
- API: `http://<公网IP>:8642/v1`（OpenAI 兼容格式，模型名 `hermes-agent`）

---

## 踩坑记录 & 注意事项

### ❌ 坑 1：hindsight-embed 用 uvx 下载完整版

**现象**：启动 daemon 时自动 `uvx hindsight-api@0.5.3`，下载 5GB+ 的 torch/CUDA。

**解决**：Patch `daemon_embed_manager.py` 的 `_find_api_command()`，优先用 `shutil.which("hindsight-api")` 检测本地已安装的命令。

### ❌ 坑 2：deepseek 模型被误判为推理模型

**现象**：`deepseek-v3.2` 是聊天模型，但 `_supports_reasoning_model()` 原来匹配所有 `deepseek` 开头的模型名，导致 retain 操作从 16 秒变成 98 秒。

**解决**：Patch `openai_compatible_llm.py`，只匹配 `deepseek-r1` 和 `deepseek-reasoner`。

### ❌ 坑 3：Hindsight daemon 空闲自动退出

**现象**：5 分钟无请求后 daemon 正常退出（exit 0），systemd `Restart=on-failure` 不会重启，导致下次使用报 `Cannot connect to host localhost:9177`。

**解决**：
1. `HINDSIGHT_EMBED_DAEMON_IDLE_TIMEOUT=0` — 禁用空闲超时
2. `Restart=always` — 即使正常退出也自动重启

### ❌ 坑 4：WebUI 启动重复 gateway

**现象**：担心 WebUI 启动时 `GatewayManager.startAll()` 会启动多个 gateway。

**验证**：`startAll()` 先 `detectStatus`，如果 gateway PID 文件存在且进程存活 + 健康检查通过，直接跳过。`hermes gateway start` 命令在 gateway 已运行时也只确认状态不重复启动。

**结论**：安全，不会启动重复 gateway。

### ❌ 坑 5：Hindsight 启动时 embedding API 空响应

**现象**：`ValueError: No embedding data received`，导致 daemon 启动失败，systemd 超时杀掉 PostgreSQL 进程。

**解决**：临时性网络抖动，重试即可。如果频繁出现，检查 OpenRouter API 配额和代理连接。

### ❌ 坑 6：切换 WebUI 到 systemd 时断连

**现象**：用户通过 WebUI 与 Agent 对话，停 WebUI = 断连。

**解决**：先 enable 不启动，选合适时机快速切换。Gateway 是独立 systemd service，不受 WebUI 重启影响。切换后刷新页面即可重连。

### ❌ 坑 7：Hindsight daemon 退出导致 "Unclosed client session"

**现象**：Gateway 日志大量出现 `ERROR asyncio: Unclosed client session` 和 `Unclosed client connector`。

**根因**：Hindsight daemon 因空闲超时退出（坑 3 的同类问题），Gateway 的 Hindsight 插件尝试连接 localhost:9177 被拒绝，但 aiohttp ClientSession 在异常路径没有正确关闭，Python asyncio 检测到未关闭的 session 报 ERROR。

**解决**：确保坑 3 的两项修复到位（`IDLE_TIMEOUT=0` + `Restart=always`），重启 gateway 清除残留错误。

### ❌ 坑 8：WebUI 无法弹授权窗口，agent 卡死

**现象**：通过 WebUI 使用 agent 时，执行需要审批的危险命令（如 `systemctl restart`、`apt install`）后 agent 无响应，最终超时。

**根因**：API Server 适配器（`gateway/platforms/api_server.py`）完全没有实现 approval 机制：
- 没有 `send_exec_approval` 方法（无法弹授权按钮/窗口）
- 没有注册 `register_gateway_notify` 回调
- 当 agent 需要审批时，审批请求无法送达用户，agent 线程阻塞等待 → 卡死

**解决**：在 `~/.hermes/config.yaml` 中设 `approvals.mode: off`（全局 yolo），跳过所有审批。

```yaml
approvals:
  mode: off    # manual / smart / off
```

三种模式对比：
| 模式 | 行为 | WebUI 兼容性 |
|------|------|-------------|
| `manual` | 每次需用户确认 | ❌ 卡死 |
| `smart` | 辅助 LLM 判断风险，高风险仍需人工 | ❌ 高风险命令仍卡死 |
| `off` | 全部自动放行 | ✅ 唯一可用 |

> 待 Hermes 的 API Server 适配器加上 approval 支持后，可改回 `smart`。

---

## 日常运维命令

```bash
# 查看所有服务状态
systemctl --user status hermes-gateway hermes-web-ui hindsight-daemon

# 重启单个服务
systemctl --user restart hermes-gateway
systemctl --user restart hermes-web-ui
systemctl --user restart hindsight-daemon

# 查看日志
journalctl --user -u hermes-gateway -f      # 实时跟踪
journalctl --user -u hermes-web-ui --since "1 hour ago"
journalctl --user -u hindsight-daemon -n 50  # 最近 50 行

# Hindsight 健康检查
curl -s http://localhost:9177/health | python3 -m json.tool

# Gateway 健康检查
curl -s http://localhost:8642/health

# 检查端口占用
ss -tlnp | grep -E "8642|8648|9177"
```


---

## 相关链接

- [[hermes-maintenance.md|Hermes Agent 维护知识]]