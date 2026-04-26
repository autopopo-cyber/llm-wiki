# Hermes Agent 升级指南

> 最后更新: 2026-04-26 | 维护者: 相邦

## 升级前检查

```bash
# 1. 确认当前版本
cd ~/.hermes/hermes-agent && git log --oneline -1

# 2. 确认当前补丁状态
ls ~/patches/hermes-agent/
cat ~/patches/README.md

# 3. 备份当前 config 和 .env
cp ~/.hermes/config.yaml ~/patches/backup-config-$(date +%Y%m%d).yaml
cp ~/.hermes/.env ~/patches/backup-env-$(date +%Y%m%d)
```

## 升级 Hermes

```bash
# 官方升级命令
hermes update

# 或手动 git pull
cd ~/.hermes/hermes-agent && git pull origin main

# 重新安装依赖
cd ~/.hermes/hermes-agent && source venv/bin/activate && pip install -e .
```

## 重打补丁

升级后官方的 run_agent.py 可能覆盖我们的修改。需要重新应用补丁。

### 补丁 001: DeepSeek V4 reasoning_content 400 修复

**问题**：DeepSeek V4 thinking mode 要求所有 assistant 消息携带 `reasoning_content`，缺失导致 HTTP 400。
**修复文件**：`run_agent.py`（3 处修改）
**补丁文件**：`~/patches/hermes-agent/001-deepseek-400-reasoning-content.patch`

```bash
cd ~/.hermes/hermes-agent

# 尝试自动应用
git apply ~/patches/hermes-agent/001-deepseek-400-reasoning-content.patch

# 如果失败（行号偏移），查看 diff 手动修改：
cat ~/patches/hermes-agent/001-deepseek-400-reasoning-content.patch
```

**手动应用要点**（如果自动 patch 失败）：

在 `run_agent.py` 中找到三个位置：

1. **`_supports_reasoning_extra_body` 方法**：在 `return False` 前插入 DeepSeek 检测
2. **`_build_assistant_message` 方法**：将 `msg.get("tool_calls") and self._needs_deepseek_tool_reasoning()` 改为 `self._needs_deepseek_tool_reasoning() or self._needs_kimi_tool_reasoning()`，并增加 API 无 reasoning_content 属性时的兜底
3. **`_copy_reasoning_content_for_api` 方法**：去掉 `source_msg.get("tool_calls") and` 守卫，对所有 DeepSeek/Kimi assistant 消息注入 `reasoning_content=""`

**官方修复状态**：
- 初版修复已合入 main（只覆盖 tool_calls 消息）
- 完整修复 PR (#15213) 已提交，待 merge
- 如果官方 merge 后升级，此补丁不再需要

### 自定义脚本（不受升级影响）

| 文件 | 备份位置 |
|------|---------|
| `~/.hermes/scripts/cron-preflight.py` | `~/patches/cron-preflight.py` |
| `~/.hermes/scripts/lock-manager.sh` | `~/patches/lock-manager.sh` |

这些脚本不在 hermes-agent 仓库内，升级不会覆盖。但如果重装系统需要恢复。

### 自定义 Skills（不受升级影响）

| Skill | 备份位置 |
|-------|---------|
| hindsight-process-optimization | `~/patches/skills/hindsight-process-optimization/` |
| autonomous-drive | `~/patches/skills/productivity/autonomous-drive/` |

Skills 在 `~/.hermes/skills/` 下，升级不会覆盖。

## 升级后验证

```bash
# 1. 检查导入
cd ~/.hermes/hermes-agent && python3 -c "import run_agent; print('Import OK')"

# 2. 重启 Gateway
pkill -f 'gateway run'
sleep 2
cd ~/.hermes/hermes-agent && source venv/bin/activate && nohup python -m hermes_cli.main gateway run --replace > /dev/null 2>&1 &

# 3. 验证健康
curl http://localhost:8642/health

# 4. 验证 DeepSeek 连接（发一条简单消息测试）
# 通过 Telegram/Discord 发 "ping" 确认 200 响应
```

## 升级历史

| 日期 | 版本 | 补丁状态 | 备注 |
|------|------|---------|------|
| 2026-04-26 | main@6407b3d5 | 001 需要手动应用 | 初版修复只覆盖 tool_calls |
| - | - | - | - |

## 相关文件

- 补丁目录：`~/patches/hermes-agent/`
- 补丁说明：`~/patches/README.md`
- 仙秦部署：`~/wiki-1/xianqin/deploy-progress.md`
