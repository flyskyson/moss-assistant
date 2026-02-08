#!/bin/bash
# OpenClaw 系统状态检查脚本
# 使用方法: ./scripts/check-system-status.sh

echo "================================"
echo "  OpenClaw 系统状态检查"
echo "================================"
echo ""

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查 Ollama
echo "🔧 服务状态"
echo "-----------"
if lsof -i :11434 > /dev/null 2>&1; then
    OLLAMA_PID=$(lsof -t -i :11434)
    echo -e "${GREEN}✅ Ollama${NC}: 运行中 (PID: $OLLAMA_PID)"
else
    echo -e "${RED}❌ Ollama${NC}: 未运行"
    echo "   启动命令: ollama serve > /tmp/ollama.log 2>&1 &"
fi

# 检查 Gateway
if lsof -i :18789 > /dev/null 2>&1; then
    GATEWAY_PID=$(lsof -t -i :18789)
    echo -e "${GREEN}✅ Gateway${NC}: 运行中 (PID: $GATEWAY_PID)"
else
    echo -e "${RED}❌ Gateway${NC}: 未运行"
    echo "   启动命令: openclaw gateway start"
fi

echo ""
echo "📚 知识库统计"
echo "-----------"

# 统计各类文件
WORKSPACE=~/clawd

if [ -d "$WORKSPACE/projects" ]; then
    PROJECT_COUNT=$(ls -1 "$WORKSPACE/projects" 2>/dev/null | wc -l | tr -d ' ')
    echo -e "🎯 项目: ${GREEN}$PROJECT_COUNT${NC} 个"
else
    echo -e "🎯 项目: ${YELLOW}projects/ 目录不存在${NC}"
fi

if [ -d "$WORKSPACE/docs" ]; then
    DOC_COUNT=$(ls -1 "$WORKSPACE/docs" 2>/dev/null | wc -l | tr -d ' ')
    echo -e "📄 文档: ${GREEN}$DOC_COUNT${NC} 个"
else
    echo -e "📄 文档: ${YELLOW}docs/ 目录不存在${NC}"
fi

if [ -d "$WORKSPACE/scripts" ]; then
    SCRIPT_COUNT=$(ls -1 "$WORKSPACE/scripts" 2>/dev/null | grep -v '^\.' | wc -l | tr -d ' ')
    echo -e "🔧 脚本: ${GREEN}$SCRIPT_COUNT${NC} 个"
else
    echo -e "🔧 脚本: ${YELLOW}scripts/ 目录不存在${NC}"
fi

if [ -d "$WORKSPACE/areas" ]; then
    AREA_COUNT=$(find "$WORKSPACE/areas" -type f 2>/dev/null | wc -l | tr -d ' ')
    echo -e "📖 技术文档: ${GREEN}$AREA_COUNT${NC} 个"
else
    echo -e "📖 技术文档: ${YELLOW}areas/ 目录不存在${NC}"
fi

echo ""
echo "📋 最近更新"
echo "-----------"

if [ -f "$WORKSPACE/index.md" ]; then
    INDEX_UPDATE=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$WORKSPACE/index.md" 2>/dev/null || stat -c "%y" "$WORKSPACE/index.md" 2>/dev/null | cut -d'.' -f1)
    echo "index.md: $INDEX_UPDATE"
fi

if [ -f "$WORKSPACE/MEMORY.md" ]; then
    MEMORY_UPDATE=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$WORKSPACE/MEMORY.md" 2>/dev/null || stat -c "%y" "$WORKSPACE/MEMORY.md" 2>/dev/null | cut -d'.' -f1)
    echo "MEMORY.md: $MEMORY_UPDATE"
fi

echo ""
echo "⚠️  问题检测"
echo "-----------"

ISSUES_FOUND=0

# 检查 Ollama
if ! lsof -i :11434 > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Ollama 未运行，记忆搜索功能不可用${NC}"
    ISSUES_FOUND=1
fi

# 检查 Gateway
if ! lsof -i :18789 > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Gateway 未运行，无法使用 MOSS${NC}"
    ISSUES_FOUND=1
fi

# 检查今天的记忆文件
TODAY=$(date +%Y-%m-%d)
if [ ! -f "$WORKSPACE/memory/$TODAY.md" ]; then
    echo -e "${YELLOW}⚠️  今天的记忆文件不存在: memory/$TODAY.md${NC}"
    ISSUES_FOUND=1
fi

if [ $ISSUES_FOUND -eq 0 ]; then
    echo -e "${GREEN}✅ 未发现问题，系统运行正常${NC}"
fi

echo ""
echo "================================"
echo "检查完成！"
echo "================================"
