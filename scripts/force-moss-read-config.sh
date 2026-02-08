#!/bin/bash

echo "=================================="
echo "强制 MOSS 读取新配置"
echo "=================================="
echo ""

echo "🔍 步骤 1: 完全停止 Gateway"
openclaw gateway stop
sleep 2

# 杀死所有残留进程
pkill -f "openclaw.*gateway" 2>/dev/null
sleep 1

echo ""
echo "🗑️  步骤 2: 清除所有会话缓存"
rm -rf /Users/lijian/.openclaw/agents/main/sessions/
echo "会话已清除"

echo ""
echo "🚀 步骤 3: 重新安装并启动 Gateway"
openclaw gateway install
sleep 2
openclaw gateway start
sleep 5

echo ""
echo "✅ 步骤 4: 验证配置"
echo "检查 AGENTS.md："
if grep -q "Tavily" /Users/lijian/clawd/AGENTS.md; then
    echo "  ✅ AGENTS.md 包含 Tavily 说明"
else
    echo "  ❌ AGENTS.md 缺少 Tavily 说明"
fi

echo ""
echo "检查 SOUL.md："
if grep -q "Tavily" /Users/lijian/clawd/SOUL.md; then
    echo "  ✅ SOUL.md 包含 Tavily 说明"
else
    echo "  ❌ SOUL.md 缺少 Tavily 说明"
fi

echo ""
echo "检查 TOOLS.md："
if grep -q "Tavily" /Users/lijian/clawd/TOOLS.md; then
    echo "  ✅ TOOLS.md 包含 Tavily API Key"
else
    echo "  ❌ TOOLS.md 缺少 Tavily API Key"
fi

echo ""
echo "🧪 测试步骤："
echo "  1. 打开 http://127.0.0.1:18789/（刷新浏览器）"
echo "  2. **必须发起新对话**（不要继续旧对话）"
echo "  3. 第一句话就说："
echo "     '你现在已经配置了 Tavily 搜索功能，"
echo "      当你需要搜索时，使用命令："
echo "      /Users/lijian/clawd/skills/tavily-search/search.js'"
echo "  4. 然后问：'搜索最新的 AI 新闻'"
echo ""
echo "❌ 如果还是提 Brave API，说明 DeepSeek 模型本身"
echo "   在训练时学习了这些信息，需要明确纠正。"
echo ""
echo "=================================="
