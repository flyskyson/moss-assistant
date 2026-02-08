#!/bin/bash

# 🧠 子 Agents 记忆系统初始化脚本
# 用途：为 leader-agent-v2 和 utility-agent-v2 创建 memory 目录结构
# 用法：./init-agents-memory.sh

set -e

# 配置
DATE=$(date +%Y-%m-%d)
BASE_DIR="$HOME/.openclaw/workspace-"

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# 创建 Agent Memory 目录
create_agent_memory() {
    local agent=$1
    local dir="${BASE_DIR}${agent}/memory"
    
    log_info "Creating memory directory for $agent..."
    
    # 创建目录
    mkdir -p "$dir"
    
    # 创建今日任务文件
    local today_file="$dir/$DATE.md"
    if [ ! -f "$today_file" ]; then
        cat > "$today_file" << EOF
# ${agent} 任务历史 - ${DATE}

## 今日任务
-

## 备注
-
EOF
        log_info "✅ Created today file: $today_file"
    else
        log_warn "File already exists: $today_file"
    fi
    
    # 创建项目状态追踪文件（仅 leader-agent-v2）
    if [ "$agent" = "leader-agent-v2" ]; then
        local projects_file="$dir/projects.md"
        if [ ! -f "$projects_file" ]; then
            cat > "$projects_file" << EOF
# 项目状态追踪

## 自动化项目
- 自动化备份系统：进行中
- 子 Agents 记忆激活：执行中
- 自进化知识库引擎：规划中

## 其他项目
- 企业微信迁移方案：规划中
- Multi-Agent 架构优化：验证完成
EOF
            log_info "✅ Created projects file: $projects_file"
        fi
    fi
    
    echo "✅ $agent memory setup complete"
}

# 主逻辑
main() {
    echo "========================================"
    echo "子 Agents 记忆系统初始化"
    echo "日期: $DATE"
    echo "========================================"
    echo ""
    
    # 为 leader-agent-v2 创建
    create_agent_memory "leader-agent-v2"
    echo ""
    
    # 为 utility-agent-v2 创建
    create_agent_memory "utility-agent-v2"
    echo ""
    
    echo "========================================"
    log_info "🎉 所有子 agents 记忆系统初始化完成！"
    echo "========================================"
    
    # 列出创建的目录结构
    echo ""
    echo "📁 目录结构:"
    for agent in leader-agent-v2 utility-agent-v2; do
        echo "  ${BASE_DIR}${agent}/memory/"
        ls -la "${BASE_DIR}${agent}/memory/" 2>/dev/null | grep -v "^total" | grep -v "^\." | while read line; do
            echo "    $line"
        done
    done
}

main "$@"