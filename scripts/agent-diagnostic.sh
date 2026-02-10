#!/bin/bash

# OpenClaw Agent 性能诊断工具
# 全面诊断 Agent 性能问题

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

AGENT_ID="${1:-main}"
REPORT_DIR="$HOME/clawd/diagnostics"
REPORT_FILE="$REPORT_DIR/diagnostic-$(date +%Y%m%d-%H%M%S).md"

mkdir -p "$REPORT_DIR"

echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}  ${BOLD}OpenClaw Agent 性能诊断工具${NC}                                     ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  ${BOLD}   Performance Diagnostic Tool${NC}                                  ${CYAN}║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BOLD}Agent ID:${NC} $AGENT_ID"
echo -e "${BOLD}诊断时间:${NC} $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# 开始生成报告
cat > "$REPORT_FILE" << EOF
# 🔍 OpenClaw Agent 性能诊断报告

**Agent ID**: $AGENT_ID
**诊断时间**: $(date '+%Y-%m-%d %H:%M:%S')
**诊断工具**: OpenClaw Performance Diagnostic v1.0

---

EOF

# ========================================
# 1. Session 分析
# ========================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}📊 1. Session 分析${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

SESSION_DIR="$HOME/.openclaw/agents/$AGENT_ID/sessions"

if [ -d "$SESSION_DIR" ]; then
    SESSION_COUNT=$(ls -1 "$SESSION_DIR"/*.jsonl 2>/dev/null | wc -l | tr -d ' ')
    SESSION_SIZE=$(du -sh "$SESSION_DIR" 2>/dev/null | awk '{print $1}')
    SESSION_SIZE_BYTES=$(du -s "$SESSION_DIR" 2>/dev/null | awk '{print $1}')

    # 获取最新的session
    LATEST_SESSION=$(ls -t "$SESSION_DIR"/*.jsonl 2>/dev/null | head -1)
    if [ -n "$LATEST_SESSION" ]; then
        LATEST_SIZE=$(du -h "$LATEST_SESSION" 2>/dev/null | awk '{print $1}')
        LATEST_AGE=$(( ($(date +%s) - $(stat -f %m "$LATEST_SESSION" 2>/dev/null || stat -c %Y "$LATEST_SESSION" 2>/dev/null)) / 86400 ))
    fi

    echo -e "  Session数量: ${BOLD}$SESSION_COUNT${NC}"
    echo -e "  总大小: ${BOLD}$SESSION_SIZE${NC}"
    [ -n "${LATEST_SIZE:-}" ] && echo -e "  最新session: ${BOLD}$LATEST_SIZE${NC} ( ${LATEST_AGE} 天前)"
    echo ""

    # 评估
    if [ "$SESSION_COUNT" -lt 10 ]; then
        STATUS="${GREEN}✅ 良好${NC}"
        ADVICE="Session数量正常"
    elif [ "$SESSION_COUNT" -lt 20 ]; then
        STATUS="${YELLOW}⚠️  注意${NC}"
        ADVICE="Session数量较多，建议清理"
    else
        STATUS="${RED}🚨 严重${NC}"
        ADVICE="Session数量过多！这是性能问题的主要原因"
    fi

    echo -e "  状态: $STATUS"
    echo -e "  建议: $ADVICE"
    echo ""

    # 写入报告
    cat >> "$REPORT_FILE" << EOF
## 📊 Session 分析

| 指标 | 数值 | 状态 |
|------|------|------|
| Session数量 | $SESSION_COUNT | $(echo "$STATUS" | sed 's/\x1b\[[0-9;]*m//g') |
| 总大小 | $SESSION_SIZE | - |
| 最新session | ${LATEST_SIZE:-N/A} (${LATEST_AGE:-N/A} 天前) | - |

### 📝 诊断结论

$ADVICE

---

EOF

else
    echo -e "  ${YELLOW}⚠️  Session目录不存在${NC}"
    echo ""
fi

# ========================================
# 2. 数据库分析
# ========================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}🗄️  2. 数据库分析${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

DB_DIR="$HOME/.openclaw/agents/$AGENT_ID"

if [ -d "$DB_DIR" ]; then
    DB_SIZE=$(du -sh "$DB_DIR" 2>/dev/null | awk '{print $1}')
    DB_SIZE_BYTES=$(du -s "$DB_DIR" 2>/dev/null | awk '{print $1}')
    DB_SIZE_MB=$((DB_SIZE_BYTES / 1024 / 1024))

    echo -e "  数据库大小: ${BOLD}$DB_SIZE${NC}"
    echo ""

    # 评估
    if [ "$DB_SIZE_MB" -lt 100 ]; then
        STATUS="${GREEN}✅ 正常${NC}"
        ADVICE="数据库大小正常"
    elif [ "$DB_SIZE_MB" -lt 500 ]; then
        STATUS="${YELLOW}⚠️  较大${NC}"
        ADVICE="数据库较大，建议设置 retention_days"
    else
        STATUS="${RED}🚨 膨胀${NC}"
        ADVICE="数据库严重膨胀！需要立即清理"
    fi

    echo -e "  状态: $STATUS"
    echo -e "  建议: $ADVICE"
    echo ""

    # 写入报告
    cat >> "$REPORT_FILE" << EOF
## 🗄️ 数据库分析

| 指标 | 数值 | 状态 |
|------|------|------|
| 数据库大小 | $DB_SIZE ($DB_SIZE_MB MB) | $(echo "$STATUS" | sed 's/\x1b\[[0-9;]*m//g') |

### 📝 诊断结论

$ADVICE

**建议操作**:
\`\`\`bash
# 检查 retention_days 设置
cat ~/.openclaw/agents/$AGENT_ID/config.yaml | grep retention_days

# 如果没有设置，建议添加
# retention_days: 7  # 只保留7天数据
\`\`\`

---

EOF
fi

# ========================================
# 3. 系统资源分析
# ========================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}💻 3. 系统资源分析${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# CPU使用
CPU_USAGE=$(ps aux | grep -E "[o]penclaw|[g]ateway" | awk '{sum+=$3} END {print sum}' || echo "0")
MEMORY_USAGE=$(ps aux | grep -E "[o]penclaw|[g]ateway" | awk '{sum+=$4} END {print sum}' || echo "0")

echo -e "  OpenClaw CPU使用: ${BOLD}${CPU_USAGE}%${NC}"
echo -e "  OpenClaw 内存使用: ${BOLD}${MEMORY_USAGE}%${NC}"
echo ""

# 检查热节流（macOS）
if command -v sysctl &> /dev/null; then
    # 检查CPU频率（可能被热节流）
    if sysctl -a 2>/dev/null | grep -q "cpu.*frequency"; then
        CPU_FREQ=$(sysctl -a | grep "cpu.*frequency" | head -1 | awk '{print $2}')
        echo -e "  CPU频率: ${BOLD}$CPU_FREQ MHz${NC}"
    fi
fi

echo ""

# 写入报告
cat >> "$REPORT_FILE" << EOF
## 💻 系统资源分析

| 资源 | 使用率 | 状态 |
|------|--------|------|
| CPU | ${CPU_USAGE}% | $([ "$(echo "$CPU_USAGE < 50" | bc)" -eq 1 ] && echo "✅ 正常" || echo "⚠️ 较高") |
| 内存 | ${MEMORY_USAGE}% | $([ "$(echo "$MEMORY_USAGE < 70" | bc)" -eq 1 ] && echo "✅ 正常" || echo "⚠️ 较高") |

---

EOF

# ========================================
# 4. 网络连接分析
# ========================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}🌐 4. 网络连接分析${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# 检查OpenClaw Gateway端口
GATEWAY_PORT=${OPENCLAW_GATEWAY_PORT:-8080}
if command -v lsof &> /dev/null; then
    if lsof -i :$GATEWAY_PORT &> /dev/null; then
        echo -e "  Gateway端口 ${BOLD}$GATEWAY_PORT${NC}: ${GREEN}✅ 正在监听${NC}"
    else
        echo -e "  Gateway端口 ${BOLD}$GATEWAY_PORT${NC}: ${RED}❌ 未监听${NC}"
    fi
fi

echo ""

# 写入报告
cat >> "$REPORT_FILE" << EOF
## 🌐 网络连接分析

Gateway端口 $GATEWAY_PORT: $(lsof -i :$GATEWAY_PORT &> /dev/null && echo "✅ 正常" || echo "❌ 未监听")

---

EOF

# ========================================
# 5. 性能建议
# ========================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}💡 5. 性能优化建议${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

RECOMMENDATIONS=""

# 根据Session数量
if [ "${SESSION_COUNT:-0}" -gt 20 ]; then
    echo -e "${RED}🚨 紧急建议:${NC} 清理旧session"
    echo ""
    echo "  执行命令:"
    echo "  ${CYAN}~/clawd/scripts/agent-rejuvenate.sh $AGENT_ID${NC}"
    echo ""

    RECOMMENDATIONS+="1. **清理Session** (紧急)\n"
    RECOMMENDATIONS+="\`\`\`bash\n~/clawd/scripts/agent-rejuvenate.sh $AGENT_ID\n\`\`\`\n\n"
fi

# 建议配置retention_days
if [ "${DB_SIZE_MB:-0}" -gt 100 ]; then
    echo -e "${YELLOW}⚠️  重要建议:${NC} 配置 retention_days"
    echo ""
    echo "  编辑配置文件:"
    echo "  ${CYAN}~/.openclaw/agents/$AGENT_ID/config.yaml${NC}"
    echo ""
    echo "  添加:"
    echo "  ${BOLD}retention_days: 7${NC}  # 只保留7天数据"
    echo ""

    RECOMMENDATIONS+="2. **配置数据保留策略**\n"
    RECOMMENDATIONS+="\`\`\`yaml\n# ~/.openclaw/agents/$AGENT_ID/config.yaml\nretention_days: 7\n\`\`\`\n\n"
fi

# 建议重启Gateway
if [ "${CPU_USAGE:-0}" \> "80" ] || [ "${MEMORY_USAGE:-0}" \> "80" ]; then
    echo -e "${YELLOW}⚠️  建议:${NC} 重启Gateway"
    echo ""
    echo "  执行命令:"
    echo "  ${CYAN}openclaw daemon restart${NC}"
    echo ""

    RECOMMENDATIONS+="3. **重启Gateway**\n"
    RECOMMENDATIONS+="\`\`\`bash\nopenclaw daemon restart\n\`\`\`\n\n"
fi

# 通用建议
echo -e "${GREEN}✅ 日常维护建议:${NC}"
echo ""
echo "  1. 定期清理session (每周)"
echo "  2. 监控性能指标 (使用主动性引擎)"
echo "  3. 保持系统资源充足"
echo ""

RECOMMENDATIONS+="4. **日常维护**\n"
RECOMMENDATIONS+="\`\`\`bash\n# 定期清理 (每周执行)\n~/clawd/scripts/agent-rejuvenate.sh $AGENT_ID\n\n# 监控性能\n~/clawd/scripts/proactive-engine-control.sh $AGENT_ID report\n\`\`\`\n\n"

# 写入报告
cat >> "$REPORT_FILE" << EOF
## 💡 性能优化建议

$RECOMMENDATIONS

---

EOF

# ========================================
# 6. 生成时间线
# ========================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}📈 6. 性能趋势${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

METRICS_FILE="$HOME/clawd/proactive-data/metrics.jsonl"

if [ -f "$METRICS_FILE" ]; then
    # 读取最近10条数据
    echo "  最近性能趋势:"
    echo ""

    tail -10 "$METRICS_FILE" | while IFS= read -r line; do
        if [ -n "$line" ]; then
            TIMESTAMP=$(echo "$line" | python3 -c "import sys, json; d=json.load(sys.stdin); print(d.get('timestamp', '')[:10])" 2>/dev/null)
            SESSION_COUNT=$(echo "$line" | python3 -c "import sys, json; d=json.load(sys.stdin); print(d.get('session_count', 0))" 2>/dev/null)
            echo "    $TIMESTAMP: ${BOLD}$SESSION_COUNT${NC} sessions"
        fi
    done
    echo ""

    # 写入报告
    cat >> "$REPORT_FILE" << EOF
## 📈 性能趋势

最近10次监控记录:

$(tail -10 "$METRICS_FILE" | while IFS= read -r line; do
    TIMESTAMP=$(echo "$line" | python3 -c "import sys, json; d=json.load(sys.stdin); print(d.get('timestamp', '')[:10])" 2>/dev/null)
    SESSION_COUNT=$(echo "$line" | python3 -c "import sys, json; d=json.load(sys.stdin); print(d.get('session_count', 0))" 2>/dev/null)
    echo "- $TIMESTAMP: **$SESSION_COUNT** sessions"
done)

---

EOF
else
    echo "  ${YELLOW}⚠️  暂无历史数据${NC}"
    echo "  提示: 启动主动性引擎以开始收集性能数据"
    echo ""
fi

# ========================================
# 完成报告
# ========================================
cat >> "$REPORT_FILE" << EOF
---

## 📋 总结

**诊断时间**: $(date '+%Y-%m-%d %H:%M:%S')
**Agent**: $AGENT_ID
**报告文件**: $(basename "$REPORT_FILE")

**建议优先级**:
1. ${SESSION_COUNT:-0} -gt 20 ] && echo "🔴 **紧急**: 清理Session" || echo "✅ 状态良好"}
2. ${DB_SIZE_MB:-0} -gt 100 ] && echo "🟡 **重要**: 配置 retention_days" || echo "✅ 数据库正常"}
3. ${CPU_USAGE:-0} -gt 80 ] || [ ${MEMORY_USAGE:-0} -gt 80 ] && echo "🟡 **建议**: 重启Gateway" || echo "✅ 资源使用正常"}

**下一步**:
- 查看详细建议并执行优化
- 定期运行此诊断工具
- 配置主动性引擎持续监控

---

*本报告由 OpenClaw Performance Diagnostic 工具自动生成*
EOF

# ========================================
# 输出完成信息
# ========================================
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}✅ 诊断完成！${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BOLD}报告已保存:${NC}"
echo "  📄 $REPORT_FILE"
echo ""
echo -e "${BOLD}查看报告:${NC}"
echo "  cat $REPORT_FILE"
echo "  code $REPORT_FILE"
echo ""

# 显示摘要
echo -e "${BOLD}📊 诊断摘要:${NC}"
echo "═════════════════════════════════════════"
head -50 "$REPORT_FILE" | tail -30
echo ""
echo "..."
echo "(完整报告: $REPORT_FILE)"
echo ""

exit 0
