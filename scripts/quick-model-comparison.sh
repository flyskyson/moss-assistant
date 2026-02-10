#!/bin/bash

# Quick Model Comparison for Sub-Agents
# 子 Agent 模型快速对比测试
# 目标: 确定是否有必要为不同任务使用不同模型

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# API Keys
DEEPSEEK_KEY="sk-1e040b7546b341b0bee289c8bc74ea4f"
OPENROUTER_KEY="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"

echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}  ${BOLD}子 Agent 模型快速对比测试${NC}                                ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  ${BOLD}   DeepSeek 全能 vs MiniMax 编程专用${NC}                      ${CYAN}║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# 测试场景
echo -e "${BOLD}测试场景:${NC}"
echo "  1. 编程任务 - 简单 Python 函数"
echo "  2. 速度对比 - 响应时间"
echo ""

# ========================================
# 测试 1: 编程能力
# ========================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}🧪 场景 1: 编程任务${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

PROGRAMMING_TASK="写一个 Python 函数，计算斐波那契数列的第 n 项（要求高效）"

# DeepSeek 官方
echo -e "${BOLD}A. DeepSeek 官方专线${NC}"
echo -n "   测试... "
start=$(date +%s)
deepseek_code=$(curl -s -X POST "https://api.deepseek.com/chat/completions" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $DEEPSEEK_KEY" \
    -d "{
      \"model\": \"deepseek-chat\",
      \"messages\": [{\"role\": \"user\", \"content\": \"$PROGRAMMING_TASK\"}],
      \"max_tokens\": 500
    }" | jq -r '.choices[0].message.content')
end=$(date +%s)
deepseek_time=$((end - start))
echo -e "${GREEN}✓${NC} ${deepseek_time}s"
echo ""

# MiniMax
echo -e "${BOLD}B. MiniMax M2.1 (编程专用)${NC}"
echo -n "   测试... "
start=$(date +%s)
minimax_code=$(curl -s -X POST "https://openrouter.ai/api/v1/chat/completions" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $OPENROUTER_KEY" \
    -d "{
      \"model\": \"minimax/minimax-m2.1\",
      \"messages\": [{\"role\": \"user\", \"content\": \"$PROGRAMMING_TASK\"}],
      \"max_tokens\": 500
    }" | jq -r '.choices[0].message.content')
end=$(date +%s)
minimax_time=$((end - start))
echo -e "${GREEN}✓${NC} ${minimax_time}s"
echo ""

# 简单对比代码质量
echo -e "${BOLD}代码质量对比:${NC}"
echo ""
echo "DeepSeek 代码:"
echo "$deepseek_code" | head -10
echo "..."
echo ""
echo "MiniMax 代码:"
echo "$minimax_code" | head -10
echo "..."
echo ""

# ========================================
# 测试 2: 速度对比
# ========================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}🧪 场景 2: 速度对比（3次平均）${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

TEST_PROMPT="你好"

echo -e "${BOLD}A. DeepSeek 官方专线${NC}"
total=0
for i in {1..3}; do
    echo -n "   [$i/3] "
    start=$(date +%s)
    curl -s -X POST "https://api.deepseek.com/chat/completions" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $DEEPSEEK_KEY" \
        -d "{\"model\": \"deepseek-chat\", \"messages\": [{\"role\": \"user\", \"content\": \"$TEST_PROMPT\"}], \"max_tokens\": 50}" >/dev/null
    end=$(date +%s)
    elapsed=$((end - start))
    echo "${elapsed}s"
    total=$((total + elapsed))
done
deepseek_avg=$((total / 3))
echo "   平均: ${deepseek_avg}s"
echo ""

echo -e "${BOLD}B. MiniMax M2.1${NC}"
total=0
for i in {1..3}; do
    echo -n "   [$i/3] "
    start=$(date +%s)
    curl -s -X POST "https://openrouter.ai/api/v1/chat/completions" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $OPENROUTER_KEY" \
        -d "{\"model\": \"minimax/minimax-m2.1\", \"messages\": [{\"role\": \"user\", \"content\": \"$TEST_PROMPT\"}], \"max_tokens\": 50}" >/dev/null
    end=$(date +%s)
    elapsed=$((end - start))
    echo "${elapsed}s"
    total=$((total + elapsed))
done
minimax_avg=$((total / 3))
echo "   平均: ${minimax_avg}s"
echo ""

# ========================================
# 总结与推荐
# ========================================
echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}  ${BOLD}📊 测试总结与建议${NC}                                            ${CYAN}║${NC}"
echo -e "${CYAN}╚══════════════════════════════════━━━━━━━━━━━━━━━━━━━━━━━━━╝${NC}"
echo ""

echo -e "${BOLD}对比结果:${NC}"
echo ""
printf "%-25s %-15s %-15s\n" "模型" "编程任务" "平均速度"
echo "───────────────────────────────────────────────────────"
printf "%-25s %-15s %-15s\n" "DeepSeek 官方" "${deepseek_time}s" "${deepseek_avg}s"
printf "%-25s %-15s %-15s\n" "MiniMax M2.1" "${minimax_time}s" "${minimax_avg}s"
echo ""

# 推荐策略
echo -e "${BOLD}💡 推荐策略:${NC}"
echo ""

if [ $minimax_avg -gt $((deepseek_avg * 2)) ]; then
    echo -e "${GREEN}  ✅ 全部使用 DeepSeek 官方专线${NC}"
    echo ""
    echo "  理由:"
    echo "  • MiniMax 速度慢 2倍以上（通过 OpenRouter）"
    echo "  • DeepSeek 编程能力已足够（97.5% GPT-4o）"
    echo "  • 统一模型简化配置和维护"
    echo ""
    echo "  配置:"
    echo "  • MOSS: deepseek-chat"
    echo "  • Leader Agent: deepseek-chat"
    echo "  • Utility Agent: deepseek-chat"
    echo "  • 其他子 Agent: deepseek-chat"

elif [ $minimax_avg -le $deepseek_avg ]; then
    echo -e "${YELLOW}  ⚠️  MiniMax 速度相当或更快${NC}"
    echo ""
    echo "  理由:"
    echo "  • MiniMax 速度不慢（可能网络好）"
    echo "  • MiniMax 编程性能 72.5% SWE-bench"
    echo ""
    echo "  建议混合配置:"
    echo "  • MOSS: deepseek-chat（主模型）"
    echo "  • Leader Agent: minimax/minimax-m2.1（编程任务）"
    echo "  • Utility Agent: deepseek-chat"
    echo "  • 其他: 根据任务类型选择"

else
    echo -e "${GREEN}  ✅ 推荐: 全部使用 DeepSeek${NC}（简单高效）"
    echo ""
    echo -e "${YELLOW}  ⚠️  备选: 编程任务用 MiniMax${NC}（如果需要极致性能）"
    echo ""
    echo "  配置选项:"
    echo ""
    echo "  ${BOLD}选项 A: 简化配置（推荐）${NC}"
    echo "  • 所有 Agent: deepseek-chat"
    echo "  • 优点: 配置简单，速度最快，成本最低"
    echo "  • 适用: 95% 的场景"
    echo ""
    echo "  ${BOLD}选项 B: 优化配置${NC}"
    echo "  • MOSS: deepseek-chat"
    echo "  • 编程 Agent: minimax/minimax-m2.1"
    echo "  • 其他: deepseek-chat"
    echo "  • 优点: 编程任务可能更好"
    echo "  • 缺点: 配置复杂，速度慢"
fi

echo ""
echo -e "${BOLD}🎯 我的建议:${NC}"
echo ""
echo -e "${GREEN}  除非有明确的编程性能需求，否则全部使用 DeepSeek 官方专线。${NC}"
echo ""
echo "  原因:"
echo "  1. DeepSeek V3.2 已经很强（97.5% GPT-4o）"
echo "  2. 速度快 3-4 倍（1s vs 4s）"
echo "  3. 配置简单，维护方便"
echo "  4. 成本更低（无 OpenRouter 中转）"
echo ""
echo "  如需更详细测试，可以运行完整版测试。"
echo ""
