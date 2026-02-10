#!/bin/bash
#
# 清理 Session 锁文件脚本
# 用法: ~/clawd/scripts/clear-session-locks.sh
#

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║          🔒 Session 锁文件清理工具                            ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# 查找锁文件
LOCK_FILES=$(find ~/.openclaw/agents/main/sessions -name "*.lock" -type f 2>/dev/null)

if [ -z "$LOCK_FILES" ]; then
    echo "✅ 没有发现锁文件"
    echo ""
    echo "Session 状态正常！"
    exit 0
fi

echo "⚠️  发现锁文件:"
echo "$LOCK_FILES" | while read lock_file; do
    echo ""
    echo "📁 文件: $lock_file"

    # 显示文件大小和时间
    ls -lh "$lock_file" | awk '{print "   大小: " $5}'
    stat -f "   修改时间: %Sm" -t "%Y-%m-%d %H:%M:%S" "$lock_file" 2>/dev/null || \
    stat -c "   修改时间: %y" "$lock_file" 2>/dev/null

    # 尝试读取 PID
    if [ -r "$lock_file" ]; then
        PID=$(grep -o "pid":[0-9]* "$lock_file" 2>/dev/null | head -1 | cut -d: -f2)
        if [ -n "$PID" ]; then
            echo "   关联 PID: $PID"

            # 检查进程是否还在运行
            if ps -p "$PID" > /dev/null 2>&1; then
                echo "   状态: ⚠️  进程仍在运行"
                echo "   建议: 检查进程是否正常，谨慎删除"
            else
                echo "   状态: ✅ 进程已结束（安全删除）"
            fi
        fi
    fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
read -p "是否删除这些锁文件？(yes/no): " confirm

if [ "$confirm" = "yes" ] || [ "$confirm" = "y" ]; then
    echo ""
    echo "正在删除锁文件..."
    echo "$LOCK_FILES" | while read lock_file; do
        rm -f "$lock_file"
        echo "  ✅ 已删除: $(basename "$lock_file")"
    done
    echo ""
    echo "✅ 锁文件清理完成！"
    echo ""
    echo "💡 建议:"
    echo "  • 重启 Gateway 确保状态正常: openclaw gateway restart"
    echo "  • 或继续使用，系统会自动处理"
else
    echo ""
    echo "❌ 已取消清理"
    echo ""
    echo "💡 如果稍后要手动删除:"
    echo "  rm -f ~/.openclaw/agents/main/sessions/*.lock"
fi
