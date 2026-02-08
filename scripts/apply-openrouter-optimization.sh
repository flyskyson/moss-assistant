#!/bin/bash

###############################################################################
# OpenRouter 优化配置实施脚本
#
# 用途: 自动配置 OpenClaw agents 使用成本优化的模型
# 基于: docs/openrouter-optimization-strategy.md
# 预期节省: 80-90% 成本
#
# 使用方法:
#   1. 先充值 OpenRouter: https://openrouter.ai/settings/credits
#   2. 运行此脚本: bash scripts/apply-openrouter-optimization.sh
#
###############################################################################

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 工作区路径
WORKSPACE="/Users/lijian/clawd"
UTILITY_WS="$WORKSPACE/temp/utility-agent-ws"
LEADER_WS="$WORKSPACE/temp/leader-agent-ws"

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查 OpenClaw 是否安装
check_openclaw() {
    log_info "检查 OpenClaw 安装..."

    if ! command -v openclaw &> /dev/null; then
        log_error "OpenClaw 未安装，请先安装 OpenClaw"
        exit 1
    fi

    log_success "OpenClaw 已安装"
}

# 检查 OpenRouter 余额
check_credits() {
    log_info "检查 OpenRouter 积分余额..."

    # 尝试调用一个简单的请求来检查余额
    if ! openclaw agent --agent main --message "测试" 2>&1 | grep -q "Insufficient credits"; then
        log_success "OpenRouter 积分充足"
    else
        log_error "OpenRouter 积分不足！"
        echo ""
        echo "请先充值 OpenRouter："
        echo "  访问: https://openrouter.ai/settings/credits"
        echo "  建议充值: \$10-20"
        echo ""
        exit 1
    fi
}

# 显示当前配置
show_current_config() {
    log_info "当前 Agent 配置："
    echo ""
    openclaw agents list
    echo ""
}

# 备份当前配置
backup_config() {
    local backup_file="$HOME/.openclaw/openclaw.json.backup-$(date +%Y%m%d-%H%M%S)"

    log_info "备份当前配置到: $backup_file"

    cp "$HOME/.openclaw/openclaw.json" "$backup_file"

    log_success "配置已备份"
}

# 添加优化的模型（示例函数，实际需要 openclaw configure 支持）
add_optimized_models() {
    log_info "添加成本优化的模型..."

    # 注意: 这里假设您已经通过 openclaw configure 添加了这些模型
    # 实际使用时，请先运行: openclaw configure
    # 然后选择添加以下模型:
    #   - deepseek/deepseek-v3.2
    #   - minimax/minimax-m2.1
    #   - xiaomi/mimo-v2-flash (可选，免费)

    log_warning "请确保已通过 'openclaw configure' 添加以下模型："
    echo "  1. deepseek/deepseek-v3.2 (\$0.25/\$0.38 per 1M)"
    echo "  2. minimax/minimax-m2.1 (\$0.28/\$1.00 per 1M)"
    echo "  3. (可选) xiaomi/mimo-v2-flash (免费)"
    echo ""
    read -p "按 Enter 继续..."
}

# 创建优化版本的 utility-agent
create_utility_agent_v2() {
    log_info "创建 utility-agent-v2 (DeepSeek V3.2)..."

    # 检查是否已存在
    if openclaw agents list | grep -q "utility-agent-v2"; then
        log_warning "utility-agent-v2 已存在，跳过创建"
        return
    fi

    # 创建 workspace
    mkdir -p "$UTILITY_WS"

    # 添加 agent
    openclaw agents add utility-agent-v2 \
        --workspace "$UTILITY_WS" \
        --model deepseek/deepseek-v3.2 \
        --non-interactive

    log_success "utility-agent-v2 已创建"
}

