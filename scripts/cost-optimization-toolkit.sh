#!/bin/bash

# 成本优化工具包
# Cost Optimization Toolkit for OpenClaw Agents

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ========================================
# 功能1: 成本分析
# ========================================
analyze_cost() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}💰 成本分析${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    SESSION_DIR="$HOME/.openclaw/agents/main/sessions"

    # 统计最近7天的session
    RECENT_SESSIONS=$(find "$SESSION_DIR" -name "*.jsonl" -mtime -7)
    TOTAL_SIZE=$(echo "$RECENT_SESSIONS" | xargs wc -c 2>/dev/null | tail -1 | awk '{print $1}' || echo 0)

    # 估算tokens (1字符≈0.5token)
    ESTIMATED_TOKENS=$((TOTAL_SIZE / 2))

    # 计算成本 (DeepSeek: ¥0.001/1K tokens)
    COST_DEEPSEEK=$(echo "scale=2; $ESTIMATED_TOKENS * 0.001 / 1000" | bc)
    COST_GPT4O=$(echo "scale=2; $ESTIMATED_TOKENS * 18 / 1000000" | bc)
    COST_CLAUDE=$(echo "scale=2; $ESTIMATED_TOKENS * 108 / 1000000" | bc)

    echo "最近7天统计:"
    echo "  Session数量: $(echo "$RECENT_SESSIONS" | wc -l | awk '{print $1}')"
    echo "  总字符数: $TOTAL_SIZE"
    echo "  估算tokens: $(echo "$ESTIMATED_TOKENS" | numfmt --to=si)"
    echo ""
    echo "如果用不同模型的成本:"
    echo "  DeepSeek官方: ¥$COST_DEEPSEEK ${GREEN}✅ 推荐${NC}"
    echo "  GPT-4o:       ¥$COST_GPT4O"
    echo "  Claude Opus:  ¥$COST_CLAUDE ${RED}❌ 太贵${NC}"
    echo ""

    # 日均
    DAILY_DEEPSEEK=$(echo "scale=2; $COST_DEEPSEEK / 7" | bc)
    echo "日均成本 (DeepSeek): ¥$DAILY_DEEPSEEK"

    # 月度预估
    MONTHLY_DEEPSEEK=$(echo "scale=2; $COST_DEEPSEEK / 7 * 30" | bc)
    echo "月度预估 (DeepSeek): ¥$MONTHLY_DEEPSEEK"
}

