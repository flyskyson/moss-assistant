#!/bin/bash
# OpenClaw 步骤3实时监控脚本
# 监控 main 和 main-fresh 的系统状态

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# 配置
LOG_DIR="/Users/lijian/clawd-test-logs/phase2-step3-monitor"
AGENT1="main"
AGENT2="main-fresh"
ALERT_SIZE_MB=50
ALERT_RESPONSE_MS=100

# 创建日志目录
mkdir -p "$LOG_DIR"

echo -e "${CYAN}🔍 OpenClaw 实时监控${NC}"
echo "===================="
echo "开始时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo "监控间隔: 30秒"
echo ""

# 函数：获取文件大小（KB）
get_file_size_kb() {
    local file=$1
    if [ -f "$file" ]; then
        # macOS
        size=$(stat -f%z "$file" 2>/dev/null)
        if [ -n "$size" ]; then
            echo $(( size / 1024 ))
        fi
    fi
}

# 函数：格式化大小
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

# 函数：监控Agent状态
monitor_agent() {
    local agent=$1
    local session_file="$HOME/.openclaw/agents/$agent/sessions/sessions.json"

    echo -e "${BLUE}📊 $agent 状态:${NC}"

    # 会话文件大小
    if [ -f "$session_file" ]; then
        size=$(stat -f%z "$session_file" 2>/dev/null || stat -c%s "$session_file" 2>/dev/null)
        if [ -n "$size" ]; then
            formatted=$(format_size $size)
            echo "  会话文件: $formatted"

            # 告警检查
            if [ $size -gt $(($ALERT_SIZE_MB * 1048576)) ]; then
                echo -e "    ${RED}⚠️  告警: 超过 ${ALERT_SIZE_MB}MB 阈值${NC}"
            fi
        fi
    else
        echo "  会话文件: 不存在"
    fi

    # 内存使用（如果进程存在）
    # 注意：OpenClaw agents 不一定有独立进程
    # 这里监控Gateway的整体内存
}

# 函数：监控Gateway状态
monitor_gateway() {
    echo -e "${CYAN}🔧 Gateway 状态:${NC}"

    if pgrep -x "openclaw-gateway" > /dev/null; then
        gateway_pid=$(pgrep -x "openclaw-gateway")
        mem_kb=$(ps -o rss= -p $gateway_pid | tr -d ' ')
        mem_mb=$(awk "BEGIN {printf \"%.2f\", $mem_kb/1024}")
        cpu=$(ps -o %cpu= -p $gateway_pid | tr -d ' ')

        echo -e "  ${GREEN}运行中${NC} (PID: $gateway_pid)"
        echo "  内存: ${mem_mb} MB"
        echo "  CPU: ${cpu}%"
    else
        echo -e "  ${RED}未运行${NC}"
    fi
}

# 函数：监控系统资源
monitor_system() {
    echo -e "${CYAN}💻 系统资源:${NC}"

    # CPU使用率（macOS）
    cpu_usage=$(top -l 1 | grep "CPU usage" | awk '{print $3}' | sed 's/%//')
    echo "  CPU: ${cpu_usage}%"

    # 内存使用
    memory_pressure=$(ps -A -o %mem | awk '{s+=$1} END {printf "%.1f", s}')
    echo "  内存使用: ${memory_pressure}%"

    # 磁盘使用
    disk_usage=$(df -h "$HOME" | tail -1 | awk '{print $5}')
    echo "  磁盘使用: $disk_usage"
}

# 函数：记录监控日志
log_monitor_data() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local log_file="$LOG_DIR/monitor-$(date +%Y%m%d).log"

    echo "[$timestamp] Agent状态检查" >> "$log_file"

    # 记录会话大小
    for agent in "$AGENT1" "$AGENT2"; do
        local session_file="$HOME/.openclaw/agents/$agent/sessions/sessions.json"
        if [ -f "$session_file" ]; then
            size=$(stat -f%z "$session_file" 2>/dev/null || echo "0")
            echo "  $agent: $size bytes" >> "$log_file"
        fi
    done
}

# 主监控循环
main() {
    local iteration=0
    local max_iterations=480  # 30秒间隔 * 480 = 4小时

    echo "按 Ctrl+C 停止监控"
    echo ""

    while [ $iteration -lt $max_iterations ]; do
        clear
        echo -e "${CYAN}🔍 OpenClaw 实时监控 - 第 $((iteration + 1)) 次检查${NC}"
        echo "=================================="
        echo "时间: $(date '+%Y-%m-%d %H:%M:%S')"
        echo ""

        # 执行监控
        monitor_gateway
        echo ""
        monitor_agent "$AGENT1"
        monitor_agent "$AGENT2"
        echo ""
        monitor_system
        echo ""

        # 记录日志
        log_monitor_data

        # 下次检查倒计时
        echo -e "${BLUE}⏰ 30秒后下次检查...${NC}"

        # 等待30秒
        sleep 30

        iteration=$((iteration + 1))
    done
}

# 执行主流程
main
