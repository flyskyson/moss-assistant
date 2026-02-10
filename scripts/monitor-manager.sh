#!/bin/bash
# OpenClaw 监控管理脚本
# 用于查看和控制实时监控

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

MONITOR_PID_FILE="/Users/lijian/clawd-test-logs/phase2-step3-monitor/.monitor_pid"
LOG_DIR="/Users/lijian/clawd-test-logs/phase2-step3-monitor"

case "${1:-status}" in
    start)
        echo -e "${CYAN}🚀 启动实时监控...${NC}"
        nohup ~/clawd/scripts/step3-realtime-monitor.sh > "$LOG_DIR/monitor.log" 2>&1 &
        pid=$!
        echo $pid > "$MONITOR_PID_FILE"
        echo "✅ 监控已启动 (PID: $pid)"
        echo "   停止命令: $0 stop"
        ;;

    stop)
        if [ -f "$MONITOR_PID_FILE" ]; then
            pid=$(cat "$MONITOR_PID_FILE")
            kill $pid 2>/dev/null
            rm -f "$MONITOR_PID_FILE"
            echo -e "${GREEN}✅ 监控已停止 (PID: $pid)${NC}"
        else
            echo -e "${YELLOW}⚠️  监控未运行${NC}"
        fi
        ;;

    status)
        echo -e "${CYAN}📊 监控状态${NC}"
        echo "==========="
        echo ""

        # 检查监控进程
        if ps -p "$([ -f "$MONITOR_PID_FILE" ] && cat "$MONITOR_PID_FILE")" 2>/dev/null | grep -q grep; then
            echo -e "${GREEN}✅ 监控运行中${NC}"
        else
            echo -e "${YELLOW}⚠️  监控未运行${NC}"
        fi
        echo ""

        # 显示系统状态
        echo "🔧 Gateway状态:"
        if pgrep -x "openclaw-gateway" > /dev/null; then
            pid=$(pgrep -x "openclaw-gateway")
            mem=$(ps -o rss= -p $pid | awk '{printf "%.2f", $1/1024}')
            echo "  ✅ 运行中 (PID: $pid, 内存: ${mem}MB)"
        else
            echo "  ❌ 未运行"
        fi
        echo ""

        echo "📊 Agent会话状态:"
        for agent in main main-fresh main-new; do
            size=$(ls -lh ~/.openclaw/agents/$agent/sessions/sessions.json 2>/dev/null | awk '{print $5}')
            echo "  $agent: $size"
        done
        echo ""

        echo "📄 最近监控日志:"
        if [ -f "$LOG_DIR/monitor.log" ]; then
            tail -5 "$LOG_DIR/monitor.log"
        else
            echo "  （暂无日志）"
        fi
        ;;

    log)
        echo -e "${CYAN}📄 监控日志${NC}"
        echo "=============="
        echo ""
        if [ -f "$LOG_DIR/monitor.log" ]; then
            tail -20 "$LOG_DIR/monitor.log"
        else
            echo "日志文件不存在"
        fi
        ;;

    tail)
        echo -e "${CYAN}📄 实时日志跟踪${NC}"
        echo "=================="
        echo "按 Ctrl+C 退出"
        echo ""
        if [ -f "$LOG_DIR/monitor.log" ]; then
            tail -f "$LOG_DIR/monitor.log"
        else
            echo "日志文件不存在"
        fi
        ;;

    *)
        echo "OpenClaw 监控管理脚本"
        echo ""
        echo "用法: $0 {start|stop|status|log|tail}"
        echo ""
        echo "命令:"
        echo "  start  - 启动实时监控"
        echo "  stop   - 停止实时监控"
        echo "  status - 查看监控状态"
        echo "  log    - 查看监控日志"
        echo "  tail   - 实时跟踪日志"
        echo ""
        exit 1
        ;;
esac
