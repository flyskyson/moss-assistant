#!/bin/bash

# 🔄 知识库自进化主协调器
# 用途：协调监控、分类、更新、优化全流程
# 用法：./evolve.sh [full|monitor|classify|update|optimize]
# 集成：由 leader-agent-v2 调用执行

set -e

# 配置
BASE_DIR="/Users/lijian/clawd"
SCRIPT_DIR="$BASE_DIR/scripts/knowledge-evolution"
LOG_FILE="$BASE_DIR/logs/knowledge-evolution.log"
LOCK_FILE="/tmp/knowledge-evolution.lock"

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

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

log_section() {
    echo ""
    echo -e "${CYAN}🔄 $1${NC}"
    echo "======================================"
}

# 检查锁文件（防止并发运行）
check_lock() {
    if [ -f "$LOCK_FILE" ]; then
        log_warn "检测到锁文件，可能是上一个任务还在运行"
        log_warn "如果确定没有运行，可以删除：rm $LOCK_FILE"
        return 1
    fi
    return 0
}

# 创建锁文件
create_lock() {
    echo "$$" > "$LOCK_FILE"
    log_info "创建锁文件: $LOCK_FILE"
}

# 删除锁文件
remove_lock() {
    rm -f "$LOCK_FILE"
    log_info "删除锁文件"
}

# 清理函数
cleanup() {
    remove_lock
}

# 设置陷阱
trap cleanup EXIT

# 完整演化流程
run_full_evolution() {
    log_section "完整知识库演化"
    
    log_info "开始完整演化流程..."
    
    # 1. 监控
    log_info "步骤 1/4: 监控系统"
    $SCRIPT_DIR/monitor.sh simple
    
    # 2. 分类
    log_info "步骤 2/4: 分类系统"
    $SCRIPT_DIR/classifier.sh --batch "$BASE_DIR" > /tmp/classification-result.txt 2>&1
    
    # 3. 更新索引
    log_info "步骤 3/4: 更新索引"
    $SCRIPT_DIR/index-updater.sh --dry-run
    
    # 4. 优化
    log_info "步骤 4/4: 优化引擎"
    $SCRIPT_DIR/optimizer.sh
    
    log_info "完整演化流程完成"
}

# 仅监控和分类
run_monitor_classify() {
    log_section "监控 + 分类"
    
    log_info "执行监控..."
    $SCRIPT_DIR/monitor.sh simple
    
    log_info "执行分类..."
    $SCRIPT_DIR/classifier.sh --batch "$BASE_DIR"
}

# 仅更新索引
run_update() {
    log_section "索引更新"
    
    log_info "执行索引健康检查..."
    $SCRIPT_DIR/index-updater.sh --dry-run
}

# 仅优化
run_optimize() {
    log_section "优化分析"
    
    log_info "执行优化分析..."
    $SCRIPT_DIR/optimizer.sh
}

# 生成状态报告
show_status() {
    log_section "知识库状态"
    
    echo "📊 知识库当前状态："
    echo ""
    
    echo "📁 文件统计："
    echo "  - 文档: $(find "$BASE_DIR/docs" -name "*.md" 2>/dev/null | wc -l) 个"
    echo "  - 项目: $(find "$BASE_DIR/projects" -name "*.md" 2>/dev/null | wc -l) 个"
    echo "  - 脚本: $(find "$BASE_DIR/scripts" -name "*.sh" 2>/dev/null | wc -l) 个"
    echo "  - 技能: $(find "$BASE_DIR/skills" -name "*.md" 2>/dev/null | wc -l) 个"
    echo "  - 记忆: $(find "$BASE_DIR/memory" -name "*.md" 2>/dev/null | wc -l) 个"
    echo ""
    
    echo "📝 最近活动："
    echo "  - 24小时内修改: $(find "$BASE_DIR" -type f \( -name "*.md" -o -name "*.sh" \) -mtime -1 2>/dev/null | wc -l) 个文件"
    echo "  - 7天内修改: $(find "$BASE_DIR" -type f \( -name "*.md" -o -name "*.sh" \) -mtime -7 2>/dev/null | wc -l) 个文件"
    echo ""
    
    echo "⚙️ 脚本状态："
    echo "  - 监控器: $([ -x "$SCRIPT_DIR/monitor.sh" ] && echo "✅" || echo "❌")"
    echo "  - 分类器: $([ -x "$SCRIPT_DIR/classifier.sh" ] && echo "✅" || echo "❌")"
    echo "  - 更新器: $([ -x "$SCRIPT_DIR/index-updater.sh" ] && echo "✅" || echo "❌")"
    echo "  - 优化器: $([ -x "$SCRIPT_DIR/optimizer.sh" ] && echo "✅" || echo "❌")"
    echo ""
    
    echo "📅 Cron 任务："
    echo "  - 监控: 每天 22:00"
    echo "  - 优化: 每周日 00:00"
    echo ""
}

# 主逻辑
main() {
    local mode="${1:-status}"
    
    echo "🔄 知识库自进化协调器"
    echo "===================="
    
    case "$mode" in
        full)
            check_lock || exit 1
            create_lock
            run_full_evolution
            ;;
        monitor|mon)
            check_lock || exit 1
            create_lock
            run_monitor_classify
            ;;
        update|idx)
            run_update
            ;;
        optimize|opt)
            run_optimize
            ;;
        status|stat)
            show_status
            ;;
        help|--help|-h)
            echo "🔄 知识库自进化协调器"
            echo ""
            echo "用法：$0 [模式]"
            echo ""
            echo "模式："
            echo "  full     - 完整演化（监控→分类→更新→优化）"
            echo "  monitor  - 仅监控和分类"
            echo "  update   - 仅索引更新"
            echo "  optimize - 仅优化分析"
            echo "  status   - 显示当前状态"
            echo "  help     - 显示帮助"
            echo ""
            echo "示例："
            echo "  $0 full       # 执行完整演化"
            echo "  $0 status     # 查看状态"
            echo "  $0 monitor    # 仅监控变化"
            echo ""
            ;;
        *)
            show_status
            ;;
    esac
}

main "$@"