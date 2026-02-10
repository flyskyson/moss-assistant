#!/usr/bin/env python3
"""
任务复杂度检测器
Task Complexity Detector for OpenClaw Multi-Agent System

根据任务特征自动判断使用 Single-Agent 还是 Multi-Agent 模式
Automatically determines whether to use Single-Agent or Multi-Agent mode based on task characteristics
"""

import json
import re
import sys
from pathlib import Path
from datetime import datetime

class TaskComplexityDetector:
    """任务复杂度检测器"""

    def __init__(self, config_path=None):
        """初始化检测器"""
        self.config = self._load_config(config_path)
        self.thresholds = self.config.get("thresholds", {
            "simple_max_steps": 10,
            "complex_min_steps": 30,
            "max_parallel_tasks": 5
        })

    def _load_config(self, config_path):
        """加载配置"""
        if config_path is None:
            config_path = Path(__file__).parent.parent / "config" / "task-routing-config.json"
        else:
            config_path = Path(config_path)

        if config_path.exists():
            with open(config_path, 'r', encoding='utf-8') as f:
                return json.load(f)
        else:
            # 默认配置
            return {
                "thresholds": {
                    "simple_max_steps": 10,
                    "complex_min_steps": 30,
                    "max_parallel_tasks": 5
                },
                "keywords": {
                    "simple": ["解释", "翻译", "总结", "单个", "简单"],
                    "complex": ["并行", "协作", "多步骤", "复杂", "分析", "研究"]
                }
            }

    def detect_complexity(self, task_description, context=None):
        """
        检测任务复杂度

        Args:
            task_description: 任务描述
            context: 上下文信息（可选）

        Returns:
            dict: 包含复杂度级别和建议的字典
        """
        result = {
            "timestamp": datetime.now().isoformat(),
            "task": task_description,
            "complexity": "unknown",
            "estimated_steps": 0,
            "can_parallelize": False,
            "recommended_mode": "multi-agent",
            "confidence": 0.0,
            "reasons": []
        }

        # 1. 分析关键词
        complexity_score = self._analyze_keywords(task_description)
        result["reasons"].append(f"关键词分析得分: {complexity_score}")

        # 2. 估计步骤数
        estimated_steps = self._estimate_steps(task_description, context)
        result["estimated_steps"] = estimated_steps
        result["reasons"].append(f"估计步骤数: {estimated_steps}")

        # 3. 检测并行可能性
        can_parallelize = self._check_parallelization(task_description)
        result["can_parallelize"] = can_parallelize
        result["reasons"].append(f"可并行化: {can_parallelize}")

        # 4. 综合判断
        if estimated_steps <= self.thresholds["simple_max_steps"]:
            result["complexity"] = "simple"
            result["recommended_mode"] = "single-agent"
            result["confidence"] = 0.85
            result["reasons"].append("步骤数少，适合单 Agent 处理")
        elif estimated_steps >= self.thresholds["complex_min_steps"]:
            result["complexity"] = "complex"
            result["recommended_mode"] = "multi-agent"
            result["confidence"] = 0.90
            result["reasons"].append("步骤数多，多 Agent 协作更高效")
        else:
            # 中等复杂度
            if can_parallelize or complexity_score > 0.6:
                result["complexity"] = "medium-high"
                result["recommended_mode"] = "multi-agent"
                result["confidence"] = 0.70
                result["reasons"].append("中等复杂度但可并行，建议多 Agent")
            else:
                result["complexity"] = "medium-low"
                result["recommended_mode"] = "single-agent"
                result["confidence"] = 0.65
                result["reasons"].append("中等复杂度，单 Agent 足够")

        return result

    def _analyze_keywords(self, task):
        """分析任务关键词"""
        keywords = self.config.get("keywords", {})
        simple_kw = keywords.get("simple", [])
        complex_kw = keywords.get("complex", [])

        score = 0.5  # 基础分

        for kw in simple_kw:
            if kw in task:
                score -= 0.1

        for kw in complex_kw:
            if kw in task:
                score += 0.15

        return max(0.0, min(1.0, score))

    def _estimate_steps(self, task, context):
        """估计任务步骤数"""
        # 简单启发式规则
        steps = 1

        # 检查动作动词
        action_patterns = [
            (r'(分析|研究|调研)', 5),
            (r'(创建|开发|实现|构建)', 8),
            (r'(优化|改进|重构)', 6),
            (r'(测试|验证|检查)', 3),
            (r'(部署|发布|上线)', 4),
            (r'(并行|同时|分别)', 10),
            (r'(然后|接着|之后|下一步)', 2)
        ]

        for pattern, add_steps in action_patterns:
            matches = len(re.findall(pattern, task))
            steps += matches * add_steps

        # 检查是否包含多个子任务
        if '和' in task or '与' in task or '以及' in task:
            parts = re.split(r'[和与及]|以及', task)
            steps += len(parts) - 1

        return min(steps, 100)  # 上限

    def _check_parallelization(self, task):
        """检查任务是否可以并行化"""
        parallel_indicators = [
            "并行", "同时", "分别", "各自",
            "多个", "批量", "一起"
        ]

        return any(indicator in task for indicator in parallel_indicators)

    def format_output(self, result):
        """格式化输出结果"""
        output = []
        output.append("═" * 60)
        output.append("任务复杂度检测结果")
        output.append("═" * 60)
        output.append(f"任务: {result['task'][:50]}...")
        output.append(f"复杂度: {result['complexity']}")
        output.append(f"估计步骤: {result['estimated_steps']}")
        output.append(f"可并行: {result['can_parallelize']}")
        output.append(f"推荐模式: {result['recommended_mode']}")
        output.append(f"置信度: {result['confidence']:.0%}")
        output.append("")
        output.append("判断依据:")
        for reason in result['reasons']:
            output.append(f"  • {reason}")
        output.append("═" * 60)

        return "\n".join(output)


def main():
    """命令行入口"""
    if len(sys.argv) < 2:
        print("用法: task-complexity-detector.py <任务描述>")
        print("示例: task-complexity-detector.py '分析和优化这个Python脚本'")
        sys.exit(1)

    task = " ".join(sys.argv[1:])

    detector = TaskComplexityDetector()
    result = detector.detect_complexity(task)

    print(detector.format_output(result))

    # 返回推荐模式（用于脚本集成）
    sys.exit(0 if result['recommended_mode'] == 'single-agent' else 1)


if __name__ == "__main__":
    main()
