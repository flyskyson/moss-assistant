#!/bin/bash

# Smart File Editor - File Analysis Tool
# Analyzes files to recommend the safest editing strategy
# Prevents 30+ minute hangs from Gemini Edit tool failures

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Usage function
usage() {
    echo "Usage: $0 <file_path>"
    echo ""
    echo "Analyzes a file and recommends the safest editing strategy."
    echo ""
    echo "Output format: STRATEGY:REASON"
    echo "  STRATEGY can be: SAFE_TO_EDIT, USE_WRITE_STRATEGY, REQUIRE_CLAUDE"
    echo ""
    exit 1
}

# Check if file path provided
if [ $# -eq 0 ]; then
    usage
fi

FILE_PATH="$1"

# Check if file exists
if [ ! -f "$FILE_PATH" ]; then
    echo -e "${RED}ERROR: File not found: $FILE_PATH${NC}"
    exit 1
fi

# Analysis flags
HAS_CHINESE=false
HAS_EMOJI=false
LINE_COUNT=0
BYTE_SIZE=0
IS_CORE_CONFIG=false
COMPLEX_FORMATTING=false

# Get basic file info
LINE_COUNT=$(wc -l < "$FILE_PATH" | tr -d ' ')
BYTE_SIZE=$(wc -c < "$FILE_PATH" | tr -d ' ')

# Check for Chinese characters (using LC_ALL=C and character range)
if LC_ALL=C grep -q "$(printf '[\xE3-\xE9][\x80-\xBF][\x80-\xBF]')" "$FILE_PATH" 2>/dev/null; then
    HAS_CHINESE=true
fi

# Check for emoji (basic detection)
if grep -qE '(🎯|🦞|✅|❌|⚠️|🔄|📝|💻|🧠)' "$FILE_PATH" 2>/dev/null; then
    HAS_EMOJI=true
fi

# Check if core config file
case "$(basename "$FILE_PATH")" in
    IDENTITY.md|USER.md|SOUL.md|TASKS.md|HEARTBEAT.md)
        IS_CORE_CONFIG=true
        ;;
esac

# Check for complex formatting
# Nested markdown, multiple code blocks, tables
CODE_BLOCK_COUNT=$(grep -c '```' "$FILE_PATH" 2>/dev/null || echo "0")
NESTED_LIST_COUNT=$(grep -E '^  +-' "$FILE_PATH" 2>/dev/null | wc -l | tr -d ' ')
TABLE_COUNT=$(grep -c '^|' "$FILE_PATH" 2>/dev/null || echo "0")

if [ "$CODE_BLOCK_COUNT" -gt 2 ] || [ "$NESTED_LIST_COUNT" -gt 5 ] || [ "$TABLE_COUNT" -gt 0 ]; then
    COMPLEX_FORMATTING=true
fi

# Decision matrix
RECOMMENDATION="SAFE_TO_EDIT"
REASONS=()

# Rule 1: Chinese detected
if [ "$HAS_CHINESE" = true ]; then
    RECOMMENDATION="USE_WRITE_STRATEGY"
    REASONS+=("Chinese characters detected (Edit tool tokenization issues)")
fi

# Rule 2: Emoji detected
if [ "$HAS_EMOJI" = true ]; then
    RECOMMENDATION="USE_WRITE_STRATEGY"
    REASONS+=("Emoji detected (multi-byte characters cause mismatches)")
fi

# Rule 3: Large file
if [ "$LINE_COUNT" -gt 100 ]; then
    RECOMMENDATION="USE_WRITE_STRATEGY"
    REASONS+=("File is $LINE_COUNT lines (>100 = higher Edit failure risk)")
fi

# Rule 4: Core config file
if [ "$IS_CORE_CONFIG" = true ]; then
    RECOMMENDATION="REQUIRE_CLAUDE"
    REASONS+=("Core config file (requires maximum reliability)")
fi

# Rule 5: Complex formatting
if [ "$COMPLEX_FORMATTING" = true ]; then
    if [ "$RECOMMENDATION" = "SAFE_TO_EDIT" ]; then
        RECOMMENDATION="USE_WRITE_STRATEGY"
    fi
    REASONS+=("Complex formatting ($CODE_BLOCK_COUNT code blocks, nested structures)")
fi

# Output recommendation
echo -e "${BLUE}=== Smart File Editor Analysis ===${NC}"
echo -e "File: ${BLUE}$(basename "$FILE_PATH")${NC}"
echo -e "Size: ${BLUE}$LINE_COUNT lines${NC}, ${BLUE}$BYTE_SIZE bytes${NC}"
echo ""

# Content flags
echo -e "${BLUE}Content Analysis:${NC}"
echo -ne "  Chinese:      "
if [ "$HAS_CHINESE" = true ]; then
    echo -e "${RED}✓ DETECTED${NC}"
else
    echo -e "${GREEN}✗ None${NC}"
fi

echo -ne "  Emoji:        "
if [ "$HAS_EMOJI" = true ]; then
    echo -e "${RED}✓ DETECTED${NC}"
else
    echo -e "${GREEN}✗ None${NC}"
fi

echo -ne "  Core Config:  "
if [ "$IS_CORE_CONFIG" = true ]; then
    echo -e "${YELLOW}✓ YES${NC}"
else
    echo -e "${GREEN}✗ No${NC}"
fi

echo -ne "  Complex:      "
if [ "$COMPLEX_FORMATTING" = true ]; then
    echo -e "${YELLOW}✓ YES${NC} ($CODE_BLOCK_COUNT code blocks)"
else
    echo -e "${GREEN}✗ No${NC}"
fi

echo ""
echo -e "${BLUE}Recommendation:${NC}"

case "$RECOMMENDATION" in
    SAFE_TO_EDIT)
        echo -e "  ${GREEN}STRATEGY: SAFE_TO_EDIT${NC}"
        echo "  → Edit tool should work (simple English file, low risk)"
        if [ ${#REASONS[@]} -gt 0 ]; then
            echo "  → Note: ${REASONS[*]}"
        fi
        ;;
    USE_WRITE_STRATEGY)
        echo -e "  ${YELLOW}STRATEGY: USE_WRITE_STRATEGY${NC}"
        echo "  → Use Read + Write workflow (Read entire file, modify, Write back)"
        echo "  → Reasons:"
        for reason in "${REASONS[@]}"; do
            echo "     - $reason"
        done
        ;;
    REQUIRE_CLAUDE)
        echo -e "  ${RED}STRATEGY: REQUIRE_CLAUDE${NC}"
        echo "  → CRITICAL: This file requires Claude Sonnet for reliable editing"
        echo "  → Use Write strategy + Claude Sonnet model"
        echo "  → Reasons:"
        for reason in "${REASONS[@]}"; do
            echo "     - $reason"
        done
        echo ""
        echo "  → If Claude unavailable: Tell user to switch models or use Write strategy with extreme caution"
        ;;
esac

echo ""
echo -e "${BLUE}=== End Analysis ===${NC}"

# Exit with recommendation code for scripting
case "$RECOMMENDATION" in
    SAFE_TO_EDIT)
        exit 0
        ;;
    USE_WRITE_STRATEGY)
        exit 10
        ;;
    REQUIRE_CLAUDE)
        exit 20
        ;;
esac
