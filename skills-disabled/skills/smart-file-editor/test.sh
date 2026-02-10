#!/bin/bash

# Smart File Editor - Test and Demo
# Demonstrates the analysis capability on various file types

set -euo pipefail

echo "=== Smart File Editor - Testing ==="
echo ""

# Test 1: Simple English file (should be SAFE_TO_EDIT)
echo "Test 1: Simple English file"
echo "Creating test file..."
cat > /tmp/test_simple.txt << 'EOF'
# Simple Test File
This is a simple test file with English only.
It has no special characters or complex formatting.

Just plain text that should be safe to edit.
EOF

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANALYZE_SCRIPT="$SCRIPT_DIR/analyze.sh"

# Test 1: Simple English file (should be SAFE_TO_EDIT)
echo "Test 1: Simple English file"
echo "Creating test file..."
cat > /tmp/test_simple.txt << 'EOF'
# Simple Test File
This is a simple test file with English only.
It has no special characters or complex formatting.

Just plain text that should be safe to edit.
EOF

"$ANALYZE_SCRIPT" /tmp/test_simple.txt
echo ""

# Test 2: Chinese file (should be USE_WRITE_STRATEGY)
echo "Test 2: File with Chinese"
echo "Creating test file..."
cat > /tmp/test_chinese.md << 'EOF'
# 中文测试文件

这是一个包含中文的测试文件。
中文内容会导致 Edit 工具的匹配问题。

## 测试章节

这是一个中文段落，用来测试编辑工具的稳定性。
EOF

"$ANALYZE_SCRIPT" /tmp/test_chinese.md
echo ""

# Test 3: Emoji file (should be USE_WRITE_STRATEGY)
echo "Test 3: File with emoji"
echo "Creating test file..."
cat > /tmp/test_emoji.md << 'EOF'
# Task List 🎯

## Completed ✅
- Task 1: Initial setup ⭐
- Task 2: Configuration 📝
- Task 3: Testing 🧪

## In Progress 🔄
- Task 4: Deployment 🚀
EOF

"$ANALYZE_SCRIPT" /tmp/test_emoji.md
echo ""

# Test 4: Core config file (should be REQUIRE_CLAUDE)
echo "Test 4: Core config file simulation"
echo "Creating test file..."
cat > /tmp/test_IDENTITY.md << 'EOF'
# IDENTITY.md - Core Configuration

## My Identity
This is a core configuration file with Chinese content.
它定义了 AI Agent 的身份和行为准则。

## Principles
- 核心原则：诚实透明
- 工作方式：直接高效 ⚡
EOF

"$ANALYZE_SCRIPT" /tmp/test_IDENTITY.md
echo ""

echo "=== Testing Complete ==="
echo ""
echo "To analyze a real file:"
echo "  /Users/lijian/clawd/skills/smart-file-editor/analyze.sh /path/to/file"
echo ""
echo "Exit codes:"
echo "  0 = SAFE_TO_EDIT"
echo "  10 = USE_WRITE_STRATEGY"
echo "  20 = REQUIRE_CLAUDE"
