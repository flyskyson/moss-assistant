#!/bin/bash

echo "=================================="
echo "MOSS 缓存问题修复脚本"
echo "=================================="
echo ""

echo "🔄 步骤 1: 停止 Gateway..."
openclaw gateway stop
sleep 2

echo "🗑️  步骤 2: 清除会话缓存..."
rm -f /Users/lijian/.openclaw/agents/main/sessions/sessions.json

echo "🚀 步骤 3: 启动 Gateway..."
openclaw gateway start
sleep 3

echo ""
echo "✅ 修复完成！"
echo ""
echo "📋 当前状态："
echo "  - 搜索技能: tavily-search（唯一）"
echo "  - API Key: tvly-dev-****"
echo "  - 会话缓存: 已清除"
echo "  - Gateway: 运行中"
echo ""
echo "🧪 测试步骤："
echo "  1. 打开 Web UI: http://127.0.0.1:18789/"
echo "  2. 或在飞书发起新对话"
echo "  3. 问：'2026年春节是哪天？'"
echo "  4. 预期：MOSS 调用搜索并给出答案"
echo ""
echo "❌ 不应该再看到："
echo "  - '需要 Brave API'"
echo "  - '无法访问远程仓库文件'"
echo "  - '搜索功能受限'"
echo ""
echo "=================================="
