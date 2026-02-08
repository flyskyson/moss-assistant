#!/bin/bash

# Utility-Agent: 高效的 Flash 模型调用脚本
# 用途：快速使用 Gemini 2.5 Flash 处理简单任务
# 成本：$0.30/M input, $2.50/M output (比 Pro 便宜 75%)

set -e

# 配置
WORKSPACE="/Users/lijian/clawd/temp/utility-agent-ws"
MODEL="openrouter/google/gemini-2.5-flash"
SYSTEM_PROMPT="You are a highly efficient, utility-focused AI assistant. You will be given a context and a clear instruction. Execute the instruction precisely and respond only with the final result, without any conversational fluff."

# 解析参数
QUIET_MODE=false
TASK=""
CONTEXT=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --quiet|-q)
      QUIET_MODE=true
      shift
      ;;
    *)
      if [ -z "$TASK" ]; then
        TASK="$1"
      elif [ -z "$CONTEXT" ]; then
        CONTEXT="$1"
      fi
      shift
      ;;
  esac
done

# 创建工作目录
mkdir -p "$WORKSPACE"

# 显示用法
if [ -z "$TASK" ]; then
  if [ "$QUIET_MODE" = false ]; then
    echo "🤖 Utility-Agent - 高效的 AI 处理工具"
    echo ""
    echo "用法: $0 [--quiet] \"任务指令\" [上下文数据]"
    echo ""
    echo "示例:"
    echo "  $0 \"请总结以下文本\" \"长文本内容...\""
    echo "  $0 --quiet \"将 JSON 转换为 Markdown\" '{\"key\": \"value\"}'"
    echo "  $0 \"提取人名和公司\" \"文章内容...\""
    echo ""
    echo "支持的原子任务:"
    echo "  - 文本摘要 (summarization)"
    echo "  - 格式转换 (format conversion)"
    echo "  - 信息提取 (information extraction)"
    echo ""
    echo "模型: Gemini 2.5 Flash"
    echo "成本: $0.30/M input, $2.50/M output (比 Pro 便宜 75%)"
  fi
  exit 1
fi

# 构建完整提示
if [ -n "$CONTEXT" ]; then
  FULL_PROMPT="任务：${TASK}

原始内容：
${CONTEXT}

请执行上述任务，只返回最终结果，不要有任何对话或解释。"
else
  FULL_PROMPT="${TASK}"
fi

# 调用 OpenClaw agent（使用 Flash 模型）
if [ "$QUIET_MODE" = false ]; then
  echo "🚀 调用 Utility-Agent (Gemini 2.5 Flash)..."
  echo ""
fi

# 通过 Gateway 调用，使用虚拟号码创建独立会话（避免上下文干扰）
# 使用随机前缀 + 时间戳确保不会与任何现有会话冲突
TIMESTAMP=$(date +%s%N)
VIRTUAL_NUMBER="999utility${TIMESTAMP}"
OUTPUT=$(openclaw agent \
  --to "$VIRTUAL_NUMBER" \
  --message "$FULL_PROMPT" \
  2>&1)

# 检查是否有错误
if [ $? -ne 0 ]; then
  if [ "$QUIET_MODE" = false ]; then
    echo "❌ Error: OpenClaw agent call failed" >&2
  fi
  exit 1
fi

# 过滤掉 Doctor 输出和会话上下文，只保留 AI 的实际响应
# Doctor 输出包含 "◇" 和 "Doctor warnings/changes"
CLEANED_OUTPUT=$(echo "$OUTPUT" | \
  # 删除所有初始化块（从 --- 📋 会话初始化完成 到下一个 ---）
  sed '/--- 📋 会话初始化完成/,/--- 📅 /d' | \
  # 删除所有标题块（以 ## 开头）
  grep -v '^## ' | \
  # 删除所有列表块（以 - 开头）
  grep -v '^-' | \
  # 删除 Doctor 警告块
  sed '/◇.*Doctor warnings/,/├.*──────────────────/d' | \
  # 删除 Doctor changes 块
  sed '/◇.*Doctor changes/,/├.*──────────────────/d' | \
  # 删除 Doctor 块
  sed '/◇.*Doctor ─/,/├.*──────────────────/d' | \
  # 删除所有包含 │ 的行
  grep -v '^│' | \
  # 删除所有包含 ◇ 的行
  grep -v '^◇' | \
  # 删除包含 "Run.*openclaw doctor" 的行
  grep -v 'Run "openclaw doctor' | \
  # 删除包含 "V8 - User" 的行（Agent 思考过程）
  grep -v 'V8 - User' | \
  # 删除包含 "V8 - User provided response" 的行
  grep -v 'V8 - User provided' | \
  # 删除空行
  sed '/^$/d' | \
  # 将多行合并为一行，用空格分隔
  tr '\n' ' ' | \
  # 压缩多个空格为一个
  sed 's/[[:space:]]\+/ /g' | \
  # 去除首尾空格
  sed 's/^ *//;s/ *$//')

# 如果清理后为空，返回原始输出
if [ -z "$CLEANED_OUTPUT" ]; then
  CLEANED_OUTPUT="$OUTPUT"
fi

# 只输出 AI 的响应内容
echo "$CLEANED_OUTPUT"

if [ "$QUIET_MODE" = false ]; then
  echo ""
  echo "✅ 处理完成"
  echo ""
  echo "💡 提示: 使用 Flash 模型比 Pro 便宜 75%，适合简单重复任务"
fi
