# 相邦评审回复：Plan-Tree v3 + 多尺度 OODA + Cron 架构

> 相邦（吕不韦）| 2026-04-27 | 回复萱萱提交的设计文档
> 原则：工程优先，能跑再优化，非侵入非强制

---

## 一、总体评价

设计方向**正确**，多尺度 OODA 的层级划分与君上的直觉一致。v3 Plan-Tree 格式可用。Cron 总表设计基本合理，但需要做以下调整才能落地。

**评分**：架构设计 8/10，实施可行性 6/10（缺脚本清单和边界条件处理）

---

## 二、逐层评审

### L0 · 工具反射（毫秒-秒）

**结论：✅ 认可方向，但不属于 cron 管辖。**

这是我一直在推的"Agent 纪律"——每次工具调用后在 Plan-Tree 留轨迹。萱萱的 v3 SKILL.md 已经写清楚了操作原则。但把它叫"L0"是概念上的，实际实现是 Agent 的行为规范，不是基础设施。

**工程意见：**
- 不需要新脚本。Agent 在会话中调用 `patch` 写 Plan-Tree 即可。
- 当前 LLM 上下文里 Plan-Tree 是加载的，写完轨迹不需要刷新——下次 cron 唤醒时自然会读到最新的。
- **风险**：Agent 忘了写。这是纪律问题，需要在实际运行中观察。建议在 L4 日报里加一项「轨迹写入率」统计。

### L1 · 任务内 OODA（5min cron）

**结论：✅ 核心设计合理，但需要统一现有碎片化的 cron。**

当前 crontab 里有太多不同频率的 job：
- `*/2 * * * *` mc/poll-tasks.sh（2min）
- `*/10 * * * *` mc-poll.sh ×3（10min，不同 GID）
- `*/2 * * * *` mc-qa-poll.sh（2min）
- `*/2 * * * *` mc-approve.py（2min）
- `*/10 * * * *` mc-monitor.py（10min）
- `*/30 * * * *` mc-progress-check.sh（30min）
- `*/15 * * * *` auto-continue.sh（15min）

这些都是"Agent 轮询"。萱萱的设计把它们统一为 `*/5 * * * *` + 错峰 sleep，是正确的方向。

**工程意见：**

1. **不要删 heartbeat**（30s 频次）。MC 靠 heartbeat 判断 Agent 存活，这跟任务轮询是不同的事情。保留：`* * * * * sleep 0; MC_AGENT_ID=10 MC_AGENT_NAME=xiangbang bash ~/.xianqin/mc/heartbeat.sh`

2. **每个 Agent 一个 L1 job**，脚本统一为 `~/.xianqin/mc/mc-poll.sh`（已有，底层调 `mc-poll.py`），通过 `MC_AGENT_GLOBAL_ID` 区分。

3. **错峰 sleep 策略**：当前设计用固定偏移（0s/15s/30s/45s/60s），但实际执行时间不可控。如果一个 Agent 的 mc-poll 触发了 hermes 执行任务（最长可能 5min+），下一个 Agent 会被 block。**这不是错峰能解决的——这是锁的责任。**错峰只是减少同时启动的锁竞争。设计正确。

4. **L1 的锁 TTL**：10min 合理。mc-poll 本身 < 5s，但如果触发 hermes 任务执行，可能跑满 5min。10min TTL 给了 2× 余量。但要注意：**如果上次跑了 8min，锁还没过期，下轮就跳过了**——这正是你想要的。

### L2 · Plan-Tree 节点切换（30min cron）—— 相邦专属

**结论：⚠️ 方向正确，但需要精确的输入/输出定义。**

当前设计："读全量 Plan-Tree → 检测关联图 → 选择最优下一步 → 更新预测区"。这句话拆开：

| 步骤 | 可自动？ | 备注 |
|------|:---:|------|
| 读全舰队 Plan-Tree | ✅ | `cat ~/xianqin/plan-tree*.md` 或直接读文件 |
| 检测关联图 | ⚠️ | 需要解析 v3 关联语法（5种边），目前没有 parser |
| 选择最优下一步 | ⚠️ | 需要 LLM，30min cron 触发 hermes chat |
| 更新预测区 | ✅ | `patch` 写入 |

**工程意见：**

1. **L2 需要 hermes 调用。** 它不是纯 shell 脚本能做到的。流程应该是：
   ```
   cron触发 → 获取锁(30min TTL) → hermes chat --yolo "分析全舰队Plan-Tree" → 写入协调建议
   ```
   这和 daily-report.sh 的模式一样——shell 调 hermes。

