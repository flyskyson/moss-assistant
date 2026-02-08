#!/bin/bash

# 📝 知识库索引更新器
# 用途：自动更新 index.md，添加新文件链接
# 用法：./index-updater.sh [--dry-run]
# Cron: 0 23 * * * /Users/lijian/clawd/scripts/knowledge-evolution/index-updater.sh

set -e

# 配置
BASE_DIR="/Users/lijian/clawd"
INDEX_FILE="$BASE_DIR/index.md"
BACKUP_FILE="$BASE_DIR/index.md.backup.$(date +%Y%m%d%H%M%S)"
LOG_FILE="/tmp/knowledge-index-update.log"

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
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

# DRY-RUN 模式
DRY_RUN=false
if [ "${1:-}" = "--dry-run" ]; then
    DRY_RUN=true
    log_info "运行在 DRY-RUN 模式，不会修改文件"
fi

# 备份 index.md
backup_index() {
    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] 会备份: $INDEX_FILE -> $BACKUP_FILE"
    else
        cp "$INDEX_FILE" "$BACKUP_FILE"
        log_info "已备份 index.md: $BACKUP_FILE"
    fi
}

# 获取所有 Markdown 文件
get_all_files() {
    find "$BASE_DIR" -type f \( -name "*.md" -o -name "*.sh" \) | \
        grep -v node_modules | \
        grep -v ".git" | \
        grep -v "index.md" | \
        grep -v "MEMORY.md" | \
        sort
}

# 解析 index.md 中的现有链接
get_existing_links() {
    grep -oE '\[[^]]+\]\([^)]+\)' "$INDEX_FILE" | \
        sed 's/.*(\(.*\)).*/\1/' | \
        sort -u
}

# 生成文件列表（相对路径）
generate_file_list() {
    local files=()
    while IFS= read -r file; do
        local rel="${file#$BASE_DIR/}"
        files+=("$rel")
    done < <(get_all_files)
    
    printf '%s\n' "${files[@]}"
}

# 检测缺失的文件（index.md 中引用但文件不存在）
detect_missing_files() {
    log_info "检测缺失的文件..."
    
    local missing=()
    local existing_links=$(get_existing_links)
    
    while IFS= read -r link; do
        # 跳过外部链接
        if [[ "$link" =~ ^http ]]; then
            continue
        fi
        
        # 检查文件是否存在
        if [ ! -f "$BASE_DIR/$link" ]; then
            missing+=("$link")
            log_warn "缺失文件: $link"
        fi
    done <<< "$existing_links"
    
    # 输出缺失文件列表
    printf '%s\n' "${missing[@]}"
}

# 检测新文件（index.md 中未引用但文件存在）
detect_new_files() {
    log_info "检测新文件..."
    
    local existing_links=$(get_existing_links)
    local new_files=()
    
    while IFS= read -r file; do
        local rel="${file#$BASE_DIR/}"
        
        # 检查是否已在 index.md 中
        if ! grep -q "($rel)" "$INDEX_FILE" 2>/dev/null; then
            # 排除临时文件和系统文件
            if [[ ! "$rel" =~ node_modules|\.git|index\.md|MEMORY\.md ]]; then
                new_files+=("$rel")
                log_info "发现新文件: $rel"
            fi
        fi
    done < <(get_all_files)
    
    printf '%s\n' "${new_files[@]}"
}

# 更新 index.md
update_index() {
    log_info "开始更新 index.md..."
    
    # 备份
    backup_index
    
    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] 跳过实际更新"
        return
    fi
    
    # 获取新文件列表
    local new_files=()
    while IFS= read -r file; do
        [ -n "$file" ] && new_files+=("$file")
    done < <(detect_new_files)
    
    if [ ${#new_files[@]} -eq 0 ]; then
        log_info "没有发现需要添加的新文件"
        return
    fi
    
    log_info "发现 ${#new_files[@]} 个新文件需要添加"
    
    # 这里应该实现实际的更新逻辑
    # 由于 index.md 结构复杂，建议手动审阅后更新
    
    echo ""
    log_info "建议添加以下文件到 index.md："
    echo ""
    
    for file in "${new_files[@]}"; do
        echo "  - [$file]($file)"
    done
    
    echo ""
    log_warn "由于 index.md 结构复杂，请手动审阅后添加"
}

# 生成索引健康报告
generate_health_report() {
    echo ""
    echo "📊 索引健康报告 - $(date '+%Y-%m-%d %H:%M')"
    echo "=========================================="
    echo ""
    
    # 统计 index.md 中的链接
    local total_links=$(grep -oE '\[[^]]+\]\([^)]+\)' "$INDEX_FILE" | wc -l)
    echo "📎 index.md 中的链接总数: $total_links"
    echo ""
    
    # 检测缺失文件
    local missing_count=0
    while IFS= read -r link; do
        [ -n "$link" ] && ((missing_count++))
    done < <(detect_missing_files)
    
    if [ $missing_count -gt 0 ]; then
        echo "❌ 缺失的文件: $missing_count"
    else
        echo "✅ 所有引用的文件都存在"
    fi
    echo ""
    
    # 检测新文件
    local new_count=0
    while IFS= read -r link; do
        [ -n "$link" ] && ((new_count++))
    done < <(detect_new_files)
    
    if [ $new_count -gt 0 ]; then
        echo "🆕 发现新文件（未在 index.md 中）: $new_count"
    else
        echo "✅ 没有发现新文件"
    fi
    echo ""
}

# 主逻辑
main() {
    echo "📝 知识库索引更新器"
    echo "=================="
    echo ""
    
    log_info "开始检查知识库索引..."
    
    # 生成健康报告
    generate_health_report
    
    # 检测新文件
    echo "🆕 新文件检测："
    local new_files=()
    while IFS= read -r file; do
        [ -n "$file" ] && new_files+=("$file")
    done < <(detect_new_files)
    
    if [ ${#new_files[@]} -gt 0 ]; then
        echo ""
        echo "建议添加到 index.md："
        for file in "${new_files[@]}"; do
            echo "  - [$file]($file)"
        done
    else
        echo "  没有发现需要添加的新文件"
    fi
    echo ""
    
    # 检测缺失文件
    echo "❌ 缺失文件检测："
    local missing_files=()
    while IFS= read -r file; do
        [ -n "$file" ] && missing_files+=("$file")
    done < <(detect_missing_files)
    
    if [ ${#missing_files[@]} -gt 0 ]; then
        echo "  以下文件被引用但不存在："
        for file in "${missing_files[@]}"; do
            echo "    - $file"
        done
    else
        echo "  所有引用的文件都存在"
    fi
    echo ""
    
    # 更新选项
    if [ "$DRY_RUN" = false ]; then
        echo "💡 提示：使用 --dry-run 模式预览更改而不实际修改文件"
        echo ""
        read -p "是否要更新 index.md？(y/n): " confirm
        
        if [ "$confirm" = "y" ]; then
            update_index
        else
            log_info "已取消更新"
        fi
    fi
    
    log_info "索引检查完成"
}

main "$@"