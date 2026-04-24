# API Server Keys — 仙秦帝国

> ⚠️ 此文件包含敏感信息，仅限内部使用

| 节点 | Tailscale IP | Gateway Port | API_SERVER_KEY |
|------|-------------|-------------|----------------|
| 始皇 (qin-server) | 100.64.63.98 | 8642 | `81110644d45e6c8f8d547c27ac5111d2755bc8367a1461f2ff7909841d4be3bc` |
| 骠骑 (.26) | 100.67.214.106 | 8642 | `41f21bda2c2874fdc1b417d8e24d4d0e80921f403904fd220ccec66e5f6b5baf` |
| 丞相 (WSL) | 100.76.65.47 | 8642 | 待配置 |

## OpenRouter API Key

所有节点共用一个 OpenRouter key（73字符，sk-or-v1-e 开头，d3357 结尾），已通过 xianqin-deploy-keys.sh 写入各节点的 auth.json 和 .env。

## A2A 测试命令

```bash
# 测试始皇
ssh qin-server 'curl -s http://localhost:8642/v1/chat/completions \
  -H "Authorization: Bearer 81110644d45e6c8f8d547c27ac5111d2755bc8367a1461f2ff7909841d4be3bc" \
  -H "Content-Type: application/json" \
  -d @/tmp/a2a-test.json'

# 测试骠骑
ssh piaoqi 'curl -s http://localhost:8642/v1/chat/completions \
  -H "Authorization: Bearer 41f21bda2c2874fdc1b417d8e24d4d0e80921f403904fd220ccec66e5f6b5baf" \
  -H "Content-Type: application/json" \
  -d @/tmp/a2a-test.json'
```

## 状态 (2026-04-24 ~19:50)

- ✅ 始皇 gateway 运行中，A2A 通信成功
- ✅ 骠骑 gateway 运行中，A2A 通信成功
- ⏳ 丞相 gateway 待配置（WSL SSH 未开）
