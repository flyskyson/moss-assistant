#!/bin/bash
#
# QQ 机器人启动脚本
# 日期：2026-02-08
#

echo "🤖 QQ 机器人启动脚本"
echo "==================="
echo ""

# 检查 Go-CQHTTP 是否已安装
if [ ! -f "$HOME/gocqhttp/go-cqhttp" ]; then
    echo "❌ Go-CQHTTP 未找到"
    echo "   请先下载并解压到 ~/gocqhttp/"
    exit 1
fi

# 检查是否已在运行
if pgrep -f "go-cqhttp" > /dev/null; then
    echo "⚠️  Go-CQHTTP 已在运行"
    echo ""
    read -p "是否重启？(y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🔄 正在停止现有进程..."
        pkill go-cqhttp
        sleep 2
    else
        echo "❌ 已取消启动"
        exit 0
    fi
fi

# 进入工作目录
cd ~/gocqhttp

echo "🚀 启动 Go-CQHTTP..."
echo ""
echo "📱 启动后请使用手机 QQ 扫码登录"
echo "📄 日志将保存到: ~/gocqhttp/go-cqhttp.log"
echo ""
echo "按 Ctrl+C 停止服务"
echo ""

# 启动 Go-CQHTTP
./go-cqhttp
