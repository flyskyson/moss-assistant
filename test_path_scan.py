"""
测试路径扫描功能
验证 MOSS 能否正确识别和扫描用户指定的任意路径
"""

import sys
from pathlib import Path

# 添加当前目录到路径
sys.path.insert(0, str(Path(__file__).parent))

from moss import MOSSAssistant

print("=" * 70)
print("MOSS Assistant - 路径扫描测试")
print("=" * 70)
print()

# 初始化 MOSS
moss = MOSSAssistant()

# 测试用例：用户指定扫描 moss-assistant 目录
test_input = "你能扫描C:\\Users\\flyskyson\\moss-assistant的文件，并给我优化的建议吗"

print(f"用户输入: {test_input}")
print()
print("测试关键词检测...")
print()

# 调用工具检查方法
tool_result = moss._check_and_call_tools(test_input)

if tool_result:
    print("[PASS] Tool called successfully!")
    print()
    print("=== Tool Result ===")
    print(tool_result)
    print()
    print("=== Data Authenticity Check ===")
    print("- Checking for real file names...")
    if "moss.py" in tool_result:
        print("  [PASS] Real file: moss.py")
    if "app.py" in tool_result:
        print("  [PASS] Real file: app.py")
    if "config.yaml" in tool_result:
        print("  [PASS] Real file: config.yaml")
    if "2024年1月15日" in tool_result:
        print("  [FAIL] Fabricated time!")
    if "training_data.json" in tool_result:
        print("  [FAIL] Fabricated file!")
else:
    print("[FAIL] Tool not called")
    print("Keyword detection failed")

print()
print("=" * 70)
