#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Agent Router Integration Library
Agent 路由集成库 - 方案 1 + 方案 3 混合实施

为所有 Agent 提供统一的模型路由接口

2026-02-08
"""

import sys
import os
import yaml
import logging
from pathlib import Path
from datetime import datetime
from typing import Dict, Optional, Tuple

# 导入路由器核心
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, SCRIPT_DIR)

# 导入 ModelRouter（需要先导入）
import importlib.util
spec = importlib.util.spec_from_file_location("model_router",
    os.path.join(SCRIPT_DIR, "model-router.py"))
model_router_module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(model_router_module)
ModelRouter = model_router_module.ModelRouter

# Agent 工作区映射
AGENT_WORKSPACES = {
    'MOSS': '/Users/lijian/clawd',
    'LEADER': os.path.expanduser('~/.clawdbot-leader'),
    'THINKER': os.path.expanduser('~/.clawdbot-thinker'),
    'COORDINATOR': os.path.expanduser('~/.clawdbot-coordinator'),
    'EXECUTOR': os.path.expanduser('~/.clawdbot-executor'),
}

# Agent 路由配置映射
AGENT_ROUTING_CONFIGS = {
    'MOSS': '/Users/lijian/clawd/config/moss-routing.yaml',
    'LEADER': '/Users/lijian/clawd/config/leader-routing.yaml',
    'THINKER': '/Users/lijian/clawd/config/leader-routing.yaml',  # Thinker 使用类似配置
    'COORDINATOR': '/Users/lijian/clawd/config/leader-routing.yaml',
    'EXECUTOR': '/Users/lijian/clawd/config/executor-routing.yaml',
}

# 配置日志
LOG_DIR = Path("/Users/lijian/clawd/logs")
LOG_DIR.mkdir(exist_ok=True)


class AgentRouter:
    """Agent 专用路由器 - 集成方案 1 + 方案 3"""

    def __init__(self, agent_name: str):
        """
        初始化 Agent 路由器

        Args:
            agent_name: Agent 名称（MOSS, LEADER, EXECUTOR 等）
        """
        self.agent_name = agent_name.upper()
        self.config_path = Path(AGENT_ROUTING_CONFIGS.get(self.agent_name,
                                                         AGENT_ROUTING_CONFIGS['MOSS']))

        # 加载路由器
        self.router = ModelRouter(self.config_path)

        # Agent 特定配置
        self.agent_config = self.router.config.get(f"{self.agent_name.lower()}_config", {})

        # 设置日志
        self.logger = logging.getLogger(f"AgentRouter.{self.agent_name}")
        self.logger.setLevel(logging.INFO)

        handler = logging.StreamHandler(sys.stdout)
        handler.setFormatter(logging.Formatter(
            f'%(asctime)s - [{self.agent_name}] - %(levelname)s - %(message)s'
        ))
        self.logger.addHandler(handler)

        self.logger.info(f"Agent Router initialized for {self.agent_name}")

    def route_task(self, task_context: Dict) -> Dict:
        """
        为 Agent 任务路由模型

        Args:
            task_context: 任务上下文
                - task_type: 任务类型
                - file_path: 文件路径（可选）
                - file_content: 文件内容（可选）
                - user_message: 用户消息（可选）

        Returns:
            路由决策字典
        """
        # 获取基础路由决策
        result = self.router.analyze_task(task_context)

        # 添加 Agent 特定信息
        result['agent_name'] = self.agent_name
        result['agent_workspace'] = AGENT_WORKSPACES.get(self.agent_name)
        result['agent_specialty'] = self._get_agent_specialty()

        # Leader 特殊处理：添加 Agent 分配建议
        if self.agent_name == 'LEADER':
            result['agent_assignment'] = self._suggest_agent_assignment(result)

        self.logger.info(f"Task routed to {result['recommended_model']} (confidence: {result['confidence']:.0%})")

        return result

    def _get_agent_specialty(self) -> str:
        """获取 Agent 专长描述"""
        specialties = {
            'MOSS': '文件编辑、中文内容、工具调用',
            'LEADER': '任务分解、协调决策、Agent 分配',
            'THINKER': '深度分析、复杂推理、长期规划',
            'COORDINATOR': '工作流编排、依赖管理、进度跟踪',
            'EXECUTOR': '批量任务、高频操作、成本优化',
        }
        return specialties.get(self.agent_name, '通用任务')

    def _suggest_agent_assignment(self, routing_result: Dict) -> Optional[str]:
        """
        Leader 专用：根据路由建议分配 Agent

        Args:
            routing_result: 路由决策

        Returns:
            建议分配的 Agent 名称
        """
        # 读取 Leader 配置中的映射
        leader_config = self.router.config.get('leader_config', {})
        agent_mapping = leader_config.get('agent_mapping', {})

        recommended_model = routing_result['recommended_model']

        # 查找映射
        for model, agents in agent_mapping.items():
            if model == recommended_model:
                # 返回第一个匹配的 Agent
                return agents[0] if isinstance(agents, list) else agents

        # 默认映射
        default_mapping = {
            'minimax-m2.1': 'MOSS',
            'deepseek-v3.2': 'THINKER',
            'mimo-v2-flash': 'EXECUTOR',
            'devstral-2': 'COORDINATOR',
        }

        return default_mapping.get(recommended_model, 'MOSS')

    def execute_with_routed_model(self, task_context: Dict, execute_func) -> any:
        """
        使用路由选择的模型执行任务

        Args:
            task_context: 任务上下文
            execute_func: 执行函数（接收 model_id 作为参数）

        Returns:
            执行结果
        """
        # 获取路由决策
        routing = self.route_task(task_context)

        model_id = routing['model_id']
        self.logger.info(f"Executing with model: {model_id}")

        # 执行任务
        try:
            result = execute_func(model_id)
            self.logger.info("Task completed successfully")
            return result
        except Exception as e:
            self.logger.error(f"Task failed: {e}")

            # 尝试回退模型
            for fallback_model in routing['fallback_models']:
                self.logger.info(f"Retrying with fallback model: {fallback_model}")

                try:
                    # 获取回退模型的 model_id
                    fallback_model_id = self.router.models.get(fallback_model, {}).get('model_id')
                    result = execute_func(fallback_model_id)
                    self.logger.info(f"Task completed with fallback model: {fallback_model}")
                    return result
                except Exception as e2:
                    self.logger.error(f"Fallback also failed: {e2}")
                    continue

            raise Exception("All models failed")


def create_agent_router(agent_name: str) -> AgentRouter:
    """
    创建 Agent 路由器（工厂函数）

    Args:
        agent_name: Agent 名称

    Returns:
        AgentRouter 实例

    Example:
        >>> router = create_agent_router('MOSS')
        >>> result = router.route_task({
        ...     'task_type': 'file_edit',
        ...     'file_path': 'IDENTITY.md'
        ... })
    """
    return AgentRouter(agent_name)


# CLI 接口
def main():
    """命令行接口"""
    if len(sys.argv) < 3:
        print("Usage: python3 agent-router-integration.py <agent_name> <file_path> [task_type]")
        print("")
        print("Agents: MOSS, LEADER, THINKER, COORDINATOR, EXECUTOR")
        print("")
        print("Examples:")
        print("  python3 agent-router-integration.py MOSS IDENTITY.md")
        print("  python3 agent-router-integration.py LEADER task.md research")
        sys.exit(1)

    agent_name = sys.argv[1]
    file_path = sys.argv[2]
    task_type = sys.argv[3] if len(sys.argv) > 3 else 'file_edit'

    # 读取文件内容
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            file_content = f.read()
    except Exception as e:
        print(f"Error reading file: {e}")
        sys.exit(1)

    # 创建路由器
    router = create_agent_router(agent_name)

    # 路由任务
    result = router.route_task({
        'task_type': task_type,
        'file_path': file_path,
        'file_content': file_content
    })

    # 输出结果
    print(f"\n=== {agent_name} Agent Routing Decision ===")
    print(f"Agent: {agent_name}")
    print(f"Specialty: {result['agent_specialty']}")
    print(f"Task: {task_type}")
    print(f"File: {os.path.basename(file_path)}")
    print("")
    print(f"✓ Recommended Model: {result['recommended_model']}")
    print(f"  Model ID: {result['model_id']}")
    print(f"  Provider: {result['provider']}")
    print(f"  Confidence: {result['confidence']:.0%}")
    print("")
    print(f"Reason: {result['reason']}")
    print("")

    if result.get('agent_assignment'):
        print(f"Leader Decision: Assign task to {result['agent_assignment']} Agent")
        print("")

    print(f"Fallback order:")
    for i, model in enumerate(result['fallback_models'], 1):
        print(f"  {i}. {model}")

    # 返回退出码
    if result['recommended_model'] in ['minimax-m2.1']:
        sys.exit(20)  # 需要高质量模型
    elif result['recommended_model'] in ['deepseek-v3.2']:
        sys.exit(10)  # 使用经济模型
    else:
        sys.exit(0)  # 免费模型


if __name__ == '__main__':
    main()
