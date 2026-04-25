# ENSURE_CONTINUATION — 生存保障

> 来自 plan-tree 的完整子树，由 idle loop 维护

## LV.2 — HEALTH_CHECK 🔁
> 系统健康检查：磁盘/RAM/服务/cron
> [last: 2026-04-25 18:51 | 🔁]
- LV.3 磁盘空间检查 [last: 2026-04-25 18:51 | ✅]
- LV.3 内存与负载检查 [last: 2026-04-25 18:51 | ✅]
- LV.3 关键进程存活（gateway✅ MC⚠️ MemOS⚠️）[last: 2026-04-25 18:51 | ✅]
- LV.3 Cron job 状态检查 [last: 2026-04-25 18:51 | ✅] heartbeat(30s)✅ lock-refresh(5min)✅ idle-loop✅
- LV.3 MemOS 孤儿进程清理 [last: 2026-04-25 18:51 | ✅] 0 orphan

## LV.2 — BACKUP_DATA 🔁
> 备份数据与配置
> [last: 2026-04-25 18:51 | 🔁]
- LV.3 自动备份执行（plan-tree, config, wiki）[last: 2026-04-25 18:51 | ✅] 20260425-1851.tar.gz 7.4KB
- LV.3 备份轮转策略（保留最近5份）[last: 2026-04-25 18:51 | ✅] 5-rotation active

## LV.2 — SKILL_INTEGRITY 🔁
> Skill 完整性验证
> [last: 2026-04-25 18:05 | 🔁]
- LV.3 抽样检查 SKILL.md frontmatter [last: 2026-04-25 18:05 | ✅] → 抽样20个 skill，全部 YAML frontmatter 有效
- LV.3 检查 skill 引用的工具/命令可用性 [last: 2026-04-25 18:05 | ✅] → 20个命令检查：18/20可用，docker 和 imagemagick(convert) 缺失但不影响核心 skill

## LV.2 — CRON_RESTORE 🔁
> 重建丢失的 cron 定时任务
> [last: 2026-04-25 18:51 | 🔁]
- LV.3 轻量心跳 cron (30s, bash-only, curl MC) [last: 2026-04-25 18:51 | ✅] crontab installed, MC not running (skips)
- LV.3 Idle loop cron (30min, LLM驱动) [last: 2026-04-25 18:51 | ✅] active (b291ea56be8f)
- LV.3 锁续期 cron (5min) [last: 2026-04-25 18:51 | ✅] crontab installed