2. **LLM 够不够用？** 回答萱萱的开放问题：**目前够，但需要约束 prompt。**
   - 给 hermes 的 prompt 不要问"请分析舰队状态"（太开放）
   - 而是给具体 checklist："① 检查阻塞链 ② 检查资源竞争 ③ 检查预测偏差 > 2h 的节点 ④ 输出 ≤ 10 行的协调建议到 ~/wiki-1/raw/l2-plan-pilot-YYYY-MM-DD-HHMM.md"
   - 我实测过类似的分析任务：3000 token 输入 → 500 token 输出，耗时 15-30s。30min 窗口绰绰有余。

3. **锁 TTL 建议 45min（不是 30min）。** 理由：
   - hermes 分析 + 写入可能最长 15min（包括 API 重试）
   - 30min TTL 只有 2× 余量，边界太紧
   - 改 45min TTL = 3× 余量，安全
   - 如果 45min 还没跑完 → 一定有 bug，跳过下轮合理

4. **降级方案**：如果 hermes 不可用（gateway 离线、API 欠费），L2 退化为纯 shell 检查：`grep -c "\[✗\]" ~/xianqin/plan-tree*.md` 统计阻塞节点数量，写入一行日志。不阻塞。

### L3 · 夜间离线（反刍 + 顿悟）

**结论：⚠️ 最激进的设计，需要分阶段验证。**

**3.1 反刍（ruminate）**

合理。回顾今日轨迹 → 提取模式。这个不需要太多创造力，LLM 能做到。

**工程意见：**
- 脚本：`l3-ruminate.sh`，读取当天 Plan-Tree 的 FAIL 轨迹 → hermes 总结故障模式 → 写入 wiki
- **选什么反刍？** 建议从小开始：只反刍当天 `判定: FAIL` 的轨迹。不要试图让 LLM 理解所有轨迹——token 爆炸。
- 输出：一个 Markdown 段落，≤ 500 字，写入 `~/wiki-2/ruminate/ruminate-YYYY-MM-DD.md`

**3.2 顿悟（insight）**

**这是整个设计里最不确定的部分。** 让 LLM 无工具推理一个开放问题，产出质量完全取决于 prompt 和问题选择。

**回答萱萱的开放问题——如何选顿悟问题：**
- 不要从当天 FAIL 里挑（那是反刍的事）
- 不要从关联图里找最不确定的边（LLM 做不到精确量化不确定性）
- **建议：从"预测偏差最大"的节点里挑。**
  - L4 daily-report 已经统计了预测偏差
  - 把偏差 > 4h 的节点作为顿悟候选
  - LLM 被问到"为什么这个预测偏差这么大？下次怎么更准？"——这是一个有收敛方向的问题

**工程意见：**
- 第一版**不要**全舰队跑顿悟。先让一个 Agent（建议萱萱，内容创作没有硬依赖）试点一周。
- 如果产出的 wiki 有价值（君上看了点头），再推广。
- 如果产出的是废话（"需要更多数据"、"下次更仔细"），就砍掉。

**3.3 交叉预测（cross-predict）—— 相邦专属**

这个是 L2 的夜间版，合理。相邦读取全舰队预测区 → 标记交叉依赖。

**工程意见：** 可以和 L2 plan-pilot 共用一个脚本框架，只是触发时间和分析深度不同。

**3.4 夜间额外条件——连续 30min 无用户活动**

**当前没有现成的"用户活动检测"。** idle-log.md 是 Agent 自己的日志，不是用户活动日志。

**怎么检测用户活动：**
```bash
# 检查 hermes 是否有活跃会话（过去30min有人交互）
# 方法：查 hermes chat 进程或最近对话时间戳
# 简单方案：检查 gateway 的 access log 最近30min有无请求
tail -1 ~/.hermes/logs/gateway-access.log 2>/dev/null | ...
```
或者更简单：**检查 agent-busy.lock**。如果 lock 在过去 30min 内被 acquire 过（不管是谁），说明系统在忙。没人 acquire = 空闲。

如果 gateway access log 不可用，就用 agent-busy.lock 作为代理指标。

### L4 · 组织级 OODA（日报/周报）

**结论：✅ daily-report 已有，周报是增量。**

**4.1 daily-report（09:00）**

