# ~/.hermes/ 纯净原则

> 御批 2026-04-26 | 适用于所有仙秦 Agent

## 原则

`~/.hermes/` 目录**只放 Hermes 代码和配置文件**。其他一切移出。

## 迁移清单

| 原位置 | 新位置 | 说明 |
|--------|--------|------|
| `~/.hermes/plan-tree.md` | `~/xianqin/plan-tree.md` | 核心调度 |
| `~/.hermes/idle-log.md` | `~/wiki-{N}/raw/idle-log.md` | 操作日志 |
| `~/.hermes/pending-tasks.md` | `~/wiki-{N}/pending-tasks.md` | 待办清单 |
| `~/.hermes/SOUL.md` | `~/xianqin/soul.md` | Agent 灵魂 |
| `~/.hermes/browser-use-venv/` | `~/.local/venvs/browser-use/` | 非 Hermes venv |
| `~/.hermes/bin/*` | `~/.local/bin/` | 第三方二进制 |
| 大文件/数据集 | `/lhcos-data/` (256TB) | 数据盘 |

## 执行

每个 Agent 在每日回顾时执行：
1. 检查 `~/.hermes/` 下是否有不应存在的文件
2. 按上表迁移
3. 更新引用该文件的所有 skill/script/wiki

## Why

- Hermes 升级/重装不应影响仙秦帝国数据
- `rm -rf ~/.hermes/` 应该是安全的（除了备份 .env 和 config.yaml）
- 数据盘 256TB，系统盘 120G — 数据放对地方
