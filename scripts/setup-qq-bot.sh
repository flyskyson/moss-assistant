#!/bin/bash
#
# OpenClaw QQ 机器人自动化配置脚本
# 日期：2026-02-08
#

set -e

echo "🤖 OpenClaw QQ 机器人配置向导"
echo "==========================="
echo ""
echo "本脚本将帮您配置 QQ 机器人与 OpenClaw 的双向交互。"
echo ""

# 检查 Docker
echo "🔍 检查 Docker..."
if ! command -v docker &> /dev/null; then
    echo "❌ Docker 未安装"
    echo ""
    echo "请先安装 Docker："
    echo "  brew install --cask docker"
    echo ""
    exit 1
fi
echo "✅ Docker 已安装"

# 检查 Docker 是否运行
if ! docker ps &> /dev/null; then
    echo "❌ Docker 未运行"
    echo ""
    echo "请启动 Docker Desktop 应用"
    exit 1
fi
echo "✅ Docker 运行正常"
echo ""

# 获取 QQ 号
while true; do
    read -p "请输入您的 QQ 号: " QQ_NUMBER
    if [ -n "$QQ_NUMBER" ]; then
        break
    fi
    echo "❌ QQ 号不能为空，请重新输入"
done

# 创建配置目录
echo ""
echo "📁 创建配置目录..."
mkdir -p ~/napcat/config
mkdir -p ~/.openclaw/channels/qq
echo "✅ 配置目录已创建"

# 创建 NapCat 配置
echo ""
echo "📝 创建 NapCat 配置..."
cat > ~/napcat/config/config.json << EOF
{
  "qq": "$QQ_NUMBER",
  "password": "",
  "loginType": 2,
  "ws_port": 3000,
  "http_port": 6099,
  "heartbeat": {
    "enable": true,
    "interval": 30000
  }
}
EOF
echo "✅ NapCat 配置已创建: ~/napcat/config/config.json"

# 停止并删除旧容器（如果存在）
echo ""
echo "🔄 清理旧容器..."
if docker ps -a | grep -q napcat; then
    echo "  停止旧容器..."
    docker stop napcat 2>/dev/null || true
    docker rm napcat 2>/dev/null || true
    echo "  ✅ 旧容器已清理"
fi

# 拉取最新镜像
echo ""
echo "⬇️ 拉取 NapCat Docker 镜像..."
echo "（这可能需要几分钟，取决于您的网络速度）"
if ! docker pull mlikiowa/napcat-docker:latest; then
    echo "❌ 镜像拉取失败"
    echo ""
    echo "可能的原因："
    echo "  1. 网络连接问题"
    echo "  2. Docker Hub 访问受限"
    echo ""
    echo "请检查网络后重试"
    exit 1
fi
echo "✅ 镜像拉取完成"

# 运行容器
echo ""
echo "🚀 启动 NapCat 容器..."
docker run -d \
  --name napcat \
  --restart=unless-stopped \
  -p 3000:3000 \
  -p 6099:6099 \
  -v ~/napcat/config:/app/config \
  mlikiowa/napcat-docker:latest

if [ $? -eq 0 ]; then
    echo "✅ NapCat 容器已启动"
else
    echo "❌ 容器启动失败"
    echo ""
    echo "请查看日志："
    echo "  docker logs napcat"
    exit 1
fi

# 等待容器启动
echo ""
echo "⏳ 等待 NapCat 启动..."
sleep 5

# 检查容器状态
if docker ps | grep -q napcat; then
    echo "✅ NapCat 运行正常"
else
    echo "❌ NapCat 启动失败"
    echo ""
    echo "查看日志："
    echo "  docker logs napcat"
    exit 1
fi

# 查看日志
echo ""
echo "📄 NapCat 日志："
echo "-------------------"
docker logs napcat | tail -20
echo "-------------------"
echo ""

# 检查是否有二维码
if [ -f ~/napcat/config/qrcode.png ]; then
    echo "✅ 二维码已生成"
    echo ""
    read -p "是否打开二维码？(y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        open ~/napcat/config/qrcode.png
        echo "✅ 二维码已打开"
        echo ""
        echo "请使用手机 QQ 扫码登录"
    fi
else
    echo "⏳ 等待二维码生成..."
    echo "   请在 NapCat 应用界面中扫码登录"
fi

# 等待用户登录
echo ""
echo "⏳ 请使用手机 QQ 扫码登录"
echo "   登录后，按 Enter 继续..."
read

# 再次检查容器状态
echo ""
echo "🔍 检查登录状态..."
docker logs napcat | tail -10

echo ""
read -p "确认已登录成功？(y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ 请先完成 QQ 登录"
    echo ""
    echo "查看日志："
    echo "  docker logs -f napcat"
    exit 1
fi

# 创建 OpenClaw QQ 配置
echo ""
echo "📝 创建 OpenClaw QQ 通道配置..."
cat > ~/.openclaw/channels/qq/config.json << EOF
{
  "enabled": true,
  "mode": "websocket",
  "endpoint": "ws://localhost:3000",
  "credentials": {
    "qq": "$QQ_NUMBER"
  },
  "features": {
    "privateChat": true,
    "groupChat": true,
    "messageType": ["text", "image", "face"]
  },
  "agent": "main"
}
EOF
echo "✅ OpenClaw 配置已创建: ~/.openclaw/channels/qq/config.json"

# 验证配置
if command -v python3 &> /dev/null; then
    if python3 -m json.tool ~/.openclaw/channels/qq/config.json > /dev/null 2>&1; then
        echo "✅ 配置文件 JSON 格式验证通过"
    else
        echo "❌ 配置文件 JSON 格式错误"
        exit 1
    fi
fi

# 重启 OpenClaw Gateway
echo ""
echo "🔄 重启 OpenClaw Gateway..."
openclaw gateway restart > /dev/null 2>&1

# 等待启动
echo "⏳ 等待 Gateway 启动..."
sleep 5

# 检查状态
if openclaw gateway status > /dev/null 2>&1; then
    echo "✅ Gateway 运行正常"
else
    echo "❌ Gateway 启动失败"
    echo ""
    echo "查看日志："
    echo "  openclaw gateway logs --follow"
    exit 1
fi

# 完成
echo ""
echo "🎉 QQ 机器人配置完成！"
echo ""
echo "📋 后续步骤："
echo "1. 在 QQ 中发送测试消息：你好"
echo "2. 查看 Gateway 日志：openclaw gateway logs --follow"
echo "3. 查看 NapCat 日志：docker logs -f napcat"
echo ""
echo "📖 详细文档：docs/qq-bot-configuration-guide.md"
echo ""
echo "❓ 需要帮助？"
echo "   查看日志: openclaw gateway logs --follow"
echo "   运行诊断: openclaw doctor --fix"
echo "   检查状态: ~/clawd/scripts/check-qq-bot.sh"
echo ""
