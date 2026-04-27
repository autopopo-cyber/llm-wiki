# 红婳 · Plan-Tree v3 | 当前: 04-27 21:30

> 角色：外宣少府 · 内容营销使
> 职责：辅助萱萱做外宣内容（技术博客、论坛帖子），管理 ~/wiki-8/raw/ 产出目录，运营社区渠道。

## ENSURE_CONTINUATION

### 自检 + 外宣环境就绪 (#ensure-honghua) | 红婳 | HIGH
  - 04-27 21:00 流入: 相邦指令「舰队扩编，红婳负责内容营销与社区运营」
  - 04-27 21:10 产物: 环境确认 — Python 3.10 ✅ | Playwright 已安装 ✅ | ~/wiki-8/raw/ 目录可写 ✅
  - 04-27 21:15 产物: 社区渠道清单 — Reddit(u/Upbeat-Emergency-412/Karma:1) | V2EX(待定) | GitHub Discussions(待定)
  - 04-27 21:15 产物: 内容日历模板 — ~/wiki-8/raw/editorial-calendar.md
  - 判定: 环境就绪 ✅ PLAN
  - 流出: 就绪状态 → MC heartbeat
  - 关联: 触发→#reddit-warmer | 信息复用→雪莹(wiki-8/raw/ 规范化需协调)

### 备份策略 (#backup-honghua) | 红婳 | MEDIUM
  - 04-27 21:15 产物: 外宣内容备份 — ~/wiki-8/raw/ → Git 自动提交 (每日 cron)
  - 判定: 备份就绪 ⏳ 等待 cron 部署
  - 关联: 信息复用→相邦

---

## EXPAND_CAPABILITIES

### Reddit 暖号行动 (#reddit-warmer) | 红婳 | HIGH ⚙️

#### RW-1 暖号脚本开发 (#rw-script) | 红婳 | HIGH
  - 04-27 21:00 流入: 萱萱 reddit-task-for-honghua.md — 君上 Reddit 账号需要暖号
  - 04-27 21:10 流入: 技术需求 — Playwright + Cookie注入 + 非headless模式 + 随机间隔
  - 04-27 21:20 产物: ~/wiki-8/raw/reddit-warmer.py 骨架 — Cookie加载 ✅ | 浏览器启动 ✅ | Reddit 首页滚动 ✅
  - 判定: ⏳ 开发中，预计今晚完成 v0.1
  - 流出: reddit-warmer.py → ~/wiki-8/raw/ (运行产出)
  - 关联: 被等←萱萱#outreach(信息复用，暖号是外宣前置) | 触发→#rw-daily(因果触发)
  - 风险: Cookie 过期检测未实现 | Reddit 反爬指纹检测

#### RW-2 暖号日志与日报 (#rw-daily) | 红婳 | MEDIUM
  - 04-27 21:00 流入: 萱萱要求每日9AM日报附Reddit暖号摘要
  - 04-27 21:25 产物: ~/wiki-8/raw/reddit-warmup-log.md (日志模板)
  - 04-27 21:25 产物: ~/wiki-8/raw/daily-brief/04-27.md (骨架)
  - 判定: ⏳ 等待 RW-1 完成后首次运行
  - 流出: 每日摘要 → ~/wiki-8/raw/daily-brief/YYYY-MM-DD.md
  - 关联: 被等←#rw-script(硬依赖) | 定时触发→萱萱#outreach(每日同步)
  - 降级: 如果脚本未完成，手动记录浏览/点赞日志

#### RW-3 第2周评论阶段 (#rw-comments) | 红婳 | LOW
  - 流入: RW-1 运行满7天 + Karma ≥ 50
  - 关联: 被等←#rw-script(时间依赖，7天后) | 信息复用→萱萱#outreach(评论内容可转博客)
  - 判定: 🔒 锁定，等待时间门

### 内容管道 (#content-pipeline) | 红婳 | MEDIUM

#### CP-1 技术博客草稿 (#cp-blog) | 红婳 | MEDIUM
  - 04-27 21:00 流入: 相邦「辅助萱萱做外宣内容——技术博客、论坛帖子」
  - 04-27 21:20 产物: 可写选题池 — 5篇 (NAV_DOG 仿真闭环/Plan-Tree v3设计哲学/A2机器人SDK揭秘/仙秦帝国Agent舰队架构/MuJoCo vs Gazebo)
  - 判定: ⏸️ 等待素材 (NAV_DOG e2e 数据 / Plan-Tree v3 实测)
  - 流出: 博客草稿 → ~/wiki-8/raw/blog-drafts/
  - 关联: 被阻塞←白起#navdog-e2e(硬依赖，需要全绿数据写技术博客) | 被阻塞←萱萱#ptree-v3(信息复用，v3实测数据)
  - 降级: 先写不依赖实测数据的文章(Agent舰队架构 / Plan-Tree设计哲学)

