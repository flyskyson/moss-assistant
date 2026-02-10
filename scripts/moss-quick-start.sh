#!/bin/bash

# MOSS 快速启动脚本

echo "🦞 MOSS - 快速启动"
echo ""
echo "可用命令:"
echo "  moss        - 使用test-agent（快速，11秒）"
echo "  moss-full   - 使用main agent（慢，137-304秒）"
echo "  moss-read   - 查询记忆"
echo "  moss-tasks - 查看待办任务"
echo "  moss-memory - 查询记忆"
echo "  moss-test   - 测试连接"
echo ""
echo "示例:"
echo "  moss 'Python如何读取文件？'"
echo "  moss-read '我们的核心约定'"
echo "  moss-tasks"
echo ""
echo "配置文件: ~/.zshrc"
echo "Agent状态: test-agent (工作区: ~/clawd-test)"
