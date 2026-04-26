---
title: MemOS 记忆系统部署指南
created: 2026-04-24
updated: 2026-04-24
type: concept
tags: [infrastructure, memory, memos, deployment]
sources: [MemOS GitHub, 实际部署调试记录]
---

# MemOS 记忆系统部署指南

> 替代 Hindsight 作为 Hermes Agent 的长期记忆系统。MemOS 基于 Reflect2Evolve V7 核心，提供三层记忆检索（Tier1 策略 / Tier2 Trace / Tier3 世界模型），向量+FTS 混合搜索，自动 recall 注入。

---

## 一、架构总览

```
┌──────────────────────────────────────────────────────┐
│                    Hermes Gateway                      │
│                                                        │
│  config.yaml: memory.provider: memtensor               │
│                       │                                │
│          ┌────────────▼────────────┐                   │
│          │ MemTensorProvider       │                   │
│          │ (Python adapter)        │                   │
│          │ plugins/memory/         │                   │
│          │   memtensor/__init__.py │                   │
│          └────────────┬────────────┘                   │
│                       │ JSON-RPC 2.0 over stdio        │
│          ┌────────────▼────────────┐                   │
│          │ MemOS Bridge (Node.js)  │                   │
│          │ bridge.cjs              │                   │
│          │ ~/projects/MemOS/.../   │                   │
│          └───────┬────────┬────────┘                   │
│                  │        │                             │
│     ┌────────────▼┐  ┌───▼──────────────┐              │
│     │ SQLite DB   │  │ OpenRouter API    │              │
│     │ memos.db    │  │ LLM: deepseek-v3.2│              │
│     │ (向量+FTS)  │  │ Emb: bge-m3      │              │
│     └─────────────┘  └──────────────────┘              │
└──────────────────────────────────────────────────────┘
```

**关键路径：**

| 组件 | 路径 |
|------|------|
| Python adapter | `~/.hermes/hermes-agent/plugins/memory/memtensor/` |
| MemOS 源码 | `~/projects/MemOS/` |
| Bridge 入口 | `~/projects/MemOS/apps/memos-local-plugin/dist/bridge.cjs` |
| 配置文件 | `~/.hermes/memos-plugin/config.yaml` |
| 数据库 | `~/.hermes/memos-plugin/data/memos.db` |
| API Key | `~/.hermes/.env` (MEMOS_LLM_API_KEY / MEMOS_EMBEDDING_API_KEY) |

---

## 二、安装步骤

### 2.1 克隆并构建 MemOS

```bash
cd ~/projects
git clone https://github.com/MemTensor/MemOS.git
cd MemOS/apps/memos-local-plugin
npm install
npm run build
# 产物: dist/bridge.cjs
```

### 2.2 部署 Python adapter

MemOS 项目自带 Hermes adapter，直接复制到 Hermes 插件目录：

```bash
cp -r ~/projects/MemOS/apps/memos-local-plugin/hermes-adapter/memtensor/ \
   ~/.hermes/hermes-agent/plugins/memory/memtensor/
```

目录结构：
```
memtensor/
├── __init__.py        # MemTensorProvider 类（MemoryProvider 子类）
├── bridge_client.py   # JSON-RPC 2.0 客户端（stdio 通信）
└── daemon_manager.py  # Bridge 进程生命周期管理
```

### 2.3 停用 Hindsight

```bash
# 停止 Hindsight daemon
systemctl --user stop hindsight-daemon
systemctl --user disable hindsight-daemon

# 确认进程已杀
pgrep -f hindsight && pkill -f hindsight
```

### 2.4 配置 Hermes

**`~/.hermes/config.yaml`：**
```yaml
memory:
  provider: memtensor    # 替换 hindsight
```

**`~/.hermes/memos-plugin/config.yaml`：**
```yaml
# MemOS Plugin Configuration for Hermes + OpenRouter

llm:
  provider: openai_compatible
  model: deepseek/deepseek-v3.2
  endpoint: https://openrouter.ai/api/v1
  apiKey: "你的OpenRouter密钥"    # ⚠️ 必须填真实 key，不支持环境变量回退！
  fallbackToHost: true

embedding:
  provider: openai_compatible
  model: baai/bge-m3
  endpoint: https://openrouter.ai/api/v1
  apiKey: "你的OpenRouter密钥"    # 同上
  dimensions: 1024

viewer:
  port: 18799
  bindHost: 127.0.0.1
  openOnFirstTurn: false
```

