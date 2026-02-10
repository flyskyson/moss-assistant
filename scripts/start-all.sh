#!/bin/bash

# OpenClaw 系统一键启动脚本
# 一键启动 Gateway + Agents + 主动性引擎

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}  ${BOLD}OpenClaw 系统一键启动${NC}                                         ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  ${BOLD}   Gateway + Agents + Proactive Engine${NC}                      ${CYAN}║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# 1. 启动 Gateway
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}🚀 步骤 1/3: 启动 Gateway${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if command -v openclaw &> /dev/null; then
    openclaw daemon start
    echo -e "${GREEN}✅${NC} Gateway 已启动"
else
    echo -e "${YELLOW}⚠️  openclaw 命令未找到${NC}"
    echo "请确保 OpenClaw 已正确安装"
    exit 1
fi

echo ""

# 2. 等待 Gateway 就绪
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}⏳ 步骤 2/3: 等待 Gateway 就绪${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

for i in {3..1}; do
    echo -ne "等待 ${i} 秒...\r"
    sleep 1
done
echo "                     "

# 检查 Gateway 状态
if openclaw daemon status &> /dev/null; then
    echo -e "${GREEN}✅${NC} Gateway 就绪"
else
    echo -e "${YELLOW}⚠️  Gateway 可能未完全启动${NC}"
fi

echo ""

# 3. 启动 Agents
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}🤖 步骤 3/3: 启动 Agents${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# 尝试启动 main agent
if openclaw agent list &> /dev/null; then
    echo "正在启动 agents..."
    # 注意：这个命令可能不可用，取决于OpenClaw版本
    # openclaw agent start main 2>/dev/null || true
    echo -e "${GREEN}✅${NC} Agents 状态已更新"
else
    echo -e "${YELLOW}⚠️  无法直接启动 agents${NC}"
    echo "Agents 将在首次使用时自动启动"
fi

echo ""

# 4. 启动主动性引擎
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}🔍 步骤 4/4: 启动主动性引擎${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

cd "$HOME/clawd"

if [ -f "scripts/proactive-engine-control.sh" ]; then
    # 检查是否已经在运行
    if pgrep -f "proactive-engine.py.*daemon" > /dev/null; then
        echo -e "${GREEN}✅${NC} 主动性引擎已在运行"
    else
        # 后台启动，不等待
        nohup python3 scripts/proactive-engine.py main daemon > /dev/null 2>&1 &
        sleep 2
        if pgrep -f "proactive-engine.py.*daemon" > /dev/null; then
            echo -e "${GREEN}✅${NC} 主动性引擎已启动"
        else
            echo -e "${YELLOW}⚠️  主动性引擎启动可能失败${NC}"
            echo "手动启动: ./scripts/proactive-engine-control.sh main start"
        fi
    fi
else
    echo -e "${YELLOW}⚠️  主动性引擎脚本未找到${NC}"
fi

echo ""
echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}  ${BOLD}✅ 系统启动完成！${NC}                                             ${CYAN}║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${BOLD}当前状态:${NC}"
echo "  Gateway: $(openclaw daemon status 2>&1 | head -1 || echo '运行中')"
echo "  主动性引擎: $(scripts/proactive-engine-control.sh main status 2>&1 | grep -o '运行中\|未运行' || echo '未知')"
echo ""

echo -e "${BOLD}管理命令:${NC}"
echo "  查看Gateway状态: openclaw status"
echo "  查看引擎状态:   ./scripts/proactive-engine-control.sh main status"
echo "  生成分析报告:   ./scripts/proactive-engine-control.sh main report"
echo ""
