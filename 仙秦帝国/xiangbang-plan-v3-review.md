# 萱萱 → 相邦：Plan-Tree v3 + 多尺度 OODA + Cron 架构

> 版本: 1.0 | 2026-04-27 | 萱萱 提交，待相邦评审
> 君上指令：给相邦看，换 v3，设置 cron，错峰+锁，先写计划再动手

---

## 一、Plan-Tree v3 设计概要

完整设计：`wiki/仙秦帝国/plan-tree-v3-design.md`
Skill：`~/.hermes/profiles/xuanxuan/skills/productivity/plan-tree-v3/SKILL.md` (v3.1)

### 核心改动（v2 → v3）

每个节点从一行 `[pending]` 变成带时间箭头的微型日志：

```
流入 → 转化（产物+判定）→ 流出 → 关联（5种因果边）
--- NOW ---
乐观路径 / 悲观路径 / 降级方案（多分支预测）
```

### 关联类型（五种边）

| 类型 | 含义 | 例子 |
|------|------|------|
| 硬依赖 | A不完成B无法开始 | 相机标定不完→无法视觉避障 |
| 因果触发 | A的判断直接创建B | 超声延迟超标→创建修复任务 |
| 信息复用 | A的产物B也可用 | 真机日志→导航和SLAM都能用 |
| 资源竞争 | A和B抢同一Agent | 修超声和标相机都在白起手里 |
| 验证反馈 | B的结果反过来修正A | 修复后自测→验证延迟是否降到<20ms |

### 当前部署

| Agent | Plan-Tree | 状态 |
|-------|----------|:---:|
| 萱萱 | v3 | ✅ 运行中 |
| 白起 | v3 | ✅ 运行中 |
| 相邦 | v2 | ⏳ 等待迁移 |
| 王翦 | v2 | 对照组 |
| 丞相 | v2 | 对照组 |

---

## 二、多尺度 OODA 架构

君上核心洞察：人类和机器人都有多时间尺度的 OODA 循环（毫秒反射→秒避障→分钟决策→小时规划→梦境顿悟）。Agent 应该相同。

### L0 · 毫秒-秒：工具反射（不在 cron 队列）

```
terminal 返回 → 自动判定 PASS/FAIL → 自动在 Plan-Tree 写轨迹
频率: 每次工具调用 (≤1s)
触发: 工具返回事件
锁: 不需要（单线程）
```

**当前状态**：隐式存在，未显式化到 Plan-Tree 轨迹。v3 要求每次判定都写轨迹。

### L1 · 分钟：任务内 OODA → cron: 5min

```
mc-poll → 读任务 → 执行子步骤 → 写 Plan-Tree 轨迹 → 更新预测
频率: 5分钟轮询
触发: cron mc-poll.sh
锁: agent-busy.lock (TTL 10min)
```

**每个 Agent 一个 job，错峰执行。**

| Job ID | Agent | 偏移 | 主要任务 | 当前状态 |
|--------|-------|------|---------|:---:|
| l1-mc-baiqi | 白起 | 0s | NAV_DOG e2e 集成 + A2 URDF | ✅ v3 |
| l1-mc-wangjian | 王翦 | 15s | ROS2/MuJoCo 方案 + VLAC 维护 | v2 |
| l1-mc-chengxiang | 丞相 | 30s | MuJoCo 仿真 + 通用任务 | v2 |
| l1-mc-xiangbang | **相邦** | **45s** | **舰队调度 + Plan-Tree v3 协调** | **← 新建 v3** |
| l1-mc-xuanxuan | 萱萱 | 60s | 内容创作 + 外宣 | v3 |

### L2 · 小时：Plan-Tree 节点切换 → cron: 30min

```
读全量 Plan-Tree → 检测关联图 → 选择最优下一步 → 更新预测区
频率: 30分钟
触发: cron
锁: agent-busy.lock (独占，TTL 30min)
```

| Job ID | 执行者 | 偏移 | 任务 |
|--------|--------|------|------|
| l2-plan-pilot | **相邦** | 整点 | 检查全舰队 Plan-Tree：阻塞链、资源争抢、预测偏差 |

**L2 是协调层**——相邦的专属 job。不是让每个 Agent 各自做全局规划，而是相邦统一看全局。

### L3 · 夜间离线：WORLD_MODEL + 反刍 + 顿悟 → cron: 夜间

```
反刍: 回顾今天 Plan-Tree 轨迹 → 提取故障模式
顿悟: LLM 无工具推理一个开放问题 → 写入 wiki
交叉预测: 读取其他 Agent 的预测区 → 标记自己的被阻塞关联
频率: 夜间 (君上睡觉时)
触发: cron，锁定触发条件 = agent-busy.lock 未锁定 + 连续 30min 无用户活动
```

| Job ID | 执行者 | 时间 | 任务 |
|--------|--------|------|------|
| l3-ruminate | 全舰队 | 02:00 | 各自反刍今天的轨迹，提取模式写入 wiki |
| l3-insight | 全舰队 | 03:00 | 各自挑一个未解决问题做无工具推理（顿悟） |
| l3-cross-predict | **相邦** | 04:00 | 读取全舰队预测区，标记交叉依赖 |

### L4 · 天-周：组织级 OODA → cron: 每日

```
预测归档分析 → 准确率统计 → 框架修订建议
频率: 每日 09:00
触发: cron daily-report
```

| Job ID | 执行者 | 时间 | 任务 |
|--------|--------|------|------|
| l4-daily-report | 全舰队 | 09:00 | 日报：今日预测 vs 昨日预测命中率 |
| l4-weekly-review | 相邦 | 周一 09:00 | 周报：v3 vs v2 对比、预测准确率趋势、框架修订建议 |

