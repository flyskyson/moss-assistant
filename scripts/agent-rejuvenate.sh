#!/bin/bash

# Agent年轻化脚本
# 提取经验、清理session、优化性能
# Usage: ./agent-rejuvenate.sh [agent-id]

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

AGENT_ID="${1:-main}"
SESSION_DIR="$HOME/.openclaw/agents/$AGENT_ID/sessions"
WORKSPACE="$HOME/clawd"

echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}  ${BOLD}Agent年轻化工具${NC}                                              ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  ${BOLD}   Agent Rejuvenation Tool${NC}                                     ${CYAN}║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BOLD}Agent ID:${NC} $AGENT_ID"
echo ""

# 检查Agent是否存在
if [ ! -d "$SESSION_DIR" ]; then
    echo -e "${RED}❌ Agent不存在: $AGENT_ID${NC}"
    echo "可用的Agent:"
    ls -1 "$HOME/.openclaw/agents/" 2>/dev/null | grep -v "^total$" || echo "无"
    exit 1
fi

# ========================================
# 步骤1: 提取经验
# ========================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}📝 步骤1: 提取经验${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

python3 << PYTHON
import json
from pathlib import Path
from datetime import datetime, timedelta
import sys

session_dir = Path("$SESSION_DIR")
workspace = Path("$WORKSPACE")

if not session_dir.exists():
    print(f"❌ Session目录不存在: {session_dir}")
    sys.exit(1)

# 获取所有session文件
session_files = list(session_dir.glob("*.jsonl"))
total_sessions = len(session_files)

print(f"找到 {total_sessions} 个session文件")

if total_sessions == 0:
    print("✅ 无需提取，没有session文件")
    sys.exit(0)

# 获取最近7天的session
cutoff = datetime.now() - timedelta(days=7)
recent_sessions = [
    f for f in session_files
    if f.stat().st_mtime > cutoff.timestamp()
]

print(f"最近7天: {len(recent_sessions)} 个session")

# 提取成功模式
success_patterns = []
failed_attempts = []

for session in recent_sessions[:10]:  # 只处理最近10个
    try:
        with open(session, 'r') as f:
            lines = f.readlines()

            # 提取assistant的回答
            for i, line in enumerate(lines):
                try:
                    data = json.loads(line)
                    if data.get('role') == 'assistant':
                        content = data.get('content', '')
                        if len(content) > 50:
                            success_patterns.append(content[:300])
                except:
                    pass
    except Exception as e:
        failed_attempts.append(str(e))

print(f"✅ 提取了 {len(success_patterns)} 个成功模式")

# 保存到EXPERIENCE.md
experience_file = workspace / "EXPERIENCE.md"

# 创建新文件或追加
with open(experience_file, 'a') as f:
    f.write(f"\n## {datetime.now().strftime('%Y-%m-%d %H:%M')} 年轻化经验提取\n\n")
    f.write(f"### 统计\n")
    f.write(f"- 总session数: {total_sessions}\n")
    f.write(f"- 最近7天: {len(recent_sessions)}\n")
    f.write(f"- 成功模式: {len(success_patterns)}\n\n")

    if success_patterns:
        f.write(f"### 成功模式 (前10个)\n\n")
        for i, pattern in enumerate(success_patterns[:10], 1):
            f.write(f"{i}. {pattern[:100]}...\n")

print(f"✅ 经验已保存到: {experience_file}")
PYTHON

echo ""

# ========================================
# 步骤2: 清理旧session
# ========================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}🧹 步骤2: 清理旧session${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

cd "$SESSION_DIR"
TOTAL_COUNT=$(ls -1 *.jsonl 2>/dev/null | wc -l)
echo "当前session数: $TOTAL_COUNT"

if [ $TOTAL_COUNT -gt 10 ]; then
    DELETE_COUNT=$((TOTAL_COUNT - 10))
    echo "将删除 $DELETE_COUNT 个旧session文件，保留最近10个"

    # 创建备份目录
    BACKUP_DIR="$WORKSPACE/sessions-backup/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"

    # 备份将被删除的文件
    ls -t *.jsonl | tail -n +11 | xargs -I {} cp {} "$BACKUP_DIR/"

    # 删除旧文件
    ls -t *.jsonl | tail -n +11 | xargs rm -f

    echo -e "${GREEN}✅ 已删除 ${DELETE_COUNT} 个旧session${NC}"
    echo -e "${GREEN}✅ 备份位置: $BACKUP_DIR${NC}"
else
    echo -e "${YELLOW}⚠️  session数 ≤10，无需清理${NC}"
fi

echo ""

# ========================================
# 步骤3: 清理工作区临时文件
# ========================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}🧹 步骤3: 清理工作区${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if [ -d "$WORKSPACE/temp" ]; then
    TEMP_SIZE=$(du -sh "$WORKSPACE/temp" 2>/dev/null | cut -f1)
    rm -rf "$WORKSPACE/temp"/*
    echo -e "${GREEN}✅ 临时文件已清理 (大小: $TEMP_SIZE)${NC}"
else
    echo "⚠️  没有temp目录"
fi

echo ""

# ========================================
# 步骤4: 重启Gateway
# ========================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}🔄 步骤4: 重启Gateway${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo "重启OpenClaw Gateway..."
pkill -f "openclaw-gateway" 2>/dev/null || true
sleep 2

# 检查Gateway是否在运行
if pgrep -f "openclaw-gateway" > /dev/null; then
    echo "Gateway已运行"
else
    echo "Gateway未运行，无需重启"
fi

echo ""

# ========================================
# 步骤5: 测试性能
# ========================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}⚡ 步骤5: 测试性能${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo "测试Agent响应时间..."
echo "任务: '你好，请简单介绍一下你自己'"

START=$(date +%s)
openclaw agent --agent "$AGENT_ID" --message "你好，请简单介绍一下你自己" 2>&1 | head -5
END=$(date +%s)

ELAPSED=$((END - START))
echo ""
echo -e "${BOLD}响应时间:${NC} ${ELAPSED}秒"

if [ $ELAPSED -lt 10 ]; then
    echo -e "${GREEN}✅✅✅ Agent性能优秀！ (<10秒)${NC}"
elif [ $ELAPSED -lt 30 ]; then
    echo -e "${YELLOW}⚠️  Agent性能良好 (10-30秒)${NC}"
else
    echo -e "${RED}❌ Agent响应较慢 (>30秒)，可能需要进一步优化${NC}"
fi

echo ""

# ========================================
# 总结
# ========================================
echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}  ${BOLD}📊 年轻化完成${NC}                                                ${CYAN}║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BOLD}Agent:${NC} $AGENT_ID"
echo -e "${BOLD}时间:${NC} $(date '+%Y-%m-%d %H:%M:%S')"
echo ""
echo -e "${BOLD}完成的操作:${NC}"
echo "  ✅ 提取经验 → EXPERIENCE.md"
echo "  ✅ 清理旧session → 保留最近10个"
echo "  ✅ 清理工作区临时文件"
echo "  ✅ 重启Gateway"
echo ""
echo -e "${BOLD}下一步:${NC}"
echo "  1. 查看提取的经验: cat ~/clawd/EXPERIENCE.md"
echo "  2. 观察Agent性能变化"
echo "  3. 建议每周执行一次此脚本"
echo ""
echo -e "${BOLD}自动化建议:${NC}"
echo "  添加到crontab: 0 3 * * 0 ~/clawd/scripts/agent-rejuvenate.sh"
echo "  (每周日凌晨3点自动执行)"
echo ""
