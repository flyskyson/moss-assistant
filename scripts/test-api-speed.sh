#!/bin/bash

# API Speed Test Script
# 测试不同 DeepSeek API 的速度和性能
# 2026-02-08

set -euo pipefail

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# 测试配置
TEST_PROMPT="请用一句话介绍你自己，不要超过50字"
TEST_ITERATIONS=5

# 日志
LOG_FILE="/Users/lijian/clawd/logs/api-speed-test-$(date +%Y%m%d-%H%M%S).log"
mkdir -p /Users/lijian/clawd/logs

echo "========================================" | tee -a "$LOG_FILE"
echo "DeepSeek API Speed Test" | tee -a "$LOG_FILE"
echo "开始时间: $(date)" | tee -a "$LOG_FILE"
echo "========================================" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# 检查 API Keys
if [ -z "${OPENROUTER_API_KEY:-}" ]; then
    echo -e "${RED}❌ OPENROUTER_API_KEY 未设置${NC}"
    echo "请设置: export OPENROUTER_API_KEY='your-key'"
    exit 1
fi

if [ -z "${DEEPSEEK_API_KEY:-}" ]; then
    echo -e "${YELLOW}⚠️  DEEPSEEK_API_KEY 未设置${NC}"
    echo "如需测试 DeepSeek 官方专线，请设置: export DEEPSEEK_API_KEY='your-key'"
    echo ""
fi

# 测试函数
test_api() {
    local name="$1"
    local url="$2"
    local model="$3"
    local api_key="$4"

    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}" | tee -a "$LOG_FILE"
    echo -e "${BLUE}测试: $name${NC}" | tee -a "$LOG_FILE"
    echo -e "${BLUE}模型: $model${NC}" | tee -a "$LOG_FILE"
    echo -e "${BLUE}URL: $url${NC}" | tee -a "$LOG_FILE"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}" | tee -a "$LOG_FILE"

    local total_time=0
    local success_count=0
    local failed_count=0

    for i in $(seq 1 $TEST_ITERATIONS); do
        echo -n "  测试 $i/$TEST_ITERATIONS ... " | tee -a "$LOG_FILE"

        local start_time=$(date +%s.%N)

        # 发送请求
        local response=$(curl -s -w "\n%{http_code}\n%{time_total}" \
            -X POST "$url" \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $api_key" \
            -d "{
              \"model\": \"$model\",
              \"messages\": [{\"role\": \"user\", \"content\": \"$TEST_PROMPT\"}],
              \"max_tokens\": 100,
              \"stream\": false
            }" 2>&1)

        local end_time=$(date +%s.%N)
        local elapsed=$(echo "$end_time - $start_time" | bc)

        # 解析响应
        local http_code=$(echo "$response" | tail -n 2 | head -n 1)
        local curl_time=$(echo "$response" | tail -n 1)
        local body=$(echo "$response" | head -n -2)

        if [ "$http_code" = "200" ]; then
            # 提取回复内容
            local content=$(echo "$body" | jq -r '.choices[0].message.content // empty' 2>/dev/null || echo "")

            if [ -n "$content" ]; then
                echo -e "${GREEN}✓${NC} (${elapsed}s)" | tee -a "$LOG_FILE"
                echo "    回复: $content" | tee -a "$LOG_FILE"
                total_time=$(echo "$total_time + $elapsed" | bc)
                success_count=$((success_count + 1))
            else
                echo -e "${RED}✗ 响应解析失败${NC}" | tee -a "$LOG_FILE"
                failed_count=$((failed_count + 1))
            fi
        else
            echo -e "${RED}✗ HTTP $http_code${NC}" | tee -a "$LOG_FILE"
            echo "    错误: $body" | tee -a "$LOG_FILE"
            failed_count=$((failed_count + 1))
        fi

        sleep 0.5  # 避免速率限制
    done

    # 计算统计数据
    if [ $success_count -gt 0 ]; then
        local avg_time=$(echo "scale=3; $total_time / $success_count" | bc)
        echo "" | tee -a "$LOG_FILE"
        echo -e "${GREEN}📊 统计结果:${NC}" | tee -a "$LOG_FILE"
        echo "  成功: $success_count/$TEST_ITERATIONS" | tee -a "$LOG_FILE"
        echo "  失败: $failed_count/$TEST_ITERATIONS" | tee -a "$LOG_FILE"
        echo "  平均响应时间: ${avg_time}s" | tee -a "$LOG_FILE"
        echo "  总耗时: ${total_time}s" | tee -a "$LOG_FILE"

        # 估算每秒 token 数（假设平均 50 tokens）
        local tps=$(echo "scale=2; 50 / $avg_time" | bc)
        echo "  预估吞吐量: ${tps} tokens/秒" | tee -a "$LOG_FILE"

        # 返回平均时间
        echo "$avg_time"
    else
        echo "" | tee -a "$LOG_FILE"
        echo -e "${RED}❌ 所有测试失败${NC}" | tee -a "$LOG_FILE"
        echo "999"
    fi

    echo "" | tee -a "$LOG_FILE"
}

