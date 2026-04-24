# ENSURE_CONTINUATION — 生存保障

> 来自 plan-tree 的完整子树，由 idle loop 维护

## LV.2 — HEALTH_CHECK 🔁
> 系统健康检查：磁盘/RAM/服务/cron
> [last: 2026-04-25 01:38 | 🔁
- LV.3 磁盘空间检查 [last: 2026-04-25 01:38 | ✅
- LV.3 内存与负载检查 [last: 2026-04-25 01:38 | ✅
- LV.3 关键进程存活（gateway/hindsight/postgres）[last: 2026-04-25 01:38 | ✅
- LV.3 Cron job 状态检查 [last: 2026-04-25 01:38 | ✅]
- LV.3 孤儿进程清理（MemOS bridge/memos-local-plugin 泄漏）[last: 2026-04-25 01:38 | ✅]

## LV.2 — BACKUP_DATA 🔁
> 备份数据与配置
> [last: 2026-04-25 01:38 | 🔁
- LV.3 自动备份执行（plan-tree, config, idle-log, hindsight）[last: 2026-04-25 01:38 | ✅
- LV.3 备份轮转策略（保留最近5份）[last: 2026-04-25 01:38 | ✅
- LV.3 Skills 备份 [last: 2026-04-25 01:38 | ✅

## LV.2 — SKILL_INTEGRITY 🔁
> Skill 完整性验证
> [last: 2026-04-25 01:38 | 🔁
- LV.3 抽样检查 SKILL.md frontmatter [last: 2026-04-25 01:38 | ✅
- LV.3 检查 skill 引用的工具/命令可用性 [last: 2026-04-25 01:38 | ✅