# GBrain 移植计划（修订版）

> 2026-04-23 修订 | 基于上下文衰减与分层记忆架构的重新评估
> 原方案：MCP Sidecar 14-22h | 修订后：增强 Hindsight 单系统 18-26h

## 决策变更

原方案采用双系统（Hindsight + GBrain MCP Sidecar），经评估改为**单系统增强 Hindsight**。

**原因**：
1. 双系统 = 双故障点 + 数据一致性风险 + 额外运维
2. GBrain 80% 功能面向人际知识管理，机器人场景不需要
3. 我们真正缺的 3 样东西（持久化队列、混合搜索、覆盖更新）都能在 Hindsight 内实现
4. 单系统可靠性 > 耦合系统，物理世界不允许额外故障模式

## 从 GBrain 借鉴的设计洞察（不移植代码）

| GBrain 设计 | 我们的需求 | 实现方式 |
|---|---|---|
| Minions 持久化队列 | L2 任务记忆 | Python pgqueuer 或 SQLite 队列 |
| Compiled Truth + Timeline | L3 空间记忆 | Hindsight retain 加 action='replace' + TTL |
| Skillify 10 项检查 | skill 质量保证 | 独立 Python 检查脚本 |
| 混合搜索 (向量+关键词) | 多维检索 | Hindsight 加 FTS5 + RRF 融合 |
| Self-Wiring Graph | ❌ 人际关系图 | 导航拓扑图另做 |

## 增强计划

### Phase 1: Hindsight 加覆盖更新能力（8-12h）
- retain 新增 action='replace'/'update'
- 语义：该 slug 的当前状态是 X（覆盖），不是记录一条关于 X 的新知识（追加）
- 保留原追加模式作为 Timeline（审计/回溯用）
- 加 TTL：spatial 层 5 分钟过期，task 层任务完成即删，skill 层永不过期

### Phase 2: Hindsight 加关键词搜索（6-8h）
- SQLite FTS5 做 tsvector 等价
- 向量 + 关键词 RRF 融合排序
- recall 加权重：semantic 0.3 / temporal 0.3 / spatial 0.2 / task 0.2

### Phase 3: 独立持久化 Job Queue（4-6h）
- SQLite 本地持久化（机器狗端，离线可用）
- Postgres 云端聚合（多机协调）
- 任务 = 结构化数据，不依赖 Agent 上下文
- 失败恢复 = 读 DB 重放未完成任务

## 核心设计原则

参见 [[上下文衰减与分层记忆架构]]
