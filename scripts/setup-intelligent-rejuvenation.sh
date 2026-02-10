#!/bin/bash

# 智能老化防护 - 自动配置脚本
# Intelligent Anti-Aging - Auto Configuration Script

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

REJUVENATE_SCRIPT="$HOME/clawd/scripts/agent-rejuvenate-intelligent.sh"
CRON_ENTRY="0 3 * * 0 $REJUVENATE_SCRIPT main auto run >> $HOME/clawd/logs/rejuvenation-intelligent.log 2>&1"
CRON_ENTRY_CHECK="0 */6 * * * $REJUVENATE_SCRIPT main auto run >> $HOME/clawd/logs/rejuvenation-intelligent-check.log 2>&1"

# ========================================
# 显示当前配置
# ========================================
show_current() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}📋 当前Cron配置${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    crontab -l 2>/dev/null | grep -E "agent-rejuvenate|proactive" || echo "未找到相关配置"
    echo ""
}

# ========================================
# 安装智能配置
# ========================================
install_intelligent() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}  ${BOLD}智能Agent老化防护 - 安装${NC}                                    ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    # 检查脚本是否存在
    if [ ! -f "$REJUVENATE_SCRIPT" ]; then
        echo -e "${YELLOW}⚠️  智能脚本不存在: $REJUVENATE_SCRIPT${NC}"
        exit 1
    fi

    echo -e "${GREEN}✅${NC} 找到智能脚本"
    echo ""

    # 创建日志目录
    mkdir -p "$HOME/clawd/logs"
    echo -e "${GREEN}✅${NC} 日志目录: $HOME/clawd/logs"
    echo ""

    # 备份当前crontab
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}💾 备份当前Crontab${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    CRON_BACKUP="$HOME/clawd/backups/crontab-backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$(dirname "$CRON_BACKUP")"
    crontab -l > "$CRON_BACKUP" 2>/dev/null || true
    echo -e "${GREEN}✅${NC} 已备份到: $CRON_BACKUP"
    echo ""

    # 移除旧的配置
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}🔄 更新Crontab配置${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    # 创建新的crontab（移除旧的，添加新的）
    {
        # 保留其他cron任务（除了agent-rejuvenate）
        crontab -l 2>/dev/null | grep -v "agent-rejuvenate" || true

        # 添加新的智能配置
        echo "# 智能Agent老化防护 - 每周日凌晨3点"
        echo "$CRON_ENTRY"
        echo ""
        echo "# 智能Agent老化防护 - 每6小时检查一次"
        echo "$CRON_ENTRY_CHECK"
    } | crontab -

    echo -e "${GREEN}✅${NC} Crontab已更新"
    echo ""

    # 显示新配置
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}📋 新的Cron配置${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    crontab -l | grep -E "agent-rejuvenate|智能"
    echo ""

    # 测试运行
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}🧪 测试运行${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    echo "执行: $REJUVENATE_SCRIPT main auto status"
    echo ""
    if "$REJUVENATE_SCRIPT" main auto status; then
        echo ""
        echo -e "${GREEN}✅${NC} 测试成功"
    else
        echo ""
        echo -e "${YELLOW}⚠️  测试失败（可能需要进一步配置）${NC}"
    fi
    echo ""

    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}  ${BOLD}🎉 智能老化防护已安装！${NC}                                     ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BOLD}功能:${NC}"
    echo "  ✓ 每周日凌晨3点: 完整检查和清理"
    echo "  ✓ 每6小时: 智能状态检查"
    echo "  ✓ 基于分析决策: 只在需要时清理"
    echo ""
    echo -e "${BOLD}查看日志:${NC}"
    echo "  tail -f $HOME/clawd/logs/rejuvenation-intelligent.log"
    echo "  tail -f $HOME/clawd/logs/rejuvenation-intelligent-check.log"
    echo ""
    echo -e "${BOLD}手动测试:${NC}"
    echo "  $REJUVENATE_SCRIPT main auto status"
    echo "  $REJUVENATE_SCRIPT main auto run"
}

# ========================================
# 卸载配置
# ========================================
uninstall() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}🛑 卸载智能老化防护${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    # 备份
    CRON_BACKUP="$HOME/clawd/backups/crontab-backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$(dirname "$CRON_BACKUP")"
    crontab -l > "$CRON_BACKUP" 2>/dev/null || true

    # 移除相关配置
    crontab -l 2>/dev/null | grep -v "agent-rejuvenate-intelligent" | crontab -

    echo -e "${GREEN}✅${NC} 已从crontab移除"
    echo ""
    echo -e "${GREEN}✅${NC} 备份保存到: $CRON_BACKUP"
}

# ========================================
# 查看状态
# ========================================
show_status() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}📊 智能老化防护状态${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    # 检查脚本
    if [ -f "$REJUVENATE_SCRIPT" ]; then
        echo -e "${GREEN}✅${NC} 智能脚本: $REJUVENATE_SCRIPT"
    else
        echo -e "${RED}❌${NC} 智能脚本不存在"
    fi
    echo ""

    # 检查cron配置
    if crontab -l 2>/dev/null | grep -q "agent-rejuvenate-intelligent"; then
        echo -e "${GREEN}✅${NC} Cron配置: 已安装"
        echo ""
        echo "定时任务:"
        crontab -l 2>/dev/null | grep "agent-rejuvenate-intelligent" | sed 's/^/  /'
    else
        echo -e "${YELLOW}⚠️  Cron配置: 未安装${NC}"
    fi
    echo ""

    # 检查日志
    if [ -f "$HOME/clawd/logs/rejuvenation-intelligent.log" ]; then
        echo -e "${GREEN}✅${NC} 日志文件: $HOME/clawd/logs/rejuvenation-intelligent.log"
        echo ""
        echo "最近日志:"
        tail -5 "$HOME/clawd/logs/rejuvenation-intelligent.log" | sed 's/^/  /'
    else
        echo -e "${YELLOW}⚠️  日志文件: 不存在${NC}"
    fi
    echo ""

    # 运行状态检查
    if [ -f "$REJUVENATE_SCRIPT" ]; then
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${BOLD}🔍 当前状态${NC}"
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        "$REJUVENATE_SCRIPT" main auto status
    fi
}

# ========================================
# 主菜单
# ========================================
case "${1:-install}" in
    install)
        show_current
        echo ""
        install_intelligent
        ;;
    uninstall)
        uninstall
        ;;
    status)
        show_status
        ;;
    test)
        echo -e "${BOLD}测试运行:${NC}"
        "$REJUVENATE_SCRIPT" main auto status
        ;;
    *)
        echo "用法: $0 <command>"
        echo ""
        echo "命令:"
        echo "  install   - 安装智能老化防护"
        echo "  uninstall - 卸载智能老化防护"
        echo "  status    - 查看状态"
        echo "  test      - 测试运行"
        echo ""
        echo "示例:"
        echo "  $0 install"
        echo "  $0 status"
        echo "  $0 uninstall"
        exit 0
        ;;
esac
