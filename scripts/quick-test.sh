#!/bin/bash

# Quick API Speed Test - Interactive Version
# 快速 API 速度测试 - 交互式版本

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# 测试配置
TEST_PROMPT="你好，请用一句话介绍你自己，不要超过50字"
LOG_FILE="/Users/lijian/clawd/logs/quick-test-$(date +%Y%m%d-%H%M%S).log"
mkdir -p /Users/lijian/clawd/logs

echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}  ${BOLD}DeepSeek API 速度测试${NC}                                     ${CYAN}║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# 获取 API Keys
echo -e "${BOLD}📝 请输入 API Keys（跳过请按 Enter）${NC}"
echo ""

# OpenRouter Key
if [ -z "${OPENROUTER_API_KEY:-}" ]; then
    echo -n "1. OpenRouter API Key: "
    read -t 30 -r OPENROUTER_INPUT || OPENROUTER_INPUT=""
    if [ -n "$OPENROUTER_INPUT" ]; then
        export OPENROUTER_API_KEY="$OPENROUTER_INPUT"
        echo -e "${GREEN}✓ 已设置${NC}"
    else
        echo -e "${YELLOW}⊘ 跳过${NC}"
    fi
else
    echo -e "1. OpenRouter: ${GREEN}已设置${NC} (${OPENROUTER_API_KEY:0:12}...)"
fi

# DeepSeek Key
if [ -z "${DEEPSEEK_API_KEY:-}" ]; then
    echo -n "2. DeepSeek 官方 API Key: "
    read -t 30 -r DEEPSEEK_INPUT || DEEPSEEK_INPUT=""
    if [ -n "$DEEPSEEK_INPUT" ]; then
        export DEEPSEEK_API_KEY="$DEEPSEEK_INPUT"
        echo -e "${GREEN}✓ 已设置${NC}"
    else
        echo -e "${YELLOW}⊘ 跳过${NC}"
    fi
else
    echo -e "2. DeepSeek: ${GREEN}已设置${NC} (${DEEPSEEK_API_KEY:0:12}...)"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 检查是否有可用的 API Key
if [ -z "${OPENROUTER_API_KEY:-}" ] && [ -z "${DEEPSEEK_API_KEY:-}" ]; then
    echo -e "${RED}❌ 未配置任何 API Key，无法继续测试${NC}"
    echo ""
    echo "获取 API Keys:"
    echo "  OpenRouter: https://openrouter.ai/keys"
    echo "  DeepSeek:   https://platform.deepseek.com/api_keys"
    echo ""
    exit 1
fi

