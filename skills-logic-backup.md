# 仙秦帝国 · Skills & 插件逻辑备份

> 最后更新: 2026-04-24 23:30
> 目的: 记录所有 skill/job/插件的核心逻辑，代码可能丢失但逻辑永存

---

## 1. autonomous-drive Skill (核心调度)

### 设计原则
- 谁在忙谁持有锁，用户永远优先
- 非活跃 root 折叠到 wiki
- 3步硬约束：idle-log → plan-tree时间戳 → pending-tasks.md

### 忙锁机制
- 锁文件: `~/.hermes/agent-busy.lock` (内容: `timestamp:reason`)
- 管理脚本: `~/.hermes/scripts/lock-manager.sh`
- 锁持有者: `conversation` / `idle-loop`
- TTL: 10分钟自动过期
- check返回值陷阱: 检查输出文本(0=锁存在,1=无锁),不是exit_code

### 分级执行
- 锁存在 → 只扫描写 pending-tasks.md
- 锁不存在 → 完整idle loop(3分支)

### Plan-Tree瘦身
- 活跃root展开到LV.3
- 非活跃root折叠为一行 + `→ wiki:plan-ROOT-NAME`
- wiki页面: `~/llm-wiki/plan-ROOT-NAME.md`

### 反模式(血泪教训)
- ❌ write_file()配read_file()缓存消息会覆盖文件
- ❌ re.sub跨行匹配plan-tree静默失败
- ❌ str.replace()无上下文替换会误伤其他条目
- ✅ 用terminal("python3 /tmp/xxx.py")做文件更新
- ✅ 每个替换包含条目标题做上下文

---

## 2. single-task-loop Skill (逻辑变革)

### 核心思想
- 一个会话只做一件事
- 做完即写wiki → 汇报 → 等1分钟 → 开始新任务
- plan-tree驱动，不靠prompt
- 中断可恢复（plan-tree记录状态）

### 与现有逻辑对比
| 维度 | 现有 | 设想 |
|------|------|------|
| 会话粒度 | N件事 | 1件事 |
| 进度持久化 | 结束才写 | 每步写 |
| 中断恢复 | 丢进度 | plan-tree继续 |
| 任务驱动 | prompt | plan-tree循环 |

---

## 3. agent-orchestration Skill (协调者)

### 角色分工
- 协调者(相邦): 战略调度，不下场执行
- 执行者(始皇/骠骑/丞相): 各自执行，汇报结果

### A2A通信
- 协议: Hermes API (/v1/chat/completions)
- 认证: API_SERVER_KEY (每个agent独立)
- 格式: OpenAI兼容

### 心跳机制(设计中)
- 各agent定期上报状态
- 协调者维护任务森林
- 森林节点: [执行者] [开始时间] [预期结束] [实际结束]

---

## 4. executor-template Skill (执行者模板)

### 核心约束
- approvals.mode: none
- 执行前确认非致命指令
- venv隔离保护系统Python
- GitHub访问: 代理7897或镜像站

---

## 5. MemOS Plugin 逻辑

### 安装
- 克隆: git clone https://github.com/MemTensor/MemOS.git ~/projects/MemOS
- 构建: cd ~/projects/MemOS/apps/memos-local-plugin && npm install && npm run build
- Bridge: dist/bridge.cjs (MCP stdio模式)

### Hermes集成
- config.yaml: `memory.provider: memtensor`
- daemon_manager.py: `_bridge_script()` 指向 bridge.cjs 路径
- 路径硬编码问题: 需修改为每台机器的实际路径

### MCP配置
```yaml
mcp_servers:
  memos:
    command: node
    args: ["~/projects/MemOS/apps/memos-local-plugin/dist/bridge.cjs"]
    env:
      MEMOS_API_KEY: "xxx"
```

---

## 6. Cron Jobs

### idle-loop (每30分钟)
- Job ID: 4fa1b5490d8c
- Prompt: "Load skill 'autonomous-drive' and run idle loop."
- 轻量设计: 锁存在只扫描，不存在才执行

### lock-refresh (每5分钟)
- 自动续期 busy lock

---

## 7. 仙秦帝国组织架构

| 称号 | 机器 | IP | 角色 |
|------|------|-----|------|
| 相邦 | 云服务器 | 100.80.136.1 | 协调者 |
| 始皇帝 | qin-server | 100.64.63.98 | 全栈工程师 |
| 骠骑将军 | .26 | 100.67.214.106 | GPU骑兵 |
| 丞相 | WSL | 100.76.65.47 | 制度建筑师 |

用户: 秦剑（秦王剑），始皇帝本尊，祖龙飞升，帝位空悬
