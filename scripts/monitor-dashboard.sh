#!/bin/bash
# OpenClaw 监控面板

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║     OpenClaw 实时监控面板              ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
echo ""

# Gateway 状态
echo -e "${BLUE}🔧 Gateway 状态${NC}"
if pgrep -x "openclaw-gateway" > /dev/null; then
    pid=$(pgrep -x "openclaw-gateway")
    mem=$(ps -o rss= -p $pid | awk '{printf "%.2f", $1/1024}')
    echo -e "  ${GREEN}✓ 运行中${NC} (PID: $pid, 内存: ${mem}MB)"
else
    echo -e "  ${RED}✗ 未运行${NC}"
fi
echo ""

# main 状态
echo -e "${BLUE}📊 Agent: main${NC}"
main_session=$(ls -lh ~/.openclaw/agents/main/sessions/sessions.json 2>/dev/null | awk '{print $5}')
main_active=$(find ~/.openclaw/agents/main/sessions -name "*.jsonl" -type f 2>/dev/null | wc -l | tr -d ' ')
echo -e "  会话: ${main_session}"
echo -e "  活跃会话数: ${main_active}"
echo ""

# main-fresh 状态
echo -e "${BLUE}📊 Agent: main-fresh${NC}"
fresh_session=$(ls -lh ~/.openclaw/agents/main-fresh/sessions/sessions.json 2>/dev/null | awk '{print $5}')
fresh_active=$(find ~/.openclaw/agents/main-fresh/sessions -name "*.jsonl" -type f 2>/dev/null | wc -l | tr -d ' ')
echo -e "  会话: ${fresh_session}"
echo -e "  活跃会话数: ${fresh_active}"
echo ""

# test-agent 状态
echo -e "${BLUE}📊 Agent: test-agent${NC}"
test_session=$(ls -lh ~/.openclaw/agents/test-agent/sessions/sessions.json 2>/dev/null | awk '{print $5}')
test_active=$(find ~/.openclaw/agents/test-agent/sessions -name "*.jsonl" -type f 2>/dev/null | wc -l | tr -d ' ')
echo -e "  会话: ${test_session}"
echo -e "  活跃会话数: ${test_active}"
echo ""

# 系统资源
echo -e "${BLUE}💻 系统资源${NC}"
cpu=$(top -l 1 | grep "CPU usage" | awk '{print $3}' | sed 's/%//')
mem=$(top -l 1 | grep "PhysMem" | awk '{print $2}')
echo -e "  CPU: ${cpu}%"
echo -e "  内存: ${mem}"
echo ""

# 最新监控日志
echo -e "${CYAN}📋 最近监控日志${NC}"
if [ -f "/Users/lijian/clawd-test-logs/phase2-step3-monitor/latest.log" ]; then
    tail -5 /Users/lijian/clawd-test-logs/phase2-step3-monitor/latest.log
else
    echo -e "  ${YELLOW}暂无监控日志${NC}"
fi
echo ""

echo -e "${CYAN}更新时间: $(date '+%H:%M:%S')${NC}"
echo -e "${YELLOW}按 Ctrl+C 退出${NC}"
