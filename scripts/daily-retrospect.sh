#!/bin/bash

# 每日复盘脚本 v2.0 - 稳定版
# 自动生成每日复盘报告

set -e

WORKSPACE="/Users/lijian/clawd"
MEMORY_DIR="$WORKSPACE/memory"
LOG_FILE="$WORKSPACE/logs/daily-retrospect.log"

# 当前日期
TODAY=$(date +"%Y-%m-%d")
YESTERDAY=$(date -v-1d +"%Y-%m-%d")
YESTERDAY_FILE="$MEMORY_DIR/$YESTERDAY.md"
OUTPUT_FILE="$MEMORY_DIR/retrospect-$YESTERDAY.md"

# 创建日志目录
mkdir -p "$(dirname "$LOG_FILE")"
mkdir -p "$MEMORY_DIR"

echo "📊 [$(date)] 开始每日复盘..." | tee -a "$LOG_FILE"

# 检查文件是否存在
if [ ! -f "$YESTERDAY_FILE" ]; then
    echo "⚠️ 找不到 $YESTERDAY.md，创建基础报告" | tee -a "$LOG_FILE"
    cat > "$OUTPUT_FILE" << EOF
# 📊 每日复盘报告 | $YESTERDAY

## 🎯 概述
- **日期**: $YESTERDAY
- **状态**: 无详细记录文件
- **生成时间**: $(date)

## 🔮 建议
1. 养成每日记录习惯
2. 使用模板创建记忆文件
3. 定期回顾复盘报告

*此报告由 MOSS 自动生成*
EOF
    echo "✅ 基础复盘报告已创建: $OUTPUT_FILE" | tee -a "$LOG_FILE"
    exit 0
fi

# 提取关键数据
COMPLETED_TASKS=$(grep -c "✅" "$YESTERDAY_FILE" || echo "0")
IN_PROGRESS_TASKS=$(grep -c "🔄" "$YESTERDAY_FILE" || echo "0")
NEW_FILES=$(grep -c "新增文件" "$YESTERDAY_FILE" || echo "0")

# 生成完整复盘报告
cat > "$OUTPUT_FILE" << EOF
# 📊 每日复盘报告 | $YESTERDAY

## 📈 数据概览
- **完成任务**: $COMPLETED_TASKS 项
- **进行中任务**: $IN_PROGRESS_TASKS 项
- **新增文件**: $NEW_FILES 个
- **完成率**: $(if [ $COMPLETED_TASKS -gt 0 ]; then echo "较高"; else echo "待提升"; fi)

## ✅ 已完成事项
$(grep "✅" "$YESTERDAY_FILE" | head -8 | sed 's/✅/- ✅/')

## 🔄 进行中事项
$(grep "🔄" "$YESTERDAY_FILE" | head -8 | sed 's/🔄/- 🔄/')

## 🧠 关键洞察
$(grep -i "突破\|创新\|学习\|理解" "$YESTERDAY_FILE" | head -3 | sed 's/^/- /')

## 💡 重要决策
$(grep -i "决策\|决定\|选择\|协议" "$YESTERDAY_FILE" | head -3 | sed 's/^/- /')

## 📊 效率分析
- **产出密度**: $(if [ $COMPLETED_TASKS -gt 5 ]; then echo "高"; elif [ $COMPLETED_TASKS -gt 2 ]; then echo "中"; else echo "低"; fi)
- **任务延续性**: $(if [ $IN_PROGRESS_TASKS -eq 0 ]; then echo "良好"; else echo "有待完成"; fi)
- **知识积累**: $(if [ $NEW_FILES -gt 0 ]; then echo "持续增长"; else echo "稳定"; fi)

## 🎯 明日建议
1. **优先级**: 先完成进行中的 $IN_PROGRESS_TASKS 项任务
2. **效率**: 保持或提升当前产出节奏
3. **记录**: 继续详细记录工作过程

## 🔗 相关文件
- **昨日完整记录**: [$YESTERDAY.md](./$YESTERDAY.md)
- **所有复盘报告**: [memory/](./)

---

*报告由 MOSS 自动生成于 $(date)*  
*生成逻辑: 分析记忆文件 → 提取关键信息 → 生成结构化报告*
EOF

# 添加链接到原文件
echo "" >> "$YESTERDAY_FILE"
echo "---" >> "$YESTERDAY_FILE"
echo "## 📊 复盘报告" >> "$YESTERDAY_FILE"
echo "每日复盘已生成: [retrospect-$YESTERDAY.md](./retrospect-$YESTERDAY.md)" >> "$YESTERDAY_FILE"

echo "✅ 复盘报告生成完成: $OUTPUT_FILE" | tee -a "$LOG_FILE"
echo "📊 统计数据: 完成$COMPLETED_TASKS项, 进行中$IN_PROGRESS_TASKS项, 新增$NEW_FILES文件" | tee -a "$LOG_FILE"

exit 0