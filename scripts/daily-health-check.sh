#!/bin/bash
# 每日健康检查脚本
# 执行时间：每天早上 6:00
# 用途：快速检查系统状态，报告问题

set -euo pipefail

# 配置
WORKSPACE=~/clawd
REPORT_FILE="$WORKSPACE/docs/health-check-$(date +%Y-%m-%d).md"
TODAY=$(date +%Y-%m-%d)

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 问题计数器
ISSUES=0

echo "================================"
echo "  每日健康检查 - $(date '+%Y-%m-%d %H:%M:%S')"
echo "================================"
echo ""

# 创建报告
cat > "$REPORT_FILE" << EOF
# 🏥 系统健康检查

**日期**: $(date '+%Y-%m-%d %H:%M:%S')
**执行人**: LaunchAgent (自动任务)

---

## 🔧 服务状态

EOF

# 1. 检查 Ollama
echo "检查 Ollama..."
if lsof -i :11434 > /dev/null 2>&1; then
    OLLAMA_PID=$(lsof -t -i :11434)
    echo -e "${GREEN}✅ Ollama 运行中${NC} (PID: $OLLAMA_PID)"
    echo "✅ Ollama: 运行中 (PID: $OLLAMA_PID)" >> "$REPORT_FILE"
else
    echo -e "${RED}❌ Ollama 未运行${NC}"
    echo "❌ Ollama: 未运行" >> "$REPORT_FILE"
    ISSUES=$((ISSUES + 1))
fi

# 2. 检查 Gateway
echo "检查 Gateway..."
if lsof -i :18789 > /dev/null 2>&1; then
    GATEWAY_PID=$(lsof -t -i :18789)
    echo -e "${GREEN}✅ Gateway 运行中${NC} (PID: $GATEWAY_PID)"
    echo "✅ Gateway: 运行中 (PID: $GATEWAY_PID)" >> "$REPORT_FILE"
else
    echo -e "${RED}❌ Gateway 未运行${NC}"
    echo "❌ Gateway: 未运行" >> "$REPORT_FILE"
    ISSUES=$((ISSUES + 1))
fi

echo "" >> "$REPORT_FILE"

# 3. 检查今天的记忆文件
echo "" >> "$REPORT_FILE"
echo "## 📝 文件检查" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

echo "检查记忆文件..."
if [ -f "$WORKSPACE/memory/$TODAY.md" ]; then
    echo -e "${GREEN}✅ 今天的记忆文件存在${NC}"
    echo "✅ 今天的记忆文件: memory/$TODAY.md" >> "$REPORT_FILE"
else
    echo -e "${YELLOW}⚠️  今天的记忆文件不存在${NC}"
    echo "⚠️  今天的记忆文件: 不存在 (memory/$TODAY.md)" >> "$REPORT_FILE"
fi

# 4. 检查磁盘空间
echo "" >> "$REPORT_FILE"
echo "## 💾 磁盘空间" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

WORKSPACE_SIZE=$(du -sm "$WORKSPACE" 2>/dev/null | cut -f1)
echo "知识库大小: ${WORKSPACE_SIZE}M" >> "$REPORT_FILE"

# 警告：如果超过 1GB
if [ "$WORKSPACE_SIZE" -gt 1024 ]; then
    echo -e "${YELLOW}⚠️  知识库超过 1GB (${WORKSPACE_SIZE}M)${NC}"
    echo "⚠️  超过 1GB，建议清理" >> "$REPORT_FILE"
    ISSUES=$((ISSUES + 1))
else
    echo -e "${GREEN}✅ 磁盘空间正常${NC} (${WORKSPACE_SIZE}M)"
    echo "✅ 磁盘空间正常 (${WORKSPACE_SIZE}M)" >> "$REPORT_FILE"
fi

# 5. 错误日志检查
echo "" >> "$REPORT_FILE"
echo "## 📋 错误日志" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

if [ -f /tmp/ollama.err ] && [ -s /tmp/ollama.err ]; then
    echo "⚠️  Ollama 错误日志非空" >> "$REPORT_FILE"
    ISSUES=$((ISSUES + 1))
else
    echo "✅ Ollama 错误日志为空" >> "$REPORT_FILE"
fi

# 6. 总结
echo "" >> "$REPORT_FILE"
echo "---" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

if [ $ISSUES -eq 0 ]; then
    echo "✅ **未发现问题，系统运行正常**" >> "$REPORT_FILE"
    echo -e "${GREEN}✅ 未发现问题，系统运行正常${NC}"
else
    echo "⚠️  **发现 $ISSUES 个问题，需要关注**" >> "$REPORT_FILE"
    echo -e "${YELLOW}⚠️  发现 $ISSUES 个问题，需要关注${NC}"
fi

echo "" >> "$REPORT_FILE"
echo "*本报告由 LaunchAgent 自动生成*" >> "$REPORT_FILE"

echo ""
echo "================================"
echo "✅ 健康检查完成！"
echo "================================"
echo ""
echo "📄 报告已生成: $REPORT_FILE"
echo ""