# 测试函数
test_api() {
    local name="$1"
    local url="$2"
    local model="$3"
    local key="$4"

    echo -e "${BOLD}🧪 测试: $name${NC}"
    echo -e "   模型: $model"
    echo ""

    local success=0
    local total_time=0
    local iterations=3

    for i in $(seq 1 $iterations); do
        echo -n "   [$i/$iterations] "

        local start=$(date +%s.%N)

        local response=$(curl -s -w "\n%{http_code}\n%{time_total}" \
            -X POST "$url" \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $key" \
            -d "{
              \"model\": \"$model\",
              \"messages\": [{\"role\": \"user\", \"content\": \"$TEST_PROMPT\"}],
              \"max_tokens\": 100
            }" 2>&1)

        local end=$(date +%s.%N)
        local elapsed=$(echo "$end - $start" | bc)

        # 解析响应（兼容 macOS）
        local lines=$(echo "$response" | wc -l | tr -d ' ')
        local body_lines=$((lines - 2))
        local body=$(echo "$response" | head -n "$body_lines")
        local http_code=$(echo "$response" | tail -n 2 | head -n 1)

        if [ "$http_code" = "200" ]; then
            local content=$(echo "$body" | jq -r '.choices[0].message.content // empty' 2>/dev/null || echo "")
            if [ -n "$content" ]; then
                echo -e "${GREEN}✓${NC} ${elapsed}s"
                echo "   → $content"
                total_time=$(echo "$total_time + $elapsed" | bc)
                success=$((success + 1))
            else
                echo -e "${RED}✗${NC} 响应解析失败"
            fi
        else
            echo -e "${RED}✗${NC} HTTP $http_code"
        fi
    done

    echo ""
    if [ $success -gt 0 ]; then
        local avg=$(echo "scale=3; $total_time / $success" | bc)
        echo -e "   ${BOLD}平均: ${avg}s${NC}  ($success/$iterations 成功)"

        # 评级
        local fast=$(echo "$avg < 2.0" | bc)
        if [ "$fast" = "1" ]; then
            echo -e "   评级: ${GREEN}🚀 快 (适合 MOSS)${NC}"
        elif $(echo "$avg < 4.0" | bc -l); then
            echo -e "   评级: ${YELLOW}⚡ 中 (可用)${NC}"
        else
            echo -e "   评级: ${RED}🐌 慢 (不推荐)${NC}"
        fi

        echo "$avg"
    else
        echo -e "   ${RED}全部失败${NC}"
        echo "999"
    fi
    echo ""
}

# 运行测试
echo -e "${BOLD}开始测试...${NC}"
echo ""

# 结果存储
declare -a results
declare -a names

# 测试 1: OpenRouter DeepSeek
if [ -n "${OPENROUTER_API_KEY:-}" ]; then
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    time1=$(test_api \
        "OpenRouter - DeepSeek V3.2" \
        "https://openrouter.ai/api/v1/chat/completions" \
        "deepseek/deepseek-v3.2" \
        "$OPENROUTER_API_KEY")
    names+=("OpenRouter DeepSeek")
    results+=("$time1")
fi

# 测试 2: DeepSeek 官方
if [ -n "${DEEPSEEK_API_KEY:-}" ]; then
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    time2=$(test_api \
        "DeepSeek 官方专线" \
        "https://api.deepseek.com/chat/completions" \
        "deepseek-chat" \
        "$DEEPSEEK_API_KEY")
    names+=("DeepSeek 官方")
    results+=("$time2")
fi

# 测试 3: OpenRouter MiniMax
if [ -n "${OPENROUTER_API_KEY:-}" ]; then
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    time3=$(test_api \
        "OpenRouter - MiniMax M2.1" \
        "https://openrouter.ai/api/v1/chat/completions" \
        "minimax/minimax-m2.1" \
        "$OPENROUTER_API_KEY")
    names+=("MiniMax M2.1")
    results+=("$time3")
fi

# 总结
echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}  ${BOLD}📊 测试结果总结${NC}                                             ${CYAN}║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

printf "%-25s %-12s %s\n" "方案" "平均时间" "评级"
echo "─────────────────────────────────────────────────"

best_time=999
best_name=""

for i in "${!names[@]}"; do
    time=${results[$i]}
    name=${names[$i]}

    if [ "$time" != "999" ]; then
        # 评级
        fast=$(echo "$time < 2.0" | bc)
        if [ "$fast" = "1" ]; then
            rating="${GREEN}🚀 快${NC}"
        elif $(echo "$time < 4.0" | bc -l); then
            rating="${YELLOW}⚡ 中${NC}"
        else
            rating="${RED}🐌 慢${NC}"
        fi

        printf "%-25s %-12s %b\n" "$name" "${time}s" "$rating"

        # 找出最快的
        faster=$(echo "$time < $best_time" | bc)
        if [ "$faster" = "1" ]; then
            best_time=$time
            best_name="$name"
        fi
    fi
done

echo ""
echo -e "${BOLD}💡 推荐:${NC}"

if [ -n "$best_name" ]; then
    if [ "$best_name" = "DeepSeek 官方" ]; then
        echo -e "${GREEN}  ✅ 使用 DeepSeek 官方专线 - 最快的方案！${NC}"
        echo ""
        echo "  配置方式:"
        echo "  1. 设置环境变量:"
        echo "     export DEEPSEEK_API_KEY=\"your-key\""
        echo ""
        echo "  2. 在 OpenClaw 中使用:"
        echo "     model: \"deepseek-chat\""
        echo "     baseUrl: \"https://api.deepseek.com\""
    elif [ "$best_name" = "OpenRouter DeepSeek" ]; then
        echo -e "${GREEN}  ✅ 使用 OpenRouter DeepSeek${NC}"
        echo ""
        echo "  MOSS 配置:"
        echo "  model: \"deepseek/deepseek-v3.2\""
        echo ""
        echo "  其他任务: 使用智能路由"
    elif [ "$best_name" = "MiniMax M2.1" ]; then
        echo -e "${YELLOW}  ⚠️  MiniMax 最快，但这是编程专用模型${NC}"
        echo ""
        echo "  建议:"
        echo "  - MOSS: 使用 DeepSeek"
        echo "  - 编程任务: 使用 MiniMax M2.1"
    fi
else
    echo -e "${RED}  ❌ 所有测试均失败${NC}"
    echo "  请检查 API Keys 是否正确"
fi

echo ""
echo "详细日志: $LOG_FILE"
