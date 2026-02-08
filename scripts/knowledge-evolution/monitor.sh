#!/bin/bash

# 📡 知识库智能监控器
# 用途：监控知识库目录变化，检测新文件
# 用法：./monitor.sh [json|simple]
# Cron: 0 22 * * * /Users/lijian/clawd/scripts/knowledge-evolution/monitor.sh

set -e

# 配置
BASE_DIR="/Users/lijian/clawd"
WATCH_DIRS=("docs" "projects" "scripts" "skills" "memory")
OUTPUT_FILE="/tmp/knowledge-changes.json"
LOG_FILE="/tmp/knowledge-monitor.log"

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
    echo "[INFO] $(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
    echo "[WARN] $(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# 检测新文件（24小时内修改）
detect_new_files() {
    local dir=$1
    local target="$BASE_DIR/$dir"
    
    if [ ! -d "$target" ]; then
        return
    fi
    
    find "$target" -type f \( -name "*.md" -o -name "*.sh" \) -mtime -1 2>/dev/null
}

# 检测修改的文件（7天内修改）
detect_modified_files() {
    local dir=$1
    local target="$BASE_DIR/$dir"
    
    if [ ! -d "$target" ]; then
        return
    fi
    
    find "$target" -type f \( -name "*.md" -o -name "*.sh" \) -mtime -7 2>/dev/null
}

# 获取文件信息
get_file_info() {
    local file=$1
    local rel_path="${file#$BASE_DIR/}"
    local modified=$(stat -f%m "$file" 2>/dev/null || stat -c%Y "$file")
    local size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file")
    local name=$(basename "$file")
    local ext="${name##*.}"
    
    # 获取标题（如果是 markdown）
    local title=""
    if [ "$ext" = "md" ]; then
        title=$(head -3 "$file" 2>/dev/null | grep -E "^# " | head -1 | sed 's/^# //')
        if [ -z "$title" ]; then
            title="$name"
        fi
    else
        title="$name"
    fi
    
    # 输出 JSON
    cat << EOF
    {
      "path": "$rel_path",
      "name": "$name",
      "title": "$title",
      "extension": "$ext",
      "size": $size,
      "modified": $modified,
      "modified_str": "$(date -r $modified '+%Y-%m-%d %H:%M')"
    }
EOF
}

# 生成 JSON 报告
generate_json_report() {
    local new_files=()
    local modified_files=()
    
    # 检测新文件
    for dir in "${WATCH_DIRS[@]}"; do
        while read file; do
            if [ -n "$file" ]; then
                new_files+=("$file")
            fi
        done < <(detect_new_files "$dir")
    done
    
    # 检测修改的文件
    for dir in "${WATCH_DIRS[@]}"; do
        while read file; do
            if [ -n "$file" ]; then
                # 排除新文件（已经在 new_files 中）
                local is_new=false
                for new_file in "${new_files[@]}"; do
                    if [ "$file" = "$new_file" ]; then
                        is_new=true
                        break
                    fi
                done
                if [ "$is_new" = false ]; then
                    modified_files+=("$file")
                fi
            fi
        done < <(detect_modified_files "$dir")
    done
    
    # 生成 JSON
    echo "{"
    echo "  \"timestamp\": \"$(date -u '+%Y-%m-%dT%H:%M:%SZ')\","
    echo "  \"base_dir\": \"$BASE_DIR\","
    echo "  \"new_files\": ["
    
    local first=true
    for file in "${new_files[@]}"; do
        if [ "$first" = true ]; then
            first=false
        else
            echo ","
        fi
        get_file_info "$file"
    done
    
    echo ""
    echo "  ],"
    echo "  \"modified_files\": ["
    
    first=true
    for file in "${modified_files[@]}"; do
        if [ "$first" = true ]; then
            first=false
        else
            echo ","
        fi
        get_file_info "$file"
    done
    
    echo ""
    echo "  ]"
    echo "}"
}

# 生成简单报告
generate_simple_report() {
    local new_count=0
    local modified_count=0
    
    # 统计新文件
    for dir in "${WATCH_DIRS[@]}"; do
        while read file; do
            if [ -n "$file" ]; then
                ((new_count++))
            fi
        done < <(detect_new_files "$dir")
    done
    
    # 统计修改的文件
    for dir in "${WATCH_DIRS[@]}"; do
        while read file; do
            if [ -n "$file" ]; then
                ((modified_count++))
            fi
        done < <(detect_modified_files "$dir")
    done
    
    echo "📡 知识库监控报告 - $(date '+%Y-%m-%d %H:%M')"
    echo "=========================================="
    echo ""
    echo "🆕 新文件（24小时内）: $new_count"
    echo "📝 修改的文件（7天内）: $modified_count"
    echo ""
    
    if [ $new_count -gt 0 ]; then
        echo "🆕 新文件列表："
        for dir in "${WATCH_DIRS[@]}"; do
            while read file; do
                if [ -n "$file" ]; then
                    local rel="${file#$BASE_DIR/}"
                    echo "   - $rel"
                fi
            done < <(detect_new_files "$dir")
        done
        echo ""
    fi
    
    if [ $modified_count -gt 0 ]; then
        echo "📝 修改的文件列表："
        for dir in "${WATCH_DIRS[@]}"; do
            while read file; do
                if [ -n "$file" ]; then
                    local rel="${file#$BASE_DIR/}"
                    echo "   - $rel"
                fi
            done < <(detect_modified_files "$dir")
        done
        echo ""
    fi
    
    if [ $new_count -eq 0 ] && [ $modified_count -eq 0 ]; then
        echo "✅ 没有发现新文件或修改"
    fi
}

# 主逻辑
main() {
    local format="${1:-simple}"
    
    log_info "开始监控知识库..."
    
    case "$format" in
        json)
            generate_json_report > "$OUTPUT_FILE"
            log_info "JSON 报告已生成: $OUTPUT_FILE"
            cat "$OUTPUT_FILE"
            ;;
        simple|*)
            generate_simple_report
            ;;
    esac
    
    log_info "监控完成"
}

main "$@"