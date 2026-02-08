#!/bin/bash

# 🚀 自动化备份脚本 v2
# 用途：每日自动备份知识库，防止数据丢失
# 用法：./auto-backup.sh [daily|weekly|monthly]
# Cron: 0 3 * * * /Users/lijian/clawd/scripts/auto-backup.sh daily

set -e

# 配置
BACKUP_DIR="$HOME/backups"
CLAWD_DIR="$HOME/clawd"
DATE=$(date +%Y-%m-%d)
LOG_FILE="$BACKUP_DIR/backup.log"

# 初始化日志
echo "========================================" > "$LOG_FILE"
echo "Backup Run: $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_FILE"
echo "========================================" >> "$LOG_FILE"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
    echo "[INFO] $1" >> "$LOG_FILE"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
    echo "[WARN] $1" >> "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    echo "[ERROR] $1" >> "$LOG_FILE"
}

# 备份函数
create_backup() {
    local type=$1
    local filename="clawd-${type}-${DATE}.tar.gz"
    local filepath="$BACKUP_DIR/${type}/${filename}"
    
    log_info "Creating ${type} backup: $filename"
    
    # 创建目录
    mkdir -p "$BACKUP_DIR/${type}"
    
    # 备份 memory 目录（如果存在）
    local memory_args=""
    if [ -d "$CLAWD_DIR/memory" ]; then
        memory_args="memory/"
    fi
    
    # 备份 .openclaw 工作区（只备份存在的目录）
    local workspace_args=""
    for dir in "$HOME/.openclaw/workspace-main" "$HOME/.openclaw/workspace-leader-agent-v2" "$HOME/.openclaw/workspace-utility-agent-v2"; do
        if [ -d "$dir" ]; then
            workspace_args="$workspace_args $(basename $dir)/"
        fi
    done
    
    # 构建 tar 命令
    local tar_cmd="tar -czf '$filepath' --exclude='node_modules' --exclude='.git' --exclude='outputs' --exclude='logs' -C '$CLAWD_DIR'"
    
    # 添加 memory 目录
    if [ -n "$memory_args" ]; then
        tar_cmd="$tar_cmd $memory_args"
    fi
    
    # 添加 .openclaw 工作区
    if [ -n "$workspace_args" ]; then
        tar_cmd="$tar_cmd -C '$HOME/.openclaw' $workspace_args"
    fi
    
    # 执行备份
    eval "$tar_cmd" 2>> "$LOG_FILE"
    
    if [ $? -eq 0 ] && [ -f "$filepath" ]; then
        local size=$(du -h "$filepath" | cut -f1)
        log_info "✅ Backup created: $filename ($size)"
        
        # 更新 latest 软链接
        rm -f "$BACKUP_DIR/${type}/latest"
        ln -s "$filename" "$BACKUP_DIR/${type}/latest"
        
        return 0
    else
        log_error "❌ Backup failed: $filename"
        return 1
    fi
}

# 清理旧备份
cleanup_old() {
    local type=$1
    local days=$2
    
    if [ "$days" -gt 0 ]; then
        local count=$(find "$BACKUP_DIR/${type}" -name "*.tar.gz" -mtime +$days 2>/dev/null | wc -l)
        if [ "$count" -gt 0 ]; then
            find "$BACKUP_DIR/${type}" -name "*.tar.gz" -mtime +$days -delete 2>/dev/null
            log_info "Cleaned up $count old ${type} backups (>$days days)"
        fi
    fi
}

# 验证备份
verify_backup() {
    local filepath="$1"
    
    if [ -f "$filepath" ]; then
        local size=$(stat -f%z "$filepath" 2>/dev/null || stat -c%s "$filepath" 2>/dev/null)
        if [ "$size" -gt 1024 ]; then
            log_info "✅ Backup verified: $(basename $filepath) (${size} bytes)"
            return 0
        else
            log_warn "⚠️ Backup file too small: $(basename $filepath) (${size} bytes)"
            return 1
        fi
    else
        log_error "❌ Backup file not found: $filepath"
        return 1
    fi
}

# 主逻辑
main() {
    local type="${1:-daily}"
    
    log_info "Starting ${type} backup for $CLAWD_DIR..."
    
    # 创建备份
    if create_backup "$type"; then
        # 清理旧备份
        case "$type" in
            daily)
                cleanup_old daily 7
                ;;
            weekly)
                cleanup_old weekly 28
                ;;
            monthly)
                cleanup_old monthly 90
                ;;
        esac
        
        # 验证最新备份
        verify_backup "$BACKUP_DIR/${type}/clawd-${type}-${DATE}.tar.gz"
        
        log_info "🎉 ${type} backup completed successfully!"
        
        # 列出备份
        echo ""
        echo "📦 Current backups:"
        ls -lh "$BACKUP_DIR/${type}/"*.tar.gz 2>/dev/null | tail -5 || echo "  No backups found"
    else
        log_error "Backup failed!"
        exit 1
    fi
}

# 立即运行
main "$@"