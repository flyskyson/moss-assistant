#!/bin/bash

# Simple API Speed Test
# 简化版 API 速度测试

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# 配置
DEEPSEEK_KEY="sk-1e040b7546b341b0bee289c8bc74ea4f"
TEST_PROMPT="你好，请用一句话介绍你自己，不要超过50字"
ITERATIONS=3

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}🚀 DeepSeek API 速度测试${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# 测试函数
test_api() {
    local name="$1"
    local url="$2"
    local model="$3"
    local key="$4"

    echo -e "${BOLD}测试: $name${NC}"
    echo "模型: $model"
    echo "URL: $url"
    echo ""

    local success=0
    local total_time=0

    for i in $(seq 1 $ITERATIONS); do
        echo -n "  [$i/$ITERATIONS] 测试... "

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
            echo "     → $content"
            total_time=$((total_time + elapsed))
            success=$((success + 1))
        else
            echo -e "${RED}✗${NC} 失败"
            echo "     $(echo "$response" | head -c 100)..."
        fi

        sleep 1
    done

    echo ""
    if [ $success -gt 0 ]; then
        local avg=$((total_time / success))
        echo -e "  平均: ${GREEN}${avg}s${NC} ($success/$ITERATIONS 成功)"

        if [ $avg -lt 2 ]; then
            echo -e "  评级: ${GREEN}🚀 快 (适合 MOSS)${NC}"
        elif [ $avg -lt 4 ]; then
            echo -e "  评级: ${YELLOW}⚡ 中 (可用)${NC}"
        else
            echo -e "  评级: ${RED}🐌 慢 (不推荐)${NC}"
        fi

        return $avg
    else
        echo -e "  ${RED}全部失败${NC}"
        return 999
    fi
}

# 测试 1: DeepSeek 官方专线
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
test_api "DeepSeek 官方专线" "https://api.deepseek.com/chat/completions" "deepseek-chat" "$DEEPSEEK_KEY"
deepseek_time=$?

echo ""
echo ""

# 测试 2: OpenRouter (需要 API Key)
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}测试 OpenRouter DeepSeek V3.2${NC}"
echo ""
echo "请输入 OpenRouter API Key (或按 Enter 跳过):"
read -t 30 -r OPENROUTER_KEY || OPENROUTER_KEY=""

if [ -n "$OPENROUTER_KEY" ]; then
    echo ""
    test_api "OpenRouter DeepSeek V3.2" "https://openrouter.ai/api/v1/chat/completions" "deepseek/deepseek-v3.2" "$OPENROUTER_KEY"
    openrouter_time=$?
else
    echo -e "${YELLOW}⊘ 跳过 OpenRouter 测试${NC}"
    openrouter_time=999
fi

# 总结
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}📊 测试结果总结${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

printf "%-30s %-10s\n" "方案" "平均时间"
echo "───────────────────────────────────────────────"

if [ $deepseek_time -ne 999 ]; then
    printf "%-30s %-10s\n" "DeepSeek 官方专线" "${deepseek_time}s"
fi

if [ $openrouter_time -ne 999 ]; then
    printf "%-30s %-10s\n" "OpenRouter DeepSeek" "${openrouter_time}s"
fi

echo ""
echo -e "${BOLD}💡 推荐配置:${NC}"
echo ""

if [ $deepseek_time -ne 999 ] && [ $openrouter_time -eq 999 ]; then
    echo -e "${GREEN}✅ 使用 DeepSeek 官方专线${NC}"
    echo ""
    echo "配置方式:"
    echo "  export DEEPSEEK_API_KEY=\"$DEEPSEEK_KEY\""
    echo ""
    echo "在 OpenClaw 中使用:"
    echo '  model: "deepseek-chat"'
    echo "  baseUrl: \"https://api.deepseek.com\""

elif [ $deepseek_time -ne 999 ] && [ $openrouter_time -ne 999 ]; then
    if [ $deepseek_time -lt $openrouter_time ]; then
        improvement=$((100 - (deepseek_time * 100 / openrouter_time)))
        echo -e "${GREEN}✅ 使用 DeepSeek 官方专线 - 快 ${improvement}%${NC}"
    else
        echo -e "${YELLOW}⚠️  OpenRouter 更快，继续使用 OpenRouter${NC}"
    fi
fi

echo ""
