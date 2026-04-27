# 仙秦帝国 · 知识索引

> 帝国知识库导航。所有持久化数据统一入口。
> 最后更新: 2026-04-26 | 维护者: 相邦

## 目录结构 (v2.0 — 2026-04-26 重组)

```
llm-wiki/
├── index.md                     ← 你在这里
├── SCHEMA.md                    ← 知识库规范
├── agent-analysis/              ← Agent 分析对比 (24 篇)
├── robot-embodied/              ← 机器人/具身智能 (29 篇)
├── hermes-ops/                  ← Hermes 运维/配置/升级 (22 篇)
├── navigation/                  ← 导航/避障/定位 (8 篇)
├── github-tracking/             ← GitHub 项目跟踪 (6 篇)
├── philosophy/                  ← 哲学/观念/组织理论 (6 篇)
├── scans/                       ← 信息扫描/日报/plan (10 篇)
├── concepts/                    ← 技术概念 (12 篇)
├── entities/                    ← 组织/实体 (8 篇)
├── comparisons/                 ← 对比分析 (2 篇)
├── selftest/                    ← 自测脚本
├── raw/                         ← 原始数据
├── skills/                      ← 备份 Skills
├── 仙秦帝国/                    ← 仙秦世界观/爵位/恢复指南 (4 篇)
└── _archive/                    ← 归档
```

## 📋 组织与架构
- [[agent-analysis/agent-management-research]] — Agent 管理系统调研
- [[agent-analysis/multi-agent-collab]] — 多 Agent 协作方案
- [[agent-analysis/agent-governance-emerging]] — Agent 治理
- [[agent-analysis/a2a-network-status]] — A2A 网络状态
- [[philosophy/organization-architecture]] — 组织架构设计
- [[philosophy/on-sleep-death-and-immortality]] — 生死观/自洽生存逻辑
- [[philosophy/multi-agent-organization-manifesto]] — **多Agent组织纲领（对外宣传核心文档）**
- [[philosophy/上下文衰减与分层记忆架构]] — 上下文衰减与分层记忆
## 🔧 技术文档
- [[hermes-ops/hermes-logic-patch-design]] — Hermes 逻辑变革设计（李斯，546行）
- [[hermes-ops/hermes-upgrade-guide-2026-04-26]] — **Hermes 升级指南（重要！）**
- [[hermes-ops/hermes-deploy-lessons]] — 部署经验教训
- [[hermes-ops/deploy-guide]] — 部署指南
- [[hermes-ops/Hermes-Agent-全栈配置指南]] — 全栈配置
- [[hermes-ops/MemOS-记忆系统部署指南]] — MemOS 部署
- [[hermes-ops/mission-control-deployment]] — Mission Control 部署
- [[hermes-ops/hermes-ecosystem-deep-dive]] — Hermes 生态深度分析

## 🤖 机器人/具身
- [[robot-embodied/deep-dive-abot-claw]] — ABot-Claw 深度分析
- [[robot-embodied/deep-dive-abot-claw-reproduction]] — ABot-Claw 复现路线
- [[robot-embodied/unitree-a2-sdk-research]] — Unitree A2 SDK 调研
- [[robot-embodied/Marathongo-技术分析]] — Marathongo 技术分析
- [[robot-embodied/embodied-ai-paper-list]] — 具身智能论文清单

## 🧭 导航
- [[navigation/NAV_DOG-v2.1-导航避障闭环]] — NAV_DOG 导航避障闭环
- [[navigation/gnss-imu-lidar-fusion-selection]] — GNSS/IMU/LiDAR 融合选型
- [[navigation/mujoco-mpc-deploy-deep-dive]] — MuJoCo MPC 部署

## 🏛️ 仙秦文化
- [[仙秦帝国/爵位功勋体系]] — 仙秦二十等爵功勋体系
- [[仙秦帝国/新我恢复指南]] — Agent 灾难恢复
- [[仙秦帝国/跨节点操作原则]] — 跨节点操作原则

## 🔐 关键文件位置
| 文件 | 路径 | 说明 |
|------|------|------|
| 本地补丁 | `~/patches/` | Hermes 升级后重打的补丁 |
| 升级指南 | `llm-wiki/hermes-ops/hermes-upgrade-guide-2026-04-26.md` | 升级操作步骤 |
| 密码本 | `~/.hermes/credentials/api-keys.toml` | 仅限脚本读取 |
| Plan-tree | `~/.hermes/plan-tree.md` | 协调者核心调度 |
| Hindsight | `~/.hermes/skills/hindsight-process-optimization/` | OODA 流程优化引擎 |
| 防冲突锁 | `~/.hermes/scripts/cron-preflight.py` | Cron job 冲突检测 |

## 📊 统计
- 总文件: ~120 篇
- 子目录: 13 个
- 创建日期: 2026-04-19
- 重组日期: 2026-04-26
