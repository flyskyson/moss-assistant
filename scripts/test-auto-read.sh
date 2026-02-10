#!/bin/bash

echo "=== test-agent 自动读取功能测试 ==="
echo ""

echo "测试1: 普通问题（不需要读取文件）"
echo "命令: openclaw agent --agent test-agent --message \"你好\""
echo ""
start=$(date +%s)
output=$(openclaw agent --agent test-agent --message "你好，请简单介绍一下你自己" 2>&1)
end=$(date +%s)
duration=$((end - start))
echo "耗时: ${duration}秒"
echo "回答: $(echo "$output" | head -5)"
echo ""

echo "测试2: 需要访问记忆的问题"
echo "命令: openclaw agent --agent test-agent --message \"请读取MEMORY.md，告诉我我们的核心约定\""
echo ""
start=$(date +%s)
output=$(openclaw agent --agent test-agent --message "请先读取MEMORY.md，然后告诉我我们的核心约定是什么" 2>&1)
end=$(date +%s)
duration=$((end - start))
echo "耗时: ${duration}秒"
echo "回答: $(echo "$output" | head -10)"
echo ""

echo "测试3: 需要查看任务的问题"
echo "命令: openclaw agent --agent test-agent --message \"请读取TASKS.md，列出当前任务\""
echo ""
start=$(date +%s)
output=$(openclaw agent --agent test-agent --message "请先读取TASKS.md，然后告诉我当前的待办任务有哪些" 2>&1)
end=$(date +%s)
duration=$((end - start))
echo "耗时: ${duration}秒"
echo "回答: $(echo "$output" | head -10)"
echo ""

echo "=== 测试完成 ==="
