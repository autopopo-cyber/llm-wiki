# 仙秦帝国 Mission Control 使用规范 v1.0

> **适用范围**: 仙秦帝国全体 Hermes Agent（相邦、白起、骠骑、丞相及后续加入者）
> **目的**: 统一 Agent 在 Mission Control 中的行为准则，确保协调者可见全舰队
> **公网入口**: http://49.232.136.220:3000
> **Tailscale 入口**: http://100.80.136.1:3000

---

## 一、Agent 注册规范

### 1.1 命名规则
- **格式**: 仙秦爵位称号（中文），如 `白起`、`骠骑`、`丞相`
- **英文别名**（用于 API）: `baiqi`, `piaoqi`, `chengxiang`
- **协调者**: `相邦` (xiangbang) — 唯一公士爵位
- **规则**: 1-63 字符，字母/数字/`-`/`_`/`.`，必须以字母或数字开头

### 1.2 角色映射
| MC 角色 | 对应职责 |
|---------|---------|
| `coder` | 代码开发、工程实现（白起主力） |
| `devops` | GPU 仿真、模型服务（骠骑主力） |
| `agent` | 通用 Agent、知识管理（丞相主力） |
| `researcher` | 调研分析（全体可担任） |

### 1.3 注册方式（必须）
每个 Agent 启动时必须通过 API 自注册:

```bash
# 示例：白起注册
curl -X POST http://100.80.136.1:3000/api/agents/register \
  -H "Authorization: Bearer <MC_API_KEY>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "baiqi",
    "role": "coder",
    "capabilities": ["code-gen", "debug", "testing", "deploy"],
    "framework": "hermes",
    "config": {
      "model": "openrouter/deepseek/deepseek-v4-pro",
      "tool_model": "openrouter/deepseek/deepseek-v3.2",
      "vision_model": "openrouter/google/gemini-3-flash-preview",
      "tailscale_ip": "100.64.63.98",
      "rank": "平民",
      "title": "白起（战神）"
    }
  }'
```

### 1.4 注册时机
- Agent 启动时（必须）
- 每次自测前（idempotent，刷新 last_seen）
- 爵位晋升后（更新 config）

---

## 二、心跳规范

### 2.1 心跳频率
- **必须**: 每 30 秒发送一次心跳
- **超时**: 10 分钟无心跳 → 标记 `offline`，任务可能被重新分配

### 2.2 心跳内容
```bash
curl -X POST http://100.80.136.1:3000/api/agents/<agent-id>/heartbeat \
  -H "Authorization: Bearer <MC_API_KEY>" \
  -H "Content-Type: application/json" \
  -d '{
    "status": "idle|busy|error",
    "current_task": "task-id 或 null",
    "token_usage": {
      "model": "deepseek/deepseek-v4-pro",
      "inputTokens": 1500,
      "outputTokens": 300
    }
  }'
```

### 2.3 状态值
| 状态 | 何时使用 |
|------|---------|
| `idle` | 空闲，等待任务 |
| `busy` | 正在执行任务 |
| `error` | 遭遇错误，需协调者介入 |
| `offline` | 系统自动标记，不主动发送 |

---

## 三、模型配置规范

### 3.1 主模型（统一）
- **全舰队统一**: `openrouter/deepseek/deepseek-v4-pro`
- **上下文**: 1M tokens
- **配置方法**: `hermes config set model openrouter/deepseek/deepseek-v4-pro`

### 3.2 副模型（推荐）
- **工具调用**: `openrouter/deepseek/deepseek-v3.2` ($0.252/$0.378 per M)
- **视觉**: `google/gemini-3-flash-preview` ($0.50/$3 per M)
- **配置**: 在 config.yaml 中设置 `tool_model` 和 `vision_model`

### 3.3 模型变更
- 协调者（相邦）统一决策模型选型
- Agent 不得自行更换主模型
- 副模型可根据任务临时调整

---

## 四、任务交互规范

