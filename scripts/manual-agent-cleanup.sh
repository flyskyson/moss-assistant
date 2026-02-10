#!/bin/bash

# 手动Agent清理脚本
# Manual Agent Cleanup Script

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

AGENT_ID="${1:-main}"
SESSION_DIR="$HOME/.openclaw/agents/$AGENT_ID/sessions"
WORKSPACE="$HOME/clawd"

echo -e "${BLUE}=== 手动Agent清理: $AGENT_ID ===${NC}"
echo ""

# ========================================
# 选项1: 查看当前状态
# ========================================
show_status() {
    echo -e "${BOLD}📊 当前状态:${NC}"
    echo ""

    # Session数量
    if [ -d "$SESSION_DIR" ]; then
        SESSION_COUNT=$(ls -1 "$SESSION_DIR"/*.jsonl 2>/dev/null | wc -l)
        SESSION_SIZE=$(du -sh "$SESSION_DIR" 2>/dev/null | cut -f1)

        echo "Session数量: $SESSION_COUNT"
        echo "Session大小: $SESSION_SIZE"
        echo ""

        # 最大的5个session
        echo "最大的5个session文件:"
        ls -lhS "$SESSION_DIR"/*.jsonl 2>/dev/null | head -5 | awk '{print "  " $9 " (" $5 ")"}'
        echo ""
    else
        echo "❌ Agent不存在: $AGENT_ID"
        exit 1
    fi

    # 工作区大小
    if [ -d "$WORKSPACE" ]; then
        WORKSPACE_SIZE=$(du -sh "$WORKSPACE" 2>/dev/null | cut -f1)
        echo "工作区大小: $WORKSPACE_SIZE"
    fi
}

# ========================================
# 选项2: 列出所有session
# ========================================
list_sessions() {
    echo -e "${BOLD}📋 所有Session文件:${NC}"
    echo ""

    if [ -d "$SESSION_DIR" ]; then
        echo "数量 大小       日期                  文件"
        echo "──── ───────── ───────────────────── ─────────────"
        ls -lt "$SESSION_DIR"/*.jsonl 2>/dev/null | awk '{
            size=$5
            date=$6" "$7" "$8
            file=$9
            gsub(/.*\//, "", file)
            printf "%-4s %-10s %-21s %s\n", NR, size, date, file
        }'
    fi
}

# ========================================
# 选项3: 清理旧session
# ========================================
cleanup_old_sessions() {
    local KEEP_COUNT="${1:-10}"

    echo -e "${BOLD}🧹 清理旧Session${NC}"
    echo "保留最近 ${KEEP_COUNT} 个session"
    echo ""

    cd "$SESSION_DIR"
    TOTAL_COUNT=$(ls -1 *.jsonl 2>/dev/null | wc -l)

    if [ $TOTAL_COUNT -le $KEEP_COUNT ]; then
        echo -e "${YELLOW}⚠️  当前session数 ($TOTAL_COUNT) ≤ 保留数 ($KEEP_COUNT)，无需清理${NC}"
        return
    fi

    DELETE_COUNT=$((TOTAL_COUNT - KEEP_COUNT))
    echo "将删除 ${DELETE_COUNT} 个旧session文件"
    echo ""

    read -p "确认删除? (y/N): " confirm
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        echo "已取消"
        return
    fi

    # 创建备份
    BACKUP_DIR="$WORKSPACE/sessions-backup/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    echo "备份到: $BACKUP_DIR"

    # 备份将被删除的文件
    ls -t *.jsonl | tail -n +$((KEEP_COUNT + 1)) | while read file; do
        cp "$file" "$BACKUP_DIR/"
    done

    # 删除旧文件
    ls -t *.jsonl | tail -n +$((KEEP_COUNT + 1)) | xargs rm -f

    echo -e "${GREEN}✅ 已删除 ${DELETE_COUNT} 个旧session${NC}"
    echo -e "${GREEN}✅ 备份位置: $BACKUP_DIR${NC}"
}

# ========================================
# 选项4: 清理特定session
# =================================#
cleanup_specific_session() {
    echo -e "${BOLD}🗑️  清理特定Session${NC}"
    echo ""

    list_sessions
    echo ""

    read -p "输入要删除的session编号 (多个用空格分隔): " numbers

    if [ -z "$numbers" ]; then
        echo "已取消"
        return
    fi

    cd "$SESSION_DIR"
    FILES_TO_DELETE=()

    for num in $numbers; do
        FILE=$(ls -t *.jsonl 2>/dev/null | sed -n "${num}p")
        if [ -n "$FILE" ]; then
            FILES_TO_DELETE+=("$FILE")
        fi
    done

    if [ ${#FILES_TO_DELETE[@]} -eq 0 ]; then
        echo "❌ 无效的编号"
        return
    fi

    echo ""
    echo "将删除以下文件:"
    for file in "${FILES_TO_DELETE[@]}"; do
        echo "  - $file"
    done

    echo ""
    read -p "确认删除? (y/N): " confirm

    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        echo "已取消"
        return
    fi

    # 备份
    BACKUP_DIR="$WORKSPACE/sessions-backup/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"

    for file in "${FILES_TO_DELETE[@]}"; do
        cp "$file" "$BACKUP_DIR/"
        rm -f "$file"
        echo -e "${GREEN}✅ 已删除: $file${NC}"
    done

    echo ""
    echo -e "${GREEN}✅ 备份位置: $BACKUP_DIR${NC}"
}

# ========================================
# 选项5: 清理大文件session
# ========================================
cleanup_large_sessions() {
    local SIZE_THRESHOLD="${1:-1M}"  # 默认1MB

    echo -e "${BOLD}🗑️  清理大Session (> ${SIZE_THRESHOLD})${NC}"
    echo ""

    cd "$SESSION_DIR"

    # 查找大文件
    LARGE_FILES=$(find . -name "*.jsonl" -size +${SIZE_THRESHOLD} -type f)

    if [ -z "$LARGE_FILES" ]; then
        echo -e "${YELLOW}⚠️  没有找到 > ${SIZE_THRESHOLD} 的session文件${NC}"
        return
    fi

    echo "找到以下大文件:"
    echo ""
    echo "大小       文件"
    echo "──────── ─────────────"
    ls -lh $LARGE_FILES | awk '{printf "%-10s %s\n", $5, $9}'
    echo ""

    read -p "删除这些大文件? (y/N): " confirm

    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        echo "已取消"
        return
    fi

    # 备份并删除
    BACKUP_DIR="$WORKSPACE/sessions-backup/large-files-$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"

    echo ""
    for file in $LARGE_FILES; do
        cp "$file" "$BACKUP_DIR/"
        rm -f "$file"
        echo -e "${GREEN}✅ 已删除: $file${NC}"
    done

    echo ""
    echo -e "${GREEN}✅ 备份位置: $BACKUP_DIR${NC}"
}

# ========================================
# 选项6: 清理工作区临时文件
# ========================================
cleanup_workspace() {
    echo -e "${BOLD}🧹 清理工作区${NC}"
    echo ""

    # 临时文件
    if [ -d "$WORKSPACE/temp" ]; then
        TEMP_SIZE=$(du -sh "$WORKSPACE/temp" 2>/dev/null | cut -f1)
        rm -rf "$WORKSPACE/temp"/*
        echo -e "${GREEN}✅ 临时文件已清理 (大小: $TEMP_SIZE)${NC}"
    else
        echo "⚠️  没有temp目录"
    fi

    # 备份文件
    if [ -d "$WORKSPACE/backups" ]; then
        BACKUP_SIZE=$(du -sh "$WORKSPACE/backups" 2>/dev/null | cut -f1)
        echo ""
        read -p "清理备份文件? (大小: $BACKUP_SIZE) (y/N): " confirm
        if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
            rm -rf "$WORKSPACE/backups"/*
            echo -e "${GREEN}✅ 备份文件已清理${NC}"
        fi
    fi
}

# ========================================
# 主菜单
# ========================================
show_menu() {
    echo ""
    echo -e "${BOLD}请选择操作:${NC}"
    echo ""
    echo "  1) 查看当前状态"
    echo "  2) 列出所有session"
    echo "  3) 清理旧session (保留最近N个)"
    echo "  4) 清理特定session"
    echo "  5) 清理大session (>1MB)"
    echo "  6) 清理工作区临时文件"
    echo "  7) 全部清理 (3+5+6)"
    echo "  0) 退出"
    echo ""
    read -p "选择 (0-7): " choice

    case $choice in
        1)
            show_status
            ;;
        2)
            list_sessions
            ;;
        3)
            read -p "保留最近多少个session? (默认10): " keep
            cleanup_old_sessions "${keep:-10}"
            ;;
        4)
            cleanup_specific_session
            ;;
        5)
            read -p "大小阈值? (默认1M，可指定如500K、2M): " threshold
            cleanup_large_sessions "${threshold:-1M}"
            ;;
        6)
            cleanup_workspace
            ;;
        7)
            echo -e "${BOLD}执行全部清理...${NC}"
            echo ""
            cleanup_old_sessions 10
            echo ""
            cleanup_large_sessions 1M
            echo ""
            cleanup_workspace
            echo ""
            echo -e "${GREEN}✅ 全部清理完成！${NC}"
            ;;
        0)
            echo "退出"
            exit 0
            ;;
        *)
            echo -e "${RED}❌ 无效选择${NC}"
            ;;
    esac
}

# ========================================
# 主程序
# ========================================
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "用法: $0 [agent-id]"
    echo ""
    echo "示例:"
    echo "  $0 main          # 交互式菜单"
    echo ""
    exit 0
fi

# 如果有参数，直接显示状态后进入菜单
show_status

# 循环菜单
while true; do
    show_menu
done
