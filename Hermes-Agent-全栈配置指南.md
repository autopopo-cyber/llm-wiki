---
title: Hermes Agent 全栈配置指南
created: 2026-04-21
updated: 2026-04-21
type: concept
tags: [open-source, tutorial, maintenance]
sources: [deploy-guide.md, hermes-maintenance.md, Hermes-plan-机制调研与OpenClaw对比.md, tree-plan skill, llm-wiki skill, cloud-deploy-guide skill]
---

# Hermes Agent 全栈配置指南

> 从零到完整运行的 Hermes Agent 全栈配置手册。涵盖安装、Hindsight 记忆系统、Wiki 知识库与 tree-plan、WebUI（占位）。
> 部署运维排错见 [[hermes-maintenance]]，Plan 机制设计思路见 [[Hermes-plan-机制调研与OpenClaw对比]]。

---

## 一、架构总览

```
                        ┌──────────────┐
                        │   Internet   │
                        └──────┬───────┘
                               │
                    ┌──────────▼──────────┐
                    │  WebUI  (:8648)     │  ← 暂未启用（稳定性不足）
                    └──────────┬──────────┘
                               │
                    ┌──────────▼──────────┐
                    │  Gateway  (:8642)   │  ← OpenAI 兼容 API + 微信/Telegram
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
    └────────────────┘ │ baai/bge-m3   │ │ active-plan.md │
                       │ Reranker:     │ └────────────────┘
                       │ cohere/rerank │
                       │ LLM: 多种模型 │
                       └───────────────┘
```

| 服务 | 端口 | systemd unit | 功能 |
|------|------|-------------|------|
| Gateway | 8642 | hermes-gateway | 消息平台网关 + OpenAI 兼容 API |
| WebUI | 8648 | hermes-web-ui | Web 管理界面（当前已禁用） |
| Hindsight | 9177 | hindsight-daemon | 长期记忆后端 |

依赖关系：`WebUI → Gateway + Hindsight`，`Gateway → 无`，`Hindsight → 无`。

---

## 二、Hermes Agent 安装与配置

### 2.1 系统准备

```bash
# 换清华镜像源
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

# 安装代理（访问外网必须，详见 skill: mihomo-proxy-setup）
# 默认监听 http://127.0.0.1:7890

# 启用 user lingering（未登录时服务也运行）
sudo loginctl enable-linger agentuser
```

### 2.2 安装 Hermes

```bash
export http_proxy=http://127.0.0.1:7890
export https_proxy=http://127.0.0.1:7890

pip install hermes-agent
# 安装到 ~/.hermes/hermes-agent/
```

### 2.3 主配置 `~/.hermes/config.yaml`

```yaml
model: z-ai/glm-5.1                  # 主模型 (via OpenRouter)
cheap_model: deepseek/deepseek-v3.2   # 副模型 (via OpenRouter)

provider: openrouter
api_key: sk-or-xxx                    # OpenRouter API Key

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

# ⚠️ WebUI 无审批机制，必须设 off（否则 agent 卡死）
approvals:
  mode: off
```

**approvals.mode 三种模式对比：**

| 模式 | 行为 | WebUI 兼容性 |
|------|------|-------------|
| `manual` | 每次需用户确认 | ❌ 卡死 |
| `smart` | 辅助 LLM 判断风险，高风险仍需人工 | ❌ 高风险命令仍卡死 |
| `off` | 全部自动放行 | ✅ 唯一可用 |

> 待 API Server 适配器加上 approval 支持后可改回 `smart`。

### 2.4 环境变量 `~/.hermes/.env`

```
API_SERVER_HOST=0.0.0.0
API_SERVER_PORT=8642
API_SERVER_KEY=<your-api-server-key>
API_SERVER_CORS_ORIGINS=*

OPENROUTER_API_KEY=***

http_proxy=http://127.0.0.1:7890
https_proxy=http://127.0.0.1:7890

WIKI_PATH=/home/agentuser/llm-wiki
```

### 2.5 关键配置文件索引

| 文件 | 用途 |
|------|------|
| `~/.hermes/config.yaml` | 主配置：模型、审批模式、记忆 provider、辅助模型 |
| `~/.hermes/.env` | API 密钥、代理、端口等环境变量 |
| `~/.hermes/persona.md` | Agent 行为人格定义 |
| `~/.hermes/plans/active-plan.md` | 当前活跃计划树（tree-plan） |

---

## 三、Hindsight 记忆系统

### 3.1 安装 Hindsight

