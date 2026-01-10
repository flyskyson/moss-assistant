import re

test_input = "你能扫描C:\\Users\\flyskyson\\moss-assistant的文件，并给我优化的建议吗"

# 测试正则表达式
path_match = re.search(r'([A-Z]:\\(?:[^"\\]+\\)*[^"\\]+)', test_input)

if path_match:
    print(f"Match found: {path_match.group(1)}")
else:
    print("No match")

# 尝试更简单的正则
path_match2 = re.search(r'([A-Z]:\\[^，\s]+)', test_input)
if path_match2:
    print(f"Simple match: {path_match2.group(1)}")
