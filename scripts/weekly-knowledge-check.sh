#!/bin/bash
# 每周知识库检查脚本
# 执行时间：每周五 20:00
# 用途：检查知识库结构，生成基础报告

set -euo pipefail

# 配置
WORKSPACE=~/clawd
REPORT_DIR="$WORKSPACE/docs"
REPORT_FILE="$REPORT_DIR/weekly-report-$(date +%Y-%m-%d).md"
TEMP_REPORT="/tmp/weekly-check-$(date +%Y%m%d).md"

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "================================"
echo "  知识库周检 - $(date '+%Y-%m-%d %H:%M:%S')"
echo "================================"
echo ""

# 创建报告头
cat > "$TEMP_REPORT" << EOF
# 📊 知识库周报

**日期**: $(date '+%Y-%m-%d %H:%M:%S')
**执行人**: LaunchAgent (自动任务)

---

## 🔍 系统状态

EOF

# 1. 检查 Ollama
echo "检查 Ollama 服务..."
if lsof -i :11434 > /dev/null 2>&1; then
    OLLAMA_PID=$(lsof -t -i :11434)
    echo -e "${GREEN}✅ Ollama 运行中${NC} (PID: $OLLAMA_PID)"
    echo "- ✅ Ollama: 运行中 (PID: $OLLAMA_PID)" >> "$TEMP_REPORT"
else
    echo -e "${RED}❌ Ollama 未运行${NC}"
    echo "- ❌ Ollama: 未运行" >> "$TEMP_REPORT"
fi

# 2. 检查 Gateway
echo "检查 Gateway 服务..."
if lsof -i :18789 > /dev/null 2>&1; then
    GATEWAY_PID=$(lsof -t -i :18789)
    echo -e "${GREEN}✅ Gateway 运行中${NC} (PID: $GATEWAY_PID)"
    echo "- ✅ Gateway: 运行中 (PID: $GATEWAY_PID)" >> "$TEMP_REPORT"
else
    echo -e "${RED}❌ Gateway 未运行${NC}"
    echo "- ❌ Gateway: 未运行" >> "$TEMP_REPORT"
fi

echo "" >> "$TEMP_REPORT"

# 3. 统计知识库
echo "" >> "$TEMP_REPORT"
echo "## 📚 知识库统计" >> "$TEMP_REPORT"
echo "" >> "$TEMP_REPORT"

echo "统计知识库文件..."
if [ -d "$WORKSPACE/projects" ]; then
    PROJECT_COUNT=$(ls -1 "$WORKSPACE/projects" 2>/dev/null | wc -l | tr -d ' ')
    echo "- 🎯 项目: **$PROJECT_COUNT** 个" >> "$TEMP_REPORT"
    echo "  项目: $PROJECT_COUNT 个"
else
    echo "- 🎯 项目: 0 个" >> "$TEMP_REPORT"
fi

if [ -d "$WORKSPACE/docs" ]; then
    DOC_COUNT=$(ls -1 "$WORKSPACE/docs" 2>/dev/null | wc -l | tr -d ' ')
    echo "- 📄 文档: **$DOC_COUNT** 个" >> "$TEMP_REPORT"
    echo "  文档: $DOC_COUNT 个"
else
    echo "- 📄 文档: 0 个" >> "$TEMP_REPORT"
fi

if [ -d "$WORKSPACE/scripts" ]; then
    SCRIPT_COUNT=$(ls -1 "$WORKSPACE/scripts" 2>/dev/null | grep -v '^\.' | wc -l | tr -d ' ')
    echo "- 🔧 脚本: **$SCRIPT_COUNT** 个" >> "$TEMP_REPORT"
    echo "  脚本: $SCRIPT_COUNT 个"
else
    echo "- 🔧 脚本: 0 个" >> "$TEMP_REPORT"
fi

if [ -d "$WORKSPACE/areas" ]; then
    AREA_COUNT=$(find "$WORKSPACE/areas" -type f 2>/dev/null | wc -l | tr -d ' ')
    echo "- 📖 技术文档: **$AREA_COUNT** 个" >> "$TEMP_REPORT"
    echo "  技术文档: $AREA_COUNT 个"
else
    echo "- 📖 技术文档: 0 个" >> "$TEMP_REPORT"
fi

echo "" >> "$TEMP_REPORT"

# 4. 最近更新
echo "" >> "$TEMP_REPORT"
echo "## 📋 最近更新" >> "$TEMP_REPORT"
echo "" >> "$TEMP_REPORT"

if [ -f "$WORKSPACE/index.md" ]; then
    INDEX_STAT=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$WORKSPACE/index.md" 2>/dev/null || stat -c "%y" "$WORKSPACE/index.md" 2>/dev/null | cut -d'.' -f1)
    echo "- index.md: $INDEX_STAT" >> "$TEMP_REPORT"
fi

if [ -f "$WORKSPACE/MEMORY.md" ]; then
    MEMORY_STAT=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$WORKSPACE/MEMORY.md" 2>/dev/null || stat -c "%y" "$WORKSPACE/MEMORY.md" 2>/dev/null | cut -d'.' -f1)
    echo "- MEMORY.md: $MEMORY_STAT" >> "$TEMP_REPORT"
fi

# 5. 磁盘使用
echo "" >> "$TEMP_REPORT"
echo "## 💾 磁盘使用" >> "$TEMP_REPORT"
echo "" >> "$TEMP_REPORT"

WORKSPACE_SIZE=$(du -sh "$WORKSPACE" 2>/dev/null | cut -f1)
echo "- 知识库大小: **$WORKSPACE_SIZE**" >> "$TEMP_REPORT"
echo "  大小: $WORKSPACE_SIZE"

# 6. 完成标记
echo "" >> "$TEMP_REPORT"
echo "---" >> "$TEMP_REPORT"
echo "" >> "$TEMP_REPORT"
echo "*本报告由 LaunchAgent 自动生成*" >> "$TEMP_REPORT"
echo "*详细日志: /tmp/weekly-check.log*" >> "$TEMP_REPORT"

# 移动到最终位置
mv "$TEMP_REPORT" "$REPORT_FILE"

echo ""
echo "================================"
echo "✅ 周检完成！"
echo "================================"
echo ""
echo "📄 报告已生成: $REPORT_FILE"
echo ""
