#!/bin/bash
#
# QQ 机器人状态检查脚本
# 日期：2026-02-08
#

echo "🤖 QQ 机器人状态检查"
echo "==================="
echo ""

# 检查 Docker
if command -v docker &> /dev/null; then
    echo "✅ Docker 已安装"

    # 检查 Docker 是否运行
    if docker ps &> /dev/null; then
        echo "✅ Docker 运行正常"

        # 检查 NapCat 容器
        if docker ps | grep -q napcat; then
            echo "✅ NapCat 容器运行中"

            # 显示容器信息
            echo ""
            echo "📊 NapCat 容器信息："
            docker ps | grep napcat
        else
            echo "❌ NapCat 容器未运行"
            echo "   启动命令："
            echo "   docker start napcat"
        fi
    else
        echo "❌ Docker 未运行"
        echo "   请启动 Docker Desktop"
    fi
else
    echo "❌ Docker 未安装"
    echo "   安装命令：brew install --cask docker"
fi

echo ""

# 检查端口
echo "🔌 端口状态："
if lsof -i :3000 > /dev/null 2>&1; then
    echo "✅ NapCat WebSocket 端口 3000 已开放"
else
    echo "❌ NapCat WebSocket 端口 3000 未开放"
fi

if lsof -i :6099 > /dev/null 2>&1; then
    echo "✅ NapCat HTTP API 端口 6099 已开放"
else
    echo "❌ NapCat HTTP API 端口 6099 未开放"
fi

echo ""

# 检查 OpenClaw
echo "🦞 OpenClaw Gateway："
if openclaw gateway status > /dev/null 2>&1; then
    echo "✅ OpenClaw Gateway 运行中"

    # 检查 QQ 配置
    if [ -f ~/.openclaw/channels/qq/config.json ]; then
        echo "✅ QQ 通道配置存在"

        # 检查是否启用
        if grep -q '"enabled": true' ~/.openclaw/channels/qq/config.json; then
            echo "✅ QQ 通道已启用"

            # 显示 QQ 号
            QQ_NUM=$(grep '"qq"' ~/.openclaw/channels/qq/config.json | head -1 | sed 's/.*: "\(.*\)".*/\1/')
            echo "   QQ 号：$QQ_NUM"
        else
            echo "⚠️ QQ 通道未启用"
        fi
    else
        echo "❌ QQ 通道配置不存在"
        echo "   请运行配置脚本：~/clawd/scripts/setup-qq-bot.sh"
    fi
else
    echo "❌ OpenClaw Gateway 未运行"
    echo "   启动命令：openclaw gateway start"
fi

echo ""
echo "📋 查看日志："
echo "   NapCat:    docker logs -f napcat"
echo "   OpenClaw:  openclaw gateway logs --follow"
echo ""
echo "🔧 常用命令："
echo "   重启 NapCat:    docker restart napcat"
echo "   重启 Gateway:   openclaw gateway restart"
echo "   重新配置:       ~/clawd/scripts/setup-qq-bot.sh"
echo ""
