#!/bin/bash
#
# MOSS 核心配置快速注入脚本
# 用法: 复制整个脚本内容，粘贴到终端执行
#

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║          📮 正在告诉 MOSS 核心配置位置...                     ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# 发送核心配置信息给 MOSS
openclaw agent --agent main --message "MOSS, 请记住核心配置文件位置：

📋 核心配置文件 (都在 ~/clawd/ 目录):
1. HEARTBEAT.md - 每日任务清单
2. SOUL.md - 性格配置
3. USER.md - 用户偏好
4. TASKS.md - 任务列表
5. WORKSPACE-STRUCTURE.md - 工作区架构
6. IDENTITY.md - 身份定义

🔍 主动性引擎:
- 控制脚本: ~/clawd/scripts/proactive-engine-control.sh
- 报告命令: ./scripts/proactive-engine-control.sh main report

📝 记忆系统:
- 目录: ~/clawd/memory/
- 格式: YYYY-MM-DD.md

🤖 三方协作模式:
- 用户: 决策层
- MOSS: 设计层
- 技术后台(Claude Code): 执行层

请记住这些位置，需要时主动检索。"

echo ""
echo "✅ 完成！MOSS 已收到核心配置信息。"
