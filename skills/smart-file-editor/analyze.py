#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Smart File Editor - File Analysis Tool
Analyzes files to recommend the safest editing strategy
Prevents 30+ minute hangs from Gemini Edit tool failures
"""

import sys
import os
import re

def analyze_file(file_path):
    """Analyze a file and recommend editing strategy"""

    if not os.path.exists(file_path):
        print(f"ERROR: File not found: {file_path}")
        return 1

    # Get file info
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    line_count = len(content.splitlines())
    byte_size = len(content.encode('utf-8'))
    file_name = os.path.basename(file_path)

    # Analysis flags
    has_chinese = False
    has_emoji = False
    is_core_config = False
    complex_formatting = False

    # Check for Chinese characters (CJK Unified Ideographs)
    for char in content:
        if '\u4e00' <= char <= '\u9fff':
            has_chinese = True
            break

    # Check for emoji (basic set)
    emoji_pattern = r'[\U0001F600-\U0001F64F]|[\U0001F300-\U0001F5FF]|✅|❌|⚠️|🔄|📝|💻|🧠|🎯|🚀|💡|🤔|📚|🔧|⭐|🦞'
    if re.search(emoji_pattern, content):
        has_emoji = True

    # Check if core config file
    core_configs = ['IDENTITY.md', 'USER.md', 'SOUL.md', 'TASKS.md', 'HEARTBEAT.md']
    if file_name in core_configs:
        is_core_config = True

    # Check for complex formatting
    code_block_count = content.count('```')
    nested_list_count = len(re.findall(r'^  +-', content, re.MULTILINE))
    table_count = len(re.findall(r'^\|', content, re.MULTILINE))

    if code_block_count > 2 or nested_list_count > 5 or table_count > 0:
        complex_formatting = True

    # Output analysis
    print(f"=== Smart File Editor Analysis ===")
    print(f"File: {file_name}")
    print(f"Size: {line_count} lines, {byte_size} bytes")
    print("")
    print("Content Analysis:")
    print(f"  Chinese:     {has_chinese}")
    print(f"  Emoji:       {has_emoji}")
    print(f"  Core Config: {is_core_config}")
    print(f"  Complex:     {complex_formatting}")
    print("")

    # Decision matrix
    reasons = []
    recommendation = "SAFE_TO_EDIT"

    if has_chinese:
        recommendation = "USE_WRITE_STRATEGY"
        reasons.append("Chinese characters detected (Edit tool tokenization issues)")

    if has_emoji:
        recommendation = "USE_WRITE_STRATEGY"
        reasons.append("Emoji detected (multi-byte characters cause mismatches)")

    if line_count > 100:
        recommendation = "USE_WRITE_STRATEGY"
        reasons.append(f"File is {line_count} lines (>100 = higher Edit failure risk)")

    if is_core_config:
        recommendation = "REQUIRE_CLAUDE"
        reasons.append("Core config file (requires maximum reliability)")

    if complex_formatting:
        if recommendation == "SAFE_TO_EDIT":
            recommendation = "USE_WRITE_STRATEGY"
        reasons.append(f"Complex formatting ({code_block_count} code blocks, nested structures)")

    # Output recommendation
    print("Recommendation:")

    if recommendation == "SAFE_TO_EDIT":
        print("  STRATEGY: SAFE_TO_EDIT")
        print("  → Edit tool should work (simple English file, low risk)")
        if reasons:
            print(f"  → Note: {reasons[0]}")
        return 0

    elif recommendation == "USE_WRITE_STRATEGY":
        print("  STRATEGY: USE_WRITE_STRATEGY")
        print("  → Use Read + Write workflow (Read entire file, modify, Write back)")
        print("  → Reasons:")
        for reason in reasons:
            print(f"     - {reason}")
        return 10

    elif recommendation == "REQUIRE_CLAUDE":
        print("  STRATEGY: REQUIRE_CLAUDE")
        print("  → CRITICAL: This file requires Claude Sonnet for reliable editing")
        print("  → Use Write strategy + Claude Sonnet model")
        print("  → Reasons:")
        for reason in reasons:
            print(f"     - {reason}")
        return 20

    return 0

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 analyze.py <file_path>")
        print("")
        print("Analyzes a file and recommends the safest editing strategy.")
        sys.exit(1)

    file_path = sys.argv[1]
    sys.exit(analyze_file(file_path))
