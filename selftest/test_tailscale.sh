#!/usr/bin/env bash
# test_tailscale.sh — 仙秦帝国 Tailscale 虚拟局域网自测
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPORT="${SCRIPT_DIR}/report_tailscale.txt"

echo "=== Tailscale Self-Test ===" > "$REPORT"
date >> "$REPORT"
echo "" >> "$REPORT"

PASS=0
FAIL=0
INFO=0

log() {
    local level="$1"
    local msg="$2"
    echo "[$level] $msg" | tee -a "$REPORT"
    case "$level" in
        PASS) PASS=$((PASS+1)) ;;
        FAIL) FAIL=$((FAIL+1)) ;;
        INFO) INFO=$((INFO+1)) ;;
    esac
}

# 1. tailscale 二进制是否存在可执行
if command -v tailscale &>/dev/null; then
    log PASS "tailscale binary found: $(which tailscale)"
else
    log FAIL "tailscale binary not found in PATH"
fi

# 2. tailscaled 服务状态
if systemctl is-active --quiet tailscaled 2>/dev/null || pgrep -x tailscaled >/dev/null 2>&1; then
    log PASS "tailscaled daemon is running"
else
    log FAIL "tailscaled daemon is NOT running"
fi

# 3. 本机 tailscale IP
LOCAL_IP=$(tailscale ip -4 2>/dev/null || true)
if [[ -n "$LOCAL_IP" ]]; then
    log PASS "Local Tailscale IP: $LOCAL_IP"
else
    log FAIL "Cannot get local Tailscale IP"
fi

# 4. 节点列表成功获取
NODES=$(tailscale status 2>/dev/null | grep -E '^100\.' | wc -l)
if [[ "$NODES" -ge 4 ]]; then
    log PASS "Tailscale mesh has $NODES nodes (expected >= 4)"
else
    log FAIL "Tailscale mesh only has $NODES nodes (expected >= 4)"
fi

# 5. 各关键节点 ping
NODES_TO_PING=(
    "100.80.136.1:相邦(vm-0-16-ubuntu)"
    "100.64.63.98:始皇(qin-super-server)"
    "100.67.214.106:骥骑(qin-x99-d8-server)"
    "100.76.65.47:丞相(architect)"
)
for entry in "${NODES_TO_PING[@]}"; do
    ip="${entry%%:*}"
    name="${entry##*:}"
    if timeout 8 tailscale ping -c 1 "$ip" &>/dev/null; then
        # 记录延迟
        delay=$(timeout 8 tailscale ping -c 1 "$ip" 2>/dev/null | grep -oE 'in [0-9.]+ms' | head -1 || echo "")
        log PASS "Ping $name ($ip) OK $delay"
    else
        log FAIL "Ping $name ($ip) FAILED (timeout or unreachable)"
    fi
done

# 6. DERP 中继状态
if tailscale status 2>/dev/null | grep -q "DERP"; then
    log INFO "Some nodes are using DERP relay (high latency expected)"
fi

echo "" >> "$REPORT"
echo "Summary: PASS=$PASS FAIL=$FAIL INFO=$INFO" >> "$REPORT"
log INFO "Done. Report: $REPORT"
