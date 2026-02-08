#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""Quick test for model router - 通过创建测试文件并调用路由器"""

import subprocess
import sys

# 创建测试文件
test_files = {
    'quick_question.txt': 'This is a simple question with no special characters',
    'research.txt': 'This is a complex research task requiring deep reasoning and analysis',
    'code.py': 'def function():\n    pass'
}

# 创建测试文件
for filename, content in test_files.items():
    filepath = f'/tmp/{filename}'
    with open(filepath, 'w') as f:
        f.write(content)
    print(f"Created: {filepath}")

print("\n=== Test 1: Quick Question (should use mimo-v2-flash) ===")
result = subprocess.run(
    ['python3', '/Users/lijian/clawd/scripts/model-router.py', '/tmp/quick_question.txt'],
    capture_output=True,
    text=True
)
print(result.stdout)

print("=== Test 2: Research Task (should use deepseek-v3.2) ===")
# Note: router needs task type as second arg, but we can't pass it easily via CLI
# For now, we'll test with a file and see what default routing happens
result = subprocess.run(
    ['python3', '/Users/lijian/clawd/scripts/model-router.py', '/tmp/research.txt'],
    capture_output=True,
    text=True
)
print(result.stdout)

print("=== Test 3: Code File (should use minimax-m2.1 for complex tasks) ===")
result = subprocess.run(
    ['python3', '/Users/lijian/clawd/scripts/model-router.py', '/tmp/code.py', 'code_refactoring'],
    capture_output=True,
    text=True
)
print(result.stdout)

