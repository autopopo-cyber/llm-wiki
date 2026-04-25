#!/usr/bin/env bash
# test_memos.sh — MemOS 矢量记忆自测
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPORT="${SCRIPT_DIR}/report_memos.txt"

echo "=== MemOS Self-Test ===" > "$REPORT"
date >> "$REPORT"
echo "" >> "$REPORT"

PASS=0; FAIL=0; INFO=0
log() { local l="$1" m="$2"; echo "[$l] $m" | tee -a "$REPORT"; case "$l" in PASS) PASS=$((PASS+1));; FAIL) FAIL=$((FAIL+1));; INFO) INFO=$((INFO+1));; esac; }

MEMOS_DIR="${HOME}/.hermes/memos-plugin"
MEMOS_SRC="${HOME}/projects/MemOS"

# 1. 源码存在
if [[ -d "$MEMOS_SRC" ]]; then
    log PASS "MemOS source exists: $MEMOS_SRC"
else
    log FAIL "MemOS source missing"
fi

# 2. Bridge 进程
if pgrep -f "bridge.cjs.*hermes" >/dev/null 2>&1; then
    log PASS "MemOS bridge process running (hermes agent)"
else
    log FAIL "MemOS bridge process NOT running"
fi

# 3. 端口监听
if ss -tlnp 2>/dev/null | grep -q "18799"; then
    log PASS "Port 18799 is listening"
else
    log FAIL "Port 18799 not listening"
fi

# 4. 数据库文件
if [[ -f "$MEMOS_DIR/data/memos.db" ]]; then
    SIZE=$(du -sh "$MEMOS_DIR/data/memos.db" | cut -f1)
    log PASS "memos.db exists ($SIZE)"
    # WAL 活跃程度
    WAL=$(du -sh "$MEMOS_DIR/data/memos.db-wal" 2>/dev/null | cut -f1 || echo "0")
    log INFO "memos.db-wal size: $WAL (non-zero = active writes)"
else
    log FAIL "memos.db missing"
fi

# 5. 配置文件
if [[ -f "$MEMOS_DIR/config.yaml" ]]; then
    log PASS "config.yaml exists"
    KEY_OK=$(grep "apiKey:" "$MEMOS_DIR/config.yaml" 2>/dev/null | grep -v '""' | wc -l)
    if [[ "$KEY_OK" -ge 2 ]]; then
        log PASS "API keys are non-empty"
    else
        log FAIL "API keys may be empty"
    fi
else
    log FAIL "config.yaml missing"
fi

# 6. 连接测试
timeout 3 bash -c "echo > /dev/tcp/127.0.0.1/18799" 2>/dev/null && log PASS "TCP connect to 18799 OK" || log FAIL "TCP connect to 18799 FAILED"

# 7. 写入测试（通过 MCP 管道写入）
# 注意：此处只做管道存活检查，实际向量写入需要 embedding API
log INFO "Vector write test requires active embedding API (skipped in shell)"

# 8. 侵入情况检查：memos-plugin 是否被正确挂载到 hermes
if grep -q "memtensor" "${HOME}/.hermes/config.yaml" 2>/dev/null; then
    log PASS "Hermes config uses memtensor provider"
else
    log FAIL "Hermes config does NOT use memtensor provider"
fi

# 9. 检索测试：session 启动时 memory_search 是否生效
# 实际验证需要 session 日志，这里仅检查目录
if [[ -d "${HOME}/.hermes/sessions" ]]; then
    log INFO "Sessions dir exists; verify manually that new sessions inject memory results"
else
    log FAIL "Sessions dir missing"
fi

echo "" >> "$REPORT"
echo "Summary: PASS=$PASS FAIL=$FAIL INFO=$INFO" >> "$REPORT"
log INFO "Done. Report: $REPORT"
