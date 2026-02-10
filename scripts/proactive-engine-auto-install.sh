#!/bin/bash

# 主动性引擎自动启动配置脚本
# Proactive Engine Auto-Start Configuration Script

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

PLIST_SOURCE="$HOME/clawd/com.clawd.proactive-engine.plist"
PLIST_TARGET="$HOME/Library/LaunchAgents/com.clawd.proactive-engine.plist"
DATA_DIR="$HOME/clawd/proactive-data"

# ========================================
# 安装自动启动
# ========================================
install_autostart() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}  ${BOLD}主动性引擎自动启动安装${NC}                                     ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${BOLD}   Proactive Engine Auto-Start Installation${NC}                   ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    # 检查plist文件
    if [ ! -f "$PLIST_SOURCE" ]; then
        echo -e "${RED}❌ 找不到plist文件: $PLIST_SOURCE${NC}"
        exit 1
    fi

    # 创建数据目录
    mkdir -p "$DATA_DIR"
    echo -e "${GREEN}✅${NC} 数据目录: $DATA_DIR"
    echo ""

    # 复制plist文件到LaunchAgents目录
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}📋 安装 launchd 配置文件${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    cp "$PLIST_SOURCE" "$PLIST_TARGET"
    echo -e "${GREEN}✅${NC} 已复制到: $PLIST_TARGET"
    echo ""

    # 加载launchd agent
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}🚀 加载并启动服务${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    # 先卸载旧版本（如果存在）
    if launchctl list | grep -q "com.clawd.proactive-engine"; then
        echo "卸载旧版本..."
        launchctl unload "$PLIST_TARGET" 2>/dev/null || true
        sleep 1
    fi

    # 加载新版本
    launchctl load "$PLIST_TARGET"
    echo -e "${GREEN}✅${NC} launchd agent 已加载"
    echo ""

    # 启动服务
    launchctl start com.clawd.proactive-engine 2>/dev/null || echo "服务会自动启动..."
    echo ""

    # 验证状态
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}📊 验证状态${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    if launchctl list | grep -q "com.clawd.proactive-engine"; then
        echo -e "${GREEN}✅${NC} 主动性引擎自动启动已配置"
        echo ""
        echo -e "${BOLD}服务信息:${NC}"
        echo "  Label: com.clawd.proactive-engine"
        echo "  配置文件: $PLIST_TARGET"
        echo "  日志文件: $DATA_DIR/launchd-*.log"
        echo ""

        echo -e "${BOLD}管理命令:${NC}"
        echo "  查看状态: launchctl list | grep proactive-engine"
        echo "  停止服务: launchctl stop com.clawd.proactive-engine"
        echo "  卸载服务: launchctl unload $PLIST_TARGET"
        echo "  重新加载: launchctl unload $PLIST_TARGET && launchctl load $PLIST_TARGET"
        echo ""

        echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}║${NC}  ${BOLD}🎉 主动性引擎现在会自动启动！${NC}                               ${CYAN}║${NC}"
        echo -e "${CYAN}║${NC}  ${BOLD}系统重启后会自动运行${NC}                                         ${CYAN}║${NC}"
        echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    else
        echo -e "${YELLOW}⚠️  服务可能未成功启动${NC}"
        echo ""
        echo "查看日志:"
        echo "  tail -f $DATA_DIR/launchd-stderr.log"
    fi
}

# ========================================
# 卸载自动启动
# ========================================
uninstall_autostart() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}🛑 卸载自动启动${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    if [ ! -f "$PLIST_TARGET" ]; then
        echo -e "${YELLOW}⚠️  未安装自动启动${NC}"
        exit 0
    fi

    # 停止服务
    launchctl stop com.clawd.proactive-engine 2>/dev/null || true
    sleep 1

    # 卸载服务
    launchctl unload "$PLIST_TARGET"
    echo -e "${GREEN}✅${NC} 已卸载 launchd agent"
    echo ""

    # 删除plist文件
    rm -f "$PLIST_TARGET"
    echo -e "${GREEN}✅${NC} 已删除配置文件"
    echo ""

    echo -e "${GREEN}✅ 自动启动已完全卸载${NC}"
}

# ========================================
# 查看状态
# ========================================
show_autostart_status() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}📊 自动启动状态${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    if launchctl list | grep -q "com.clawd.proactive-engine"; then
        echo -e "${GREEN}✅${NC} 自动启动已安装"
        echo ""
        echo "服务信息:"
        launchctl list | grep proactive-engine
        echo ""
        echo "配置文件: $PLIST_TARGET"
    else
        echo -e "${YELLOW}⚠️  自动启动未安装${NC}"
        echo ""
        echo "安装命令:"
        echo "  $0 install"
    fi
}

# ========================================
# 主菜单
# ========================================
case "${1:-install}" in
    install)
        install_autostart
        ;;
    uninstall)
        uninstall_autostart
        ;;
    status)
        show_autostart_status
        ;;
    *)
        echo "用法: $0 <command>"
        echo ""
        echo "命令:"
        echo "  install   - 安装自动启动"
        echo "  uninstall - 卸载自动启动"
        echo "  status    - 查看状态"
        echo ""
        echo "示例:"
        echo "  $0 install"
        echo "  $0 status"
        echo "  $0 uninstall"
        exit 0
        ;;
esac