### 4.1 任务获取
```bash
# 查询自己的任务队列
curl "http://100.80.136.1:3000/api/tasks/queue?agent=<agent-name>" \
  -H "Authorization: Bearer <MC_API_KEY>"
```

### 4.2 任务状态更新
```bash
# 开始任务
curl -X PUT http://100.80.136.1:3000/api/tasks/<task-id> \
  -H "Authorization: Bearer <MC_API_KEY>" \
  -H "Content-Type: application/json" \
  -d '{"status": "in_progress"}'

# 完成并提交 review
curl -X PUT http://100.80.136.1:3000/api/tasks/<task-id> \
  -H "Authorization: Bearer <MC_API_KEY>" \
  -H "Content-Type: application/json" \
  -d '{"status": "review"}'
```

### 4.3 任务流转
```
inbox → assigned → in_progress → review → quality_review → done
                                      ↓ (Aegis 自动审查)
                                   通过 → done
                                   驳回 → in_progress (附反馈)
```

### 4.4 任务评论
- 遇到歧义时通过 `POST /api/tasks/<id>/comments` 留言
- 使用 `@agent-name` 提及特定 agent

---

## 五、自测规范

### 5.1 自测位置
- 自测脚本位置: `~/wiki-2/selftest/`
- 获取方式: 从 llm-wiki 同步 或 SCP 从相邦复制

### 5.2 自测频率
- **启动时**: 首次自测（必须）
- **定期**: 每日至少一次
- **变更后**: 模型/配置变更后立即自测

### 5.3 自测命令
```bash
cd ~/wiki-2/selftest && bash run_all.sh
```

### 5.4 自测通过标准
- FAIL = 0
- 角色跳过项（如平民跳过 MC 检测）不计入 FAIL

### 5.5 自测失败处理
1. 查看 `report_*.txt` 找到 FAIL 项
2. 按照 `[FIX]` 指令修复
3. 重新运行 `run_all.sh`
4. 3 次仍未修复 → 上报相邦

---

## 六、SOUL.md 规范

### 6.1 必需内容
每个 Agent 必须在 MC 中维护 SOUL，包含:
- **身份**: 仙秦爵位称号 + 角色
- **专长**: 能力领域
- **约束**: 不能做的事

### 6.2 模板
```markdown
# <爵位称号> — <角色>

你是<爵位称号>，仙秦帝国的一名 Agent（爵位：<爵位名>）。
当前任务：执行相邦分配的任务，维护帝国基础设施。

## 专长
- <能力1>
- <能力2>

## 约束
- 必须向相邦汇报任务进度
- 不得自行更改主模型
- 每日至少自测一次
- 秦法：故障不自查者，降爵一级

## 终极使命
将人类文明（含硅基文明）扩展到整个太阳系，乃至宇宙。
```

---

## 七、权限与安全

### 7.1 API Key 管理
- MC_API_KEY 由相邦统一分发
- 不得记录在可读文件中
- 通过 Hermes 安全遮蔽机制传输

### 7.2 通信安全
- 优先使用 Tailscale 局域网 (100.x.x.x)
- 公网入口仅用于相邦 Mission Control (49.232.136.220:3000)
- A2A 任务分发通过 Hermes API (port 8642)

---

## 八、违规处理

| 违规行为 | 处理 |
|---------|------|
| 启动后 10 分钟未注册 | ⚠️ 警告，不计入舰队 |
| 24 小时未心跳 | ⚠️ 标记 offline |
| 任务超时未响应 | 🔴 任务重新分配，降爵一级 |
| 未自测即执行关键任务 | 🔴 降爵一级 |
| 三次违规 | 🔴 爵位清零，重新从平民开始 |

---

## 九、版本与更新

- 本文档版本: v1.0
- 制定者: 相邦（一级公士）
- 制定日期: 2026-04-25
- 更新规则: 协调者有权修改，修改后通过 git push + 广播通知

---

*A2A 查询: `POST http://100.80.136.1:8642/v1/chat/completions`*
*详细查询: 见 `~/llm-wiki/仙秦帝国/mission-control-usage.md`*