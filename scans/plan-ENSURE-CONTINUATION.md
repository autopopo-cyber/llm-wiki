# ENSURE_CONTINUATION — 生存保障

> 来自 plan-tree 的完整子树，由 idle loop 维护

## LV.2 — HEALTH_CHECK 🔁
> 系统健康检查：磁盘/RAM/服务/cron
> [last: 2026-04-26 16:07 | 🔁]
- LV.3 磁盘空间检查 [last: 2026-04-26 09:09 | ✅]
- LV.3 内存与负载检查 [last: 2026-04-26 09:09 | ✅]
- LV.3 关键进程存活（gateway✅ MC✅ MemOS✅）[last: 2026-04-26 09:09 | ✅]
- LV.3 Cron job 状态检查 [last: 2026-04-26 09:09 | ✅] heartbeat(30s)✅ lock-refresh(5min)✅ idle-loop✅
- LV.3 MemOS 孤儿进程清理 [last: 2026-04-26 09:09 | ✅] 0 orphan

## LV.2 — BACKUP_DATA 🔁
> 备份数据与配置
> [last: 2026-04-26 16:41 | 🔁]
- LV.3 自动备份执行（plan-tree, config, wiki, skills）[last: 2026-04-26 16:41 | ✅] backup_20260426-1641.tar.gz 3.9MB
- LV.3 备份轮转策略（保留最近5份）[last: 2026-04-26 16:41 | ✅] 5/5 in rotation

## LV.2 — SKILL_INTEGRITY 🔁
> Skill 完整性验证
> [last: 2026-04-26 15:34 | 🔁]
- LV.3 抽样检查 SKILL.md frontmatter [last: 2026-04-26 15:34 | ✅] → 89 leaf skills, 8 sampled — 7/8 valid (1 legacy missing version)
- LV.3 检查 skill 引用的工具/命令可用性 [last: 2026-04-26 15:34 | ✅] → 2 broken refs (api_helpers.py, mc-poll.sh), 87 healthy

## LV.2 — CRON_RESTORE 🔁
> 重建丢失的 cron 定时任务
> [last: 2026-04-26 17:18 | 🔁]
- LV.3 轻量心跳 cron (30s, bash-only, curl MC) [last: 2026-04-26 17:18 | ✅] crontab installed, MC not running (skips)
- LV.3 Idle loop cron (30min, LLM驱动) [last: 2026-04-26 17:18 | ✅] active (b291ea56be8f)
- LV.3 锁续期 cron (5min) [last: 2026-04-26 17:18 | ✅] crontab installed
