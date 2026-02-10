#!/bin/bash
# OpenClaw 自动刷新监控
# 每 10 秒刷新一次

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

while true; do
    clear
    echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║   OpenClaw 实时监控 (自动刷新)         ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
    echo ""

    # Gateway 状态
    echo -e "${BLUE}🔧 Gateway${NC}"
    if pgrep -x "openclaw-gateway" > /dev/null; then
        pid=$(pgrep -x "openclaw-gateway")
        mem=$(ps -o rss= -p $pid | awk '{printf "%.2f", $1/1024}')
        echo -e "  ${GREEN}✓ 运行中${NC} PID:$pid 内存:${mem}MB"
    else
        echo -e "  ${RED}✗ 未运行${NC}"
    fi
    echo ""

    # Agents 状态
    echo -e "${BLUE}📊 Agents${NC}"
    for agent in main main-fresh test-agent; do
        session=$(ls -lh ~/.openclaw/agents/$agent/sessions/sessions.json 2>/dev/null | awk '{print $5}')
        active=$(find ~/.openclaw/agents/$agent/sessions -name "*.jsonl" -type f 2>/dev/null | wc -l | tr -d ' ')
        printf "  %-15s 会话:%-8s 活跃:%s\n" "$agent" "$session" "$active"
    done
    echo ""

    # 系统资源
    echo -e "${BLUE}💻 系统${NC}"
    cpu=$(top -l 1 | grep "CPU usage" | awk '{print $3}' | sed 's/%//')
    mem_used=$(vm_stat | grep "Pages free" | awk '{print $3}' | sed 's/\.//')
    echo -e "  CPU: ${cpu}%"
    echo -e "  内存: ${mem_used}"
    echo ""

    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}更新: $(date '+%H:%M:%S')${NC} ${YELLOW}| 10秒刷新 | Ctrl+C 退出${NC}"

    sleep 10
done
