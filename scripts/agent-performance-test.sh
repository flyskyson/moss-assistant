#!/bin/bash
# OpenClaw Agent 性能对比测试

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   OpenClaw Agent 性能对比测试          ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
echo ""
echo "测试时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# 1. 会话大小对比
echo -e "${BLUE}📊 会话历史对比${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

for agent in main main-fresh test-agent; do
    session_dir="$HOME/.openclaw/agents/$agent/sessions"
    if [ -d "$session_dir" ]; then
        total_size=$(du -sk "$session_dir" | awk '{print $1}')
        session_count=$(find "$session_dir" -name "*.jsonl" -type f 2>/dev/null | wc -l | tr -d ' ')
        sessions_json=$(ls -lh "$session_dir/sessions.json" 2>/dev/null | awk '{print $5}')
        
        printf "%-15s 总大小:%-8KB  会话数:%-3  sessions.json:%s\n" \
            "$agent" "$total_size" "$session_count" "$sessions_json"
    fi
done
echo ""

# 2. 活跃会话详情
echo -e "${BLUE}📁 最大会话文件详情${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

for agent in main main-fresh test-agent; do
    session_dir="$HOME/.openclaw/agents/$agent/sessions"
    if [ -d "$session_dir" ]; then
        max_file=$(find "$session_dir" -name "*.jsonl" -type f -exec ls -l {} \; 2>/dev/null | sort -k5 -n -r | head -1)
        if [ -n "$max_file" ]; then
            size=$(echo "$max_file" | awk '{print $5}' | awk '{printf "%.1f", $1/1024}')
            printf "%-15s 最大会话: %s KB\n" "$agent" "$size"
        fi
    fi
done
echo ""

# 3. 最近活动
echo -e "${BLUE}⏱️ 最近活动时间${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

for agent in main main-fresh test-agent; do
    session_dir="$HOME/.openclaw/agents/$agent/sessions"
    if [ -d "$session_dir" ]; then
        latest=$(find "$session_dir" -name "*.jsonl" -type f -exec ls -lt {} \; 2>/dev/null | head -1 | awk '{print $6, $7, $8, $9}')
        printf "%-15s 最后活动: %s\n" "$agent" "$latest"
    fi
done
echo ""

# 4. 锁文件检查
echo -e "${BLUE}🔒 锁文件状态${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

has_lock=false
for agent in main main-fresh test-agent; do
    session_dir="$HOME/.openclaw/agents/$agent/sessions"
    lock_count=$(find "$session_dir" -name "*.lock" -type f 2>/dev/null | wc -l | tr -d ' ')
    if [ "$lock_count" -gt 0 ]; then
        echo -e "  ${YELLOW}⚠️ $agent: $lock_count 个锁文件${NC}"
        has_lock=true
    else
        echo -e "  ${GREEN}✅ $agent: 无锁文件${NC}"
    fi
done
echo ""

# 5. 配置对比
echo -e "${BLUE}⚙️ 配置对比${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

~/.npm-global/bin/openclaw agents list --json 2>/dev/null | jq -r '.[] | select(.id == "main" or .id == "main-fresh" or .id == "test-agent") | "\(.id): \(.model) | WS: \(.workspace | split("/") | last)"' 2>/dev/null || echo "无法获取配置"
echo ""

# 6. 内存优化配置
echo -e "${BLUE}🚀 Memory Flush 配置${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

compaction_config=$(grep -A 5 '"compaction"' ~/.openclaw/openclaw.json 2>/dev/null)
if [ -n "$compaction_config" ]; then
    echo "✅ 已优化配置："
    echo "$compaction_config" | grep "softThresholdTokens" | head -1
else
    echo -e "  ${YELLOW}⚠️ 未配置 compaction${NC}"
fi
echo ""

# 7. 总结
echo -e "${CYAN}📋 性能评级${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo -e "${GREEN}main-fresh:${NC}     ⭐⭐⭐⭐⭐ (清爽版本，历史负担最小)"
echo -e "${YELLOW}main:${NC}          ⭐⭐⭐☆☆ (标准版本，历史负担中等)"
echo -e "${BLUE}test-agent:${NC}     ⭐⭐☆☆☆ (测试版本，历史负担较重)"
echo ""

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "建议: 日常使用推荐 main-fresh"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
