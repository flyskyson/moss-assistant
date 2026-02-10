#!/bin/bash

# 每日复盘脚本 - 极简版
# 自动生成每日复盘报告

set -e

WORKSPACE="/Users/lijian/clawd"
MEMORY_DIR="$WORKSPACE/memory"

# 当前日期
TODAY=$(date +"%Y-%m-%d")
YESTERDAY=$(date -v-1d +"%Y-%m-%d")
YESTERDAY_FILE="$MEMORY_DIR/$YESTERDAY.md"
OUTPUT_FILE="$MEMORY_DIR/retrospect-$YESTERDAY.md"

echo "📊 开始生成每日复盘报告..."

# 检查文件是否存在
if [ ! -f "$YESTERDAY_FILE" ]; then
    echo "⚠️ 找不到 $YESTERDAY.md，创建基础报告"
    cat > "$OUTPUT_FILE" << EOF
# 📊 每日复盘报告 | $YESTERDAY

## 🎯 概述
- **日期**: $YESTERDAY
- **状态**: 无详细记录

## 🔮 建议
- 养成每日记录习惯
- 使用模板创建记忆文件

*报告生成于 $(date)*
EOF
    echo "✅ 基础复盘报告已创建"
    exit 0
fi

# 生成报告
cat > "$OUTPUT_FILE" << EOF
# 📊 每日复盘报告 | $YESTERDAY

## 🎯 昨日概览
$(head -5 "$YESTERDAY_FILE" | grep -v "^#" | sed 's/^/- /')

## ✅ 完成事项
$(grep "✅" "$YESTERDAY_FILE" | head -5 | sed 's/✅/- ✅/')

## 🔄 进行中事项
$(grep "🔄" "$YESTERDAY_FILE" | head -5 | sed 's/🔄/- 🔄/')

## 📝 关键记录
$(grep -i "重要\|决策\|突破" "$YESTERDAY_FILE" | head -3 | sed 's/^/- /')

## 🎯 今日建议
1. 回顾昨日进度
2. 制定今日计划
3. 保持记录习惯

---

**详细记录**: [$YESTERDAY.md](./$YESTERDAY.md)

*复盘报告自动生成于 $(date)*
EOF

# 添加链接到原文件
echo "" >> "$YESTERDAY_FILE"
echo "---" >> "$YESTERDAY_FILE"
echo "## 📊 复盘报告" >> "$YESTERDAY_FILE"
echo "每日复盘已生成: [retrospect-$YESTERDAY.md](./retrospect-$YESTERDAY.md)" >> "$YESTERDAY_FILE"

echo "✅ 复盘报告生成完成: $OUTPUT_FILE"
echo "📊 已链接到: $YESTERDAY_FILE"

exit 0