# 创建优化版本的 leader-agent
create_leader_agent_v2() {
    log_info "创建 leader-agent-v2 (MiniMax M2.1)..."

    # 检查是否已存在
    if openclaw agents list | grep -q "leader-agent-v2"; then
        log_warning "leader-agent-v2 已存在，跳过创建"
        return
    fi

    # 创建 workspace
    mkdir -p "$LEADER_WS"

    # 添加 agent
    openclaw agents add leader-agent-v2 \
        --workspace "$LEADER_WS" \
        --model minimax/minimax-m2.1 \
        --non-interactive

    log_success "leader-agent-v2 已创建"
}

# 配置 agent identities
configure_identities() {
    log_info "配置 Agent 身份信息..."

    # utility-agent-v2 identity
    if openclaw agents list | grep -q "utility-agent-v2"; then
        openclaw agents set-identity \
            --agent utility-agent-v2 \
            --name "Utility (Optimized)" \
            --emoji "⚡"
        log_success "utility-agent-v2 身份已设置"
    fi

    # leader-agent-v2 identity
    if openclaw agents list | grep -q "leader-agent-v2"; then
        openclaw agents set-identity \
            --agent leader-agent-v2 \
            --name "Leader (Optimized)" \
            --emoji "🎯"
        log_success "leader-agent-v2 身份已设置"
    fi
}

# 测试新 agents
test_agents() {
    log_info "测试优化后的 Agents..."

    echo ""
    echo "测试 utility-agent-v2..."
    echo "请回复OK" | openclaw agent --agent utility-agent-v2 --message - 2>&1 | head -10
    echo ""

    echo "测试 leader-agent-v2..."
    echo "你好，请简单介绍一下你自己" | openclaw agent --agent leader-agent-v2 --message - 2>&1 | head -10
    echo ""

    log_success "Agents 测试完成"
}

# 显示使用指南
show_usage_guide() {
    echo ""
    log_info "=== 优化后的 Agents 使用指南 ==="
    echo ""
    echo "1. utility-agent-v2 (DeepSeek V3.2 - \$0.38/1M tokens)"
    echo "   适用: 简单任务、文本摘要、格式转换"
    echo ""
    echo "   示例:"
    echo "   openclaw agent --agent utility-agent-v2 --message \"请总结这段文本\""
    echo ""
    echo ""
    echo "2. leader-agent-v2 (MiniMax M2.1 - \$1.00/1M tokens)"
    echo "   适用: 编程任务、项目规划、代码生成"
    echo ""
    echo "   示例:"
    echo "   openclaw agent --agent leader-agent-v2 --message \"请规划项目架构\""
    echo ""
    echo ""
    echo "3. main (保留原配置)"
    echo "   适用: 复杂推理、关键决策"
    echo ""
    echo "   示例:"
    echo "   openclaw agent --agent main --message \"请分析这个架构设计的优缺点\""
    echo ""
    echo ""
    echo "=== 成本对比 ==="
    echo "优化前: ~\$22.50/月 (50次/日)"
    echo "优化后: ~\$2.60/月 (50次/日)"
    echo "节省:   88%"
    echo ""
}

# 主函数
main() {
    echo ""
    echo "========================================"
    echo "  OpenRouter 优化配置实施"
    echo "  基于: docs/openrouter-optimization-strategy.md"
    echo "========================================"
    echo ""

    # 检查 OpenClaw
    check_openclaw

    # 显示当前配置
    show_current_config

    # 备份配置
    backup_config

    # 检查积分
    check_credits

    # 添加优化模型
    add_optimized_models

    # 创建优化的 agents
    create_utility_agent_v2
    create_leader_agent_v2

    # 配置身份
    configure_identities

    # 测试
    test_agents

    # 显示使用指南
    show_usage_guide

    echo ""
    log_success "=== 优化配置完成！==="
    echo ""
    echo "下一步:"
    echo "  1. 使用新的 agents (utility-agent-v2, leader-agent-v2)"
    echo "  2. 更新脚本使用优化的 agents"
    echo "  3. 监控成本: https://openrouter.ai/logs"
    echo "  4. 一周后评估效果并调整"
    echo ""
}

# 运行主函数
main "$@"