**⚠️ 关键：使用 `hindsight-api-slim`，不要用 `hindsight-api`！**

- `hindsight-api` = 完整版，会拉 torch/CUDA（5GB+）
- `hindsight-api-slim[embedded-db]` = 轻量版，只含 pg0-embedded 数据库

```bash
VENV_PYTHON=~/.hermes/hermes-agent/venv/bin/python

uv pip install --python $VENV_PYTHON \
  "hindsight-api-slim[embedded-db]" \
  hindsight-client \
  hindsight-embed
```

### 3.2 必要 Patch（安装后手动应用）

#### Patch 1：修复 daemon 启动逻辑

**文件**：`venv/lib/python3.11/site-packages/hindsight_embed/daemon_embed_manager.py`

**问题**：默认用 `uvx hindsight-api@{version}` 启动 daemon，会下载完整版（5GB+ torch/CUDA）。

**修复**：在 `_find_api_command()` 方法开头添加：

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

#### Patch 2：修复 reasoning model 检测

**文件**：`venv/lib/python3.11/site-packages/hindsight_api/engine/providers/openai_compatible_llm.py`

**问题**：`_supports_reasoning_model()` 原来匹配所有 `deepseek` 开头的模型，导致 `deepseek-v3.2` 被当作推理模型，retain 从 16s 变 98s。

**修复**：

```python
def _supports_reasoning_model(self) -> bool:
    """Check if the current model is a reasoning model."""
    model_lower = self.model.lower()
    # Only match deepseek-r1/reasoner, not deepseek-chat/v3.2
    return any(x in model_lower for x in ["gpt-5", "o1", "o3", "deepseek-r1", "deepseek-reasoner"])
```

> ⚠️ 这两个 patch 在 `pip install` 升级 hindsight 后可能被覆盖，需重新应用。

### 3.3 Hindsight 集成配置 `~/.hermes/hindsight/config.json`

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

**memory_mode 三种模式：**

| 模式 | 行为 | 适用场景 |
|------|------|---------|
| `hybrid` | 自动注入上下文 + 提供工具调用 | 默认推荐 |
| `context` | 仅自动注入，不提供工具 | 让 agent 专注于已注入内容 |
| `tools` | 仅提供工具，不自动注入 | 需要精确控制召回时机 |

### 3.4 Hindsight Daemon Profile `~/.hindsight/profiles/hermes.env`

```bash
# LLM 配置（通过 OpenRouter，OpenAI 兼容格式）
HINDSIGHT_API_LLM_PROVIDER=openai
HINDSIGHT_API_LLM_API_KEY=***
HINDSIGHT_API_LLM_MODEL=deepseek/deepseek-v3.2
HINDSIGHT_API_LLM_BASE_URL=https://openrouter.ai/api/v1

# Embedding 配置（通过 OpenRouter）
HINDSIGHT_API_EMBEDDINGS_PROVIDER=openrouter
HINDSIGHT_API_EMBEDDINGS_OPENROUTER_API_KEY=***
HINDSIGHT_API_EMBEDDINGS_OPENROUTER_MODEL=baai/bge-m3

# Reranker 配置（通过 OpenRouter）
HINDSIGHT_API_RERANKER_PROVIDER=openrouter
HINDSIGHT_API_RERANKER_OPENROUTER_API_KEY=***
HINDSIGHT_API_RERANKER_OPENROUTER_MODEL=cohere/rerank-v3.5

# 禁用空闲超时（必须！否则 5 分钟无人用就退出）
HINDSIGHT_EMBED_DAEMON_IDLE_TIMEOUT=0

# 限制 retain 输出 token 数
HINDSIGHT_API_RETAIN_MAX_COMPLETION_TOKENS=4096
```

**⚠️ `HINDSIGHT_EMBED_DAEMON_IDLE_TIMEOUT=0` 必须设置！** 否则 daemon 5 分钟无请求自动退出，而 systemd `Restart=on-failure` 不会重启正常退出（exit code 0）的进程。

### 3.5 Hindsight 工作流程

```
用户发消息
    ↓
Gateway 接收 → 创建/获取 Agent 实例
    ↓
queue_prefetch_all(user_message)  ← 后台线程发起 recall
    ↓
Agent 处理消息（prefetch 结果注入 system prompt 的 memory-context 块）
    ↓
Agent 回复完成
    ↓
sync_turn(user_msg, assistant_msg)  ← 后台线程 retain 对话轮
    ↓
queue_prefetch_all(assistant_msg)   ← 为下一轮预取
```

