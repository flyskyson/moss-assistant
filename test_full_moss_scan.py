import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

from moss import MOSSAssistant

print("Testing MOSS path scanning...")
print()

moss = MOSSAssistant()

test_input = "你能扫描C:\\Users\\flyskyson\\moss-assistant的文件，并给我优化的建议吗"
print(f"User input: {test_input}\n")
print("=" * 70)
print()

# 获取工具结果
tool_result = moss._check_and_call_tools(test_input)

if tool_result:
    # Save to file to avoid encoding issues
    with open("scan_output.txt", "w", encoding="utf-8") as f:
        f.write(tool_result)
    print("Output saved to scan_output.txt")
    print()
    print("=" * 70)
    print("\nVerification:")
    print(f"[OK] Time is 2026: {('2026-01-10' in tool_result)}")
    print(f"[OK] Has moss.py: {('moss.py' in tool_result)}")
    print(f"[OK] Has app.py: {('app.py' in tool_result)}")
    print(f"[OK] Has config.yaml: {('config.yaml' in tool_result)}")
    print(f"[OK] No 2024: {('2024年' not in tool_result)}")
    print(f"[OK] No training_data.json: {('training_data.json' not in tool_result)}")
else:
    print("ERROR: Tool not called!")
