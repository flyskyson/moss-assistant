#!/bin/bash
#
# 方案1执行脚本：干净Agent对比测试
# 预计时间：10分钟
#

set -e

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║          🧪 方案1：干净Agent对比测试                           ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo "📋 测试目标：验证 main Agent 性能问题根源"
echo "⏱️  预计时间：10分钟"
echo ""

# 第一阶段：创建干净Agent
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔧 阶段1：创建干净Agent（约3分钟）"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 检查是否已存在
if openclaw agents list | grep -q "clean-speed-test"; then
    echo "✅ 测试Agent已存在，跳过创建"
    TEST_AGENT="clean-speed-test"
else
    echo "📝 创建测试Agent..."
    # 创建测试工作区
    TEST_WORKSPACE="$HOME/clawd-test-clean"
    mkdir -p "$TEST_WORKSPACE"

    # 创建极简配置
    echo "# MOSS - 极简速度测试版

你是MOSS，一个AI助手。

**唯一任务**：快速响应用户消息。
**测试目标**：验证响应速度。

请用最简短的方式回答。" > "$TEST_WORKSPACE/IDENTITY.md"

    # 添加agent
    openclaw agents add clean-speed-test --workspace "$TEST_WORKSPACE" --model deepseek/deepseek-chat

    echo "✅ 测试Agent创建完成"
    TEST_AGENT="clean-speed-test"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚡ 阶段2：速度对比测试（约5分钟）"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "🧪 测试1：干净Agent响应速度"
echo "-------------------------------------------"
echo "发送测试消息..."

START_TIME=$(date +%s)
openclaw agent --agent "$TEST_AGENT" --message "测试响应速度，请简短回答" > /tmp/clean-agent-test.txt 2>&1 &
CLEAN_PID=$!

# 等待最多60秒
for i in {1..60}; do
    if ! kill -0 $CLEAN_PID 2>/dev/null; then
        break
    fi
    sleep 1
    echo -n "."
done

END_TIME=$(date +%s)
CLEAN_TIME=$((END_TIME - START_TIME))

echo ""
echo "✅ 干净Agent测试完成"
echo "⏱️  响应时间：${CLEAN_TIME} 秒"
echo ""

echo "🧪 测试2：main Agent响应速度"
echo "-------------------------------------------"
echo "发送测试消息..."

START_TIME=$(date +%s)
openclaw agent --agent main --message "测试响应速度，请简短回答" > /tmp/main-agent-test.txt 2>&1 &
MAIN_PID=$!

# 等待最多60秒
for i in {1..60}; do
    if ! kill -0 $MAIN_PID 2>/dev/null; then
        break
    fi
    sleep 1
    echo -n "."
done

END_TIME=$(date +%s)
MAIN_TIME=$((END_TIME - START_TIME))

echo ""
echo "✅ main Agent测试完成"
echo "⏱️  响应时间：${MAIN_TIME} 秒"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 阶段3：结果分析（约2分钟）"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                    📊 测试结果对比                            ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
printf "%-20s | %-15s | %-15s\n" "Agent类型" "响应时间" "状态"
echo "────────────────────────────┼─────────────────┼─────────────────"
if [ $CLEAN_TIME -lt 10 ]; then
    printf "%-20s | %-15s | %-15s\n" "干净Agent" "${CLEAN_TIME} 秒" "✅ 正常"
else
    printf "%-20s | %-15s | %-15s\n" "干净Agent" "${CLEAN_TIME} 秒" "⚠️  较慢"
fi

if [ $MAIN_TIME -lt 10 ]; then
    printf "%-20s | %-15s | %-15s\n" "main Agent" "${MAIN_TIME} 秒" "✅ 正常"
else
    printf "%-20s | %-15s | %-15s\n" "main Agent" "${MAIN_TIME} 秒" "❌ 很慢"
fi
echo ""

# 分析结果
if [ $CLEAN_TIME -lt 10 ] && [ $MAIN_TIME -gt 30 ]; then
    echo "🎯 结论：干净Agent响应正常，main Agent响应慢"
    echo ""
    echo "✅ **确认问题根源**：main Agent 的配置/技能/历史导致性能问题"
    echo ""
    echo "📋 下一步建议："
    echo "  1. 检查 main Agent 加载的技能"
    echo "  2. 清理 main Agent 的会话历史"
    echo "  3. 对比两个Agent的配置差异"
    echo ""
    echo "执行命令："
    echo "  ls -la ~/.openclaw/agents/main/skills/"
    echo "  openclaw agents list"
    echo ""
elif [ $CLEAN_TIME -gt 30 ] && [ $MAIN_TIME -gt 30 ]; then
    echo "🎯 结论：两个Agent都慢"
    echo ""
    echo "⚠️  **问题不在Agent配置**：可能是系统或模型问题"
    echo ""
    echo "📋 下一步建议："
    echo "  1. 检查网络连接"
    echo "  2. 检查 DeepSeek API 状态"
    echo "  3. 查看 Gateway 日志"
    echo ""
else
    echo "🎯 结论：两个Agent响应速度都正常"
    echo ""
    echo "✅ **性能问题已解决**：之前的Session清理已生效"
    echo ""
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📁 详细日志已保存："
echo "  • 干净Agent: /tmp/clean-agent-test.txt"
echo "  • main Agent: /tmp/main-agent-test.txt"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✅ 方案1执行完成！"
