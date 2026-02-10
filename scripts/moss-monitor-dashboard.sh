#!/bin/bash

#############################################
# MOSS 实时监控仪表盘
# 提供清晰的 Agent 动态可视化
#############################################

set -euo pipefail

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# 配置
AGENT_NAME="main"
LOG_FILE="/tmp/openclaw/openclaw-$(date +%Y-%m-%d).log"
GATEWAY_LOG="$HOME/.openclaw/logs/gateway.log"
SESSION_DIR="$HOME/.openclaw/agents/main/sessions"

# 清屏并显示标题
show_header() {
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC} ${BOLD}🤖 MOSS 实时监控仪表盘${NC}                                          ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC} ${BOLD}Agent: ${GREEN}${AGENT_NAME}${NC}                                                ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo -e "${CYAN}📅${NC} $(date '+%Y-%m-%d %H:%M:%S') | ${CYAN}🔄${NC} 自动刷新中... (Ctrl+C 退出)"
    echo ""
}

# 获取 Session 数量
get_session_count() {
    ls -1 "$SESSION_DIR" 2>/dev/null | wc -l | tr -d ' '
}

# 获取今天请求数量
get_today_requests() {
    grep -c "embedded run start:" "$LOG_FILE" 2>/dev/null || echo "0"
}

# 获取当前使用的模型
get_current_model() {
    tail -100 "$GATEWAY_LOG" 2>/dev/null | grep "agent model:" | tail -1 | sed 's/.*agent model: //' || echo "未知"
}

# 获取提供商
get_provider() {
    local model=$(get_current_model)
    if [[ "$model" == *"openrouter"* ]]; then
        echo -e "${YELLOW}OpenRouter${NC}"
    elif [[ "$model" == *"deepseek"* ]]; then
        echo -e "${GREEN}DeepSeek 官方${NC}"
    elif [[ "$model" == *"moonshot"* ]]; then
        echo -e "${CYAN}Moonshot${NC}"
    else
        echo -e "${YELLOW}其他${NC}"
    fi
}

# 获取最近的超时次数
get_recent_timeouts() {
    local count=$(grep -c "timeoutMs=120000" "$LOG_FILE" 2>/dev/null || echo "0")
    if [ "$count" -gt 0 ]; then
        echo -e "${RED}${count}${NC}"
    else
        echo -e "${GREEN}${count}${NC}"
    fi
}

# 获取最近的错误
get_recent_errors() {
    grep -c "logLevelName.*ERROR" "$LOG_FILE" 2>/dev/null || echo "0"
}

# 获取最后一次活动时间
get_last_activity() {
    local last=$(grep "embedded run start:" "$LOG_FILE" 2>/dev/null | tail -1 | grep -o '[0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}' || echo "无")
    echo "$last"
}

# 显示状态卡片
show_status_card() {
    local title="$1"
    local value="$2"
    local status="$3"
    local icon="📊"

    case $status in
        "good")
            color=$GREEN
            icon="✅"
            ;;
        "warning")
            color=$YELLOW
            icon="⚠️ "
            ;;
        "critical")
            color=$RED
            icon="❌"
            ;;
        *)
            color=$CYAN
            icon="📊"
            ;;
    esac

    echo -e "${color}┌─ ${title}${NC}"
    echo -e "${color}│${NC}   ${icon}  ${value}"
    echo -e "${color}└────────────────────${NC}"
}

# 显示详细的 Session 信息
show_sessions_detail() {
    echo -e "${BOLD}📂 Session 详情:${NC"

    local session_count=$(get_session_count)
    local threshold_critical=25
    local threshold_warning=18
    local threshold_normal=12

    echo -e "   数量: ${session_count} 个"
    echo -e "   阈值: "
    echo -e "     • 临界: ${RED}${threshold_critical}${NC} 个"
    echo -e "     • 警告: ${YELLOW}${threshold_warning}${NC} 个"
    echo -e "     • 正常: ${GREEN}${threshold_normal}${NC} 个"

    if [ "$session_count" -ge "$threshold_critical" ]; then
        echo -e "   状态: ${RED}⚠️  临界状态 - 需要立即清理！${NC}"
        echo -e "   建议: ${YELLOW}~/clawd/scripts/agent-rejuvenate-intelligent.sh main clean${NC}"
    elif [ "$session_count" -ge "$threshold_warning" ]; then
        echo -e "   状态: ${YELLOW}⚠️  警告状态 - 建议清理${NC}"
    else
        echo -e "   状态: ${GREEN}✅ 正常${NC}"
    fi
}

