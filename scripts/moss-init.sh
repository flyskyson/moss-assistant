#!/bin/bash
# MOSS 对话初始化快捷命令（备用方案）
# 使用方法：在终端输入 mi，然后粘贴给 MOSS
# 用途：当自动初始化失败时使用，或测试 MOSS 是否正确读取所有文件

# 获取今天的日期
TODAY=$(date +%Y-%m-%d)

# 生成完整的初始化提示
INIT_MESSAGE="你好！请执行完整初始化（测试用）：

**请按顺序读取以下文件**：
1. SOUL.md - 重新认识你是谁
2. USER.md - 重新认识你的用户
3. index.md - 查看知识库导航（⭐ 重要）
4. TASKS.md - 查看任务清单（⭐ 重要）
5. 今天的记忆文件 - memory/${TODAY}.md
6. MEMORY.md - 长期记忆

**完成后，请告诉我**：
- 你是谁（简短的自我介绍）
- 每日例行任务有哪些（从 TASKS.md）
- 今天有什么计划（从今天的记忆文件）
- 知识库中有哪些项目（从 index.md）"

# 复制到剪贴板（macOS）
if command -v pbcopy &> /dev/null; then
    echo "$INIT_MESSAGE" | pbcopy
    echo "✅ 完整初始化提示已复制到剪贴板！"
    echo ""
    echo "📝 现在可以直接粘贴给 MOSS"
    echo ""
    echo "💡 用途说明："
    echo "   - 备用方案：当说'你好'自动初始化失败时使用"
    echo "   - 测试工具：验证 MOSS 是否正确读取所有文件"
    echo "   - 强制刷新：清除缓存后快速验证配置"
    echo ""
    echo "🔧 如果自动初始化失败，可以先清除会话缓存："
    echo "   rm -rf ~/.openclaw/agents/main/sessions/"
    echo "   openclaw gateway restart"
else
    # Linux 备用方案
    echo "$INIT_MESSAGE"
    echo ""
    echo "⚠️  请手动复制上面的内容"
fi
