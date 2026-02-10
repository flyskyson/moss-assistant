#!/bin/bash

# Test Method 1: Model Fallback Configuration
# 测试DeepSeek官方API + OpenRouter回退

echo "========================================="
echo "测试方法1：模型回退配置"
echo "主模型: DeepSeek官方API (deepseek-chat)"
echo "回退模型: OpenRouter DeepSeek V3.2"
echo "配置: maxConcurrent=2, timeout=120s"
echo "========================================="
echo ""

# Configuration
declare -a TEST_QUERIES=(
    "请简单介绍一下你自己，不超过100字"
    "什么是人工智能？用一句话回答"
    "OpenClaw的三个核心优势是什么？"
    "解释什么是模型回退机制，用50字以内"
    "如何在DeepSeek API中优化性能？"
)

TOTAL_TESTS=${#TEST_QUERIES[@]}
SUCCESS_COUNT=0
FAIL_COUNT=0
TOTAL_TIME=0
declare -a RESPONSE_TIMES

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test function
test_query() {
    local query="$1"
    local test_num="$2"

    echo -n "测试 $test_num/$TOTAL_TESTS: "

    # Start timer
    local start_time=$(date +%s.%N)

    # Send query via openclaw agent
    local output
    if output=$(openclaw agent --agent main --message "$query" --json 2>&1); then
        # End timer
        local end_time=$(date +%s.%N)
        local duration=$(echo "$end_time - $start_time" | bc)

        # Check for successful response
        if echo "$output" | jq -e '.response' > /dev/null 2>&1; then
            echo -e "${GREEN}✅ 成功${NC} (${duration}s)"
            RESPONSE_TIMES+=("$duration")
            ((SUCCESS_COUNT++))
            TOTAL_TIME=$(echo "$TOTAL_TIME + $duration" | bc)
        else
            echo -e "${RED}❌ 失败${NC} (无效响应)"
            echo "错误: $output" | head -n 2
            ((FAIL_COUNT++))
        fi
    else
        # End timer
        local end_time=$(date +%s.%N)
        local duration=$(echo "$end_time - $start_time" | bc)
        echo -e "${RED}❌ 失败${NC} (${duration}s)"
        echo "错误: $output" | head -n 2
        ((FAIL_COUNT++))
    fi

    # Brief pause between tests
    sleep 1
}

# Check prerequisites
echo "检查前置条件..."

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}警告: jq未安装，将跳过JSON解析${NC}"
fi

# Check if bc is installed
if ! command -v bc &> /dev/null; then
    echo -e "${RED}错误: bc未安装，无法计算时间${NC}"
    echo "请运行: brew install bc"
    exit 1
fi

# Check Gateway status
if ! openclaw gateway status | grep -q "Runtime: running"; then
    echo -e "${RED}错误: Gateway未运行${NC}"
    echo "请先运行: openclaw gateway start"
    exit 1
fi

echo -e "${GREEN}✓ 前置条件检查通过${NC}"
echo ""

# Run tests
echo "开始测试..."
echo "========================================="
echo ""

for i in "${!TEST_QUERIES[@]}"; do
    test_query "${TEST_QUERIES[$i]}" $((i + 1))
done

# Calculate statistics
echo ""
echo "========================================="
echo "测试总结"
echo "========================================="
echo "总测试数: $TOTAL_TESTS"
echo -e "成功: ${GREEN}$SUCCESS_COUNT${NC}"
echo -e "失败: ${RED}$FAIL_COUNT${NC}"
echo "成功率: $(echo "scale=1; $SUCCESS_COUNT * 100 / $TOTAL_TESTS" | bc)%"

if [ $SUCCESS_COUNT -gt 0 ]; then
    local avg_time=$(echo "scale=2; $TOTAL_TIME / $SUCCESS_COUNT" | bc)
    echo "平均响应时间: ${avg_time}秒"

    # Find min and max
    local min_time=${RESPONSE_TIMES[0]}
    local max_time=${RESPONSE_TIMES[0]}
    for time in "${RESPONSE_TIMES[@]}"; do
        if (( $(echo "$time < $min_time" | bc -l) )); then
            min_time=$time
        fi
        if (( $(echo "$time > $max_time" | bc -l) )); then
            max_time=$time
        fi
    done
    echo "最快响应: ${min_time}秒"
    echo "最慢响应: ${max_time}秒"
fi

echo ""
echo "稳定性评估:"
if [ $SUCCESS_COUNT -eq $TOTAL_TESTS ]; then
    if (( $(echo "$avg_time < 10" | bc -l) )); then
        echo -e "${GREEN}✅ 优秀 - 所有请求成功，平均响应时间<10秒${NC}"
    elif (( $(echo "$avg_time < 20" | bc -l) )); then
        echo -e "${GREEN}✅ 良好 - 所有请求成功，平均响应时间<20秒${NC}"
    else
        echo -e "${YELLOW}⚠️  一般 - 所有请求成功，但响应时间较慢${NC}"
    fi
elif [ $SUCCESS_COUNT -gt $((TOTAL_TESTS * 80 / 100)) ]; then
    echo -e "${YELLOW}⚠️  可接受 - 超过80%的请求成功${NC}"
elif [ $SUCCESS_COUNT -gt $((TOTAL_TESTS / 2)) ]; then
    echo -e "${RED}❌ 较差 - 超过一半的请求失败${NC}"
else
    echo -e "${RED}❌ 不可接受 - 大部分请求失败${NC}"
fi

# Check logs for fallback usage
echo ""
echo "检查回退机制使用情况..."
LOG_FILE="/tmp/openclaw/openclaw-$(date +%Y-%m-%d).log"
if [ -f "$LOG_FILE" ]; then
    if grep -q "fallback\|Fallback" "$LOG_FILE"; then
        echo -e "${YELLOW}检测到回退机制被触发${NC}"
        echo "相关日志:"
        grep -i "fallback" "$LOG_FILE" | tail -n 5
    else
        echo -e "${GREEN}未检测到回退 - 主模型工作正常${NC}"
    fi
fi

echo ""
echo "详细日志位置: /tmp/openclaw/"
echo "Gateway控制台: http://127.0.0.1:18789/"
echo "========================================="
