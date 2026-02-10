#!/bin/bash
#
# OpenClaw 钉钉双向交互配置脚本
# 日期：2026-02-08
#

set -e

echo "🤖 OpenClaw 钉钉配置向导"
echo "======================"
echo ""
echo "本脚本将帮您配置钉钉双向交互功能。"
echo ""

# 检查是否已有配置
CONFIG_DIR="$HOME/.openclaw/channels/dingtalk"
CONFIG_FILE="$CONFIG_DIR/config.json"

if [ -f "$CONFIG_FILE" ]; then
    echo "⚠️ 检测到已存在的钉钉配置文件："
    echo "   $CONFIG_FILE"
    echo ""
    read -p "是否覆盖现有配置？(y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ 已取消配置"
        exit 1
    fi

    # 备份现有配置
    BACKUP_DIR="$HOME/clawd/backups/dingtalk-$(date +%Y%m%d%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    cp "$CONFIG_FILE" "$BACKUP_DIR/"
    echo "✅ 已备份现有配置到: $BACKUP_DIR"
fi

# 获取用户输入
echo ""
echo "📝 请输入钉钉应用凭证信息"
echo "（您可以在钉钉开放平台 https://open.dingtalk.com/ 的应用详情页面找到）"
echo ""

# 输入 AppKey
while true; do
    read -p "AppKey (Client ID): " APPKEY
    if [ -n "$APPKEY" ]; then
        break
    fi
    echo "❌ AppKey 不能为空，请重新输入"
done

# 输入 AppSecret
while true; do
    read -p "AppSecret (Client Secret): " APPSECRET
    if [ -n "$APPSECRET" ]; then
        break
    fi
    echo "❌ AppSecret 不能为空，请重新输入"
done

# 确认信息
echo ""
echo "请确认配置信息："
echo "  AppKey:    $APPKEY"
echo "  AppSecret: ${APPSECRET:0:8}..."  # 只显示前8位
echo ""
read -p "确认配置？(y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ 已取消配置"
    exit 1
fi

# 创建配置目录
mkdir -p "$CONFIG_DIR"

# 生成配置文件
cat > "$CONFIG_FILE" << EOF
{
  "enabled": true,
  "mode": "stream",
  "credentials": {
    "appKey": "$APPKEY",
    "appSecret": "$APPSECRET"
  },
  "features": {
    "privateChat": true,
    "groupChat": true,
    "streamMode": true
  },
  "agent": "main"
}
EOF

echo ""
echo "✅ 配置文件已创建: $CONFIG_FILE"
echo ""

# 验证 JSON 格式
if command -v python3 &> /dev/null; then
    if python3 -m json.tool "$CONFIG_FILE" > /dev/null 2>&1; then
        echo "✅ 配置文件 JSON 格式验证通过"
    else
        echo "❌ 配置文件 JSON 格式错误"
        exit 1
    fi
fi

# 重启 Gateway
echo ""
echo "🔄 正在重启 OpenClaw Gateway..."
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
    echo "请查看日志："
    echo "  openclaw gateway logs --follow"
    exit 1
fi

# 完成
echo ""
echo "🎉 钉钉配置完成！"
echo ""
echo "📋 后续步骤："
echo "1. 在钉钉客户端找到您的应用：OpenClaw AI 助手"
echo "2. 发送测试消息：你好"
echo "3. 检查日志：openclaw gateway logs --follow"
echo ""
echo "📖 详细文档：docs/dingtalk-setup-guide.md"
echo ""
echo "❓ 需要帮助？"
echo "   查看日志: openclaw gateway logs --follow"
echo "   运行诊断: openclaw doctor --fix"
echo ""