### 2.5 重启 Gateway

```bash
systemctl --user restart hermes-gateway
```

---

## 三、踩坑记录（核心！）

### 🔴 坑 1：环境变量名错误

**现象：** Bridge 用了 `~/.openclaw/` 默认路径，agent 名为 `openclaw`，embedding 用 `local`（Xenova/all-MiniLM-L6-v2, 384维）

**原因：** `__init__.py` 最初传的是 `MEMOS_CONFIG_PATH`，但 MemOS 实际识别的是 `MEMOS_HOME` + `MEMOS_CONFIG_FILE`

**修复：** `__init__.py` 第 146-149 行：
```python
self._bridge = MemosBridgeClient(
    extra_env={
        "MEMOS_HOME": str(Path.home() / ".hermes" / "memos-plugin"),
        "MEMOS_CONFIG_FILE": str(Path.home() / ".hermes" / "memos-plugin" / "config.yaml"),
    },
)
```

### 🔴 坑 2：apiKey 不能为空

**现象：** `memory_search` 返回 0 hits，搜索耗时 1-10ms（embedding 完全没调）

**原因：** `save_config()` 故意把 apiKey 写成空字符串 `""`，设计意图是通过环境变量注入。但 **MemOS 不支持 `MEMOS_LLM_API_KEY` 环境变量回退**！`apiKey: ""` = 空 key → embedding 调用失败 → 搜索无结果

**修复：** 在 `config.yaml` 中填入真实 OpenRouter key。Hermes 会对工具输出做脱敏（显示为 `sk-or-...3357`），但实际文件里是完整的。

### 🔴 坑 3：importBundle 不自动生成 embedding

**现象：** wiki 数据通过 HTTP API `importBundle` 导入后，搜索返回 0 hits

**原因：** `importBundle` 只写入 trace 数据到 SQLite，**不触发向量化**。向量只在 `memory.add` 或 `turn.end` 时按需生成。

**修复：** 用 Python 脚本批量调 OpenRouter embedding API，直接写入 SQLite：
```python
import sqlite3, requests, struct

db = sqlite3.connect("~/.hermes/memos-plugin/data/memos.db")
rows = db.execute("SELECT rowid, summary FROM traces WHERE vec_summary IS NULL").fetchall()

for rowid, text in rows:
    resp = requests.post("https://openrouter.ai/api/v1/embeddings",
        headers={"Authorization": f"Bearer {API_KEY}"},
        json={"model": "baai/bge-m3", "input": text})
    vec = resp.json()["data"][0]["embedding"]
    blob = struct.pack(f"{len(vec)}f", *vec)
    db.execute("UPDATE traces SET vec_summary=? WHERE rowid=?", (blob, rowid))
db.commit()
```

### 🔴 坑 4：Gateway 重启后旧会话不切换 provider

**现象：** 重启 gateway 后，当前微信会话的 `memory_search` 仍返回空

**原因：** gateway 重启后，**已有的微信会话延续旧的 provider 实例**（Hindsight 或空 apiKey 的旧 bridge）。只有新会话才会用新 bridge。

**修复：** 重启 gateway 后，**必须发新消息开启新会话上下文**，旧会话才能用上新的 MemOS provider。

### 🟡 坑 5：多个 bridge 进程

**现象：** `ps aux | grep bridge` 发现有 3-4 个 bridge 进程

**原因：** gateway 每次创建新 provider 实例都可能 spawn 一个新 bridge 进程

**影响：** 不影响功能，但浪费资源。可定期 `pkill -f bridge.cjs` 清理，重启 gateway 时会自动重建。

### 🟡 坑 6：FTS 中文支持

**现象：** SQLite FTS5 索引搜不到中文内容

**原因：** MemOS 的 FTS 使用默认 tokenizer（基于空格分词），对中文无效

**影响：** 中文内容只能靠向量搜索召回，FTS 无法辅助。向量搜索（bge-m3）对中文支持良好，所以实际影响不大。

---

## 四、验证清单

部署完成后，逐一验证：

- [ ] `pgrep -f bridge.cjs` 有进程在跑
- [ ] `curl http://127.0.0.1:18799/api/status` 返回 `{"status":"ok","llm":"available","embedder":"available"}`
- [ ] 给 Hermes 发消息，检查日志有无 `MemOS: bridge ready`
- [ ] `memory_search(query="测试")` 返回非空结果
- [ ] 会话开头出现 `<memory-context>` 自动注入区

