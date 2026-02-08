#!/bin/bash

# 📊 知识库自优化引擎
# 用途：分析知识库健康状况，生成优化建议
# 用法：./optimizer.sh [--report]
# Cron: 0 0 * * 0 /Users/lijian/clawd/scripts/knowledge-evolution/optimizer.sh  # 每周日午夜

set -e

# 配置
BASE_DIR="/Users/lijian/clawd"
OUTPUT_FILE="/tmp/knowledge-optimization-report.md"
LOG_FILE="/tmp/knowledge-optimizer.log"

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
    echo "[INFO] $(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
    echo "[WARN] $(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

log_section() {
    echo ""
    echo -e "${CYAN}$1${NC}"
    echo "----------------------------------------"
}

# 生成报告模式
REPORT_MODE=false
if [ "${1:-}" = "--report" ]; then
    REPORT_MODE=true
fi

# 统计文件数量
count_files() {
    local dir=$1
    local type=$2
    find "$BASE_DIR/$dir" -type f \( -name "*.md" -o -name "*.sh" \) 2>/dev/null | wc -l | tr -d ' '
}

# 检测长期未修改的文件（90天）
detect_old_files() {
    log_info "检测长期未修改的文件..."
    
    local old_files=()
    
    while IFS= read -r file; do
        local rel="${file#$BASE_DIR/}"
        old_files+=("$rel")
    done < <(find "$BASE_DIR" -type f \( -name "*.md" -o -name "*.sh" \) -mtime +90 2>/dev/null | grep -v node_modules | grep -v ".git")
    
    printf '%s\n' "${old_files[@]}"
}

# 检测新文件（24小时内）
detect_recent_files() {
    log_info "检测新文件..."
    
    local recent_files=()
    
    while IFS= read -r file; do
        local rel="${file#$BASE_DIR/}"
        recent_files+=("$rel")
    done < <(find "$BASE_DIR" -type f \( -name "*.md" -o -name "*.sh" \) -mtime -1 2>/dev/null | grep -v node_modules | grep -v ".git")
    
    printf '%s\n' "${recent_files[@]}"
}

# 检测重复文件（通过内容哈希）
detect_duplicates() {
    log_info "检测重复文件..."
    
    local hashes=()
    local duplicates=()
    
    while IFS= read -r file; do
        # 跳过二进制文件和 node_modules
        if [[ "$file" == *"node_modules"* ]] || [[ "$file" == *".git"* ]]; then
            continue
        fi
        
        # 计算前 10 行的哈希
        local hash=$(head -10 "$file" 2>/dev/null | md5 | cut -d' ' -f1)
        
        # 检查是否已存在
        if [[ " ${hashes[*]} " =~ " $hash " ]]; then
            duplicates+=("$file")
        else
            hashes+=("$hash")
        fi
    done < <(find "$BASE_DIR" -type f -name "*.md" 2>/dev/null)
    
    printf '%s\n' "${duplicates[@]}"
}

# 检测"待创建"标记但已存在的文件
detect_implicitly_created() {
    log_info "检测已自动创建的文件..."
    
    local implicit_files=()
    
    # index.md 中标记为"待创建"的文件
    local pending=$(grep -oE '\[\^[^]]+\]\([^)]+\)' "$BASE_DIR/index.md" 2>/dev/null | wc -l)
    
    echo "$pending"
}

# 生成 Markdown 报告
generate_markdown_report() {
    cat > "$OUTPUT_FILE" << EOF
# 知识库优化报告

**生成时间**: $(date '+%Y-%m-%d %H:%M:%S')

## 📊 总体统计

| 指标 | 数量 |
|------|------|
| 总文件数 | $(find "$BASE_DIR" -type f \( -name "*.md" -o -name "*.sh" \) 2>/dev/null | wc -l) |
| 文档文件 | $(count_files "docs") |
| 项目文件 | $(count_files "projects") |
| 脚本文件 | $(count_files "scripts") |
| 技能文件 | $(count_files "skills") |
| 记忆文件 | $(count_files "memory") |

## 🆕 新文件（24小时内）

$(detect_recent_files | while read f; do echo "- \`$f\`"; done || echo "无")

## ⏰ 长期未修改（90天前）

$(detect_old_files | head -20 | while read f; do echo "- \`$f\`"; done || echo "无")

## 🔍 优化建议

### 建议 1: 清理过期内容
长期未访问的文件可能已经过时，建议：
- 检查并归档超过 90 天未修改的文件
- 更新必要的技术文档

### 建议 2: 整理项目结构
定期审查项目文件的组织结构：
- 确保项目文件位于正确的目录
- 合并重复或相似的内容

### 建议 3: 更新索引
index.md 需要同步更新：
- 添加新创建的文件链接
- 移除已删除文件的引用

## 📝 行动清单

- [ ] 审查长期未修改的文件
- [ ] 更新过时的技术文档
- [ ] 运行 \`./index-updater.sh\` 更新索引
- [ ] 运行 \`./monitor.sh\` 监控系统状态

---
*自动生成 by 知识库自优化引擎*
EOF

    log_info "报告已生成: $OUTPUT_FILE"
}

# 控制台输出
generate_console_report() {
    echo ""
    echo -e "${BLUE}📊 知识库健康分析 - $(date '+%Y-%m-%d %H:%M')${NC}"
    echo "=========================================="
    echo ""
    
    # 统计
    log_section "📈 文件统计"
    echo "  文档: $(count_files "docs") 个"
    echo "  项目: $(count_files "projects") 个"
    echo "  脚本: $(count_files "scripts") 个"
    echo "  技能: $(count_files "skills") 个"
    echo "  记忆: $(count_files "memory") 个"
    echo ""
    
    # 新文件
    log_section "🆕 新文件（24小时内）"
    local recent_count=0
    while IFS= read -r f; do
        [ -n "$f" ] && ((recent_count++))
    done < <(detect_recent_files)
    
    if [ $recent_count -gt 0 ]; then
        echo "  发现 $recent_count 个新文件"
        detect_recent_files | head -5 | while read f; do
            echo "    - $f"
        done
    else
        echo "  没有发现新文件"
    fi
    echo ""
    
    # 旧文件
    log_section "⏰ 长期未修改（90天前）"
    local old_count=0
    while IFS= read -r f; do
        [ -n "$f" ] && ((old_count++))
    done < <(detect_old_files)
    
    if [ $old_count -gt 0 ]; then
        echo "  发现 $old_count 个长期未修改的文件"
        detect_old_files | head -5 | while read f; do
            echo "    - $f"
        done
        echo "    ..."
    else
        echo "  没有发现长期未修改的文件"
    fi
    echo ""
    
    # 优化建议
    log_section "💡 优化建议"
    
    if [ $old_count -gt 0 ]; then
        echo "  ⚠️ 建议审查长期未修改的文件，考虑归档或更新"
    fi
    
    if [ $recent_count -gt 0 ]; then
        echo "  ✅ 新文件已检测，建议更新 index.md"
    fi
    
    echo ""
    echo "  📌 建议操作："
    echo "     1. 运行 \`./index-updater.sh --dry-run\` 检查索引"
    echo "     2. 运行 \`./monitor.sh simple\` 查看变化"
    echo "     3. 审查旧文件并决定是否归档"
    echo ""
}

# 主逻辑
main() {
    log_info "开始知识库健康分析..."
    
    if [ "$REPORT_MODE" = true ]; then
        generate_markdown_report
        echo "✅ 报告已生成: $OUTPUT_FILE"
    else
        generate_console_report
    fi
    
    log_info "分析完成"
}

main "$@"