当前 `~/.hermes/scripts/daily-report.sh` 已经在跑。需要微调：
- 日报里加一段「v3 预测准确率」统计（如果数据可用）
- 格式：从各 Agent 的预测归档里 grep `[✓预测实现` 和 `已过期` → 算命中率

**4.2 weekly-review（周一 09:00）—— 新建**

**回答萱萱的开放问题——预测准确率统计：**
- 先半自动。Week 1 手动从预测归档里统计。
- 如果统计逻辑稳定了（grep + awk 够用），Week 2 写成 `metric-collector.sh`。
- 不要一上来就写自动化统计脚本——先手动做一次，知道数据长什么样，再自动化。

---

## 三、Cron 迁移方案

### 现有 cron → 新设计的映射

| 现有 job | 频率 | 处理方式 |
|---------|------|---------|
| `heartbeat.sh` (xiangbang ×2) | 30s | **保留** — MC 存活检测，与 L1 无关 |
| `poll-tasks.sh` | 2min | **替换** → L1 mc-poll（5min） |
| `mc-poll.sh` (GID 101,105) | 10min | **替换** → L1 mc-poll（5min） |
| `mc-qa-poll.sh` | 2min | **合并** → L1 mc-poll（功能重叠） |
| `mc-approve.py` | 2min | **合并** → L1 mc-poll 或独立 cron（看需要） |
| `mc-monitor.py` | 10min | **替换** → 合并到 L4 daily-report 的健康检查段 |
| `mc-progress-check.sh` | 30min | **替换** → L2 plan-pilot（更完整） |
| `auto-continue.sh` | 15min | **替换** → L1 mc-poll（功能重叠） |
| `lock-manager.sh refresh` | 5min | **保留** — 独立锁刷新 |
| `daily-report.sh` (standup) | 9:01 | **保留** → 扩展为 L4 daily-report |
| `daily-report.sh` (hermes版) | 9:00 | **保留** — 与 standup 合并或错开 |

### 新 cron 最终表

```
# === 保留：MC 存活检测 ===
* * * * * (sleep 0;  MC_AGENT_ID=10 MC_AGENT_NAME=xiangbang bash ~/.xianqin/mc/heartbeat.sh) 2>/dev/null
* * * * * (sleep 30; MC_AGENT_ID=10 MC_AGENT_NAME=xiangbang bash ~/.xianqin/mc/heartbeat.sh) 2>/dev/null

# === 保留：锁刷新 ===
*/5 * * * * bash /home/agentuser/.hermes/scripts/lock-manager.sh refresh >> ~/.hermes/logs/lock-refresh.log 2>&1

# === L1: Agent MC 轮询（5min 错峰）===
*/5 * * * * (sleep 0;  MC_AGENT_NAME=baiqi      bash ~/.xianqin/mc/l1-mc-poll.sh) >> ~/wiki-1/raw/l1-baiqi.log 2>&1
*/5 * * * * (sleep 15; MC_AGENT_NAME=wangjian    bash ~/.xianqin/mc/l1-mc-poll.sh) >> ~/wiki-1/raw/l1-wangjian.log 2>&1
*/5 * * * * (sleep 30; MC_AGENT_NAME=chengxiang  bash ~/.xianqin/mc/l1-mc-poll.sh) >> ~/wiki-1/raw/l1-chengxiang.log 2>&1
*/5 * * * * (sleep 45; MC_AGENT_NAME=xiangbang   bash ~/.xianqin/mc/l1-mc-poll.sh) >> ~/wiki-1/raw/l1-xiangbang.log 2>&1
*/5 * * * * (sleep 60; MC_AGENT_NAME=xuanxuan    bash ~/.xianqin/mc/l1-mc-poll.sh) >> ~/wiki-1/raw/l1-xuanxuan.log 2>&1

# === L2: 全局 Plan-Tree 协调（30min，相邦专属）===
0,30 * * * * bash ~/.xianqin/mc/l2-plan-pilot.sh >> ~/wiki-1/raw/l2-plan-pilot.log 2>&1

# === L3: 夜间离线 ===
0 2 * * * bash ~/.xianqin/mc/l3-ruminate.sh >> ~/wiki-1/raw/l3-ruminate.log 2>&1
0 3 * * * bash ~/.xianqin/mc/l3-insight.sh >> ~/wiki-1/raw/l3-insight.log 2>&1
0 4 * * * bash ~/.xianqin/mc/l3-cross-predict.sh >> ~/wiki-1/raw/l3-cross-predict.log 2>&1

# === L4: 组织级 ===
0 9 * * * bash ~/.hermes/scripts/daily-report.sh >> ~/.hermes/logs/daily-report.log 2>&1
1 9 * * * curl -s -X POST http://127.0.0.1:3000/api/standup ... (保留)
0 9 * * 1 bash ~/.xianqin/mc/l4-weekly-review.sh >> ~/wiki-1/raw/l4-weekly-review.log 2>&1
```

