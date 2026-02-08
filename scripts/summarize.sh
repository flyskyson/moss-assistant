#!/bin/bash

# Simple summarization tool using OpenRouter API
# Usage: ./summarize.sh "instruction" "content"

set -e

INSTRUCTION="$1"
CONTENT="${2:-}"

if [ -z "$INSTRUCTION" ] || [ -z "$CONTENT" ]; then
    echo "Usage: $0 \"instruction\" \"content\""
    exit 1
fi

# Get API key from environment or OpenClaw config
OPENROUTER_API_KEY="${OPENROUTER_API_KEY:-}"

if [ -z "$OPENROUTER_API_KEY" ]; then
    # Try to get from openclaw config
    if [ -f "$HOME/.openclaw/openclaw.json" ]; then
        # Extract openrouter profile - this is a simplified approach
        # In production, you might want to use jq or a proper JSON parser
        echo "Error: OPENROUTER_API_KEY not set in environment"
        exit 1
    else
        echo "Error: OPENROUTER_API_KEY not set and openclaw config not found"
        exit 1
    fi
fi

# Prepare the prompt
PROMPT="上下文：${CONTENT}

指令：${INSTRUCTION}

请执行以上指令，只返回最终结果，不要有任何对话式的废话。"

# Call OpenRouter API
curl -s https://openrouter.ai/api/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OPENROUTER_API_KEY" \
  -d "{
    \"model\": \"google/gemini-2.0-flash-exp:free\",
    \"messages\": [
      {\"role\": \"system\", \"content\": \"You are a helpful assistant that summarizes content concisely.\"},
      {\"role\": \"user\", \"content\": \"${PROMPT}\"}
    ]
  }" | python3 -c "import sys, json; print(json.load(sys.stdin)['choices'][0]['message']['content'])"
