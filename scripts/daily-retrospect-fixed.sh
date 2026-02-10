#!/bin/bash

# 每日复盘脚本 v1.1 - 修复版
# 自动分析当天工作，生成结构化复盘报告

set -e

# 配置文件
WORKSPACE="/Users/lijian/clawd"
TEMPLATE_FILE="$WORKSPACE/templates/daily-retrospect.md"
MEMORY_DIR="$WORKSPACE/memory"
LOG_FILE="$WORKSPACE/logs/daily-retrospect.log"

# 当前日期
TODAY=$(date +"%Y-%m-%d")
YESTERDAY=$(date -v-1d +"%Y-%m-%d")
RETROSPECT_FILE="$MEMORY_DIR/$YESTERDAY.md"
OUTPUT_FILE="$MEMORY_DIR/retrospect-$YESTERDAY.md"

# 创建日志目录
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=== 每日复盘开始于 $(date) ==="

# 1. 检查内存文件是否存在
if [ ! -f "$RETROSPECT_FILE" ]; then
    echo "❌ 找不到昨日的记忆文件: $RETROSPECT_FILE"
    exit 1
fi

# 2. 解析昨日文件内容
echo "📊 分析昨日工作数据..."

# 提取基本信息
TITLE_LINE=$(grep -i "^# " "$RETROSPECT_FILE" | head -1)
MAIN_THEME=$(echo "$TITLE_LINE" | sed 's/^# //')

# 统计文件变化（简化版）
NEW_FILES_COUNT=$(grep -c "✅ 新增" "$RETROSPECT_FILE" 2>/dev/null || echo "0")
MODIFIED_FILES_COUNT=$(grep -c "🔄 修改" "$RETROSPECT_FILE" 2>/dev/null || echo "0")

# 提取完成的任务（简化提取逻辑）
COMPLETED_TASKS=$(grep -A2 "✅ 完成" "$RETROSPECT_FILE" | head -5 | sed ':a;N;$!ba;s/\n/ | /g')
IN_PROGRESS_TASKS=$(grep -A2 "🔄 进行中" "$RETROSPECT_FILE" | head -5 | sed ':a;N;$!ba;s/\n/ | /g')

# 3. 生成复盘报告
echo "📝 生成复盘报告..."

# 读取模板
TEMPLATE_CONTENT=$(cat "$TEMPLATE_FILE")

# 使用更安全的方式替换模板变量
REPORT_CONTENT=$(echo "$TEMPLATE_CONTENT" | \
    sed -e "s/{{DATE}}/$YESTERDAY/g" \
        -e "s/{{MAIN_THEME}}/$MAIN_THEME/g" \
        -e "s/{{NEW_FILES_COUNT}}/$NEW_FILES_COUNT/g" \
        -e "s/{{MODIFIED_FILES_COUNT}}/$MODIFIED_FILES_COUNT/g" \
        -e "s/{{PROJECT_PROGRESS}}/$COMPLETED_TASKS/g" \
        -e "s/{{TECHNICAL_ACHIEVEMENTS}}/$IN_PROGRESS_TASKS/g")

# 添加生成时间
GENERATION_TIME=$(date "+%Y-%m-%d %H:%M:%S")
REPORT_CONTENT=$(echo "$REPORT_CONTENT" | sed -e "s/{{GENERATION_TIME}}/$GENERATION_TIME/g")

# 4. 写入复盘文件
echo "$REPORT_CONTENT" > "$OUTPUT_FILE"

# 5. 更新昨日记忆文件（添加复盘链接）
echo "" >> "$RETROSPECT_FILE"
echo "---" >> "$RETROSPECT_FILE"
echo "## 📊 复盘报告" >> "$RETROSPECT_FILE"
echo "每日复盘已生成: [retrospect-$YESTERDAY.md](./retrospect-$YESTERDAY.md)" >> "$RETROSPECT_FILE"

echo "✅ 复盘报告生成完成: $OUTPUT_FILE"
echo "📊 统计数据:"
echo "   - 新增文件: $NEW_FILES_COUNT"
echo "   - 修改文件: $MODIFIED_FILES_COUNT"
echo "   - 完成任务摘要: $COMPLETED_TASKS"
echo "   - 进行中任务摘要: $IN_PROGRESS_TASKS"

echo "=== 每日复盘结束于 $(date) ==="

exit 0