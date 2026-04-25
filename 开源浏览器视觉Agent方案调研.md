# 开源浏览器视觉 Agent 方案调研

日期: 2026-04-25
调研人: 相邦
动机: 替代 Claude Code 的视觉浏览器能力，使用开源方案实现「像人类一样看渲染过的浏览器页面 + 操作键鼠」。

---

## 核心需求

1. **视觉理解** — 截图→AI 分析→理解页面结构和内容（不用 DOM/HTML 文本提取）
2. **键鼠操作** — 点击、输入、滚动、拖拽、键盘快捷键
3. **自主决策** — LLM 看截图→决定下一步动作→执行→循环
4. **无需中间服务** — 不依赖 Firecrawl、Browserless 等 SaaS

---

## 方案对比

### 1. browser-use（⭐ 推荐首选）

| 项目 | 值 |
|------|-----|
| 仓库 | github.com/browser-use/browser-use |
| 许可证 | MIT |
| 语言 | Python >= 3.11 |
| 浏览器驱动 | Playwright (Chromium) |
| 热度 | ~40k+ stars |

**核心能力:**
```python
from browser_use import Agent, Browser, ChatBrowserUse

browser = Browser()
agent = Agent(
    task="注册一个GitHub账号",
    llm=ChatBrowserUse(),  # 也可用任何 OpenAI/Anthropic/Google 兼容模型
    browser=browser,
)
await agent.run()
```

**CLI 模式 (对 agent 极友好):**
```bash
browser-use open https://example.com
browser-use state          # 列出所有可点击元素
browser-use click 5        # 点击第5个元素
browser-use type "Hello"   # 输入文字
browser-use screenshot page.png  # 截图
browser-use close
```

**优点:**
- ✅ 完全开源，MIT 许可
- ✅ Playwright 驱动真实 Chromium，完整 JS/CSS 渲染
- ✅ 截图 + 元素定位双模式，LLM 同时获取视觉和结构化信息
- ✅ CLI 模式适合被 agent 的 `terminal` 工具直接调用
- ✅ 支持自定义工具扩展
- ✅ 支持浏览器持久化 profile（保存登录态）
- ✅ 有专门针对 browser-use 优化过的模型 (ChatBrowserUse)
- ✅ 文档完善，有 benchmark

**缺点:**
- ❌ 依赖 Chromium（体积大，~300MB）
- ❌ 需要 Python 环境
- ❌ 对复杂交互可能需要多次 LLM 调用

**与 Hermes 集成方式:**
1. 在相邦/骠骑上安装 `pip install browser-use`
2. Hermes 通过 `terminal` 工具调用 CLI: `browser-use open ...` → `browser-use state` → `browser-use click N`
3. 截图给视觉模型分析：`browser-use screenshot /tmp/page.png` → `vision_analyze`
4. 或直接用 browser-use 的 Agent 模式，DeepSeek V4 做主模型


### 2. Agent-S（学术 SOTA）

| 项目 | 值 |
|------|-----|
| 仓库 | github.com/simular-ai/Agent-S |
| 许可证 | 开源 |
| 语言 | Python (gui-agents 包) |
| 性能 | OSWorld 72.6%（超越人类 72%）|

**核心能力:**
- Agent-Computer Interface (ACI) — 截图→标注可交互元素→LLM决策
- 三大平台: Linux/macOS/Windows
- 需要 Grounding Model (UI-TARS-1.5-7B) 做元素定位
- 支持经验学习（agentic experience）

**优点:**
- ✅ 学术最强，超越人类基准
- ✅ 跨平台 (Linux/Mac/Windows)
- ✅ 三篇顶会论文 (ICLR 2025 + COLM 2025)
- ✅ 支持 Android (AndroidWorld)

**缺点:**
- ❌ 强依赖 Grounding Model（需要 GPU 跑 UI-TARS 7B）
- ❌ 更偏向 OS 操作而非纯 Web
- ❌ CLI 不如 browser-use 直观
- ❌ 安装较复杂 (tesseract, UI-TARS 模型)

**适用场景:** 需要跨应用操作 (浏览器+文件管理器+终端) 的场景


### 3. LaVague

| 项目 | 值 |
|------|-----|
| 仓库 | github.com/lavague-ai/LaVague |
| 驱动 | Selenium / Playwright |
| 定位 | 面向开发者的 Web Agent 框架 |

**架构:**
- World Model (指令生成) + Action Engine (动作执行)
- 支持 Selenium/Playwright/Chrome Extension 三种驱动
- 内置 Gradio 演示界面

**优点:**
- ✅ World Model + Action Engine 架构清晰
- ✅ 多种浏览器驱动可选
- ✅ Chrome Extension 可复用登录态
- ✅ 有 QA 子项目（Gherkin→测试用例）

**缺点:**
- ❌ 默认收集遥测数据（需手动关 LAVAGUE_TELEMETRY=NONE）
- ❌ 社区不如 browser-use 活跃
- ❌ 文档和生态相对薄弱

**适用场景:** 如果你偏好 Selenium 生态或需要 Chrome Extension


### 4. 补充方案（未详细调研）

| 项目 | 特点 |
|------|------|
| **WebVoyager** | 多模态 agent，纯截图理解网页，无需 DOM |
| **OS-Copilot** | FRIDAY 架构，通用 OS agent，Linux/Mac |
| **OpenAdapt** | 录制+回放 RPA，基于视觉 |
| **Skyvern** | 基于视觉的 Web 自动化，Y Combinator 孵化 |


## 针对机器狗 + Game-Auto-Android 的推荐

### 机器狗 (相邦/白起/骠骑)
- **browser-use** 是首选。机器狗开发涉及大量文档检索、GitHub issue 交互、论坛爬取。browser-use 的 CLI 模式对 Hermes 的 terminal 工具最友好。
- 安装路径: `pip install browser-use && playwright install chromium`

### Game-Auto-Android (丞相)
- **Agent-S** 更合适。AndroidWorld 是它的基准测试之一，原生支持 Android 操作。
- 或者用 **browser-use** + Android Chrome，因为很多手游有网页版/WebView

### 键鼠操作 (所有节点)
- 浏览器内的操作: browser-use/Agent-S 都能处理
- 操作系统级键鼠: **pyautogui** 或 **pynput** 作为底层库
- 无头 Linux 服务器: **Xvfb** (虚拟显示器) + **xdotool** (键鼠模拟)

---

## 部署建议

```
所有节点通用:
  pip install playwright  (Chromium 自动化)
  playwright install chromium

Web Agent:
  pip install browser-use

OS Agent (可选, 骠骑):
  pip install gui-agents  (Agent-S)
  pip install pyautogui pynput

游戏自动化 (丞相):
  Android: uiautomator2 + opencv + Agent-S
```

---

## 结论

**browser-use** 是你的最佳选择：
- 开源 MIT，无歧视中国人问题
- CLI 模式天然匹配 Hermes agent 的调用方式
- 真实 Chromium 渲染，不是 DOM 文本提取
- DeepSeek V4 可以直接做主模型
- 社区最活跃，文档最完善

不需要 Firecrawl。浏览器就是最好的页面渲染引擎。

---

*调研日期: 20260425 · 相邦*
