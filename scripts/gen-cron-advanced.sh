#!/bin/bash

# 高级自然语言转 Cron 表达式工具 v2.0
# 支持更复杂的表达式

parse_advanced() {
    local input="$1"
    local cron=""
    local explanation=""
    
    input=$(echo "$input" | tr '[:upper:]' '[:lower:]')
    
    # 工作日（周一到周五）
    if echo "$input" | grep -E "weekday|工作日" > /dev/null; then
        if echo "$input" | grep -E "9.*am|9.*点" > /dev/null; then
            cron="0 9 * * 1-5"
            explanation="工作日早上 9:00"
        else
            cron="0 9 * * 1-5"
            explanation="工作日早上 9:00"
        fi
    # 周末
    elif echo "$input" | grep -E "weekend|周末" > /dev/null; then
        if echo "$input" | grep -E "10.*am|10.*点" > /dev/null; then
            cron="0 10 * * 6,0"
            explanation="周末早上 10:00"
        else
            cron="0 10 * * 6,0"
            explanation="周末早上 10:00"
        fi
    # 每天中午 12 点
    elif echo "$input" | grep -E "noon|中午.*12|12.*pm" > /dev/null; then
        cron="0 12 * * *"
        explanation="每天中午 12:00"
    # 每天午夜
    elif echo "$input" | grep -E "midnight|午夜|0.*点" > /dev/null; then
        cron="0 0 * * *"
        explanation="每天午夜 00:00"
    # 每 30 分钟
    elif echo "$input" | grep -E "30.*min|半小时|每30分钟" > /dev/null; then
        cron="*/30 * * * *"
        explanation="每 30 分钟"
    # 每 15 分钟
    elif echo "$input" | grep -E "15.*min|15分钟|每15分钟|quarterly" > /dev/null; then
        cron="*/15 * * * *"
        explanation="每 15 分钟"
    # 每 2 小时
    elif echo "$input" | grep -E "every.*2.*hour|每.*2.*小时" > /dev/null; then
        cron="0 */2 * * *"
        explanation="每 2 小时"
    # 每周（周日）
    elif echo "$input" | grep -E "weekly|每周" > /dev/null; then
        cron="0 10 * * 0"
        explanation="每周日早上 10:00"
    # 每月 1 号早上 9 点
    elif echo "$input" | grep -E "monthly|每月" > /dev/null; then
        cron="0 9 1 * *"
        explanation="每月 1 号早上 9:00"
    # 每天早上 8 点（默认工作时间）
    elif echo "$input" | grep -E "morning|早上" > /dev/null; then
        cron="0 8 * * *"
        explanation="每天早上 8:00"
    # 每天晚上 6 点
    elif echo "$input" | grep -E "evening|晚上.*6|6.*pm" > /dev/null; then
        cron="0 18 * * *"
        explanation="每天晚上 18:00"
    else
        # 使用基础版
        /Users/lijian/clawd/scripts/gen-cron.sh "$input"
        return $?
    fi
    
    echo "✅ Cron 表达式生成成功！"
    echo ""
    echo "📅 原始输入: $1"
    echo "⏰ Cron 表达式: $cron"
    echo "📝 说明: $explanation"
    echo ""
    echo "📋 使用方法："
    echo "  crontab -e"
    echo "  # 添加以下行："
    echo "  $cron /path/to/your/script.sh"
    
    return 0
}

if [ -z "$1" ]; then
    echo "🤖 高级自然语言转 Cron 表达式工具 v2.0"
    echo ""
    echo "用法: $0 \"时间描述\""
    echo ""
    echo "支持的表达式："
    echo "  基础："
    echo "    - every day at 10am (每天早上 10 点)"
    echo "    - every hour (每小时)"
    echo "  高级："
    echo "    - weekday at 9am (工作日早上 9 点)"
    echo "    - weekend at 10am (周末早上 10 点)"
    echo "    - every 30 minutes (每 30 分钟)"
    echo "    - every 2 hours (每 2 小时)"
    echo "    - noon (每天中午)"
    echo "    - midnight (每天午夜)"
    exit 1
fi

parse_advanced "$@"
