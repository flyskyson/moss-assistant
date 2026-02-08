#!/bin/bash

# 智能自然语言转 Cron 表达式工具
# 不需要外部 API，使用规则引擎

generate_cron() {
    local input="$1"
    local cron=""
    local explanation=""
    
    # 转换为小写
    input=$(echo "$input" | tr '[:upper:]' '[:lower:]')
    
    # 每天早上 10 点
    if echo "$input" | grep -E "every.*day.*10.*am|daily.*10.*am|每天.*10.*点|每天早上.*10" > /dev/null; then
        cron="0 10 * * *"
        explanation="每天早上 10:00"
    # 每天早上 9 点
    elif echo "$input" | grep -E "every.*day.*9.*am|daily.*9.*am|每天.*9.*点|每天早上.*9" > /dev/null; then
        cron="0 9 * * *"
        explanation="每天早上 9:00"
    # 每天晚上 10 点
    elif echo "$input" | grep -E "every.*day.*10.*pm|daily.*10.*pm|每天.*晚上.*10|每天.*22.*点" > /dev/null; then
        cron="0 22 * * *"
        explanation="每天晚上 22:00"
    # 每小时
    elif echo "$input" | grep -E "every.*hour|hourly|每小时" > /dev/null; then
        cron="0 * * * *"
        explanation="每小时整点"
    # 每周一早上 10 点
    elif echo "$input" | grep -E "monday.*10.*am|每周一.*10.*点" > /dev/null; then
        cron="0 10 * * 1"
        explanation="每周一早上 10:00"
    # 每月 1 号
    elif echo "$input" | grep -E "every.*month.*1st|每月.*1.*号|每月1号" > /dev/null; then
        cron="0 0 1 * *"
        explanation="每月 1 号 00:00"
    # 每 5 分钟
    elif echo "$input" | grep -E "every.*5.*minute|每.*5.*分钟" > /dev/null; then
        cron="*/5 * * * *"
        explanation="每 5 分钟"
    # 默认：尝试解析时间
    elif echo "$input" | grep -E "([0-9]{1,2}):([0-9]{2})" > /dev/null; then
        local hour=$(echo "$input" | grep -oE "([0-9]{1,2}):([0-9]{2})" | cut -d: -f1)
        local minute=$(echo "$input" | grep -oE "([0-9]{1,2}):([0-9]{2})" | cut -d: -f2)
        cron="0 $hour * * *"
        explanation="每天 $hour:$minute"
    # 无法解析
    else
        echo "❌ 无法理解的时间表达式: $input"
        echo ""
        echo "📖 支持的格式示例："
        echo "  - every day at 10am (每天早上 10 点)"
        echo "  - every hour (每小时)"
        echo "  - monday at 10am (每周一早上 10 点)"
        echo "  - every month on 1st (每月 1 号)"
        echo "  - 10:30 (每天 10:30)"
        return 1
    fi
    
    # 输出结果
    echo "✅ Cron 表达式生成成功！"
    echo ""
    echo "📅 原始输入: $1"
    echo "⏰ Cron 表达式: $cron"
    echo "📝 说明: $explanation"
    echo ""
    echo "💡 下 3 次执行时间："
    
    # 计算下 3 次执行时间
    for i in {1..3}; do
        local next_date=$(gdate -d "+$((i-1)) days" "+%Y-%m-%d $explanation" 2>/dev/null || date -v+$((i-1))d "+%Y-%m-%d $explanation" 2>/dev/null)
        echo "  - $next_date"
    done
    
    return 0
}

# 主程序
if [ -z "$1" ]; then
    echo "🤖 智能自然语言转 Cron 表达式工具"
    echo ""
    echo "用法: $0 \"时间描述\""
    echo ""
    echo "示例:"
    echo "  $0 \"every day at 10am\""
    echo "  $0 \"每天早上10点\""
    echo "  $0 \"every hour\""
    exit 1
fi

generate_cron "$@"