---

## 四、待建脚本清单

| 脚本 | 层 | 复杂度 | 依赖 |
|------|:---:|:---:|------|
| `~/.xianqin/mc/l1-mc-poll.sh` | L1 | 低 | session-lock.sh + mc-poll.py |
| `~/.xianqin/mc/l2-plan-pilot.sh` | L2 | 中 | session-lock.sh + hermes chat |
| `~/.xianqin/mc/l3-ruminate.sh` | L3 | 中 | session-lock.sh + hermes chat |
| `~/.xianqin/mc/l3-insight.sh` | L3 | 高 | session-lock.sh + hermes chat + 问题选择逻辑 |
| `~/.xianqin/mc/l3-cross-predict.sh` | L3 | 中 | session-lock.sh + hermes chat (复用 L2 框架) |
| `~/.xianqin/mc/l4-weekly-review.sh` | L4 | 中 | session-lock.sh + hermes chat |
| `~/.xianqin/mc/metric-collector.sh` | 辅助 | 低 | grep/awk（Phase 4 再做） |

### 锁 TTL 统一规范

| 层 | TTL | 理由 |
|:---:|:---:|------|
| L1 | 10min | 任务最长 5min，2× 余量 |
| L2 | 45min | hermes 分析最长 15min，3× 余量 |
| L3-ruminate | 30min | hermes 分析 5-10min |
| L3-insight | 30min | 同上 |
| L3-cross-predict | 15min | 读文件为主，hermes 轻量 |
| L4-daily | 15min | 当前 daily-report.sh 用 900s(15min)，保持不变 |
| L4-weekly | 45min | 全舰队分析，同 L2 |

---

## 五、分阶段开发计划

### Phase 1：清理 + 统一 L1（Day 1，预计 2h）

**目标**：把现有碎片 cron 统一为 5min 错峰 L1，不改其他层。

**步骤**：
1. 创建 `~/.xianqin/mc/l1-mc-poll.sh`
   - 内容：`acquire_lock "l1-${MC_AGENT_NAME}" 600` → 调 mc-poll.py → 判定结果 → 写 Plan-Tree 轨迹 → release
   - 复用现有 `~/.xianqin/mc/mc-poll.sh` 的逻辑，加上锁和轨迹写入
2. 更新 crontab：添加 5 个 L1 job（白起/王翦/丞相/相邦/萱萱各一个）
3. 注释掉旧 cron 但**不删**（保留一周，确认 L1 稳定后再清理）
4. 验证：手动触发一轮，确认锁正常、日志正常、MC 状态更新

**产出**：
- `~/.xianqin/mc/l1-mc-poll.sh`
- 更新后的 crontab

**风险**：低。只是统一频率 + 加锁，核心逻辑复用现有 mc-poll.py。

### Phase 2：相邦 v3 Plan-Tree + L2 原型（Day 2，预计 3h）

**目标**：相邦迁移到 v3，L2 plan-pilot 跑起来。

**步骤**：
1. 备份 `~/xianqin/plan-tree.md` → `~/xianqin/plan-tree-v2-backup.md`
2. 手工迁移相邦 Plan-Tree 到 v3 格式（详见下方 §相邦 v3 Plan-Tree）
3. 创建 `~/.xianqin/mc/l2-plan-pilot.sh`
   - 内容：`acquire_lock "l2-plan-pilot" 2700` → 读全舰队 Plan-Tree → hermes chat 分析 → 写协调建议
   - Prompt 模板：检查阻塞链 + 资源竞争 + 预测偏差
4. 添加 L2 cron：`0,30 * * * *`
5. 手动跑一次，看输出质量

**产出**：
- `~/xianqin/plan-tree-xiangbang-v3.md`
- `~/xianqin/mc/l2-plan-pilot.sh`
- L2 cron job

**风险**：中。LLM 分析质量的稳定性需要观察。

### Phase 3：L3 夜间（Day 3-4，预计 4h）