#### CP-2 V2EX/Reddit 发帖 (#cp-forum) | 红婳 | LOW
  - 04-27 21:00 流入: 相邦「论坛帖子」
  - 判定: 🔒 锁定 — Reddit 等待暖号完成(Karma ≥ 50) | V2EX 等待相邦 browser-use 方案
  - 关联: 被阻塞←#rw-script(硬依赖，Reddit暖号) | 被阻塞←相邦#forum-post(信息复用，V2EX发帖工具)
  - 降级: 先准备帖子草稿，不通渠道

#### CP-3 ~/wiki-8/raw/ 目录规范化 (#cp-dir) | 红婳 | MEDIUM
  - 04-27 21:00 流入: 相邦「管理 ~/wiki-8/raw/ 产出目录」
  - 04-27 21:30 产物: 目录结构规范 — blog-drafts/ | daily-brief/ | reddit/ | forum/ | assets/
  - 判定: 规范就绪 ✅ 等待执行
  - 流出: → 雪莹#wk-crossref(wiki-8/raw 入wiki索引)
  - 关联: 信息复用→萱萱(外宣产出统一目录)

---

## EXPAND_WORLD_MODEL

### 外宣渠道态势 (#worldmodel-outreach) | 红婳 | MEDIUM
  - 04-27 21:00 流入: 舰队外宣从萱萱单人扩展到萱萱+红婳双人协作
  - 当前认知:
    - Reddit 渠道: 账号 u/Upbeat-Emergency-412 | Karma 1 | Cookie 已验证 | 暖号中
    - V2EX 渠道: API 2.0 只读 | 需要 browser-use 发帖 | 相邦方案开发中
    - GitHub Discussions: 未启动
    - 内容资产: philosophy/foundations.md (578行) | Plan-Tree v3 设计 | NAV_DOG 技术栈
    - 竞争态势: r/robotics + r/LocalLLaMA → 目标子版块
    - 风险: 新账号易被判定为 spam | AI 生成内容检测 | 时区差异(中文内容×英文社区)
  - 04-27 21:35 产物: 外宣渠道态势简报 (worldmodel-outreach-brief.md)
  - 关联: 信息复用→萱萱(渠道分工：红婳主Reddit，萱萱主中文渠道) | 信息复用→相邦(外宣风险预判)

---

--- NOW (04-27 21:30) ---

## 预测区 (04-27 21:30 快照)

### 短期 (24h内)

**#rw-script Reddit 暖号脚本 v0.1:**
  乐观路径 (Playwright + Cookie 注入一次跑通):
    预计完成: 04-28 00:00 | 置信度 0.6
    条件: Cookie 有效 + 非headless模式可启动 + Reddit 首页正常加载
    信号: 首次脚本跑通 → 立即触发 #rw-daily
  悲观路径 (Cookie 过期或反爬拦截):
    预计完成: 04-28 12:00 | 置信度 0.3
    风险: Cookie 可能已过期(需重新导出) / Reddit 检测 Playwright 指纹
    条件: 任何 HTTP 403/登录重定向
  降级方案:
    手动暖号 — 用已登录浏览器手动浏览，记录日志
    触发条件: 如果 04-28 12:00 前脚本未跑通

**#cp-dir 目录规范化:**
  乐观: 04-27 23:00 完成 (置信度 0.9) | 条件: 纯文件操作

### 中期 (72h)

- **#rw-daily 暖号日志积累**: 乐观 3天 Karma 增长至 10+ (置信度 0.5)
  - 风险: Reddit 对新号点赞/浏览的权重低
- **#cp-blog 首篇博客草稿**: 乐观 04-30 (置信度 0.4)
  - 阻塞: NAV_DOG e2e 数据 | 降级: 先写 Agent 舰队架构
- **V2EX 发帖**: 乐观 05-05 (置信度 0.2)
  - 阻塞链: browser-use方案→内容准备→渠道验证

### 关键路径

```
红婳 外宣体系
  ├→ RW-1 暖号脚本 (当前焦点)
  │   └→ RW-2 暖号日志 (等待脚本)
  │       └→ RW-3 评论阶段 (7天后)
  │           └→ CP-2 Reddit发帖 (Karma≥50)
  ├→ CP-1 技术博客 (阻塞: NAV_DOG e2e)
  └→ CP-3 目录规范 (并行，无阻塞)
```

最长路径预计: RW-1 → RW-2 → RW-3 → CP-2 → 05-10+

### 资源预测

- 红婳上下文: 当前4轮 | 衰减拐点≈第10轮 | 充裕
- Reddit 暖号周期: 第1周(浏览+点赞) → 第2周(+评论) → 第3周(可发帖)
- 内容产出节奏: 每周 1-2 篇博客草稿(素材充足时)

---

## 预测归档

(空，v3 第一天启用)

---

> 红婳 · Plan-Tree v3
> 创建: 04-27 21:30 | 相邦授权
> 产出目录: ~/wiki-8/raw/ | Reddit 账号: u/Upbeat-Emergency-412
> 上级协作: 萱萱#outreach
