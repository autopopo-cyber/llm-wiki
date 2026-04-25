#!/usr/bin/env bash
# restore-agent.sh — 仙秦帝国 Agent 零机器恢复脚本
# 在任何新机器上运行此脚本，从 wiki 仓库重建完整 Agent
# 用法: bash restore-agent.sh <agent-name> <wiki-id>
#   agent-name: 相邦|白起|骠骑|丞相
#   wiki-id:    1|2|3|4  (对应 wiki-N 私有仓库)
set -euo pipefail

GITHUB_ORG="autopopo-cyber"
GITHUB_TOKEN="${GITHUB_TOKEN:-}"
AGENT_NAME="${1:-}"
WIKI_ID="${2:-}"

if [[ -z "$AGENT_NAME" || -z "$WIKI_ID" ]]; then
    echo "用法: bash restore-agent.sh <agent-name> <wiki-id>"
    echo "  agent-name: 相邦|白起|骠骑|丞相"
    echo "  wiki-id:    1|2|3|4"
    exit 1
fi

HOME_DIR="${HOME:-/home/agentuser}"
WIKI_BASE="${HOME_DIR}/wiki-base"

echo "=========================================="
echo "  仙秦帝国 Agent 恢复脚本"
echo "  Agent: ${AGENT_NAME} (wiki-${WIKI_ID})"
echo "  $(date)"
echo "=========================================="

# ── Step 1: Clone 公共知识库 ──
echo ""
echo "[1/5] 克隆公共知识库 llm-wiki..."
mkdir -p "${WIKI_BASE}"
if [[ -d "${WIKI_BASE}/llm-wiki/.git" ]]; then
    cd "${WIKI_BASE}/llm-wiki" && git pull --ff-only
else
    git clone "https://${GITHUB_TOKEN}@github.com/${GITHUB_ORG}/llm-wiki.git" "${WIKI_BASE}/llm-wiki"
fi

# ── Step 2: Clone 私有知识库 ──
echo ""
echo "[2/5] 克隆私有知识库 wiki-${WIKI_ID}..."
if [[ -d "${WIKI_BASE}/wiki-${WIKI_ID}/.git" ]]; then
    cd "${WIKI_BASE}/wiki-${WIKI_ID}" && git pull --ff-only
else
    git clone "https://${GITHUB_TOKEN}@github.com/${GITHUB_ORG}/wiki-${WIKI_ID}.git" "${WIKI_BASE}/wiki-${WIKI_ID}"
fi

# ── Step 3: 运行自测 ──
echo ""
echo "[3/5] 运行健康自测..."
cd "${WIKI_BASE}/llm-wiki/selftest"
bash run_all.sh

# ── Step 4: 重建 Agent 配置 ──
echo ""
echo "[4/5] 重建 Agent 配置..."

# 从私有 wiki 读取 soul.md
SOUL_FILE="${WIKI_BASE}/wiki-${WIKI_ID}/soul/${AGENT_NAME}.soul.md"
if [[ -f "$SOUL_FILE" ]]; then
    echo "  ✓ soul.md 已恢复"
else
    echo "  ⚠ soul.md 未找到，从公共模板复制"
    cp "${WIKI_BASE}/llm-wiki/selftest/soul-template.md" "$SOUL_FILE" 2>/dev/null || true
fi

# 恢复密钥本（需要手动填入 API key）
KEY_FILE="${HOME_DIR}/.xianqin/credentials/api-keys.toml"
if [[ ! -f "$KEY_FILE" ]]; then
    mkdir -p "$(dirname "$KEY_FILE")"
    cp "${WIKI_BASE}/wiki-${WIKI_ID}/credentials/api-keys.toml" "$KEY_FILE" 2>/dev/null || {
        echo "  ⚠ 密钥本未找到，请手动创建 $KEY_FILE"
    }
    chmod 600 "$KEY_FILE"
fi

# ── Step 5: 启动服务 ──
echo ""
echo "[5/5] 启动 Agent 服务..."
# Gateway
if systemctl --user is-active hermes-gateway.service &>/dev/null; then
    echo "  ✓ Gateway 已运行"
else
    systemctl --user restart hermes-gateway.service 2>/dev/null || echo "  ⚠ Gateway 启动失败（可能未安装）"
fi

echo ""
echo "=========================================="
echo "  Agent ${AGENT_NAME} 恢复完成"
echo "  知识库: ${WIKI_BASE}"
echo "  公共:   ${WIKI_BASE}/llm-wiki"
echo "  私有:   ${WIKI_BASE}/wiki-${WIKI_ID}"
echo "=========================================="