# ========================================
# 功能2: 缓存管理
# ========================================
manage_cache() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}💾 缓存管理${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    CACHE_DIR="$HOME/clawd/cache/queries"

    if [ ! -d "$CACHE_DIR" ]; then
        mkdir -p "$CACHE_DIR"
        echo "✅ 已创建缓存目录: $CACHE_DIR"
    fi

    CACHE_COUNT=$(ls -1 "$CACHE_DIR"/*.json 2>/dev/null | wc -l)
    CACHE_SIZE=$(du -sh "$CACHE_DIR" 2>/dev/null | cut -f1)

    echo "缓存状态:"
    echo "  缓存文件: $CACHE_COUNT"
    echo "  缓存大小: $CACHE_SIZE"
    echo ""

    echo "操作:"
    echo "  1) 查看缓存内容"
    echo "  2) 清理过期缓存"
    echo "  3) 清空所有缓存"
    echo ""
    read -p "选择 (1-3): " choice

    case $choice in
        1)
            echo ""
            echo "最近的缓存:"
            ls -lt "$CACHE_DIR"/*.json 2>/dev/null | head -5 | awk '{print $9, $6, $7, $8}'
            ;;
        2)
            echo ""
            echo "清理7天前的缓存..."
            find "$CACHE_DIR" -name "*.json" -mtime +7 -delete
            echo "✅ 已清理过期缓存"
            ;;
        3)
            echo ""
            read -p "确认清空所有缓存? (y/N): " confirm
            if [ "$confirm" = "y" ]; then
                rm -f "$CACHE_DIR"/*.json
                echo "✅ 已清空所有缓存"
            else
                echo "已取消"
            fi
            ;;
    esac
}

# ========================================
# 功能3: 知识库管理
# ========================================
manage_knowledge() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}📚 知识库管理${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    KB_DIR="$HOME/clawd/knowledge-base"

    if [ ! -d "$KB_DIR" ]; then
        mkdir -p "$KB_DIR"
        echo "✅ 已创建知识库目录: $KB_DIR"
    fi

    KB_COUNT=$(ls -1 "$KB_DIR"/*.md 2>/dev/null | wc -l)

    echo "知识库状态:"
    echo "  知识文件: $KB_COUNT"
    echo ""

    echo "操作:"
    echo "  1) 查看知识库列表"
    echo "  2) 添加知识"
    echo "  3) 搜索知识"
    echo "  4) 从session提取知识"
    echo ""
    read -p "选择 (1-4): " choice

    case $choice in
        1)
            echo ""
            echo "知识库内容:"
            ls -1 "$KB_DIR"/*.md 2>/dev/null | while read file; do
                basename "$file"
                head -3 "$file" | grep "^#"
                echo ""
            done
            ;;
        2)
            echo ""
            read -p "主题: " topic
            read -p "内容 (支持多行，输入完后按Ctrl-D): " content
            FILE="$KB_DIR/${topic}.md"
            cat > "$FILE" << EOF
# $topic

**更新时间**: $(date '+%Y-%m-%d %H:%M:%S')

$content
EOF
            echo "✅ 已保存: $FILE"
            ;;
        3)
            echo ""
            read -p "搜索关键词: " keyword
            echo ""
            echo "搜索结果:"
            grep -r -l "$keyword" "$KB_DIR"/*.md 2>/dev/null | while read file; do
                echo "📄 $(basename "$file")"
                grep --color=always "$keyword" "$file"
                echo ""
            done
            ;;
        4)
            echo ""
            echo "从最近的session提取知识..."
            python3 << 'PYTHON'
import json
from pathlib import Path
from datetime import datetime

session_dir = Path.home() / ".openclaw/agents/main/sessions"
kb_dir = Path.home() / "clawd/knowledge-base"

# 获取最近的session
recent_sessions = sorted(session_dir.glob("*.jsonl"), key=lambda x: x.stat().st_mtime, reverse=True)[:5]

extracted = 0
for session_file in recent_sessions:
    with open(session_file) as f:
        content = f.read()

    # 简单提取：包含代码块的内容
    if "```" in content and len(content) > 1000:
        topic = session_file.stem[:20]
        kb_file = kb_dir / f"auto-{topic}.md"

        with open(kb_file, 'w') as f:
            f.write(f"# {topic}\n\n")
            f.write(f"**来源**: session\n")
            f.write(f"**提取时间**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")
            f.write(content)

        print(f"✅ 已提取: {topic}")
        extracted += 1

print(f"\n总共提取: {extracted} 个知识点")
PYTHON
            ;;
    esac
}

# ========================================
# 功能4: 优化建议
# ========================================
show_optimization_tips() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}💡 优化建议${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    echo "基于你的使用情况，以下优化建议可以节省50-90%成本:"
    echo ""

    echo -e "${GREEN}1. 启用智能缓存${NC}"
    echo "   节省: 50-70%"
    echo "   方法: 相似问题从缓存读取"
    echo "   实施: ./token-optimizer.py 已经配置"
    echo ""

    echo -e "${GREEN}2. 压缩上下文${NC}"
    echo "   节省: 30-50%"
    echo "   方法: 去除冗余，只传递必要信息"
    echo "   实施: 自动集成"
    echo ""

    echo -e "${GREEN}3. 使用本地知识库${NC}"
    echo "   节省: 80%重复查询"
    echo "   方法: 常见知识本地存储"
    echo "   实施: 选择操作4 → 4 (从session提取)"
    echo ""

    echo -e "${GREEN}4. Claude Code处理代码${NC}"
    echo "   节省: 代码任务成本"
    echo "   方法: 代码编写用Claude Code本地处理"
    echo "   实施: 手动选择工具"
    echo ""

    echo -e "${YELLOW}5. 关键任务用GPT-4o${NC}"
    echo "   成本: 少量使用，月度¥10"
    echo "   方法: 只在架构设计等关键决策时用"
    echo "   条件: token量 <5000"
    echo ""

    echo "预期总节省: 70-90%"
    echo "预期月度成本: ¥30-50"
}

# ========================================
# 主菜单
# ========================================
show_menu() {
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}  ${BOLD}成本优化工具包${NC}                                              ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${BOLD}   Cost Optimization Toolkit${NC}                               ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BOLD}请选择功能:${NC}"
    echo ""
    echo "  1) 💰 成本分析"
    echo "  2) 💾 缓存管理"
    echo "  3) 📚 知识库管理"
    echo "  4) 💡 优化建议"
    echo "  5) 📊 Token估算"
    echo "  0) 退出"
    echo ""
    read -p "选择 (0-5): " choice

    case $choice in
        1)
            analyze_cost
            ;;
        2)
            manage_cache
            ;;
        3)
            manage_knowledge
            ;;
        4)
            show_optimization_tips
            ;;
        5)
            echo ""
            read -p "输入文本估算token: " text
            python3 ~/clawd/scripts/token-optimizer.py estimate "$text"
            ;;
        0)
            echo "退出"
            exit 0
            ;;
        *)
            echo -e "${RED}❌ 无效选择${NC}"
            ;;
    esac
}

# ========================================
# 主程序
# ========================================
if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
    echo "用法: $0"
    echo ""
    echo "交互式成本优化工具"
    echo ""
    echo "功能:"
    echo "  1. 分析当前成本"
    echo "  2. 管理查询缓存"
    echo "  3. 管理本地知识库"
    echo "  4. 查看优化建议"
    echo "  5. 估算token消耗"
    echo ""
    exit 0
fi

# 循环菜单
while true; do
    show_menu
done
