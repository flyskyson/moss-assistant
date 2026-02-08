#!/bin/bash

# 🔄 备份恢复脚本
# 用途：从备份恢复知识库数据
# 用法：./restore-backup.sh [daily|weekly|monthly] [日期]

set -e

# 配置
BACKUP_DIR="$HOME/backups"
CLAWD_DIR="$HOME/clawd"
DATE=$(date +%Y-%m-%d)

# 颜色输出
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 显示可用备份
list_backups() {
    echo "📦 可用的备份文件："
    echo ""
    
    for type in daily weekly monthly; do
        local count=$(ls -1 "$BACKUP_DIR/${type}"/*.tar.gz 2>/dev/null | wc -l)
        if [ "$count" -gt 0 ]; then
            echo "  ${type}: ($count 个文件)"
            ls -1t "$BACKUP_DIR/${type}"/*.tar.gz 2>/dev/null | head -5 | while read f; do
                local name=$(basename "$f")
                local size=$(du -h "$f" | cut -f1)
                echo "    - $name ($size)"
            done
            echo ""
        fi
    done
}

# 恢复备份
restore_backup() {
    local type=$1
    local target_date=${2:-$DATE}
    local backup_file="$BACKUP_DIR/${type}/clawd-${type}-${target_date}.tar.gz"
    
    if [ ! -f "$backup_file" ]; then
        log_error "备份文件不存在: $backup_file"
        log_info "使用 'list' 查看可用的备份"
        return 1
    fi
    
    log_info "开始恢复备份: $backup_file"
    log_warn "这将覆盖当前的数据！"
    echo ""
    read -p "确认继续？(y/n): " confirm
    
    if [ "$confirm" != "y" ]; then
        log_info "已取消"
        return 0
    fi
    
    # 创建临时目录
    local temp_dir=$(mktemp -d)
    
    # 解压到临时目录
    log_info "解压备份文件..."
    tar -xzf "$backup_file" -C "$temp_dir"
    
    if [ $? -ne 0 ]; then
        log_error "解压失败"
        rm -rf "$temp_dir"
        return 1
    fi
    
    # 显示恢复内容
    echo ""
    log_info "备份内容："
    find "$temp_dir" -type f -name "*.md" | head -10
    echo ""
    
    # 执行恢复
    log_info "恢复 memory 目录..."
    if [ -d "$temp_dir/memory" ]; then
        cp -r "$temp_dir/memory/"* "$CLAWD_DIR/memory/" 2>/dev/null || true
    fi
    
    log_info "恢复 .openclaw 工作区..."
    if [ -d "$temp_dir/workspace-leader-agent-v2" ]; then
        cp -r "$temp_dir/workspace-leader-agent-v2/"* "$HOME/.openclaw/workspace-leader-agent-v2/" 2>/dev/null || true
    fi
    
    if [ -d "$temp_dir/workspace-utility-agent-v2" ]; then
        cp -r "$temp_dir/workspace-utility-agent-v2/"* "$HOME/.openclaw/workspace-utility-agent-v2/" 2>/dev/null || true
    fi
    
    # 清理
    rm -rf "$temp_dir"
    
    log_info "✅ 恢复完成！"
    log_info "恢复的备份: $backup_file"
}

# 主逻辑
case "${1:-help}" in
    list)
        list_backups
        ;;
    restore)
        restore_backup "${2:-daily}" "${3:-}"
        ;;
    help|*)
        echo "🔄 备份恢复脚本"
        echo ""
        echo "用法："
        echo "  $0 list                    - 列出可用的备份"
        echo "  $0 restore daily 2026-02-08  - 恢复指定备份"
        echo "  $0 help                    - 显示帮助"
        echo ""
        echo "示例："
        echo "  $0 list                    # 查看所有可用备份"
        echo "  $0 restore daily 2026-02-08  # 恢复今天的每日备份"
        echo ""
        ;;
esac