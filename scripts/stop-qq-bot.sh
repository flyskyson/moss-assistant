#!/bin/bash
#
# QQ 机器人停止脚本
# 日期：2026-02-08
#

echo "🛑 QQ 机器人停止脚本"
echo "==================="
echo ""

# 检查是否在运行
if pgrep -f "go-cqhttp" > /dev/null; then
    echo "正在停止 Go-CQHTTP..."
    pkill go-cqhttp
    sleep 2

    if pgrep -f "go-cqhttp" > /dev/null; then
        echo "⚠️  进程仍在运行，尝试强制停止..."
        pkill -9 go-cqhttp
        sleep 1
    fi

    if ! pgrep -f "go-cqhttp" > /dev/null; then
        echo "✅ Go-CQHTTP 已停止"
    else
        echo "❌ 无法停止进程"
        echo "   请手动执行: killall go-cqhttp"
    fi
else
    echo "ℹ️  Go-CQHTTP 未运行"
fi

echo ""
echo "💡 提示："
echo "   启动服务: ~/clawd/scripts/start-qq-bot.sh"
echo "   查看日志: tail -f ~/gocqhttp/go-cqhttp.log"
echo ""
