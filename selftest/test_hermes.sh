#!/usr/bin/env bash
# test_hermes.sh — Hermes Agent/Gateway 配置、技能、Cron 自测
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPORT="${SCRIPT_DIR}/report_hermes.txt"

echo "=== Hermes Self-Test ===" > "$REPORT"
date >> "$REPORT"
echo "" >> "$REPORT"

PASS=0; FAIL=0; INFO=0
log() { local l="$1" m="$2"; echo "[$l] $m" | tee -a "$REPORT"; case "$l" in PASS) PASS=$((PASS+1));; FAIL) FAIL=$((FAIL+1));; INFO) INFO=$((INFO+1));; esac; }

HERMES_DIR="${HOME}/.hermes"

# 1. hermes CLI
if command -v hermes &>/dev/null; then
    VER=$(hermes --version 2>/dev/null | head -1 || echo "unknown")
    log PASS "hermes CLI: $(hermes --version 2>/dev/null || echo 'not in PATH')"
    # 更新检查
    if hermes --version 2>/dev/null | grep -qi "behind\|update available"; then
        log INFO "hermes has updates available"
    fi
else
    # CLI may not be in PATH, gateway can still work via systemd
    if systemctl --user is-active hermes-gateway.service &>/dev/null; then
        log INFO "hermes CLI not in PATH, but gateway is active (OK)"
    else
        log FAIL "hermes CLI not found and gateway not active"
    fi
fi

# 2. config.yaml
if [[ -f "$HERMES_DIR/config.yaml" ]]; then
    log PASS "config.yaml exists"
    # 关键字段检查
    if grep -q "provider: memtensor" "$HERMES_DIR/config.yaml"; then
        log PASS "memory.provider = memtensor"
    else
        log FAIL "memory.provider is NOT memtensor"
    fi
    if grep -q "memory_enabled: true" "$HERMES_DIR/config.yaml"; then
        log PASS "memory_enabled = true"
    else
        log FAIL "memory_enabled is NOT true"
    fi
else
    log FAIL "config.yaml missing"
fi

# 3. 插件目录
PLUGINS_DIR="$HERMES_DIR/hermes-agent/plugins"
if [[ -d "$PLUGINS_DIR" ]]; then
    PLUGINS=$(ls "$PLUGINS_DIR" 2>/dev/null | wc -l)
    log PASS "plugins directory exists ($PLUGINS entries): $PLUGINS_DIR"
else
    log FAIL "plugins directory missing: $PLUGINS_DIR"
fi

# 4. memos-plugin 侵入检查
MEMOS_PLUGIN="$HERMES_DIR/memos-plugin"
if [[ -d "$MEMOS_PLUGIN" ]]; then
    log PASS "memos-plugin directory exists"
    if [[ -f "$MEMOS_PLUGIN/config.yaml" ]]; then
        log PASS "memos-plugin/config.yaml exists"
    else
        log FAIL "memos-plugin/config.yaml missing"
    fi
    if [[ -d "$MEMOS_PLUGIN/data" && -f "$MEMOS_PLUGIN/data/memos.db" ]]; then
        log PASS "memos-plugin database exists"
    else
        log FAIL "memos-plugin database missing"
    fi
else
    log FAIL "memos-plugin directory missing (not installed?)"
fi

# 5. Skill 列表
SKILL_COUNT=$(hermes skills list 2>/dev/null | grep -c "│" || true)
BUILT_COUNT=$(hermes skills list 2>/dev/null | grep -c "builtin" || true)
if [[ "$SKILL_COUNT" -gt 0 ]]; then
    log PASS "Skills loaded: total rows≈$SKILL_COUNT, builtin≈$BUILT_COUNT"
else
    log FAIL "No skills found"
fi

# 6. Cron jobs
CRON_OUT=$(hermes cron list 2>/dev/null || true)
if echo "$CRON_OUT" | grep -qi "No scheduled jobs"; then
    log INFO "No scheduled cron jobs"
else
    log INFO "Cron jobs exist: $CRON_OUT"
fi

# 7. Gateway 服务
GATEWAY_STATUS=$(hermes gateway status 2>/dev/null || true)
if echo "$GATEWAY_STATUS" | grep -q "active (running)"; then
    log PASS "Gateway systemd service is active"
else
    log FAIL "Gateway systemd service is NOT active"
fi
if echo "$GATEWAY_STATUS" | grep -q "outdated"; then
    log INFO "Gateway service definition is outdated; restart recommended"
fi

# 8. State DB
if [[ -f "$HERMES_DIR/state.db" ]]; then
    SIZE=$(du -sh "$HERMES_DIR/state.db" | cut -f1)
    log PASS "state.db exists ($SIZE)"
else
    log FAIL "state.db missing"
fi

# 9. Sessions directory
SESS_COUNT=$(find "$HERMES_DIR/sessions" -name "*.jsonl" 2>/dev/null | wc -l)
log INFO "Session files: $SESS_COUNT"

# 10. Response store
if [[ -f "$HERMES_DIR/response_store.db" ]]; then
    log PASS "response_store.db exists"
else
    log FAIL "response_store.db missing"
fi

echo "" >> "$REPORT"
echo "Summary: PASS=$PASS FAIL=$FAIL INFO=$INFO" >> "$REPORT"
log INFO "Done. Report: $REPORT"
