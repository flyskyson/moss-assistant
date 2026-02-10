#!/bin/bash
# MOSS 快速状态检查

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                    🤖 MOSS 系统状态                           ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# Gateway 状态
echo "📊 Gateway 状态:"
if pgrep -x openclaw-gateway > /dev/null; then
    GATEWAY_PID=$(pgrep -x openclaw-gateway)
    ps -p $GATEWAY_PID -o pid,etime,stat | tail -1 | awk '{print "   PID: " $1 "\n   运行时长: " $2 "\n   状态: " $3}'
else
    echo "   ❌ 未运行"
fi

echo ""

# Reasoning 配置
echo "🧠 Reasoning 配置:"
REASONING=$(python3 -c "import json; f=open('/Users/lijian/.openclaw/openclaw.json'); c=json.load(f); print(c['models']['providers']['deepseek']['models'][0]['reasoning'])" 2>/dev/null)
if [ "$REASONING" = "True" ]; then
    echo "   ✅ Agent 模式 (reasoning=true)"
else
    echo "   ❌ Chat 模式 (reasoning=false)"
fi

echo ""

# Session 数量
echo "📁 Session 数量:"
SESSION_COUNT=$(ls -1 ~/.openclaw/agents/main/sessions/ 2>/dev/null | wc -l | tr -d ' ')
echo "   当前: $SESSION_COUNT 个"

echo ""

# Ollama 状态
echo "🔍 Ollama 状态:"
if pgrep -f "ollama serve" > /dev/null; then
    OLLAMA_PID=$(pgrep -f "ollama serve")
    ps -p $OLLAMA_PID -o etime= | tr -d ' ' | awk '{print "   ✅ 运行中 (" $1 ")"}'
else
    echo "   ❌ 未运行"
fi

echo ""
echo "╚═══════════════════════════════════════════════════════════════╝"