# 显示最近的请求历史
show_recent_requests() {
    echo -e "\n${BOLD}📝 最近请求历史 (最新 5 条):${NC}"

    grep "embedded run start:" "$LOG_FILE" 2>/dev/null | tail -5 | while read -r line; do
        if [[ "$line" =~ provider=([^[:space:]]+) ]]; then
            local provider="${BASH_REMATCH[1]}"

            local provider_color=$CYAN
            if [[ "$provider" == "deepseek" ]]; then
                provider_color=$GREEN
            elif [[ "$provider" == "openrouter" ]]; then
                provider_color=$YELLOW
            fi

            local timestamp=$(echo "$line" | grep -o '[0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}')
            echo -e "   [$timestamp] ${provider_color}${provider}${NC}"
        fi
    done
}

# 显示性能统计
show_performance_stats() {
    echo -e "\n${BOLD}⚡ 性能统计:${NC"

    # 计算平均响应时间（从日志中提取）
    local total_time=0
    local count=0

    # 简单统计：查找超时情况
    local timeouts=$(grep -c "timeoutMs=120000" "$LOG_FILE" 2>/dev/null || echo "0")
    local total_requests=$(get_today_requests)

    if [ "$total_requests" -gt 0 ]; then
        local success_rate=$((100 - (timeouts * 100 / total_requests)))
        echo -e "   • 今日请求: ${total_requests} 次"
        echo -e "   • 超时次数: ${timeouts} 次"
        echo -e "   • 成功率: ${success_rate}%"
    else
        echo -e "   • 今日暂无请求数据"
    fi
}

# 显示 Gateway 状态
show_gateway_status() {
    echo -e "\n${BOLD}🌐 Gateway 状态:${NC}"

    if pgrep -f "openclaw-gateway" > /dev/null; then
        local pid=$(pgrep -f "openclaw-gateway")
        echo -e "   • 状态: ${GREEN}✅ 运行中${NC} (PID: $pid)"
        echo -e "   • 地址: http://127.0.0.1:18789"
        echo -e "   • 模型: $(get_current_model)"
        echo -e "   • 提供商: $(get_provider)"
    else
        echo -e "   • 状态: ${RED}❌ 未运行${NC}"
        echo -e "   • 建议: ${YELLOW}openclaw gateway start${NC}"
    fi
}

# 显示主动性引擎状态
show_proactive_engine_status() {
    echo -e "\n${BOLD}🔍 主动性引擎:${NC}"

    if pgrep -f "proactive-engine.py.*daemon" > /dev/null; then
        local pid=$(pgrep -f "proactive-engine.py.*daemon")
        echo -e "   • 状态: ${GREEN}✅ 运行中${NC} (PID: $pid)"
        echo -e "   • 日志: ~/clawd/logs/proactive-engine.log"
    else
        echo -e "   • 状态: ${YELLOW}⚠️  未运行${NC}"
        echo -e "   • 启动: ${YELLOW}~/clawd/scripts/start-all.sh${NC}"
    fi
}

# 主循环
main() {
    # 检查日志文件是否存在
    if [ ! -f "$LOG_FILE" ]; then
        echo -e "${RED}❌ 错误: 日志文件不存在: $LOG_FILE${NC}"
        echo -e "${YELLOW}💡 请确保 OpenClaw Gateway 正在运行${NC}"
        exit 1
    fi

    while true; do
        show_header

        # 状态卡片行
        echo -e "  $(show_status_card "Sessions" "$(get_session_count) 个" "normal")    $(show_status_card "今日请求" "$(get_today_requests) 次" "normal")    $(show_status_card "超时" "$(get_recent_timeouts) 次" "normal")"
        echo ""

        # 详细信息
        show_sessions_detail
        show_gateway_status
        show_proactive_engine_status
        show_performance_stats
        show_recent_requests

        # 操作提示
        echo -e "\n${BOLD}🔧 快速操作:${NC}"
        echo -e "   • 清理 Sessions: ${CYAN}~/clawd/scripts/agent-rejuvenate-intelligent.sh main clean${NC}"
        echo -e "   • 查看完整日志: ${CYAN}tail -f $LOG_FILE${NC}"
        echo -e "   • 打开 Web UI: ${CYAN}http://127.0.0.1:18789${NC}"
        echo -e "   • 运行诊断: ${CYAN}~/clawd/scripts/agent-diagnostic.sh${NC}"
        echo ""

        # 等待 5 秒后刷新
        sleep 5
    done
}

# 捕获 Ctrl+C
trap 'echo -e "\n${YELLOW}👋 监控已停止${NC}"; exit 0' INT

# 运行主函数
main
