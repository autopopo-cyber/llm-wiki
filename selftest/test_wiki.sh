#!/usr/bin/env bash
# test_wiki.sh — 公用 Wiki (llm-wiki) 与私用 Wiki (wiki-2) 自测
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPORT="${SCRIPT_DIR}/report_wiki.txt"

echo "=== Wiki Self-Test ===" > "$REPORT"
date >> "$REPORT"
echo "" >> "$REPORT"

PASS=0; FAIL=0; INFO=0
log() { local l="$1" m="$2"; echo "[$l] $m" | tee -a "$REPORT"; case "$l" in PASS) PASS=$((PASS+1));; FAIL) FAIL=$((FAIL+1));; INFO) INFO=$((INFO+1));; esac; }

# --- 公用 Wiki (wiki-0) ---
WIKI0="${HOME}/llm-wiki"

# 1. 路径存在
if [[ -d "$WIKI0" ]]; then
    log PASS "wiki-0 directory exists: $WIKI0"
else
    log FAIL "wiki-0 directory missing"
fi

# 2. Git 仓库
if [[ -d "$WIKI0/.git" ]]; then
    log PASS "wiki-0 is a git repository"
    REMOTE=$(cd "$WIKI0" && git remote get-url origin 2>/dev/null || echo "none")
    log INFO "wiki-0 remote: $REMOTE"
    BRANCH=$(cd "$WIKI0" && git branch --show-current 2>/dev/null || echo "unknown")
    log INFO "wiki-0 branch: $BRANCH"
else
    log FAIL "wiki-0 is NOT a git repository"
fi

# 3. 篇数统计
if [[ -d "$WIKI0" ]]; then
    MD_COUNT=$(find "$WIKI0" -name "*.md" -not -path "*/.git/*" | wc -l)
    log PASS "wiki-0 markdown files: $MD_COUNT"
else
    log INFO "wiki-0 markdown files: N/A"
fi

# 4. Git 同步状态
cd "$WIKI0" 2>/dev/null || true
if git diff --quiet origin/master 2>/dev/null; then
    log PASS "wiki-0 is in sync with origin/master"
else
    log INFO "wiki-0 has local changes not pushed to origin/master"
fi
if git status --short 2>/dev/null | grep -q "^UU\|^AA\|^DD\|^AU\|^UA"; then
    log FAIL "wiki-0 has merge conflicts or unmerged files"
fi

# 5. 关键文件检查
for f in index.md SCHEMA.md log.md; do
    if [[ -f "$WIKI0/$f" ]]; then
        log PASS "wiki-0 key file exists: $f"
    else
        log INFO "wiki-0 key file missing: $f"
    fi
done

# --- 私用 Wiki (wiki-2) ---
WIKI2="${HOME}/wiki-2"

if [[ -d "$WIKI2" ]]; then
    log PASS "wiki-2 directory exists: $WIKI2"
    MD2_COUNT=$(find "$WIKI2" -name "*.md" -not -path "*/.git/*" | wc -l)
    log INFO "wiki-2 markdown files: $MD2_COUNT"
    if [[ -d "$WIKI2/.git" ]]; then
        log PASS "wiki-2 is a git repository"
        REMOTE2=$(cd "$WIKI2" && git remote get-url origin 2>/dev/null || echo "none")
        log INFO "wiki-2 remote: $REMOTE2"
    else
        log FAIL "wiki-2 is NOT a git repository"
    fi
else
    log FAIL "wiki-2 directory missing"
fi

# 6. 连接性：GitHub push/pull 测试
if timeout 10 git ls-remote origin HEAD &>/dev/null; then
    log PASS "GitHub remote is reachable"
else
    log FAIL "GitHub remote is unreachable (network/proxy issue?)"
fi

echo "" >> "$REPORT"
echo "Summary: PASS=$PASS FAIL=$FAIL INFO=$INFO" >> "$REPORT"
log INFO "Done. Report: $REPORT"
