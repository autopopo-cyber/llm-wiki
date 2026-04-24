# Mission-Control 部署状态

> 部署时间: 2026-04-25 01:15
> 部署位置: 始皇帝 (qin-server, Tailscale IP)
> 访问地址: http://qin-server:3000 (Tailscale 网络)

## 部署详情

- 仓库: builderz-labs/mission-control (4333 stars)
- 版本: latest (main branch)
- 技术栈: Next.js 16.1.6 + Turbopack + SQLite + pnpm
- Node.js: v22.22.2 (via nvm)
- 端口: 3000 (0.0.0.0)

## 配置

- `.env` 文件位于 `~/projects/mission-control/.env`
- 默认连接 OpenClaw Gateway (port 18789) -- 需要改为 Hermes Gateway (port 8642)
- AUTH_SECRET 需要设置
- NEXT_PUBLIC_GATEWAY_URL 需要指向 Hermes API

## 下一步

1. 配置 .env 指向 Hermes Gateway
2. 设置 AUTH_SECRET 和管理员账号
3. 重新 build (pnpm build)
4. 注册三个 agent（始皇、骠骑、丞相）
5. 测试心跳和任务看板
