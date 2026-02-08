#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Agent Router Integration Test
Agent 路由集成测试脚本

测试所有 Agent 的路由功能和决策逻辑

2026-02-08
"""

import subprocess
import sys
import os
from pathlib import Path

# 颜色输出
GREEN = '\033[0;32m'
YELLOW = '\033[1;33m'
BLUE = '\033[0;34m'
NC = '\033[0m'

def print_header(text):
    """打印标题"""
    print(f"\n{BLUE}{'='*60}{NC}")
    print(f"{BLUE}{text}{NC}")
    print(f"{BLUE}{'='*60}{NC}\n")

def print_success(text):
    """打印成功信息"""
    print(f"{GREEN}✓ {text}{NC}")

def print_info(text):
    """打印信息"""
    print(f"{YELLOW}ℹ {text}{NC}")

def test_agent(agent_name, file_path, task_type, expected_model):
    """测试单个 Agent 路由"""
    print_info(f"Testing {agent_name}...")

    # 调用路由器
    result = subprocess.run(
        ['python3', 'agent-router-integration.py', agent_name, file_path, task_type],
        capture_output=True,
        text=True,
        cwd='/Users/lijian/clawd/scripts'
    )

    # 检查输出
    if expected_model in result.stdout:
        print_success(f"{agent_name} correctly routed to {expected_model}")
        return True
    else:
        print(f"❌ {agent_name} routing failed")
        print(f"Expected: {expected_model}")
        print(f"Output:\n{result.stdout}")
        return False

def main():
    """运行所有测试"""

    print_header("Agent Router Integration Test")

    # 创建测试文件
    test_files = {
        'identity_test.md': '''# IDENTITY.md

这是核心配置文件，包含中文内容 🎯

## 配置项
- 核心原则：诚实透明
- 工作方式：直接高效 ⚡
''',
        'research_task.md': '''# 研究任务

这是一个复杂的研究任务，需要深度分析。

## 研究问题
如何优化多 Agent 系统的性能？

## 分析维度
1. 任务分解效率
2. Agent 协作模式
3. 成本优化策略
''',
        'batch_task.txt': '''简单任务 1
简单任务 2
简单任务 3
''',
    }

    # 创建测试文件
    test_dir = Path('/tmp/agent-router-test')
    test_dir.mkdir(exist_ok=True)

    for filename, content in test_files.items():
        file_path = test_dir / filename
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print_success(f"Created test file: {filename}")

    # 测试用例
    test_cases = [
        {
            'name': 'MOSS - 核心配置编辑',
            'agent': 'MOSS',
            'file': str(test_dir / 'identity_test.md'),
            'task': 'file_edit',
            'expected': 'minimax-m2.1'
        },
        {
            'name': 'LEADER - 研究任务分解',
            'agent': 'LEADER',
            'file': str(test_dir / 'research_task.md'),
            'task': 'research',
            'expected': 'deepseek-v3.2'
        },
        {
            'name': 'EXECUTOR - 批量任务',
            'agent': 'EXECUTOR',
            'file': str(test_dir / 'batch_task.txt'),
            'task': 'batch_file_process',
            'expected': 'mimo-v2-flash'
        },
    ]

    # 运行测试
    print_header("Running Tests")

    results = []
    for test in test_cases:
        print(f"\n{test['name']}")
        passed = test_agent(
            test['agent'],
            test['file'],
            test['task'],
            test['expected']
        )
        results.append({
            'name': test['name'],
            'passed': passed
        })

    # 汇总结果
    print_header("Test Summary")

    passed_count = sum(1 for r in results if r['passed'])
    total_count = len(results)

    print(f"\nTotal: {passed_count}/{total_count} tests passed\n")

    for result in results:
        status = '✓ PASS' if result['passed'] else '✗ FAIL'
        color = GREEN if result['passed'] else '\033[0;31m'
        print(f"{color}{status}{NC} - {result['name']}")

    # 成本分析
    print_header("Cost Analysis")

    print("""
如果所有任务都使用默认 Gemini Pro:
- 成本: ~$15-20

使用智能路由后:
- MOSS (MiniMax): $1.00
- LEADER (DeepSeek): $0.38
- EXECUTOR (MiMo): FREE
- 总成本: ~$1.38

节省: 90%+ ⚡
    """)

    # 清理
    print_info("Cleaning up test files...")
    for file_path in test_dir.glob('*'):
        file_path.unlink()
    test_dir.rmdir()
    print_success("Cleanup complete")

    # 返回退出码
    sys.exit(0 if passed_count == total_count else 1)

if __name__ == '__main__':
    main()
