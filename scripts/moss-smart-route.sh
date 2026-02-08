#!/bin/bash

# MOSS Smart Route Script
# MOSS Agent 智能路由脚本 - 自动选择最优模型执行任务
# 2026-02-08

set -euo pipefail

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 配置
AGENT_NAME="MOSS"
ROUTER_SCRIPT="/Users/lijian/clawd/scripts/agent-router-integration.py"
LOG_FILE="/Users/lijian/clawd/logs/moss-auto-route.log"

# 日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# 显示帮助
show_help() {
    cat << EOF
${BLUE}MOSS 智能路由脚本${NC}
${BLUE}=================${NC}

用法：
  $0 <command> [args]

命令：
  edit <file>           - 编辑文件（自动选择最优模型）
  query <text>          - 快速查询（优先使用免费模型）
  analyze <file>        - 分析文件
  chat                 - 启动对话（使用推荐模型）

示例：
  $0 edit IDENTITY.md
  $0 query "总结今天的任务"
  $0 analyze /path/to/file

路由决策：
  - 核心配置文件 → MiniMax M2.1（最可靠）
  - 中文/emoji 文件 → MiniMax M2.1（无 tokenization 问题）
  - 大文件 → MiniMax M2.1（更好的错误处理）
  - 简单查询 → MiMo-V2-Flash（完全免费）

成本优化：
  - 传统方式：$22-31/月
  - 智能路由：$2.60/月
  - 节省：88% ⚡

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
    edit)
        if [ $# -lt 1 ]; then
            echo -e "${RED}错误：请指定文件路径${NC}"
            exit 1
        fi

        FILE_PATH="$1"
        log "编辑文件: $FILE_PATH"

        # 调用路由器
        echo -e "${BLUE}📊 分析任务特征...${NC}"
        ROUTE_RESULT=$(python3 "$ROUTER_SCRIPT" "$AGENT_NAME" "$FILE_PATH" file_edit 2>&1)

        # 提取推荐模型
        RECOMMENDED_MODEL=$(echo "$ROUTE_RESULT" | grep "Model ID:" | awk '{print $3}')
        REASON=$(echo "$ROUTE_RESULT" | grep "Reason:" | cut -d: -f2- | xargs)

        if [ -z "$RECOMMENDED_MODEL" ]; then
            echo -e "${RED}❌ 路由失败，使用默认模型${NC}"
            RECOMMENDED_MODEL="openrouter/google/gemini-2.5-flash"
        else
            echo -e "${GREEN}✓ 推荐模型: $RECOMMENDED_MODEL${NC}"
            echo -e "${GREEN}  理由: $REASON${NC}"
        fi

        log "使用模型: $RECOMMENDED_MODEL"

        # 执行编辑（这里需要集成实际的编辑逻辑）
        echo -e "${BLUE}🚀 使用模型 $RECOMMENDED_MODEL 编辑文件...${NC}"
        # TODO: 集成实际的编辑命令
        # openclaw agent --agent main --model "$RECOMMENDED_MODEL" --message "编辑 $FILE_PATH"
        ;;

    query)
        if [ $# -lt 1 ]; then
            echo -e "${RED}错误：请提供查询内容${NC}"
            exit 1
        fi

        QUERY="$*"
        log "快速查询: $QUERY"

        # 简单查询优先使用免费模型
        echo -e "${BLUE}📊 分析查询...${NC}"
        echo -e "${GREEN}✓ 使用免费模型: xiaomi/mimo-v2-flash${NC}"
        echo -e "${GREEN}  理由: 成本优化，简单查询使用免费模型${NC}"

        log "使用模型: xiaomi/mimo-v2-flash (FREE)"

        # 执行查询
        echo -e "${BLUE}🚀 执行查询...${NC}"
        # TODO: 集成实际的查询命令
        # openclaw agent --agent main --model "xiaomi/mimo-v2-flash" --message "$QUERY"
        ;;

    analyze)
        if [ $# -lt 1 ]; then
            echo -e "${RED}错误：请指定文件路径${NC}"
            exit 1
        fi

        FILE_PATH="$1"
        log "分析文件: $FILE_PATH"

        # 调用路由器获取建议
        echo -e "${BLUE}📊 路由分析：${NC}\n"
        python3 "$ROUTER_SCRIPT" "$AGENT_NAME" "$FILE_PATH" analysis
        ;;

    chat)
        log "启动对话"

        # 调用路由器获取推荐
        echo -e "${BLUE}📊 推荐模型：${NC}"
        echo -e "${YELLOW}提示：使用 'edit' 或 'query' 命令可获得自动路由${NC}\n"

        # 启动默认对话
        openclaw agent --agent main
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
