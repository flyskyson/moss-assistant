#!/bin/bash
# OpenClaw Multi-Agent 性能监控脚本
# 用于监控 agent 会话大小和性能指标

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 配置
OPENCLAW_DIR="$HOME/.openclaw"
ALERT_SIZE_MB=50  # 告警阈值：50MB
WORKSPACE="$HOME/clawd"

echo "🔍 OpenClaw Multi-Agent 性能监控"
echo "=================================="
echo "检查时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# 函数：格式化文件大小
format_size() {
    local size=$1
    if [ $size -ge 1048576 ]; then
        echo "$(awk "BEGIN {printf \"%.2f\", $size/1048576}") MB"
    elif [ $size -ge 1024 ]; then
        echo "$(awk "BEGIN {printf \"%.2f\", $size/1024}") KB"
    else
        echo "$size B"
    fi
}

# 函数：监控单个 agent
monitor_agent() {
    local agent=$1
    local session_file="$OPENCLAW_DIR/agents/$agent/sessions/sessions.json"

    if [ ! -f "$session_file" ]; then
        return
    fi

    # 获取文件大小（字节）
    local size=$(stat -f%z "$session_file" 2>/dev/null || stat -c%s "$session_file" 2>/dev/null)
    local size_mb=$(awk "BEGIN {printf \"%.2f\", $size/1048576}")

    # 检查是否超过阈值
    if [ $size -gt $(($ALERT_SIZE_MB * 1048576)) ]; then
        echo -e "${RED}🔴 告警${NC}: $agent 会话文件过大: ${size_mb} MB"
        echo "   建议: 运行清理脚本或重启 agent"
    elif [ $size -gt 10485760 ]; then
        echo -e "${YELLOW}⚠️  警告${NC}: $agent 会话文件较大: ${size_mb} MB"
    else
        echo -e "${GREEN}✅ 正常${NC}: $agent 会话文件: $(format_size $size)"
    fi
}

# 监控所有 agents
echo "📊 Agent 会话状态:"
echo "-------------------"
for agent_dir in "$OPENCLAW_DIR/agents"/*/; do
    agent=$(basename "$agent_dir")
    if [ "$agent" != "." ] && [ "$agent" != ".." ]; then
        monitor_agent "$agent"
    fi
done
echo ""

# 工作区统计
echo "📁 工作区统计:"
echo "---------------"
md_count=$(find "$WORKSPACE" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
echo "Markdown 文档: $md_count"

memory_count=$(find "$WORKSPACE/memory" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
echo "记忆文件: $memory_count"

# Gateway 状态
echo ""
echo "🔧 Gateway 状态:"
echo "----------------"
if pgrep -x "openclaw-gateway" > /dev/null; then
    gateway_pid=$(pgrep -x "openclaw-gateway")
    mem_usage=$(ps -o rss= -p $gateway_pid | awk '{printf "%.2f", $1/1024}')
    echo -e "${GREEN}✅ 运行中${NC} (PID: $gateway_pid, 内存: ${mem_usage} MB)"
else
    echo -e "${RED}❌ 未运行${NC}"
fi
echo ""

# 性能建议
echo "💡 性能优化建议:"
echo "-----------------"
if [ "$md_count" -gt 200 ]; then
    echo "- 考虑归档旧文档减少文件系统负担"
fi
if [ "$memory_count" -gt 30 ]; then
    echo "- 考虑清理或归档旧的记忆文件"
fi
echo "- 定期运行此脚本监控性能: $0"
echo "- 如会话文件持续增长，考虑调整 historyLimit 配置"

echo ""
echo "完成时间: $(date '+%Y-%m-%d %H:%M:%S')"