# ========================================
# 方案 1: OpenRouter DeepSeek V3.2
# ========================================
openrouter_time=$(test_api \
    "OpenRouter - DeepSeek V3.2" \
    "https://openrouter.ai/api/v1/chat/completions" \
    "deepseek/deepseek-v3.2" \
    "$OPENROUTER_API_KEY"
)

# ========================================
# 方案 2: DeepSeek 官方专线
# ========================================
if [ -n "${DEEPSEEK_API_KEY:-}" ]; then
    deepseek_time=$(test_api \
        "DeepSeek 官方专线 - DeepSeek-Chat" \
        "https://api.deepseek.com/chat/completions" \
        "deepseek-chat" \
        "$DEEPSEEK_API_KEY"
    )
else
    echo -e "${YELLOW}⚠️  跳过 DeepSeek 官方专线测试（API Key 未设置）${NC}" | tee -a "$LOG_FILE"
    deepseek_time="999"
fi

# ========================================
# 方案 3: MiniMax M2.1 (作为备用)
# ========================================
minimax_time=$(test_api \
    "OpenRouter - MiniMax M2.1" \
    "https://openrouter.ai/api/v1/chat/completions" \
    "minimax/minimax-m2.1" \
    "$OPENROUTER_API_KEY"
)

# ========================================
# 总结对比
# ========================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}" | tee -a "$LOG_FILE"
echo -e "${BLUE}📊 最终对比${NC}" | tee -a "$LOG_FILE"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

printf "%-35s %-15s %-15s\n" "方案" "平均响应时间" "速度评级" | tee -a "$LOG_FILE"
echo "----------------------------------------" | tee -a "$LOG_FILE"

# OpenRouter DeepSeek
if [ "$openrouter_time" != "999" ]; then
    or_rating=$(echo "$openrouter_time < 2.0" | bc)
    if [ "$or_rating" = "1" ]; then
        rating="${GREEN}快 ✓${NC}"
    elif [ "$openrouter_time" != "999" ] && $(echo "$openrouter_time < 5.0" | bc -l); then
        rating="${YELLOW}中${NC}"
    else
        rating="${RED}慢 ✗${NC}"
    fi
    printf "%-35s %-15s %-15s\n" "OpenRouter DeepSeek" "${openrouter_time}s" "$rating" | tee -a "$LOG_FILE"
fi

# DeepSeek 官方
if [ "$deepseek_time" != "999" ] && [ -n "${DEEPSEEK_API_KEY:-}" ]; then
    ds_rating=$(echo "$deepseek_time < 2.0" | bc)
    if [ "$ds_rating" = "1" ]; then
        rating="${GREEN}快 ✓${NC}"
    elif $(echo "$deepseek_time < 5.0" | bc -l); then
        rating="${YELLOW}中${NC}"
    else
        rating="${RED}慢 ✗${NC}"
    fi
    printf "%-35s %-15s %-15s\n" "DeepSeek 官方专线" "${deepseek_time}s" "$rating" | tee -a "$LOG_FILE"
fi

# MiniMax
if [ "$minimax_time" != "999" ]; then
    mm_rating=$(echo "$minimax_time < 2.0" | bc)
    if [ "$mm_rating" = "1" ]; then
        rating="${GREEN}快 ✓${NC}"
    elif $(echo "$minimax_time < 5.0" | bc -l); then
        rating="${YELLOW}中${NC}"
    else
        rating="${RED}慢 ✗${NC}"
    fi
    printf "%-35s %-15s %-15s\n" "OpenRouter MiniMax M2.1" "${minimax_time}s" "$rating" | tee -a "$LOG_FILE"
fi

echo "" | tee -a "$LOG_FILE"

# 推荐结论
echo -e "${GREEN}💡 推荐方案:${NC}" | tee -a "$LOG_FILE"

if [ "$deepseek_time" != "999" ] && [ -n "${DEEPSEEK_API_KEY:-}" ]; then
    # 对比 OpenRouter 和官方
    faster=$(echo "$deepseek_time < $openrouter_time" | bc -l)
    if [ "$faster" = "1" ]; then
        improvement=$(echo "scale=1; ($openrouter_time - $deepseek_time) / $openrouter_time * 100" | bc)
        echo "  ✅ 使用 DeepSeek 官方专线 - 比OpenRouter快 ${improvement}%" | tee -a "$LOG_FILE"
        echo "  📝 配置文件: ~/.openclaw/openclaw.json" | tee -a "$LOG_FILE"
        echo "  🎯 MOSS 主模型使用官方专线" | tee -a "$LOG_FILE"
    else
        echo "  ⚠️  OpenRouter 更快，继续使用 OpenRouter" | tee -a "$LOG_FILE"
    fi
elif [ "$openrouter_time" != "999" ]; then
    echo "  ✅ OpenRouter DeepSeek (DeepSeek 官方 API Key 未设置)" | tee -a "$LOG_FILE"
    if $(echo "$openrouter_time > 5.0" | bc -l); then
        echo "  ⚠️  但速度较慢 (${openrouter_time}s)，建议测试 DeepSeek 官方专线" | tee -a "$LOG_FILE"
    fi
fi

echo "" | tee -a "$LOG_FILE"
echo "日志已保存: $LOG_FILE" | tee -a "$LOG_FILE"
echo "测试完成: $(date)" | tee -a "$LOG_FILE"
