# YC 总裁开源了自己亲手写的 AI Agent 大脑，1 周就 1 万点赞

> 来源: [逛逛](https://mp.weixin.qq.com/s/F9RNOFvc9lAEx2lg50SNDg)
> 日期: 2026-04

Garry Tan 开源的 GBrain 项目介绍。解决 AI Agent 金鱼脑问题——给 Agent 装长期记忆。

## 核心要点

- 4 月初开源，十几天 9K+ Star
- Garry 自己用：17888 pages、4383 人物、723 公司、21 cron 全自动
- 12 天搭完

## 4 大亮点

### 1. 25 个 Skill 即插即用
- signal-detector：每条消息后台跑便宜小模型，抓观点和实体
- brain-ops：回答前先查脑子，查不到不瞎编
- 内容摄入类：会议、邮件、推特、PDF、视频、GitHub 全吃
- 运维类：cron、每日简报、引用自检、过期巡检

### 2. Compiled Truth + Timeline 知识模型
- 上面 compiled truth = 当前最佳理解（可改写）
- 下面 timeline = 只追加不删除（原始证据链）
- 两边好处都拿

### 3. 混合搜索 + 实体自动升级
- 向量 + 关键词 + RRF 融合 + 多查询扩展 + 4 层去重
- 提到 1 次 → stub，3 次 → 联网补料，8 次 → 完整 dossier
- Fail-improve 循环：意图分类器 40% → 87%

### 4. 能打电话的脑子
- Twilio + OpenAI Realtime
- 通话结束自动生成 brain page

## 部署路线
- A：让 Agent 自己装（30 分钟）
- B：本地 CLI（PGLite 零配置）
- C：接入 Claude Code / Cursor（30+ MCP 工具）

## 设计哲学
**Thin Harness, Fat Skills**：智能放 Skill，Runtime 越薄越好。

> 相关：[[gbrain-深度分析]]
