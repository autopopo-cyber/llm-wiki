#!/usr/bin/env bash
# test_mission_control.sh — Mission Control 面板自测
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPORT="${SCRIPT_DIR}/report_mission_control.txt"

echo "=== Mission Control Self-Test ===" > "$REPORT"
date >> "$REPORT"
echo "" >> "$REPORT"

PASS=0; FAIL=0; INFO=0
log() { local l="$1" m="$2"; echo "[$l] $m" | tee -a "$REPORT"; case "$l" in PASS) PASS=$((PASS+1));; FAIL) FAIL=$((FAIL+1));; INFO) INFO=$((INFO+1));; esac; }

MC_DIR="${HOME}/projects/mission-control"
PUBLIC_IP="49.232.136.220"

# 1. 安装路径
if [[ -d "$MC_DIR" ]]; then
    log PASS "Mission Control directory exists: $MC_DIR"
else
    log FAIL "Mission Control directory missing"
fi

# 2. 关键文件
[[ -f "$MC_DIR/package.json" ]] && log PASS "package.json exists" || log FAIL "package.json missing"
[[ -f "$MC_DIR/.env" ]] && log PASS ".env exists" || log FAIL ".env missing"
[[ -f "$MC_DIR/next.config.js" ]] && log PASS "next.config.js exists" || log FAIL "next.config.js missing"

# 3. Node.js 版本
NODE_VER=$(node -v 2>/dev/null || echo "none")
if [[ "$NODE_VER" =~ ^v2[2-9] ]]; then
    log PASS "Node.js version OK: $NODE_VER"
else
    log FAIL "Node.js version too old or missing: $NODE_VER"
fi

# 4. systemd 服务
if systemctl --user is-active --quiet mission-control 2>/dev/null; then
    log PASS "mission-control.service is active"
else
    log FAIL "mission-control.service is NOT active"
fi

# 5. 本地监听
if ss -tlnp 2>/dev/null | grep -q ":3000"; then
    PID=$(ss -tlnp 2>/dev/null | grep ":3000" | grep -oP 'pid=\K[0-9]+' | head -1 || echo "?")
    log PASS "Port 3000 listening (pid=$PID)"
else
    log FAIL "Port 3000 not listening"
fi

# 6. 本地 HTTP 响应
LOCAL_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:3000 2>/dev/null || echo "000")
if [[ "$LOCAL_CODE" == "200" || "$LOCAL_CODE" == "307" ]]; then
    log PASS "Local curl http://127.0.0.1:3000 → $LOCAL_CODE"
else
    log FAIL "Local curl http://127.0.0.1:3000 → $LOCAL_CODE"
fi

# 7. Tailscale IP 访问
for ip in 100.76.65.47 100.80.136.1; do
    CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 3 "http://$ip:3000" 2>/dev/null || echo "000")
    if [[ "$CODE" == "200" || "$CODE" == "307" ]]; then
        log PASS "Tailscale curl http://$ip:3000 → $CODE"
    else
        log INFO "Tailscale curl http://$ip:3000 → $CODE (may be expected if not in MC_ALLOWED_HOSTS)"
    fi
done

# 8. 公网访问（腾讯云安全组测试）
PUB_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "http://$PUBLIC_IP:3000" 2>/dev/null || echo "000")
if [[ "$PUB_CODE" == "200" || "$PUB_CODE" == "307" ]]; then
    log PASS "Public curl http://$PUBLIC_IP:3000 → $PUB_CODE"
else
    log INFO "Public curl http://$PUBLIC_IP:3000 → $PUB_CODE (security group or bind issue)"
fi

# 9. MCP server 脚本
[[ -f "$MC_DIR/scripts/mc-mcp-server.cjs" ]] && log PASS "MCP server script exists" || log INFO "MCP server script missing (optional)"

# 10. 数据库
MC_DB=$(find "$MC_DIR" -maxdepth 2 -name "*.db" 2>/dev/null | head -1 || true)
if [[ -n "$MC_DB" ]]; then
    log PASS "SQLite DB found: $MC_DB"
else
    log INFO "SQLite DB not found (may use default .data/mission-control.db)"
fi

echo "" >> "$REPORT"
echo "Summary: PASS=$PASS FAIL=$FAIL INFO=$INFO" >> "$REPORT"
log INFO "Done. Report: $REPORT"
