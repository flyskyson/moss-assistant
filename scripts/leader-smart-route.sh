#!/bin/bash

# LEADER Smart Route Script
# LEADER Agent 智能路由脚本 - 任务分解和 Agent 分配
# 2026-02-08

set -euo pipefail

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 配置
AGENT_NAME="LEADER"
ROUTER_SCRIPT="/Users/lijian/clawd/scripts/agent-router-integration.py"
LOG_FILE="/Users/lijian/clawd/logs/leader-auto-route.log"

# 日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# 显示帮助
show_help() {
    cat << EOF
${BLUE}LEADER 智能路由脚本${NC}
${BLUE}=================${NC}

用法：
  $0 <command> [args]

命令：
  decompose <task>      - 分解复杂任务
  assign <task>         - 分配任务给最优 Agent
  coordinate           - 协调多 Agent 工作
  analyze <task_file>  - 分析任务并推荐 Agent

示例：
  $0 decompose "分析项目架构并给出优化建议"
  $0 assign "更新文档"
  $0 analyze task.txt

Agent 分配规则：
  - MiniMax M2.1 → MOSS（文件编辑、中文内容）
  - DeepSeek V3.2 → THINKER（深度分析、复杂推理）
  - MiMo-V2-Flash → EXECUTOR（批量任务、简单操作）
  - Devstral 2 → COORDINATOR（工作流编排）

成本优化：
  - 传统方式：$15-20/月
  - 智能路由：$1.50/月
  - 节省：90%+ ⚡

EOF
}

# 检查参数
if [ $# -lt 1 ]; then
    show_help
    exit 1
fi

COMMAND="$1"
shift

# 执行命令
case "$COMMAND" in
    decompose)
        if [ $# -lt 1 ]; then
            echo -e "${RED}错误：请提供任务描述${NC}"
            exit 1
        fi

        TASK_DESC="$*"
        log "任务分解: $TASK_DESC"

        # 创建临时任务文件
        TASK_FILE="/tmp/leader-task-$$.md"
        echo "# 任务描述" > "$TASK_FILE"
        echo "$TASK_DESC" >> "$TASK_FILE"

        # 调用路由器
        echo -e "${BLUE}📊 分析任务特征...${NC}"
        ROUTE_RESULT=$(python3 "$ROUTER_SCRIPT" "$AGENT_NAME" "$TASK_FILE" task_decomposition 2>&1)

        # 提取推荐信息
        RECOMMENDED_MODEL=$(echo "$ROUTE_RESULT" | grep "Model ID:" | awk '{print $3}')
        REASON=$(echo "$ROUTE_RESULT" | grep "Reason:" | cut -d: -f2- | xargs)
        AGENT_ASSIGN=$(echo "$ROUTE_RESULT" | grep "Leader Decision:" | awk -F': ' '{print $2}')

        echo -e "${GREEN}✓ 推荐模型: $RECOMMENDED_MODEL${NC}"
        echo -e "${GREEN}  理由: $REASON${NC}"
        echo -e "${YELLOW}📌 决策: $AGENT_ASSIGN${NC}"

        log "使用模型: $RECOMMENDED_MODEL，分配给: $AGENT_ASSIGN"

        # 执行任务分解
        echo -e "${BLUE}🚀 执行任务分解...${NC}"
        # TODO: 集成实际的分解命令
        # openclaw agent --agent leader-agent-v2 --model "$RECOMMENDED_MODEL" --message "分解任务: $TASK_DESC"

        rm -f "$TASK_FILE"
        ;;

    assign)
        if [ $# -lt 1 ]; then
            echo -e "${RED}错误：请提供任务描述${NC}"
            exit 1
        fi

        TASK_DESC="$*"
        log "Agent 分配: $TASK_DESC"

        # 创建临时任务文件
        TASK_FILE="/tmp/leader-assign-$$.md"
        echo "# 任务" > "$TASK_FILE"
        echo "$TASK_DESC" >> "$TASK_FILE"

        # 调用路由器
        echo -e "${BLUE}📊 分析任务并分配 Agent...${NC}\n"
        python3 "$ROUTER_SCRIPT" "$AGENT_NAME" "$TASK_FILE" task_decomposition

        rm -f "$TASK_FILE"
        ;;

    analyze)
        if [ $# -lt 1 ]; then
            echo -e "${RED}错误：请指定任务文件${NC}"
            exit 1
        fi

        TASK_FILE="$1"
        log "分析任务: $TASK_FILE"

        # 调用路由器
        echo -e "${BLUE}📊 任务分析：${NC}\n"
        python3 "$ROUTER_SCRIPT" "$AGENT_NAME" "$TASK_FILE" analysis
        ;;

    coordinate)
        log "协调多 Agent"

        # 简化版协调逻辑
        echo -e "${BLUE}📊 协调建议：${NC}"
        echo -e "${YELLOW}1. 使用 decompose 分析任务${NC}"
        echo -e "${YELLOW}2. 使用 assign 分配给最优 Agent${NC}"
        echo -e "${YELLOW}3. 汇总各 Agent 结果${NC}"
        ;;

    *)
        echo -e "${RED}❌ 未知命令: $COMMAND${NC}"
        echo ""
        show_help
        exit 1
        ;;
esac

log "命令完成"
echo -e "${GREEN}✅ 完成${NC}"