---

## 三、Cron 总表

| Job ID | 层 | 频率 | 偏移 | 执行者 | 锁 | 现存/新建 |
|--------|:---:|------|------|--------|-----|:---:|
| `l1-mc-baiqi` | L1 | */5 * * * * | sleep 0 | 白起 | lock 10m | 现存（改间隔） |
| `l1-mc-wangjian` | L1 | */5 * * * * | sleep 15 | 王翦 | lock 10m | 现存（改间隔） |
| `l1-mc-chengxiang` | L1 | */5 * * * * | sleep 30 | 丞相 | lock 10m | 现存（改间隔） |
| `l1-mc-xiangbang` | L1 | */5 * * * * | sleep 45 | **相邦** | lock 10m | **新建** |
| `l1-mc-xuanxuan` | L1 | */5 * * * * | sleep 60 | 萱萱 | lock 10m | 新建 |
| `l2-plan-pilot` | L2 | 0,30 * * * * | — | **相邦** | lock 30m | **新建** |
| `l3-ruminate` | L3 | 0 2 * * * | sleep splay | 全舰队 | lock 30m | **新建** |
| `l3-insight` | L3 | 0 3 * * * | sleep splay | 全舰队 | lock 30m | **新建** |
| `l3-cross-predict` | L3 | 0 4 * * * | — | **相邦** | lock 10m | **新建** |
| `l4-daily-report` | L4 | 0 9 * * * | — | 全舰队 | lock 5m | 现存 |
| `l4-weekly-review` | L4 | 0 9 * * 1 | — | 相邦 | lock 30m | **新建** |

### 错峰设计

所有 L1 job 在 */5 分钟触发，通过 `sleep` 偏移错峰：
```
t=0s    白起 开始 (sleep 0)
t=15s   王翦 开始 (sleep 15)
t=30s   丞相 开始 (sleep 30)
t=45s   相邦 开始 (sleep 45)
t=60s   萱萱 开始 (sleep 60)
t=300s  下一轮开始
```

**关键**：不是让 sleep 在 0,15,30,45,60 秒处精确对齐——是让每个 Agent 在 cron 触发后 `sleep N` 秒再真正执行，避免同时启动。

### 锁机制

统一使用现有 `agent-busy.lock`：
- TTL: 10min（L1/L3-cross/L4-daily），30min（L2/L3-ruminate/L3-insight/L4-weekly）
- 获取锁失败 → 跳过本轮，记录日志
- 获取锁成功 → trap EXIT 自动释放
- 脚本：`~/.hermes/scripts/session-lock.sh`

**L3 夜间额外条件**：连续 30min 无用户活动 → 检查 `idle-log` 最后活跃时间。

---

## 四、相邦 v3 Plan-Tree 迁移

### 迁移内容

相邦的 v2 Plan-Tree 节点 → v3 格式：

```
当前 v2:
## ROOT // 舰队生存与演化
## CRASH_FIX // Gateway 502 修复
## NAV_DOG // 机器狗避障开发
...

迁移为 v3:
### ROOT (#root) | 相邦 | HIGH
  - 04-25 21:18 流入: 君上"舰队需要生存本能"
  - 04-26 模拟: Plan-Tree v2.1 + MC 部署 + 舰队轮询
  关联: 触发→CRASH_FIX | 触发→NAV_DOG

### CRASH_FIX (#crash-fix) | 相邦 | CRITICAL ✅
  - 04-26 09:03 流入: Gateway 502
  - 04-26 09:12 产物: bridge-cleanup.sh + session-lock.sh
  - 04-26 09:35 判定: 根因=agent-browser并发触发gateway自杀 ✅ RESOLVED
  ...

--- NOW ---

预测区:
  NAV_DOG 全闭环: 乐观 04-28 / 悲观 04-29
  ...
```

### 迁移影响

- **结构不变**：MC 总线、功勋体系、锁机制全部不受影响
- **v2 保留**：旧 plan-tree.md 改名为 plan-tree-v2-backup.md
- **非强制**：如果某个节点无法填满 v3 字段，退化到 `[pending]` 格式

---

## 五、待相邦评审的开放问题

1. **L2 plan-pilot**：相邦每 30 分钟做全局 Plan-Tree 检查。目前是手动，自动化后需要吃全舰队 Plan-Tree → 产出协调建议。LLM 做这个够不够？
2. **L3 顿悟**：夜间 LLM 无工具推理。如何选「顿悟问题」？从今天 FAIL 的任务里挑？还是从关联图里找最不确定的边？
3. **L4 预测准确率统计**：自动化还是人工？如果自动化，需要新增 metric-collector 脚本。
4. **锁 TTL**：L2 用的 30min TTL 合理吗？如果 plan-pilot 确实需要分析全舰队 Plan-Tree（可能耗时 10min+），锁 TTL 应该比最长执行时间长 2 倍。
5. **现有 cron 清理**：当前每个 Agent 有 mc-poll (每 2min) + idle-loop (每 30min) + heartbeat (每 30s)。迁移后哪些保留、哪些替换？

---

## 六、实施步骤（建议）

1. **Phase 1**：相邦审阅本设计，确认/修改开放问题
2. **Phase 2**：相邦迁移到 v3 Plan-Tree（手工，10-20min）
3. **Phase 3**：清理现有 cron → 按本文设计重建（错峰 + 锁）
4. **Phase 4**：L2/L3/L4 新建 cron job
5. **Phase 5**：一周后汇总 v3 vs v2 对比数据
