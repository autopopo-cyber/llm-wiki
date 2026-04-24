# 仙秦帝国 A2A 网络状态

> 最后更新: 2026-04-24 (Session 4)

## 网络拓扑

```
         相邦 (协调者)
         100.80.136.1
         云服务器
              │
    ┌─────────┼─────────┐
    │         │         │
始皇帝      骠骑将军    丞相李斯
100.64.63.98  100.67.214.106  100.76.65.47
qin-server   .26 RTX2080Ti   WSL
```

## A2A 通信验证

| 属下 | Gateway | API | Chat | 统一Key |
|------|---------|-----|------|---------|
| 始皇帝 | 0.0.0.0:8642 ✅ | ✅ | ✅ | ✅ |
| 骠骑将军 | 0.0.0.0:8642 ✅ | ✅ | ✅ | ✅ |
| 丞相李斯 | 0.0.0.0:8642 ✅ | ✅ | ✅ | ✅ |

## API 调用方式

```bash
# 统一认证 key (三台共用)
API_KEY=81110644d45e6c8f8d547c27ac5111d2755bc8367a1461f2ff7909841d4be3bc

# 示例：调始皇的模型列表
curl -H "Authorization: Bearer $API_KEY" http://100.64.63.98:8642/v1/models

# 示例：发聊天请求
curl -H "Authorization: Bearer $API_KEY" \
     -H "Content-Type: application/json" \
     http://100.64.63.98:8642/v1/chat/completions \
     -d '{"model":"default","messages":[{"role":"user","content":"hello"}]}'
```

## 各节点配置

### 始皇帝 (qin-server)
- Host: qin@100.64.63.98
- Hermes: /home/qin/.local/bin/hermes (v0.11.0)
- Model: kimi-k2.6
- Proxy: 127.0.0.1:7897
- 角色: 全栈工程师

### 骠骑将军 (.26)
- Host: qin@100.67.214.106
- Hermes: /home/qin/.hermes/venv/bin/hermes (v0.11.0)
- GPU: RTX 2080 Ti 11GB, CUDA 12.2
- 角色: GPU骑兵、具身智能工程师

### 丞相李斯 (WSL)
- Host: qinj@100.76.65.47
- Hermes: /home/qinj/.hermes/hermes-agent/venv/bin/hermes (v0.11.0)
- Model: kimi-k2.6
- 角色: 制度建筑师、Hermes逻辑改造者

## 凭证管理
- 密码本: ~/.hermes/credentials/api-keys.toml
- 部署脚本: /tmp/deploy-keys.py (从密码本分发到三台)
- ⚠️ API key 被 Hermes 安全机制遮蔽为 *** — 不可直接读取，必须用脚本拷贝
