#!/usr/bin/env bash
# run_all.sh — 统一运行全部自测并生成总报告
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

FINAL="${SCRIPT_DIR}/FINAL_REPORT.txt"
echo "=== 仙秦帝国 Hermes Agent 健康检查总报告 ===" > "$FINAL"
date >> "$FINAL"
echo "" >> "$FINAL"

# 并行执行各子测试
bash test_tailscale.sh &
bash test_hermes.sh &
bash test_wiki.sh &
bash test_memos.sh &
bash test_mission_control.sh &
wait

# 汇总
echo "--- 各子系统汇总 ---" >> "$FINAL"
for r in report_tailscale.txt report_hermes.txt report_wiki.txt report_memos.txt report_mission_control.txt; do
    if [[ -f "$r" ]]; then
        echo "" >> "$FINAL"
        echo "=== $r ===" >> "$FINAL"
        tail -1 "$r" >> "$FINAL" 2>/dev/null || true
    fi
done

echo "" >> "$FINAL"
echo "总报告位置: $FINAL" >> "$FINAL"
cat "$FINAL"
