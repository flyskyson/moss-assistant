#!/bin/bash

# 设置环境变量以供脚本使用
export DEEPSEEK_API_KEY="sk-1e040b7546b341b0bee289c8bc74ea4f"
export OPENROUTER_API_KEY="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"

echo "✓ API Keys 已设置"
echo "  - DeepSeek 官方: ${DEEPSEEK_API_KEY:0:20}..."
echo "  - OpenRouter: ${OPENROUTER_API_KEY:0:20}..."
echo ""
echo "使用方式:"
echo "  $DEEPSEEK_API_KEY  # DeepSeek 官方专线"
echo "  $OPENROUTER_API_KEY  # OpenRouter"
