#!/bin/bash
#
# 测试 MOSS 是否记得核心配置
#

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║          🧪 测试 MOSS 记忆状态                                 ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo "发送测试消息给 MOSS..."
echo ""

# 发送测试消息
RESULT=$(openclaw agent --agent main --message "请简单回答：你知道核心配置文件（HEARTBEAT.md、SOUL.md等）的位置吗？只回答'知道'或'不知道'。" 2>&1)

echo "$RESULT"
echo ""
echo "=== 测试完成 ==="
