#!/bin/bash

# Final API Speed Comparison Test
# 最终 API 速度对比测试

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

# 测试配置
TEST_PROMPT="你好，请用一句话介绍你自己，不要超过50字"
ITERATIONS=5

echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}  ${BOLD}🚀 DeepSeek API 速度对比测试${NC}                             ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  ${BOLD}   MOSS 核心模型选择${NC}                                         ${CYAN}║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# 测试函数
test_api() {
    local name="$1"
    local url="$2"
    local model="$3"
    local key="$4"

    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}🧪 $name${NC}"
    echo "   模型: $model"
    echo "   URL: $url"
    echo ""

    local success=0
    local total_time=0
    local times=()

    for i in $(seq 1 $ITERATIONS); do
        echo -n "   [$i/$ITERATIONS] "

        local start=$(date +%s)

        local response=$(curl -s -X POST "$url" \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $key" \
            -d "{
              \"model\": \"$model\",
              \"messages\": [{\"role\": \"user\", \"content\": \"$TEST_PROMPT\"}],
              \"max_tokens\": 100
            }" 2>&1)

        local end=$(date +%s)
        local elapsed=$((end - start))

        # 检查响应
        if echo "$response" | jq -e '.choices[0].message.content' >/dev/null 2>&1; then
            local content=$(echo "$response" | jq -r '.choices[0].message.content')
            echo -e "${GREEN}✓${NC} ${elapsed}s"
            times+=($elapsed)
            total_time=$((total_time + elapsed))
            success=$((success + 1))
        else
            echo -e "${RED}✗${NC} 失败"
        fi

        sleep 0.5
    done

    echo ""
    if [ $success -gt 0 ]; then
        local avg=$((total_time / success))

        # 计算标准差
        local variance=0
        for t in "${times[@]}"; do
            local diff=$((t - avg))
            variance=$((variance + diff * diff))
        done
        local std_dev=$((variance / success))

        echo -e "  ${BOLD}结果:${NC}"
        echo "  • 成功: $success/$ITERATIONS"
        echo "  • 平均: ${GREEN}${avg}s${NC}"

        if [ $avg -lt 2 ]; then
            echo -e "  • 评级: ${GREEN}🚀 快 (适合 MOSS)${NC}"
        elif [ $avg -lt 4 ]; then
            echo -e "  • 评级: ${YELLOW}⚡ 中 (可用)${NC}"
        else
            echo -e "  • 评级: ${RED}🐌 慢 (不推荐)${NC}"
        fi

        return $avg
    else
        echo -e "  ${RED}全部失败${NC}"
        return 999
    fi
    echo ""
}

# ========================================
# 运行测试
# ========================================

echo -e "${BOLD}开始测试...${NC}"
echo ""

# 测试 1: DeepSeek 官方专线
test_api "DeepSeek 官方专线" "https://api.deepseek.com/chat/completions" "deepseek-chat" "$DEEPSEEK_KEY"
deepseek_avg=$?

echo ""

# 测试 2: OpenRouter DeepSeek
test_api "OpenRouter - DeepSeek V3.2" "https://openrouter.ai/api/v1/chat/completions" "deepseek/deepseek-v3.2" "$OPENROUTER_KEY"
openrouter_avg=$?

echo ""

# ========================================
# 最终对比
# ========================================
echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}  ${BOLD}📊 最终对比结果${NC}                                             ${CYAN}║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${BOLD}平均响应时间对比:${NC}"
echo ""
printf "%-35s %-10s %-15s\n" "方案" "时间" "评级"
echo "───────────────────────────────────────────────────────────"

# 显示 DeepSeek 官方
if [ $deepseek_avg -ne 999 ]; then
    if [ $deepseek_avg -lt 2 ]; then
        rating="${GREEN}🚀 快${NC}"
    elif [ $deepseek_avg -lt 4 ]; then
        rating="${YELLOW}⚡ 中${NC}"
    else
        rating="${RED}🐌 慢${NC}"
    fi
    printf "%-35s %-10s %b\n" "DeepSeek 官方专线" "${deepseek_avg}s" "$rating"
fi

# 显示 OpenRouter
if [ $openrouter_avg -ne 999 ]; then
    if [ $openrouter_avg -lt 2 ]; then
        rating="${GREEN}🚀 快${NC}"
    elif [ $openrouter_avg -lt 4 ]; then
        rating="${YELLOW}⚡ 中${NC}"
    else
        rating="${RED}🐌 慢${NC}"
    fi
    printf "%-35s %-10s %b\n" "OpenRouter - DeepSeek V3.2" "${openrouter_avg}s" "$rating"
fi

echo ""
echo -e "${BOLD}💡 推荐配置:${NC}"
echo ""

# 决策
if [ $deepseek_avg -ne 999 ] && [ $openrouter_avg -ne 999 ]; then
    if [ $deepseek_avg -lt $openrouter_avg ]; then
        improvement=$((100 - (deepseek_avg * 100 / openrouter_avg)))
        echo -e "${GREEN}  ✅ 使用 DeepSeek 官方专线${NC}"
        echo -e "     比 OpenRouter 快 ${improvement}%"
        echo ""
        echo -e "  ${BOLD}配置方式:${NC}"
        echo ""
        echo "  1. 设置环境变量:"
        echo "     ${CYAN}export DEEPSEEK_API_KEY=\"$DEEPSEEK_KEY\"${NC}"
        echo ""
        echo "  2. 在 OpenClaw 配置中添加提供商 (~/.openclaw/openclaw.json):"
        echo ""
        echo '     {'
        echo '       "models": {'
        echo '         "providers": {'
        echo '           "deepseek": {'
        echo '             "baseUrl": "https://api.deepseek.com",'
        echo '             "api": "openai-completions",'
        echo '             "models": ['
        echo '               {'
        echo '                 "id": "deepseek-chat",'
        echo '                 "name": "DeepSeek Chat (Official)"'
        echo '               }'
        echo '             ]'
        echo '           }'
        echo '         }'
        echo '       }'
        echo '     }'
        echo ""
        echo "  3. MOSS 使用模型:"
        echo "     ${CYAN}model: \"deepseek-chat\"${NC}"
        echo ""

    elif [ $openrouter_avg -lt $deepseek_avg ]; then
        improvement=$((100 - (openrouter_avg * 100 / deepseek_avg)))
        echo -e "${YELLOW}  ⚠️  OpenRouter 更快${NC}"
        echo "     比官方专线快 ${improvement}%"
        echo ""
        echo "  保持当前配置即可。"
        echo ""
    else
        echo -e "${GREEN}  ✅ 两者速度相同${NC}"
        echo ""
        echo "  推荐: 使用 DeepSeek 官方专线（更稳定）"
        echo ""
    fi
fi

echo -e "${BOLD}📋 配置清单:${NC}"
echo ""
echo "  ✓ DeepSeek 官方 API Key: ${DEEPSEEK_KEY:0:20}..."
echo "  ✓ OpenRouter API Key: ${OPENROUTER_KEY:0:20}..."
echo ""
