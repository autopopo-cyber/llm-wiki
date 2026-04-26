# Web 浏览 & API 调用最佳实践

## 核心原则：按场景选工具

| 场景 | 用什么 | 为什么 |
|------|--------|--------|
| GitHub/结构化 API | `curl + jq` | 最快最准，零噪声 |
| 文章/博客内容 | `Jina Reader API` | 免费、干净 Markdown、支持 JS |
| 搜索引擎 | `Sogou (curl_cffi)` | 已有 skill，TLS 伪装 |
| 需要交互的页面 | `browser_navigate` | 唯一能点击/填表的方案 |
| 大型 JSON | `curl -o file + jq/python` | 避免截断 |

## API 调用防截断

### 规则 1：大响应永远先存文件
```bash
# ❌ 错误：管道容易截断
curl -s 'https://api.github.com/search/...' | python3 -c '...'

# ✅ 正确：先存文件再处理
curl -s 'https://api.github.com/search/...' -o /tmp/api_result.json
jq '.items[:5] | .[] | {name, stars}' /tmp/api_result.json
```

### 规则 2：用 jq 预过滤
```bash
# 只取需要的字段，减少 90%+ 数据量
curl -s URL | jq '[.items[] | {name, stars: .stargazers_count, desc: (.description[:80])}]'
```

### 规则 3：GitHub API 分页
```python
from api_helpers import github_paginate
items = github_paginate("https://api.github.com/search/repositories?q=...", max_pages=3)
```

### 规则 4：特殊字符处理
```python
from api_helpers import robust_json_loads
data = robust_json_loads(raw_text)
```

## Jina Reader API

```bash
# 基础用法（免费，无需认证）
curl -s 'https://r.jina.ai/https://example.com' \
  -H 'Accept: text/markdown' \
  --proxy http://127.0.0.1:7890

# 只取前 2000 字符（省 token）
curl -s 'https://r.jina.ai/URL' -H 'Accept: text/markdown' --proxy ... | head -80
```

限制：20 RPM（免费），输出可能包含导航噪声，适合文章/博客，不适合结构化数据。

## 不推荐

| 工具 | 原因 |
|------|------|
| Crawl4AI | 依赖 Playwright/Chromium，和现有浏览器冲突，启动慢 |
| lynx -dump | 无 JS 渲染，输出格式混乱 |
| Puppeteer | 需要写代码，和 Crawl4AI 同样的问题 |
| ScrapeGraphAI | 太重，每次调用消耗 LLM token |