---

## 五、Wiki 数据迁移

将 `~/llm-wiki/` 的 wiki 内容导入 MemOS：

```python
#!/usr/bin/env python3
"""将 llm-wiki 内容导入 MemOS 作为 world model traces"""
import os, json, requests, sqlite3, struct
from pathlib import Path

WIKI_PATH = Path.home() / "llm-wiki"
DB_PATH = Path.home() / ".hermes/memos-plugin/data/memos.db"
API_KEY = "你的OpenRouter密钥"
API_BASE = "https://openrouter.ai/api/v1"

# 1. 收集 wiki 文件
traces = []
for f in sorted(WIKI_PATH.glob("*.md")):
    text = f.read_text(encoding="utf-8")
    title = f.stem
    traces.append({
        "id": f"tr_wiki_{hash(title) & 0xFFFFFFFF:08x}",
        "agent": "hermes",
        "userId": "wiki",
        "userText": f"[Wiki] {title}",
        "assistantText": text[:8000],  # 截断过长内容
        "summary": f"Wiki page: {title}",
        "tags": ["wiki"],
        "ts": int(os.path.getmtime(f) * 1000),
    })

# 2. 通过 HTTP API importBundle
resp = requests.post("http://127.0.0.1:18799/api/v1/importBundle", json={
    "agent": "hermes",
    "traces": traces,
})

# 3. 补生成 embedding（importBundle 不会自动做）
db = sqlite3.connect(str(DB_PATH))
rows = db.execute("SELECT rowid, summary FROM traces WHERE vec_summary IS NULL").fetchall()

for rowid, text in rows:
    r = requests.post(f"{API_BASE}/embeddings",
        headers={"Authorization": f"Bearer {API_KEY}"},
        json={"model": "baai/bge-m3", "input": text})
    vec = r.json()["data"][0]["embedding"]
    blob = struct.pack(f"{len(vec)}f", *vec)
    db.execute("UPDATE traces SET vec_summary=? WHERE rowid=?", (blob, rowid))
db.commit()
print(f"导入 {len(traces)} 条 wiki，生成 {len(rows)} 条 embedding")
```

---

## 六、Hindsight vs MemOS 对比

| 特性 | Hindsight | MemOS |
|------|-----------|-------|
| 搜索方式 | 纯向量（pgvector） | 向量 cosine + FTS + 多 tier 融合 |
| 存储后端 | PostgreSQL | SQLite（零依赖） |
| 记忆层级 | 单层 | 3 层（Policy/Trace/WorldModel） |
| 自适应检索 | 无 | Tier 融合 + 重要性评分 |
| 中文支持 | 依赖 embedding 模型 | 向量搜索支持，FTS 中文弱 |
| 部署复杂度 | 需 PostgreSQL + daemon | SQLite + Node bridge，更轻 |
| 压缩时记忆保留 | 无 | `on_pre_compress` 提取快照 |
| 子 agent 记忆 | 无 | `on_delegation` 记录子 agent 结果 |
| 维护状态 | 官方内置 | 第三方插件，需手动维护 |

---

## 七、日常维护

### 查看数据库状态
```bash
sqlite3 ~/.hermes/memos-plugin/data/memos.db \
  "SELECT COUNT(*) FROM traces; SELECT COUNT(*) FROM traces WHERE vec_summary IS NOT NULL;"
```

### 查看桥进程
```bash
pgrep -af bridge.cjs
```

### 查看桥日志
```bash
journalctl --user -u hermes-gateway -n 50 | grep -i memos
```

### 清理多余桥进程
```bash
pkill -f bridge.cjs
systemctl --user restart hermes-gateway
```

---

## 八、与 Hindsight 共存注意事项

- Hindsight 和 MemOS 可以同时安装，通过 `config.yaml` 的 `memory.provider` 切换
- 切换后需要**重启 gateway** 才生效
- 旧会话可能需要**新消息**才能触发新 provider 的初始化
- Hindsight 的历史数据在 `~/.hindsight/` 下，不会自动迁移到 MemOS
- 如需回退 Hindsight：改 `memory.provider: hindsight` + 重启 gateway + 启动 hindsight-daemon
