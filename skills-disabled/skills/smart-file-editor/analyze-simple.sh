#!/bin/bash

# Smart File Editor - Simplified Analysis Tool
# Analyzes files to recommend the safest editing strategy

FILE_PATH="$1"

if [ ! -f "$FILE_PATH" ]; then
    echo "ERROR: File not found: $FILE_PATH"
    exit 1
fi

# Get file info
LINE_COUNT=$(wc -l < "$FILE_PATH" | tr -d ' ')
BYTE_SIZE=$(wc -c < "$FILE_PATH" | tr -d ' ')
FILE_NAME=$(basename "$FILE_PATH")

# Analysis flags
HAS_CHINESE=false
HAS_EMOJI=false
IS_CORE_CONFIG=false

# Check for Chinese characters
if command -v python3 >/dev/null 2>&1; then
    python3_result=$(python3 2>/dev/null <<PYTHON
import sys
path = '$FILE_PATH'
try:
    with open(path, 'r', encoding='utf-8') as f:
        for char in f.read():
            if '\u4e00' <= char <= '\u9fff':
                print("true")
                sys.exit(0)
        print("false")
except:
    print("false")
PYTHON
)
    [ "$python3_result" = "true" ] && HAS_CHINESE=true
fi

# Check for emoji
if grep -qE '(🎯|🦞|✅|❌|⚠️|🔄|📝|💻|🧠)' "$FILE_PATH" 2>/dev/null; then
    HAS_EMOJI=true
fi

# Check if core config
case "$FILE_NAME" in
    IDENTITY.md|USER.md|SOUL.md|TASKS.md|HEARTBEAT.md)
        IS_CORE_CONFIG=true
        ;;
esac

# Output analysis
echo "=== Smart File Editor Analysis ==="
echo "File: $FILE_NAME"
echo "Size: $LINE_COUNT lines, $BYTE_SIZE bytes"
echo ""
echo "Content Analysis:"
echo "  Chinese:   $HAS_CHINESE"
echo "  Emoji:     $HAS_EMOJI"
echo "  Core Config: $IS_CORE_CONFIG"
echo ""

# Recommendation
if [ "$HAS_CHINESE" = true ] || [ "$HAS_EMOJI" = true ]; then
    echo "RECOMMENDATION: USE_WRITE_STRATEGY"
    echo "Reason: Contains Chinese/emoji - Edit tool has tokenization issues"
    exit 10
elif [ "$LINE_COUNT" -gt 100 ]; then
    echo "RECOMMENDATION: USE_WRITE_STRATEGY"
    echo "Reason: Large file ($LINE_COUNT lines) - higher Edit failure risk"
    exit 10
elif [ "$IS_CORE_CONFIG" = true ]; then
    echo "RECOMMENDATION: REQUIRE_CLAUDE"
    echo "Reason: Core config file - requires maximum reliability"
    exit 20
else
    echo "RECOMMENDATION: SAFE_TO_EDIT"
    echo "Reason: Simple English file - Edit tool should work"
    exit 0
fi
