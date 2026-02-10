#!/bin/bash

# Test Method 1: Model Fallback Configuration
# This script tests DeepSeek official API with OpenRouter fallback

echo "========================================="
echo "测试方法1：模型回退配置"
echo "主模型: DeepSeek官方API (deepseek-chat)"
echo "回退模型: OpenRouter DeepSeek V3.2"
echo "========================================="
echo ""

# Configuration
TEST_QUERIES=(
    "请简单介绍一下你自己"
    "什么是人工智能？"
    "如何优化DeepSeek API的性能？"
    "请用3点总结OpenClaw的优势"
    "解释什么是模型回退机制"
)

TOTAL_TESTS=${#TEST_QUERIES[@]}
SUCCESS_COUNT=0
FALLBACK_COUNT=0
TOTAL_TIME=0

# Test function
test_query() {
    local query="$1"
    local test_num="$2"

    echo "测试 $test_num/$TOTAL_TESTS: $query"

    # Start timer
    local start_time=$(date +%s)

    # Send query via openclaw (using the main agent)
    # We'll use openclaw's CLI to interact with the agent
    local response=$(echo "$query" | timeout 60 openclaw chat --agent main 2>&1)

    # End timer
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    # Check for errors
    if echo "$response" | grep -q "error\|Error\|ERROR\|failed\|Failed"; then
        echo "❌ 失败 (耗时: ${duration}s)"
        echo "错误信息: $response" | head -n 3
    else
        echo "✅ 成功 (耗时: ${duration}s)"

        # Check if fallback was used (log analysis)
        if tail -20 /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log | grep -q "fallback\|Fallback"; then
            echo "🔄 检测到回退到OpenRouter"
            ((FALLBACK_COUNT++))
        fi

        ((SUCCESS_COUNT++))
        TOTAL_TIME=$((TOTAL_TIME + duration))
    fi

    echo ""
    sleep 2  # Brief pause between tests
}

# Run tests
echo "开始测试..."
echo "========================================="
echo ""

for i in "${!TEST_QUERIES[@]}"; do
    test_query "${TEST_QUERIES[$i]}" $((i + 1))
done

# Summary
echo "========================================="
echo "测试总结"
echo "========================================="
echo "总测试数: $TOTAL_TESTS"
echo "成功: $SUCCESS_COUNT"
echo "失败: $((TOTAL_TESTS - SUCCESS_COUNT))"
echo "回退次数: $FALLBACK_COUNT"

if [ $SUCCESS_COUNT -gt 0 ]; then
    local avg_time=$((TOTAL_TIME / SUCCESS_COUNT))
    echo "平均响应时间: ${avg_time}秒"
fi

echo ""
echo "稳定性评估:"
if [ $SUCCESS_COUNT -eq $TOTAL_TESTS ]; then
    if [ $FALLBACK_COUNT -eq 0 ]; then
        echo "✅ 优秀 - 所有请求成功，无需回退"
    elif [ $FALLBACK_COUNT -le $((TOTAL_TESTS / 2)) ]; then
        echo "⚠️  良好 - 所有请求成功，部分需要回退"
    else
        echo "⚠️  一般 - 所有请求成功，但频繁回退"
    fi
elif [ $SUCCESS_COUNT -gt $((TOTAL_TESTS / 2)) ]; then
    echo "❌ 较差 - 超过一半的请求失败"
else
    echo "❌ 不可接受 - 大部分请求失败"
fi

echo ""
echo "详细日志位置: /tmp/openclaw/"
echo "========================================="
