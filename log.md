# Wiki Log

> Chronological record of all wiki actions. Append-only.
> Format: `## [YYYY-MM-DD] action | subject`
> Actions: ingest, update, query, lint, create, archive, delete
> When this file exceeds 500 entries, rotate: rename to log-YYYY.md, start fresh.

## [2026-04-19] create | Wiki initialized
- Domain: 具身智能（机器人与机器狗软硬件开发）
- Path: ~/llm-wiki
- Structure created with SCHEMA.md, index.md, log.md
- Tag taxonomy: hardware, quadruped, software, ai-learning, industry, meta (6 categories, 25+ tags)

## [2026-04-19] ingest | Bootstrap seed content
- Created 7 entity pages: anymal, boston-dynamics, eth-zurich-robotics, google-deepmind, stanford-ai-lab, unitree, unitree-go2
- Created 9 concept pages: domain-randomization, mpc-control, octo, open-x-embodiment, openvla, qdd-actuator, rl-locomotion, rt2-vla, sim2real
- Created 2 comparison pages: quadruped-robots-comparison, vla-models-comparison
- Added 2 raw articles: quadruped-robots-review-2024.md, unitree-go2-review-2024.md
- Added 4 raw papers: learning-to-walk-in-minutes-2023.md, octo-generalist-robot-policy-2024.md, openvla-open-source-vla-2024.md, rt2-vision-language-action-2023.md
- Total wiki pages: 18

## [2026-04-19] update | deploy-guide.md + 新增 hermes-maintenance 页面
- deploy-guide.md 新增坑 7（Unclosed client session）和坑 8（WebUI 审批卡死）
- 创建 concepts/hermes-maintenance.md — Hermes 维护知识独立页面，包含：
  - 架构速查和关键配置文件
  - 常见故障排查（Unclosed session、审批卡死、daemon 退出、gateway 重启困难）
  - 已知限制（API Server 缺失功能、Hindsight patch 依赖、模型兼容性）
  - 日常运维速查命令
- index.md 更新：Total pages 19

## [2026-04-21] create | Hermes-Agent-全栈配置指南
- 新建全栈配置指南，整合 wiki 中所有 Hermes 相关内容
- 章节：架构总览 → Hermes 安装配置 → Hindsight 记忆系统 → Wiki+tree-plan → Systemd → WebUI 占位 → 故障排查
- 来源：deploy-guide.md、hermes-maintenance.md、Hermes-plan-机制调研与OpenClaw对比.md、tree-plan skill、llm-wiki skill
- index.md 更新：Total pages 35，Infrastructure 区新增条目
- tree-plan 更新：Hindsight 修复→已完成，minimax→已取消，新增文档任务→当前正在处理