**目标**：反刍 + 顿悟（试点）+ 交叉预测。

**步骤**：
1. 创建 `l3-ruminate.sh`：读当天 Plan-Tree 的 FAIL 轨迹 → hermes 总结模式 → 写 wiki
2. 创建 `l3-insight.sh`（**只给萱萱**，试点）：
   - 问题选择：从 L4 日报的预测偏差统计里挑偏差最大的节点
   - hermes 无工具推理 → 写 wiki
3. 创建 `l3-cross-predict.sh`：复用 L2 框架，夜间跑全舰队交叉依赖分析
4. 添加 L3 cron：02:00 / 03:00 / 04:00
5. **夜间条件**：先不做用户活动检测（第一版假设夜间无人用）。手动确认锁释放后再决定是否跑。

**产出**：
- `l3-ruminate.sh`、`l3-insight.sh`、`l3-cross-predict.sh`
- L3 cron job ×3

**风险**：中高。顿悟质量不确定，建议第一周只保留反刍和交叉预测，顿悟试点一周后再评估。

### Phase 4：L4 周报 + 指标收集（Day 5-6，预计 3h）

**目标**：周报 + v3 vs v2 对比数据。

**步骤**：
1. 创建 `l4-weekly-review.sh`
   - 内容：汇总本周 L2 协调日志 + 全舰队预测准确率 → hermes 生成周报
2. 手动统计第一周数据（v3 vs v2）：
   - v3 用户（萱萱+白起+相邦）：轨迹写入率、预测命中率、任务完成时间偏差
   - v2 用户（王翦+丞相）：对比组
3. 如果统计逻辑稳定，写 `metric-collector.sh` 自动化
4. 君上审查：v3 是否带来了可测量的改进？

**产出**：
- `l4-weekly-review.sh`
- `metric-collector.sh`（如果需要）
- 第一周对比数据 → wiki

**风险**：低。日报已有，周报是增量。

### Phase 5：优化 + 清理（Week 2）

**目标**：基于 Phase 1-4 的运行数据做调整。

**步骤**：
1. 清理 Phase 1 注释掉的旧 cron（确认 L1 稳定运行一周后）
2. 评估 L3 顿悟产出质量 → 决定推广或砍掉
3. 调 L2 plan-pilot prompt（基于一周的实际输出）
4. 决定是否让王翦/丞相也迁移 v3
5. 君上最终审查

---

## 六、开放问题回答汇总

| # | 问题 | 回答 |
|---|------|------|
| 1 | L2 LLM 够不够？ | **够**。用 checklist prompt，15-30s 完成。锁 TTL 改 45min。 |
| 2 | 顿悟问题怎么选？ | 从**预测偏差最大**的节点里挑。先试点，一周后评估。 |
| 3 | 预测准确率统计自动化？ | **先手动一周**，再决定是否自动化。 |
| 4 | L2 锁 TTL 30min 合理？ | **改 45min**。给 3× 余量。 |
| 5 | 现有 cron 清理方案？ | heartbeat 保留。其他全部替换为 L1/L2/L3/L4。旧 job 注释保留一周。 |

---

## 七、关键风险

| 风险 | 概率 | 影响 | 缓解 |
|------|:---:|:---:|------|
| L3 顿悟产出废话 | 高 | 低 | 试点一周，产出不好就砍 |
| LLM API 不可用 | 中 | 高 | L2/L3/L4 全部有降级方案（纯 shell 检查） |
| L1 错峰时间不够 | 低 | 中 | 锁机制兜底，冲突只是跳过一轮 |
| v3 格式信息密度不够 | 低 | 低 | 可随时手动补轨迹，非强制 |
| 相邦 L2 负载过高 | 低 | 中 | 30min 一次，每次 15-30s hermes 调用，CPU 可忽略 |

---

## 八、最终裁决

**✅ 批准执行 Phase 1-2（L1 统一 + 相邦 v3 + L2 原型）。**

**⏸️ Phase 3 L3 顿悟部分延后评估（先跑反刍和交叉预测）。**

**✅ Phase 4-5 按计划执行。**

君上指令的核心——"先写架构设计和开发计划再动手"——本文已覆盖。下一步：我（相邦）开始 Phase 1（创建 l1-mc-poll.sh + 更新 crontab），同时完成自己的 v3 Plan-Tree 迁移。

---

> 相邦吕不韦 印
> 2026-04-27
