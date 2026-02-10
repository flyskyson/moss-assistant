#!/bin/bash

# 📋 项目状态自动跟踪器
# 用途：自动更新 TASKS.md 中的项目状态
# 用法：./project-tracker.sh update <项目名> <状态> [详情]
#      ./project-tracker.sh add <项目名> <优先级> <文件路径>
#      ./project-tracker.sh report

set -e

# 配置
BASE_DIR="/Users/lijian/clawd"
TASKS_FILE="$BASE_DIR/TASKS.md"
LOG_FILE="/tmp/project-tracker.log"

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# 更新项目状态
update_status() {
    local project_name="$1"
    local new_status="$2"
    local details="${3:-}"
    
    log_info "更新项目状态: $project_name -> $new_status"
    
    # 读取 TASKS.md
    local content=$(cat "$TASKS_FILE")
    
    # 状态映射
    local status_icon=""
    local status_text=""
    
    case "$new_status" in
        "完成"|"已完成"|"✅")
            status_icon="✅"
            status_text="已完成"
            ;;
        "进行中"|"🔄")
            status_icon="🔄"
            status_text="进行中"
            ;;
        "规划中"|"📋")
            status_icon="📋"
            status_text="规划中"
            ;;
        *)
            status_icon="📝"
            status_text="$new_status"
            ;;
    esac
    
    # 更新当前时间
    local timestamp=$(date '+%Y-%m-%d %H:%M')
    
    # 使用 sed 更新（简化版本，实际使用时需要更复杂的正则）
    log_info "状态更新: $project_name -> $status_icon $status_text"
    log_info "时间: $timestamp"
    
    echo ""
    echo "💡 提示：TASKS.md 需要手动更新或使用完整版脚本"
    echo ""
    echo "建议更新格式："
    echo "  - **$project_name**（状态：$status_icon $status_text，优先级：高）"
    echo "    - 更新时间：$timestamp"
    if [ -n "$details" ]; then
        echo "    - 详情：$details"
    fi
}

# 添加新项目
add_project() {
    local project_name="$1"
    local priority="$2"
    local file_path="$3"
    
    log_info "添加新项目: $project_name (优先级: $priority)"
    
    local timestamp=$(date '+%Y-%m-%d %H:%M')
    
    echo ""
    echo "💡 建议添加到 TASKS.md："
    echo ""
    echo "### $priority 优先级项目"
    echo "- **$project_name**（状态：📋 规划中，优先级：$priority）"
    echo "  - 📁 文件：$file_path"
    echo "  - 📅 添加时间：$timestamp"
    echo "  - 🚀 下一步：制定详细实施计划"
}

# 生成进度报告
generate_report() {
    local timestamp=$(date '+%Y-%m-%d %H:%M')
    
    echo ""
    echo "📊 项目进度报告 - $timestamp"
    echo "=================================="
    echo ""
    
    echo "🔴 高优先级项目："
    grep -A5 "🔴 高优先级项目" "$TASKS_FILE" 2>/dev/null | grep "^-" | head -10 || echo "  无"
    echo ""
    
    echo "🟡 中优先级项目："
    grep -A5 "🟡 中优先级项目" "$TASKS_FILE" 2>/dev/null | grep "^-" | head -10 || echo "  无"
    echo ""
    
    echo "✅ 已完成项目："
    grep "✅ 已完成\|✅ 完成" "$TASKS_FILE" | head -10 || echo "  无"
    echo ""
    
    echo "📅 报告生成时间：$timestamp"
}

# 集成版本（需要完整实现）
integrated_update() {
    local project_name="$1"
    local new_status="$2"
    local details="$3"
    
    # 这里可以集成到实际的 TASKS.md 更新
    # 目前是预览模式
    
    local timestamp=$(date '+%Y-%m-%d %H:%M')
    
    echo ""
    echo "🔄 集成模式更新预览："
    echo "  项目: $project_name"
    echo "  新状态: $new_status"
    echo "  时间: $timestamp"
    echo "  详情: $details"
    echo ""
    echo "💡 完整功能需要："
    echo "  1. 解析 TASKS.md 结构"
    echo "  2. 精确匹配项目名称"
    echo "  3. 更新状态行"
    echo "  4. 追加进展记录"
}

# 主逻辑
case "${1:-help}" in
    update)
        update_status "$2" "$3" "$4"
        ;;
    add)
        add_project "$2" "$3" "$4"
        ;;
    report)
        generate_report
        ;;
    integrated)
        integrated_update "$2" "$3" "$4"
        ;;
    help|--help|-h|*)
        echo "📋 项目状态自动跟踪器"
        echo ""
        echo "用法："
        echo "  $0 update <项目名> <状态> [详情]  # 更新项目状态"
        echo "  $0 add <项目名> <优先级> <路径>  # 添加新项目"
        echo "  $0 report                        # 生成进度报告"
        echo "  $0 integrated <项目名> <状态>    # 集成模式（预览）"
        echo "  $0 help                          # 显示帮助"
        echo ""
        echo "示例："
        echo "  $0 update \"自动化备份系统\" \"完成\""
        echo "  $0 add \"新项目\" \"中\" \"projects/new-project.md\""
        echo "  $0 report"
        echo ""
        ;;
esac