# EXPAND_CAPABILITIES — 能力扩展

> 来自 plan-tree 的完整子树，由 idle loop 维护

## LV.2 — DISTILL_PATTERNS 🔁
> 从会话中提炼可复用模式 → 保存为 skill
> [last: 2026-04-27 13:49 | 🔁]
- LV.3 扫描近期 session 提取重复模式 [last: 2026-04-27 11:21 | ✅] 扫描7个近期会话(06:29→07:08): 5个cron idle loop, 0个user会话; 无新可结晶模式(19:58→03:23): 6个已知模式全部已在autonomous-drive anti-patterns中覆盖(idle-log恢复/patch修复/cron SSH/MC心跳/execute_code crontab等)
- LV.3 创建/更新 skill [last: 2026-04-26 06:32 | ✅] 无新skill创建需求; 现有autonomous-drive skill anti-patterns覆盖充分

## LV.2 — PATCH_SKILLS 🔁
> 修补使用中发现问题的 skill
> [last: 2026-04-27 13:49 | 🔁]
- LV.3 检查 skill 使用日志/报错 [last: 2026-04-26 06:46 | ✅]
- LV.3 修补 skill 缺陷 [last: 2026-04-27 13:49 | ✅] (powerpoint+youtube-content version field added; api_helpers.py created for autonomous-drive broken ref)

## LV.2 — OPTIMIZE_WORKFLOWS 🔁
> 优化高频工作流
> [last: 2026-04-27 11:21]
- LV.3 识别高频操作 [last: 2026-04-26 08:01 | ✅] 分析idle-log执行频率: ENSURE_CONTINUATION(10x) >> EXPAND_CAPABILITIES(4x) > EXPAND_WORLD_MODEL(3x); OPTIMIZE_WORKFLOWS首次执行 [last: 2026-04-25 18:53 | ✅]
- LV.3 自动化/简化工序 [last: 2026-04-26 08:01 | ✅] 提取Promotion+Platform Lessons 95行到references/promotion-and-platform.md; SKILL.md 858→771行(-10%)
