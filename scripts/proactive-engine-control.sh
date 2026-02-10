#!/bin/bash

# 主动性引擎启动脚本
# Proactive Engine Startup Script

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

AGENT_ID="${1:-main}"
MODE="${2:-start}"

# ========================================
# 启动主动性引擎
# ========================================
start_engine() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}  ${BOLD}主动性引擎启动${NC}                                               ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${BOLD}   Proactive Engine Startup${NC}                                     ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BOLD}Agent ID:${NC} $AGENT_ID"
    echo ""

    # 检查数据目录
    DATA_DIR="$HOME/clawd/proactive-data"
    mkdir -p "$DATA_DIR"
    echo -e "${GREEN}✅${NC} 数据目录: $DATA_DIR"
    echo ""

    # 检查是否已有实例在运行
    PID_FILE="$DATA_DIR/proactive-engine.pid"
    if [ -f "$PID_FILE" ]; then
        OLD_PID=$(cat "$PID_FILE")
        if ps -p "$OLD_PID" > /dev/null 2>&1; then
            echo -e "${YELLOW}⚠️  主动性引擎已在运行 (PID: $OLD_PID)${NC}"
            echo ""
            read -p "是否停止旧进程并重启？ (y/N): " restart
            if [ "$restart" = "y" ] || [ "$restart" = "Y" ]; then
                echo "停止旧进程..."
                kill "$OLD_PID"
                sleep 2
            else
                echo "取消启动"
                exit 0
            fi
        fi
    fi

    # 生成初始分析报告
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}📊 生成初始分析报告${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    cd "$HOME/clawd"
    python3 scripts/proactive-engine.py "$AGENT_ID" analyze
    echo ""

    # 启动监控守护进程
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}🚀 启动监控守护进程${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    LOG_FILE="$DATA_DIR/proactive-engine.log"
    PID_FILE="$DATA_DIR/proactive-engine.pid"

    nohup python3 scripts/proactive-engine.py "$AGENT_ID" daemon \
        > "$LOG_FILE" 2>&1 \
        &

    ENGINE_PID=$!
    echo $ENGINE_PID > "$PID_FILE"

    echo -e "${GREEN}✅ 主动性引擎已启动${NC}"
    echo ""
    echo -e "${BOLD}进程信息:${NC}"
    echo "  PID: $ENGINE_PID"
    echo "  日志: $LOG_FILE"
    echo "  PID文件: $PID_FILE"
    echo ""

    echo -e "${BOLD}监控功能:${NC}"
    echo "  ✓ 每5分钟收集一次指标"
    echo "  ✓ 自动检测性能问题"
    echo "  ✓ 主动发现优化机会"
    echo "  ✓ 生成分析报告"
    echo ""

    echo -e "${BOLD}管理命令:${NC}"
    echo "  查看日志: tail -f $LOG_FILE"
    echo "  查看状态: cat $PID_FILE"
    echo "  停止引擎: kill $(cat $PID_FILE)"
    echo "  分析报告: python3 scripts/proactive-engine.py $AGENT_ID analyze"
    echo ""

    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}  ${BOLD}🎉 主动性引擎现在运行中...${NC}                                 ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${BOLD}MOSS会主动得到照顾！${NC}                                     ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
}

# ========================================
# 停止主动性引擎
# ========================================
stop_engine() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}🛑 停止主动性引擎${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    PID_FILE="$HOME/clawd/proactive-data/proactive-engine.pid"

    if [ ! -f "$PID_FILE" ]; then
        echo -e "${YELLOW}⚠️  主动性引擎未运行${NC}"
        exit 0
    fi

    PID=$(cat "$PID_FILE")

    if ps -p "$PID" > /dev/null 2>&1; then
        echo "停止进程 (PID: $PID)..."
        kill "$PID"
        sleep 2

        if ps -p "$PID" > /dev/null 2>&1; then
            echo -e "${YELLOW}⚠️  进程未响应，强制停止...${NC}"
            kill -9 "$PID"
        fi

        echo -e "${GREEN}✅ 主动性引擎已停止${NC}"
    else
        echo -e "${YELLOW}⚠️  进程不存在 (PID: $PID)${NC}"
        rm -f "$PID_FILE"
    fi
}

# ========================================
# 查看状态
# ========================================
show_status() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}📊 主动性引擎状态${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    PID_FILE="$HOME/clawd/proactive-data/proactive-engine.pid"

    if [ ! -f "$PID_FILE" ]; then
        echo -e "${YELLOW}⚠️  主动性引擎未运行${NC}"
        echo ""
        echo "启动命令:"
        echo "  $0 start"
        exit 0
    fi

    PID=$(cat "$PID_FILE")

    if ps -p "$PID" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ 主动性引擎运行中${NC}"
        echo ""
        echo "进程信息:"
        echo "  PID: $PID"
        echo "  运行时间: $(ps -p $PID -o etime= | awk '{print $3}' | xargs date -r 2>/dev/null || echo '未知')"
        echo ""

        # 显示最近日志
        LOG_FILE="$HOME/clawd/proactive-data/proactive-engine.log"
        if [ -f "$LOG_FILE" ]; then
            echo "最近日志:"
            tail -5 "$LOG_FILE" | sed 's/^/  /'
        fi
    else
        echo -e "${RED}❌ 进程已停止 (PID文件存在但进程不存在)${NC}"
        rm -f "$PID_FILE"
    fi
}

# ========================================
# 生成报告
# ========================================
generate_report() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}📊 生成分析报告${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    cd "$HOME/clawd"
    python3 scripts/proactive-engine.py "$AGENT_ID" analyze
}

# ========================================
# 主菜单
# ========================================
case "$MODE" in
    start)
        start_engine
        ;;
    stop)
        stop_engine
        ;;
    restart)
        stop_engine
        sleep 1
        start_engine
        ;;
    status)
        show_status
        ;;
    report)
        generate_report
        ;;
    *)
        echo "用法: $0 <agent-id> <command>"
        echo ""
        echo "命令:"
        echo "  start   - 启动主动性引擎"
        echo "  stop    - 停止主动性引擎"
        echo "  restart - 重启主动性引擎"
        echo "  status  - 查看运行状态"
        echo "  report  - 生成分析报告"
        echo ""
        echo "示例:"
        echo "  $0 main start"
        echo "  $0 main stop"
        echo "  $0 main status"
        echo "  $0 main report"
        exit 0
        ;;
esac