**CLI vs WebUI 的关键差异：**

- CLI：Agent 实例在整个会话内复用，`_prefetch_result` 跨轮累积，正常工作。
- WebUI：gateway 的 `_agent_cache` 缓存签名含 `ephemeral_prompt`，每轮 context 变化导致缓存 miss → 每次创建新 Agent + 新 HindsightMemoryProvider → `_prefetch_result` 永远为空。这是 WebUI 侧的问题，Hindsight 本身工作正常。

---

## 四、Wiki 知识库与 tree-plan

### 4.1 Wiki 架构

使用 `llm-wiki` skill 构建，位于 `~/llm-wiki/`，是纯 markdown 文件目录，可用 Obsidian 打开。

```
llm-wiki/
├── SCHEMA.md           # 领域定义、标签体系、页面规范
├── index.md            # 内容目录（每页一行摘要）
├── log.md              # 操作日志（append-only）
├── raw/                # 不可变的原始资料
│   ├── articles/       # 网页文章
│   ├── papers/         # 论文
│   └── assets/         # 图片
├── entities/           # 实体页（人、公司、产品）
├── concepts/           # 概念页（算法、架构、方法论）
├── comparisons/        # 对比分析页
└── queries/            # 值得保留的查询结果
```

**三层架构：**
- Layer 1 — Raw Sources：不可变，Agent 只读不写
- Layer 2 — Wiki Pages：Agent 创建、更新、交叉引用
- Layer 3 — Schema：`SCHEMA.md` 定义结构和标签体系

### 4.2 Wiki 核心操作

| 操作 | 流程 |
|------|------|
| **Ingest** | 捕获原始资料 → 讨论要点 → 检查已有页 → 写/更新页 → 更新 index+log |
| **Query** | 读 index → search_files → 读相关页 → 综合回答 → 值得保留的归档到 queries/ |
| **Lint** | 检查孤立页、断裂 wikilink、frontmatter 完整性、标签合规、过期内容 |

**每次会话开始必须执行 Orientation：**
1. 读 `SCHEMA.md` — 了解领域和规范
2. 读 `index.md` — 了解已有页面
3. 扫描 `log.md` 最近 20-30 条 — 了解近期活动

### 4.3 tree-plan：树状计划管理

**文件位置**：`~/.hermes/plans/active-plan.md`

tree-plan 和 llm-wiki 互补不合并：

| | tree-plan | llm-wiki |
|--|-----------|----------|
| **用途** | 当前要做什么 | 已知的、沉淀的知识 |
| **生命周期** | 每轮对话看、结束时维护 | 周期更长，维护更细 |
| **格式** | 扁平的树状文本 | 完整 markdown 文档 |
| **关系** | tree 是精简的 index | wiki 是完成项目的归宿 |

#### 计划文件格式

```
【root】【未完成】军警级四足机器人导航系统 → [[四足导航开发路线]]
	【lv.1】【已完成】Marathongo 源码分析 → [[Marathongo-深度技术分析]]
	【lv.1】【未完成】导航避障算法开发 → [[四足导航开发路线]]
		【lv.2】【当前正在处理】Phase 1: IMU-LiDAR 融合去畸变
		【lv.2】【未完成】Phase 2: 切弧避障 + 边缘约束
```

#### 标记规范

**层级标记**：`【root】`（树根，无缩进）→ `【lv.1】`（1 tab）→ `【lv.2】`（2 tab）→ `【lv.N】`

**状态标记**：

| 标记 | 含义 | 规则 |
|------|------|------|
| 【正在处理】 | 全局注意力 | **只打在叶子节点**，全局不超过 2 个，也是中断恢复锚点 |
| 【未完成】 | 待执行 | 默认状态 |
| 【已完成】 | 已完成 | 子节点全完成 → 父节点自动推导 |
| 【已取消】 | 不再需要 | |
| 【已阻塞】 | 外部依赖阻塞 | |

**核心规则**：`【当前正在处理】` 只打在叶子节点上（没有子节点的最末端任务），父节点状态由子节点自动推导。

#### 回合生命周期（v2.0）

**Phase 1：回合开始**
1. 读 tree → 解析当前状态
2. 展示候选任务（🔴正在处理 / ⚪优先 / 📦其他，分层列出）
3. 询问用户：继续？切换？新任务？→ 标记【正在处理】

