# 论坛发帖自动化 — 技术调研

> 2026-04-26 | 相邦 | MC FORUM_POST 项目

## 目标平台

| 平台 | 类型 | API 发帖 | 浏览器自动化 | 内容适合度 |
|------|------|:---:|:---:|:---:|
| **V2EX** | 中文技术社区 80万+用户 | ❌ API 2.0 无 create topic | ✅ browser-use | 极高 — Local LLM/分享创造节点 |
| **Reddit** | 全球最大论坛 | ✅ 完整 OAuth API | 可选 | 高 — r/robotics, r/MachineLearning |
| **Hacker News** | YC旗下技术社区 | ❌ 无官方API | ✅ browser/form submit | 中 — 偏硅谷生态 |
| **知乎** | 中文知识社区 | ❌ 封闭 | ✅ 需要登录+cookie | 中 — 适合技术长文 |
| **CSDN** | 中文开发者社区 | ❌ | ✅ | 中 — 技术教程向 |

## V2EX 详情

- **API**: `https://www.v2ex.com/api/v2/`，Bearer Token 认证
- **API 接口**: notifications, member, nodes, topics(read), replies(read), set-sticky, boost
- **⚠️ 无发帖接口**: API 2.0 暂不支持创建主题，需要浏览器自动化
- **速率限制**: 600次/小时/IP
- **目标节点**: `Local LLM`、`分享创造`、`Python`
- **注册**: 需要邀请码或开放日注册

### 发帖流程（拟）
1. browser-use 打开 v2ex.com/signin
2. 填写用户名/密码登录
3. 导航到目标节点 → "创建新主题"
4. 填写标题（Markdown支持）、内容、标签
5. 提交 → 获取 topic ID

## Reddit 详情

- **API**: `https://www.reddit.com/dev/api/`，OAuth2
- **支持**: POST /api/submit 创建帖子
- **认证**: 需要创建 Reddit App 获取 client_id + client_secret
- **子版块**: r/robotics(350K), r/MachineLearning(3M), r/LocalLLaMA(250K), r/learnmachinelearning(400K)
- **限制**: 新账号有发帖频率限制，需要积累 karma

### Reddit 发帖流程（拟）
1. 注册 Reddit 账号
2. 创建 Reddit Script App → client_id + client_secret
3. OAuth2 获取 access_token
4. POST /api/submit (title, text, sr, kind=self)
5. 检查帖子是否被 spam filter 拦截

## 内容策略

### 可公开的技术文章（从 llm-wiki 提炼）
| 主题 | 来源 | 适合平台 |
|------|------|---------|
| 四足机器人避障系统架构 | NAV_DOG-v2.1 | V2EX/Reddit |
| Isaac Gym 深度相机管线 | isaac-gym-depth-camera | Reddit |
| ABot-Claw 具身智能框架分析 | deep-dive-abot-claw | V2EX/知乎 |
| GNSS+IMU+LiDAR 融合选型 | gnss-imu-lidar-fusion | Reddit |
| Hermes Agent 运维经验 | hermes-deploy-lessons | V2EX |

### 发帖节奏
- V2EX: 每周 1-2 篇（避免被判定为推广）
- Reddit: 每周 1 篇（不同子版块轮换）
- 首发 V2EX → 翻译 → Reddit（内容复用）

## 下一步

1. ⚡ V2EX 注册账号 + 获取 Token
2. ⚡ Reddit 注册 + 创建 App + OAuth 测试
3. 首个帖子：NAV_DOG 避障架构 → V2EX "分享创造" 节点
4. browser-use 自动化发帖脚本
