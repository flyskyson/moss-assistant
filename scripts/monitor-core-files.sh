#!/bin/bash
# 核心配置文件监控脚本
CORE_FILES="IDENTITY.md USER.md SOUL.md TASKS.md HEARTBEAT.md"
BACKUP_DIR="$HOME/clawd/.core-backup"
LOG_DIR="$HOME/clawd/.core-logs"

mkdir -p "$LOG_DIR"

# 检查文件变化
check_changes() {
    for file in $CORE_FILES; do
        if [ -f "$HOME/clawd/$file" ]; then
            current_sum=$(md5sum "$HOME/clawd/$file" 2>/dev/null | awk '{print $1}')
            backup_sum=$(md5sum "$BACKUP_DIR/$file" 2>/dev/null | awk '{print $1}')
            
            if [ "$current_sum" != "$backup_sum" ]; then
                echo "[$(date '+%Y-%m-%d %H:%M:%S')] 检测到变化: $file" >> "$LOG_DIR/changes.log"
                # 创建新备份
                cp "$HOME/clawd/$file" "$BACKUP_DIR/$file.backup.$(date +%Y%m%d-%H%M%S)"
            fi
        fi
    done
}

check_changes