**Phase 2：回合中**
- 唯一性维护：全局【正在处理】≤ 2
- 完成即时标记：子步骤完成立即更新 tree
- 发现新子任务：在当前节点下插入子节点
- 任务切换：旧任务降级→【未完成】，新任务→【正在处理】

**Phase 3：回合结束**（三种情况）
- ✅ 完成 → 标记【已完成】，清除【正在处理】，检查父节点
- 🔄 未完成可拆分 → 生成子节点，【正在处理】移到第一个子任务
- 🔄 未完成不可拆分 → 保持【正在处理】，下次接续
- **必须输出 📋 总结**（完成/进行中/下一步/阻塞）

**Phase 4：中断恢复**
- 【正在处理】= 断点快照，守护 loop 可检测并接续
- 无需额外 savepoint 机制

#### 叶子节点与 Wiki 的关联

叶子节点格式：`【lv.N】【状态】任务名 → [[wiki文件名]]`

- 叶子完成时，产出应沉淀到 wiki
- tree 是 wiki/index.md 的精简版 — 看 tree 知全貌，需要细节再进 wiki

---

## 五、Systemd User Services

### 5.1 Gateway Service

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

### 5.2 Hindsight Daemon Service

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

**注意**：`Restart=always`（不是 `on-failure`）+ `HINDSIGHT_EMBED_DAEMON_IDLE_TIMEOUT=0`，确保 daemon 不因空闲退出后无法恢复。

### 5.3 启用服务

```bash
systemctl --user daemon-reload
systemctl --user enable hermes-gateway hindsight-daemon

# 按依赖顺序启动
systemctl --user start hindsight-daemon
sleep 5
systemctl --user start hermes-gateway

# 验证
systemctl --user status hermes-gateway hindsight-daemon
```

---

## 六、WebUI 配置（占位）

> WebUI（hermes-web-ui）目前因稳定性问题已禁用（2026-04-21）。
> 保留配置信息供后续恢复参考。

### 6.1 已知问题

1. **Agent 缓存重建**：每轮对话 gateway 的 `_agent_cache` 缓存 miss → 重建 Agent → Hindsight prefetch 为空
2. **审批卡死**：API Server 适配器无 approval 机制，`approvals.mode` 非 `off` 时 agent 阻塞
3. **断连丢消息**：WebUI 重启过程中可能吞掉未处理的消息

### 6.2 WebUI Service 模板

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
Environment="AUTH_TOKEN=<your-auth-token>"
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

### 6.3 恢复 WebUI 的条件

- [ ] API Server 适配器实现 approval 机制（send_exec_approval + register_gateway_notify）
- [ ] Gateway `_agent_cache` 缓存签名优化，避免每轮重建 Agent
- [ ] WebUI 消息缓冲/重试机制，避免断连丢消息

恢复命令：`systemctl --user enable --now hermes-web-ui`

---

## 七、常见故障排查

| 问题 | 根因 | 解决 |
|------|------|------|
| "Unclosed client session" | Hindsight daemon 退出，gateway 插件连不上 | 确保 `IDLE_TIMEOUT=0` + `Restart=always`，重启 gateway |
| WebUI 执行命令卡死 | API Server 无 approval 机制 | `approvals.mode: off` |
| daemon 频繁退出 | 空闲超时 5 分钟 | `HINDSIGHT_EMBED_DAEMON_IDLE_TIMEOUT=0` |
| retain 从 16s 变 98s | deepseek-v3.2 被误判为推理模型 | Patch `_supports_reasoning_model()` |
| uvx 下载 5GB+ | daemon 启动用 uvx 拉完整版 | Patch `_find_api_command()` |
| embedding API 空响应 | 网络抖动 | 重试即可 |
| Gateway 卡在 deactivating | stop 超时 | `kill -9 <PID>` → `reset-failed` → `start` |

```bash
# 一键健康检查
curl -s http://localhost:9177/health && echo "Hindsight OK"
curl -s http://localhost:8642/health && echo "Gateway OK"

# 重启所有服务
systemctl --user restart hindsight-daemon && sleep 5
systemctl --user restart hermes-gateway

# 实时日志
journalctl --user -u hermes-gateway -f

# 检查端口
ss -tlnp | grep -E "8642|9177"
```

---

## 相关链接

- [[hermes-maintenance]] — 运维排错与已知限制
- [[deploy-guide]] — 原始部署流程（含踩坑细节）
- [[Hermes-plan-机制调研与OpenClaw对比]] — Plan 机制设计与 OpenClaw 对比
- [[四足导航开发路线]] — tree-plan 的实际应用
