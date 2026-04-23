# Wiki Index

> Content catalog. Every wiki page listed under its type with a one-line summary.
> Read this first to find relevant pages for any query.
> Last updated: 2026-04-21 | Total pages: 35

## 📝 深度分析

- [[Claw的启示-从Agent到具身智能的架构统一|Claw 的启示]] — ⭐ VLA 失败→Agent+RL 成功→ABot-Claw 验证→Hermes 映射，架构统一性深度分析（可发表）
- [[具身智能仿真平台调研]] — 12 个机器人/自动驾驶仿真器全面对比 + 四足导航选型建议
- [[室外障碍物检测-视觉替代与兜底方案]] — 视觉替代与兜底检测方案（取代朗毅未开源权重）

## 🎯 核心项目：四足机器狗导航系统

> 基于朗毅 Marathongo 开源项目，开发四足机器狗室内外长距离导航系统

- [[Marathongo-技术分析|Marathongo 技术分析]] — 朗毅开源项目完整技术分析（565行），四足适配评估
- [[Marathongo-深度技术分析|Marathongo 深度技术分析]] — 硬件采购表 + 三大核心问题（去畸变/避障/地图对接）+ 未开源清单
- [[Marathongo-IMU-LiDAR融合去畸变技术报告|IMU-LiDAR 融合去畸变]] — ESEKF 23维误差状态 + 点云反向补偿 + GTSAM 后端优化（最核心）
- [[Marathongo-高德地图导航对接报告|高德地图导航对接]] — API对接 + GCJ-02坐标转换 + 室内外切换方案 + Python参考实现
- [[四足导航开发路线|四足导航开发路线]] — ⭐ 架构决策（vo_navigation + 导航-避障-运控三层解耦）+ 五阶段开发计划 + 关键技术决策记录（含边缘约束测试策略）
- [[人跟随与领航-技术方案]] — 激光+视觉跟随人类，跟随/领航双模式，不依赖网络
- [[多机编队与蜂群协同-技术方案]] — 去中心化编队，UWB精准定位，领航-跟随模式
- [[四足机器人调度系统-架构设计|调度系统架构设计]] — ⭐ 安卓App + 双服务器 + A2 完整系统架构（MQTT/WebSocket/高德SDK/Playbook）
- [[军警级四足机器人三端系统架构设计|军警级三端系统架构]] — ⭐ 军警通信双模式（无线/光纤）+ APP/云端/机器人三端 + 宇树SDK对接 + 七阶段开发路线
- [[Hermes-plan-机制调研与OpenClaw对比|Hermes Plan 机制调研]] — Plan-Execute 工作流设计，Hermes vs OpenClaw 对比

## 📰 新闻源文章

- [[重磅-全球首套人形机器人马拉松全栈导航系统开源|朗毅 Marathongo 开源]] — 朗毅开源全球首套人形机器人马拉松全栈导航系统
- [[高德ABot-Claw：基于OpenClaw的机器人智能体进化框架|高德 ABot-Claw 框架]] — Map as Memory + 闭环反思 + 多智能体调度
- [[刚刚，高德ABot-Claw亦庄半马封神！具身智能的Harness来了|ABot-Claw 半马封神]] — 亦庄半马详细报道，飞轮效应 + 开源策略

## Entities

- [[anymal]] — ANYmal 是 ETH Zurich / ANYbotics 开发的工业级四足机器人，以力控执行器和工业可靠性著称
- [[boston-dynamics]] — Boston Dynamics 是四足机器人领域的先驱，从 BigDog 到 Spot，定义了四足机器人的技术标准
- [[eth-zurich-robotics]] — ETH Zurich 是四足机器人研究的顶尖机构，ANYmal 的诞生地和 Sim2Real 迁移学习的先驱
- [[google-deepmind]] — Google DeepMind 是具身智能领域的核心研究机构，在 VLA 模型领域处于领先地位
- [[stanford-ai-lab]] — Stanford AI Lab 是具身智能开源模型的核心推动者，Chelsea Finn 团队在 VLA 模型领域贡献卓著
- [[unitree]] — 宇树科技是中国四足机器人领域最具代表性的公司，以高性价比四足机器人产品闻名
- [[unitree-go2]] — Unitree Go2 是宇树科技 2023 年推出的消费级四足机器人，以高性价比和 AI 集成为核心卖点

## Concepts

- [[domain-randomization]] — 领域随机化是 Sim2Real 迁移的核心技术，通过随机化仿真参数提升策略鲁棒性
- [[hermes-maintenance]] — Hermes Agent 部署后的日常维护、排错与已知限制汇总
- [[mpc-control]] — Model Predictive Control 是四足机器人最常用的控制架构，滚动优化求解最优地面反力
- [[octo]] — Octo 是 UC Berkeley/Stanford/CMU/Google 联合发布的开源通用机器人策略
- [[open-x-embodiment]] — Open X-Embodiment 是最大开源机器人操作数据集，汇集 20+ 机构数据
- [[openvla]] — OpenVLA 是 7B 参数开源 VLA 模型，在 970k 真实机器人演示上训练
- [[qdd-actuator]] — QDD 准直驱执行器是现代四足机器人核心硬件，低减速比兼顾高扭矩和反向驱动力
- [[rl-locomotion]] — 深度强化学习训练四足机器人运动策略，仿真训练后迁移到真实机器人
- [[rt2-vla]] — RT-2 是 Google DeepMind 提出的 VLA 模型，首次将视觉语言模型用于机器人控制
- [[sim2real]] — Sim2Real 是仿真到现实的迁移技术，当前具身智能最核心的工程挑战

## Agent 框架对比

- [[GenericAgent-vs-Hermes-深度对比|GA vs Hermes 对比]] — ⭐ 3300 行 vs 40K+ 行, 记忆/压缩/自进化/自主循环 6 维对比 + 6 条融合建议
- [[Proactive-Prune-改动记录|Proactive Prune]] — GA 启发的主动 tool result 压缩改动记录

## Comparisons

- [[quadruped-robots-comparison]] — Spot vs ANYmal vs Unitree Go2 vs A1 四足机器人横向对比
- [[vla-models-comparison]] — RT-2 vs Octo vs OpenVLA 视觉-语言-动作模型对比

## Infrastructure

- [[deploy-guide]] — 云服务器部署 Hermes Agent 全栈指南
- [[Hermes-Agent-全栈配置指南]] — ⭐ Hermes 安装配置 + Hindsight + Wiki/tree-plan + WebUI 占位，一站式参考

## 相关链接
- [[分布式RPA系统]] — 上层多机协作调度，多机仿真场景参考
- [[四足机器人调度系统-架构设计]] — 安卓App + 双服务器 + A2 完整系统架构
