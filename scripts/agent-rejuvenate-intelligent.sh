#!/bin/bash

# 智能Agent老化防护系统
# Intelligent Agent Anti-Aging System

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

AGENT_ID="${1:-main}"
MODE="${2:-auto}"
DATA_DIR="$HOME/clawd/proactive-data"
LOG_FILE="$DATA_DIR/rejuvenation-intelligent.log"

# 创建日志目录
mkdir -p "$DATA_DIR"
mkdir -p "$(dirname "$LOG_FILE")"

# ========================================
# 日志函数
# ========================================
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

log_section() {
    echo "" | tee -a "$LOG_FILE"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$LOG_FILE"
    echo "$*" | tee -a "$LOG_FILE"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$LOG_FILE"
}

# ========================================
# 分析当前状态
# ========================================
analyze_status() {
    log_section "📊 分析Agent状态"

    # 1. 检查session数量
    SESSION_DIR="$HOME/.openclaw/agents/$AGENT_ID/sessions"
    if [ -d "$SESSION_DIR" ]; then
        SESSION_COUNT=$(ls -1 "$SESSION_DIR"/*.jsonl 2>/dev/null | wc -l | tr -d ' ')
        log "Session数量: $SESSION_COUNT"

        # 计算session总大小
        SESSION_SIZE=$(du -sh "$SESSION_DIR" 2>/dev/null | awk '{print $1}')
        log "Session总大小: $SESSION_SIZE"
    else
        SESSION_COUNT=0
        log "⚠️  Session目录不存在"
    fi

    # 2. 检查最近使用时间
    if [ -d "$SESSION_DIR" ]; then
        LATEST_SESSION=$(ls -t "$SESSION_DIR"/*.jsonl 2>/dev/null | head -1)
        if [ -n "$LATEST_SESSION" ]; then
            LAST_USED=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$LATEST_SESSION" 2>/dev/null || stat -c "%y" "$LATEST_SESSION" 2>/dev/null | cut -d'.' -f1)
            log "最近使用: $LAST_USED"
        fi
    fi

    # 3. 读取主动性引擎的指标（如果有）
    if [ -f "$DATA_DIR/metrics.jsonl" ]; then
        # 读取最新的指标
        LATEST_METRIC=$(tail -1 "$DATA_DIR/metrics.jsonl")
        if [ -n "$LATEST_METRIC" ]; then
            AVG_SESSIONS=$(echo "$LATEST_METRIC" | python3 -c "import sys, json; d=json.load(sys.stdin); print(d.get('session_count', 0))" 2>/dev/null || echo "0")
            log "平均Session数（引擎）: $AVG_SESSIONS"
        fi
    fi

    # 4. 评估老化程度
    log ""
    log "🔍 老化程度评估:"

    if [ "$SESSION_COUNT" -lt 10 ]; then
        AGING_LEVEL="低"
        AGING_COLOR="${GREEN}"
        RECOMMENDATION="无需清理"
    elif [ "$SESSION_COUNT" -lt 20 ]; then
        AGING_LEVEL="中"
        AGING_COLOR="${YELLOW}"
        RECOMMENDATION="建议清理"
    else
        AGING_LEVEL="高"
        AGING_COLOR="${RED}"
        RECOMMENDATION="立即清理"
    fi

    log "  老化级别: ${AGING_LEVEL}${AGING_LEVEL}${NC}"
    log "  建议: $RECOMMENDATION"

    return $SESSION_COUNT
}

# ========================================
# 智能决策
# ========================================
intelligent_decision() {
    local session_count=$1

    log_section "🧠 智能决策"

    # 决策阈值
    THRESHOLD_CRITICAL=25  # 立即清理
    THRESHOLD_WARNING=18   # 建议清理
    THRESHOLD_NORMAL=12    # 可选清理

    # 决策逻辑
    if [ "$session_count" -ge "$THRESHOLD_CRITICAL" ]; then
        log "🚨 决策: 立即执行清理"
        log "理由: Session数量 ($session_count) 超过临界阈值 ($THRESHOLD_CRITICAL)"
        return 0  # 执行清理
    elif [ "$session_count" -ge "$THRESHOLD_WARNING" ]; then
        log "⚠️  决策: 建议执行清理"
        log "理由: Session数量 ($session_count) 超过警告阈值 ($THRESHOLD_WARNING)"

        if [ "$MODE" = "auto" ]; then
            log "模式: 自动执行清理"
            return 0  # 自动模式，执行清理
        else
            log "模式: 等待确认"
            return 1  # 手动模式，需要确认
        fi
    elif [ "$session_count" -ge "$THRESHOLD_NORMAL" ]; then
        log "💡 决策: 可选清理"
        log "理由: Session数量 ($session_count) 接近正常阈值 ($THRESHOLD_NORMAL)"

        # 检查是否是周日（定期维护）
        DAY_OF_WEEK=$(date +%u)
        if [ "$DAY_OF_WEEK" -eq 7 ]; then
            log "今天是周日，执行定期维护"
            return 0  # 周日定期清理
        else
            log "跳过清理（等到周日）"
            return 1
        fi
    else
        log "✅ 决策: 无需清理"
        log "理由: Session数量 ($session_count) 在正常范围内"
        return 1  # 不需要清理
    fi
}

# ========================================
# 执行清理
# ========================================
execute_rejuvenation() {
    log_section "🚀 执行Agent清理"

    # 调用原有的清理脚本
    REJUVENATE_SCRIPT="$HOME/clawd/scripts/agent-rejuvenate.sh"

    if [ ! -f "$REJUVENATE_SCRIPT" ]; then
        log "❌ 清理脚本不存在: $REJUVENATE_SCRIPT"
        return 1
    fi

    log "执行清理脚本: $REJUVENATE_SCRIPT $AGENT_ID"
    log ""

    # 执行清理并记录输出
    if bash "$REJUVENATE_SCRIPT" "$AGENT_ID" 2>&1 | tee -a "$LOG_FILE"; then
        log ""
        log "✅ 清理完成"
        return 0
    else
        log ""
        log "❌ 清理失败"
        return 1
    fi
}

# ========================================
# 验证效果
# ========================================
verify_results() {
    log_section "✅ 验证清理效果"

    # 等待文件系统同步
    sleep 2

    # 重新检查session数量
    SESSION_DIR="$HOME/.openclaw/agents/$AGENT_ID/sessions"
    if [ -d "$SESSION_DIR" ]; then
        NEW_SESSION_COUNT=$(ls -1 "$SESSION_DIR"/*.jsonl 2>/dev/null | wc -l | tr -d ' ')
        log "清理后Session数量: $NEW_SESSION_COUNT"

        # 计算节省的空间
        if [ -n "${SESSION_COUNT:-}" ] && [ "$SESSION_COUNT" -gt 0 ]; then
            REDUCED=$((SESSION_COUNT - NEW_SESSION_COUNT))
            PERCENT=$((REDUCED * 100 / SESSION_COUNT))
            log "减少了 ${REDUCED} 个sessions (${PERCENT}%)"
        fi
    fi

    # 记录到主动性引擎
    if command -v python3 &> /dev/null; then
        log ""
        log "📊 通知主动性引擎"

        # 记录清理事件
        EVENT_FILE="$DATA_DIR/rejuvenation-events.jsonl"
        cat >> "$EVENT_FILE" <<EOF
{"timestamp": "$(date -Iseconds)", "agent_id": "$AGENT_ID", "event": "rejuvenation", "sessions_before": ${SESSION_COUNT:-0}, "sessions_after": ${NEW_SESSION_COUNT:-0}}
EOF

        log "✅ 事件已记录到: $EVENT_FILE"
    fi
}

# ========================================
# 生成报告
# ========================================
generate_report() {
    log_section "📋 清理报告"

    cat <<EOF | tee -a "$LOG_FILE"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   智能Agent老化防护 - 清理报告
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Agent ID: $AGENT_ID
执行时间: $(date '+%Y-%m-%d %H:%M:%S')
执行模式: $MODE

清理前Session: ${SESSION_COUNT:-N/A}
清理后Session: ${NEW_SESSION_COUNT:-N/A}
减少数量: $((SESSION_COUNT - NEW_SESSION_COUNT))
减少比例: $(((SESSION_COUNT - NEW_SESSION_COUNT) * 100 / SESSION_COUNT))%

状态: ✅ 成功完成

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
}

# ========================================
# 主函数
# ========================================
main() {
    log_section "🦞 智能Agent老化防护系统"
    log "Agent: $AGENT_ID"
    log "模式: $MODE"
    log ""

    # 1. 分析当前状态
    analyze_status
    SESSION_COUNT=$?

    # 2. 智能决策
    if intelligent_decision "$SESSION_COUNT"; then
        # 3. 执行清理
        execute_rejuvenation

        # 4. 验证效果
        verify_results

        # 5. 生成报告
        generate_report
    else
        log "跳过清理（不需要或不符合条件）"
    fi

    log ""
    log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log "✅ 智能老化防护检查完成"
    log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# ========================================
# 命令行接口
# ========================================
case "${3:-run}" in
    run)
        main
        ;;
    status)
        analyze_status
        ;;
    force)
        MODE="force"
        main
        ;;
    *)
        echo "用法: $0 <agent-id> <mode> <action>"
        echo ""
        echo "参数:"
        echo "  agent-id: Agent ID (默认: main)"
        echo "  mode:     auto (自动) | manual (手动)"
        echo "  action:   run (执行) | status (状态) | force (强制)"
        echo ""
        echo "示例:"
        echo "  $0 main auto run      # 自动模式执行"
        echo "  $0 main auto status   # 查看状态"
        echo "  $0 main manual run    # 手动模式执行"
        echo "  $0 main auto force    # 强制执行"
        exit 0
        ;;
esac
