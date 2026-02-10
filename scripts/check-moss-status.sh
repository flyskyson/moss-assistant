#!/bin/bash
#
# 快速诊断 MOSS 状态
# 用法: ~/clawd/scripts/check-moss-status.sh
#

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║          🔍 MOSS 快速诊断                                    ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# 1. 检查 Gateway
echo "📊 1. Gateway 状态"
if pgrep -x openclaw-gateway > /dev/null; then
    PID=$(pgrep -x openclaw-gateway)
    echo "   ✅ 运行中 (PID: $PID)"
else
    echo "   ❌ 未运行"
    echo "   💡 启动: openclaw gateway start"
fi
echo ""

# 2. 检查锁文件
echo "🔒 2. Session 锁文件"
if ls ~/.openclaw/agents/main/sessions/*.lock > /dev/null 2>&1; then
    echo "   ⚠️  发现锁文件:"
    ls -lh ~/.openclaw/agents/main/sessions/*.lock | awk '{print "   •", $9, "(" $5 ")"}'
    echo ""
    echo "   💡 删除锁文件:"
    echo "      rm -f ~/.openclaw/agents/main/sessions/*.lock"
else
    echo "   ✅ 无锁文件"
fi
echo ""

# 3. 检查最新对话
echo "💬 3. 最新对话活动"
LAST_MSG=$(tail -1 ~/.openclaw/agents/main/sessions/*.jsonl 2>/dev/null | python3 -c "import sys, json; d=json.loads(sys.stdin.read()); print(d.get('timestamp', '未知')[:19])" 2>/dev/null)
if [ -n "$LAST_MSG" ]; then
    echo "   最后对话: $LAST_MSG"
else
    echo "   ❌ 无法读取对话记录"
fi
echo ""

# 4. Session 大小
echo "📁 4. Session 文件大小"
SESSION_SIZE=$(du -sh ~/.openclaw/agents/main/sessions/ 2>/dev/null | awk '{print $1}')
SESSION_COUNT=$(ls -1 ~/.openclaw/agents/main/sessions/*.jsonl 2>/dev/null | wc -l | tr -d ' ')
echo "   总大小: $SESSION_SIZE"
echo "   文件数: $SESSION_COUNT"

if [ "$SESSION_COUNT" -gt 12 ]; then
    echo "   ⚠️  Session 过多，建议清理"
    echo "   💡 清理: ~/clawd/scripts/agent-rejuvenate-intelligent.sh main clean"
fi
echo ""

# 5. 快速测试
echo "🧪 5. 快速测试"
echo "   发送测试消息..."
START=$(date +%s)
RESPONSE=$(echo "hi" | openclaw agent --agent main --message "测试" 2>&1 | grep -i "MOSS\|助手\|你好" | head -1)
END=$(date +%s)
DURATION=$((END - START))

if [ $DURATION -lt 30 ]; then
    echo "   ✅ 响应正常 (${DURATION} 秒)"
else
    echo "   ⚠️  响应较慢 (${DURATION} 秒)"
fi
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 诊断完成"
