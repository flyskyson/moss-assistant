#!/bin/bash

# OpenClaw 开机自动启动配置脚本

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

PLIST_SOURCE="$HOME/clawd/com.clawd.start-all.plist"
PLIST_TARGET="$HOME/Library/LaunchAgents/com.clawd.start-all.plist"

# ========================================
# 显示信息
# ========================================
show_info() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}  ${BOLD}OpenClaw 开机自动启动配置${NC}                                     ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${BOLD}   Auto-Start Configuration${NC}                                    ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    echo -e "${BOLD}功能:${NC}"
    echo "  ✓ 系统启动后自动启动 OpenClaw Gateway"
    echo "  ✓ 自动启动主动性引擎"
    echo "  ✓ 延迟30秒启动（等待系统就绪）"
    echo ""
}

# ========================================
# 安装自动启动
# ========================================
install_autostart() {
    show_info

    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}📋 安装开机自动启动${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    # 检查plist文件
    if [ ! -f "$PLIST_SOURCE" ]; then
        echo -e "${RED}❌ 找不到plist文件: $PLIST_SOURCE${NC}"
        exit 1
    fi

    # 复制plist文件
    cp "$PLIST_SOURCE" "$PLIST_TARGET"
    echo -e "${GREEN}✅${NC} 已复制配置文件"

    # 加载launchd agent
    echo ""
    echo "加载 launchd 配置..."

    # 先卸载旧版本（如果存在）
    launchctl unload "$PLIST_TARGET" 2>/dev/null || true
    sleep 1

    # 加载新版本
    launchctl load "$PLIST_TARGET"
    echo -e "${GREEN}✅${NC} launchd agent 已加载"

    # 测试启动脚本
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}🧪 测试启动脚本${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    if [ -f "$HOME/clawd/scripts/start-all.sh" ]; then
        echo "执行: $HOME/clawd/scripts/start-all.sh"
        echo ""
        bash "$HOME/clawd/scripts/start-all.sh"
    else
        echo -e "${YELLOW}⚠️  启动脚本未找到${NC}"
    fi

    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}✅ 安装完成${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    echo -e "${BOLD}配置信息:${NC}"
    echo "  配置文件: $PLIST_TARGET"
    echo "  启动脚本: $HOME/clawd/scripts/start-all.sh"
    echo ""

    echo -e "${BOLD}下次开机时:${NC}"
    echo "  ✓ OpenClaw Gateway 将自动启动"
    echo "  ✓ 主动性引擎将自动启动"
    echo "  ✓ 延迟30秒启动（等待系统就绪）"
    echo ""

    echo -e "${BOLD}管理命令:${NC}"
    echo "  查看状态: launchctl list | grep clawd"
    echo "  查看日志: tail -f ~/clawd/proactive-data/start-all-*.log"
    echo "  停止服务: launchctl stop com.clawd.start-all"
    echo "  卸载服务: launchctl unload $PLIST_TARGET"
    echo ""

    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}  ${BOLD}🎉 开机自动启动已配置！${NC}                                      ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${BOLD}系统重启后将自动启动所有服务${NC}                                ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
}

# ========================================
# 卸载自动启动
# ========================================
uninstall_autostart() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}🛑 卸载开机自动启动${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    if [ ! -f "$PLIST_TARGET" ]; then
        echo -e "${YELLOW}⚠️  未安装自动启动${NC}"
        exit 0
    fi

    # 停止服务
    launchctl stop com.clawd.start-all 2>/dev/null || true
    sleep 1

    # 卸载服务
    launchctl unload "$PLIST_TARGET"
    echo -e "${GREEN}✅${NC} 已卸载 launchd agent"

    # 删除配置文件
    rm -f "$PLIST_TARGET"
    echo -e "${GREEN}✅${NC} 已删除配置文件"

    echo ""
    echo -e "${GREEN}✅ 开机自动启动已完全卸载${NC}"
}

# ========================================
# 查看状态
# ========================================
show_status() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}📊 自动启动状态${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    if launchctl list | grep -q "com.clawd.start-all"; then
        echo -e "${GREEN}✅${NC} 开机自动启动已安装"
        echo ""
        echo "服务信息:"
        launchctl list | grep clawd
        echo ""
        echo "配置文件: $PLIST_TARGET"
    else
        echo -e "${YELLOW}⚠️  开机自动启动未安装${NC}"
        echo ""
        echo "安装命令:"
        echo "  $0 install"
    fi
}

# ========================================
# 测试启动
# ========================================
test_start() {
    echo -e "${BOLD}🧪 测试启动脚本${NC}"
    echo ""

    if [ -f "$HOME/clawd/scripts/start-all.sh" ]; then
        bash "$HOME/clawd/scripts/start-all.sh"
    else
        echo -e "${RED}❌ 启动脚本未找到${NC}"
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
        show_status
        ;;
    test)
        test_start
        ;;
    *)
        echo "用法: $0 <command>"
        echo ""
        echo "命令:"
        echo "  install   - 安装开机自动启动"
        echo "  uninstall - 卸载开机自动启动"
        echo "  status    - 查看状态"
        echo "  test      - 测试启动脚本"
        echo ""
        echo "示例:"
        echo "  $0 install"
        echo "  $0 status"
        echo "  $0 uninstall"
        exit 0
        ;;
esac
