#!/bin/bash

# 📝 子 Agents 任务记录脚本
# 用途：记录任务执行历史到 memory
# 用法：./log-agent-task.sh <agent> <task_name> <result> [details]

set -e

# 配置
BASE_DIR="$HOME/.openclaw/workspace-"
TODAY=$(date +%Y-%m-%d)
TIME=$(date '+%H:%M')

# 颜色输出
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 记录任务
log_task() {
    local agent=$1
    local task_name=$2
    local result=$3
    local details=$4
    local mem_file="${BASE_DIR}${agent}/memory/${TODAY}.md"
    
    if [ ! -f "$mem_file" ]; then
        log_error "Memory file not found: $mem_file"
        return 1
    fi
    
    # 添加任务记录
    cat >> "$mem_file" << EOF

## ${TIME} - ${task_name}
- 结果：${result}
EOF

    if [ -n "$details" ]; then
        echo "  详情：${details}" >> "$mem_file"
    fi
    
    log_success "Task logged: ${task_name} -> ${agent}"
}

# 更新项目状态
update_project_status() {
    local agent=$1
    local project=$2
    local status=$3
    local proj_file="${BASE_DIR}${agent}/memory/projects.md"
    
    if [ ! -f "$proj_file" ]; then
        log_error "Projects file not found: $proj_file"
        return 1
    fi
    
    # 使用 sed 更新状态
    sed -i '' "s/- ${project}：.*/- ${project}：${status}/" "$proj_file"
    
    log_success "Project status updated: ${project} -> ${status}"
}

# 主逻辑
case "${1:-help}" in
    log)
        log_task "$2" "$3" "$4" "$5"
        ;;
    update)
        update_project_status "$2" "$3" "$4"
        ;;
    help|*)
        echo "子 Agents 任务记录脚本"
        echo ""
        echo "用法："
        echo "  $0 log <agent> <task_name> <result> [details]"
        echo "  $0 update <agent> <project_name> <status>"
        echo ""
        echo "示例："
        echo "  $0 log leader-agent-v2 '系统健康检查' '成功完成' '发现1个问题'"
        echo "  $0 update leader-agent-v2 '自动化备份系统' '进行中'"
        echo ""
        echo "Agents:"
        echo "  leader-agent-v2"
        echo "  utility-agent-v2"
        ;;
esac