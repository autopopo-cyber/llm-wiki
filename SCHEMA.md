# Wiki Schema

## Domain
具身智能（Embodied Intelligence）—— 主要覆盖机器人与机器狗的软硬件开发，包括：
- 机器人硬件设计（机械结构、传感器、执行器、嵌入式系统）
- 机器狗平台（四足机器人、仿生控制、步态规划）
- 软件栈（ROS/ROS2、运动控制、感知算法、SLAM、规划）
- AI 与学习（强化学习、模仿学习、sim-to-real、端到端控制）
- 供应链与制造（元器件选型、3D打印/CNC、PCB设计、组装工艺）
- 行业动态（公司、产品、开源项目、学术进展）

## Conventions
- File names: lowercase, hyphens, no spaces (e.g., `quadruped-gait-planning.md`)
- Every wiki page starts with YAML frontmatter (see below)
- Use `[[wikilinks]]` to link between pages (minimum 2 outbound links per page)
- When updating a page, always bump the `updated` date
- Every new page must be added to `index.md` under the correct section
- Every action must be appended to `log.md`
- 硬件相关页面标注单位体系（SI 优先），价格标注币种与日期
- 代码片段标注语言与框架版本

## Frontmatter
```yaml
---
title: Page Title
created: YYYY-MM-DD
updated: YYYY-MM-DD
type: entity | concept | comparison | query | summary
tags: [from taxonomy below]
sources: [raw/articles/source-name.md]
---
```

## Tag Taxonomy

### 硬件 Hardware
- `hardware` — 通用硬件
- `actuator` — 执行器（电机、液压、气动）
- `sensor` — 传感器（IMU、力矩、视觉、LiDAR、触觉）
- `embedded` — 嵌入式系统（MCU、SoC、FPGA）
- `pcb` — PCB 设计与制造
- `mechanical` — 机械结构设计
- `manufacturing` — 制造工艺（3D打印、CNC、注塑）

### 机器狗 Quadruped
- `quadruped` — 四足机器人通用
- `gait` — 步态规划与控制
- `sim2real` — 仿真到现实迁移

### 软件栈 Software
- `ros` — ROS/ROS2 框架
- `control` — 运动控制（PID、MPC、WBC）
- `perception` — 感知（视觉、SLAM、深度估计）
- `planning` — 路径规划与导航
- `simulation` — 仿真环境（Isaac Sim、MuJoCo、PyBullet）

### AI 与学习 AI & Learning
- `rl` — 强化学习
- `imitation` — 模仿学习
- `end2end` — 端到端控制
- `foundation-model` — 机器人基础模型

### 行业 Industry
- `company` — 公司/组织
- `product` — 产品/平台
- `open-source` — 开源项目
- `paper` — 学术论文
- `benchmark` — 基准测试/竞赛

### 元信息 Meta
- `comparison` — 对比分析
- `timeline` — 时间线/里程碑
- `controversy` — 争议/未定论
- `tutorial` — 教程/指南
- `supply-chain` — 供应链/采购
- `maintenance` — 运维/排错/已知限制

Rule: every tag on a page must appear in this taxonomy. If a new tag is needed,
add it here first, then use it. This prevents tag sprawl.

## Page Thresholds
- **Create a page** when an entity/concept appears in 2+ sources OR is central to one source
- **Add to existing page** when a source mentions something already covered
- **DON'T create a page** for passing mentions, minor details, or things outside the domain
- **Split a page** when it exceeds ~200 lines — break into sub-topics with cross-links
- **Archive a page** when its content is fully superseded — move to `_archive/`, remove from index

## Entity Pages
One page per notable entity (公司、产品、开源项目、芯片等). Include:
- Overview / what it is
- Key specs and dates (硬件标参数，软件标版本)
- Relationships to other entities ([[wikilinks]])
- Source references

## Concept Pages
One page per concept or topic (算法、架构、方法论). Include:
- Definition / explanation
- Current state of knowledge
- Open questions or debates
- Related concepts ([[wikilinks]])

## Comparison Pages
Side-by-side analyses (电机选型、开发板对比、框架对比). Include:
- What is being compared and why
- Dimensions of comparison (table format preferred)
- Verdict or synthesis
- Sources

## Update Policy
When new information conflicts with existing content:
1. Check the dates — newer sources generally supersede older ones
2. If genuinely contradictory, note both positions with dates and sources
3. Mark the contradiction in frontmatter: `contradictions: [page-name]`
4. Flag for user review in the lint report
