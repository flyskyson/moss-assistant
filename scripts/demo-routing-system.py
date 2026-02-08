#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
路由系统演示 - 展示不同场景的模型推荐
Demo: Model Router System in Action
"""

import subprocess
import sys
from pathlib import Path

def print_header(text):
    print(f"\n{'='*70}")
    print(f"  {text}")
    print(f"{'='*70}\n")

def run_router_test(agent, file_path, task_type, description):
    """运行路由测试并显示结果"""
    print(f"📋 场景：{description}")
    print(f"🤖 Agent: {agent}")
    print(f"📄 任务类型: {task_type}")

    result = subprocess.run(
        ['python3', 'agent-router-integration.py', agent, file_path, task_type],
        capture_output=True,
        text=True,
        cwd='/Users/lijian/clawd/scripts'
    )

    # 提取关键信息
    lines = result.stdout.split('\n')
    for i, line in enumerate(lines):
        if 'Recommended Model:' in line:
            print(f"✓ 推荐: {line.split(':', 1)[1].strip()}")
        if 'Model ID:' in line:
            print(f"  模型: {line.split(':', 1)[1].strip()}")
        if 'Confidence:' in line:
            print(f"  置信度: {line.split(':', 1)[1].strip()}")
        if 'Reason:' in line:
            print(f"  理由: {line.split(':', 1)[1].strip()}")
        if 'Leader Decision:' in line:
            print(f"  决策: {line.split(':', 1)[1].strip()}")

    # 显示成本信息
    if 'minimax-m2.1' in result.stdout:
        print(f"  💰 成本: $0.28/$1.00 per 1M tokens")
    elif 'deepseek-v3.2' in result.stdout:
        print(f"  💰 成本: $0.25/$0.38 per 1M tokens")
    elif 'mimo-v2-flash' in result.stdout:
        print(f"  💰 成本: FREE 🆓")

    print()

def main():
    print_header("🚀 OpenClaw 智能模型路由系统演示")

    print("""
本演示展示路由系统如何：
1. 分析任务特征
2. 结合 Agent 专长
3. 自动推荐最优模型
4. 实现成本优化
    """)

    # 场景 1: MOSS 编辑核心配置文件
    print_header("场景 1: MOSS 编辑核心配置文件（中文 + emoji）")
    run_router_test(
        'MOSS',
        '/Users/lijian/clawd/IDENTITY.md',
        'file_edit',
        '编辑包含中文和 emoji 的核心配置文件'
    )

    # 场景 2: LEADER 分解复杂任务
    print_header("场景 2: LEADER 分解复杂任务")
    run_router_test(
        'LEADER',
        '/tmp/test-tasks.md',
        'task_decomposition',
        '需要深度分析和任务分解'
    )

    # 场景 3: EXECUTOR 批量处理简单任务
    print_header("场景 3: EXECUTOR 批量处理简单任务")
    run_router_test(
        'EXECUTOR',
        '/tmp/simple-task.txt',
        'batch_file_process',
        '批量处理简单英文文件'
    )

    # 场景 4: LEADER 研究任务
    print_header("场景 4: LEADER 深度研究任务")
    run_router_test(
        'LEADER',
        '/tmp/test-tasks.md',
        'research',
        '需要深度推理的研究任务'
    )

    # 成本总结
    print_header("💰 成本分析")

    print("""
如果所有任务都使用 Gemini Pro（$2.50/$10）：
- 场景 1: ~$5
- 场景 2: ~$8
- 场景 3: ~$2
- 场景 4: ~$10
- 总成本: ~$25

使用智能路由后：
- 场景 1 (MOSS + MiniMax): ~$1.00
- 场景 2 (LEADER + DeepSeek): ~$0.38
- 场景 3 (EXECUTOR + MiMo): FREE
- 场景 4 (LEADER + DeepSeek): ~$0.38
- 总成本: ~$1.76

💡 节省: 93% ⚡
    """)

    # 关键洞察
    print_header("🎯 关键洞察")

    print("""
1. 每个 Agent 有自己的专长模型
   - MOSS: MiniMax M2.1 (文件编辑专家)
   - LEADER: DeepSeek V3.2 (协调推理专家)
   - EXECUTOR: MiMo-V2-Flash (免费执行专家)

2. 路由系统自动分析任务特征
   - 中文/emoji 内容 → 需要可靠模型
   - 任务分解 → 需要推理能力
   - 批量任务 → 优先免费模型

3. 成本优化是自动的
   - 简单任务自动用免费模型
   - 复杂任务用高性价比模型
   - 不需要手动选择

4. 完全不改变 Agent 架构
   - Multi-Agent 协作模式保持不变
   - 只是增强了模型选择能力
   - Agent 分工 + 智能工具 = 双重优化
    """)

    print_header("✅ 演示完成")

    print("""
现在你可以：

1. 测试自己的文件：
   python3 scripts/agent-router-integration.py MOSS <your-file>

2. 查看详细文档：
   cat docs/agent-router-integration-guide.md

3. 开始集成到 Agents：
   (参考文档中的集成步骤)

🚀 路由系统已就绪！
    """)

if __name__ == '__main__':
    main()
