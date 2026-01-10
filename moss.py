"""
MOSS Assistant - 主程序
苏格拉底式辩论伙伴 + 全能个人助理
"""

import os
import yaml
from pathlib import Path
from datetime import datetime
from typing import Dict, Any, Optional

try:
    import anthropic
    ANTHROPIC_AVAILABLE = True
except ImportError:
    ANTHROPIC_AVAILABLE = False
    print("⚠️  警告: 未安装 anthropic 库，将使用模拟模式")

from core.memory import PersistentMemory
from core.user_model import UserModelManager
from core.router import RoleRouter


class MOSSAssistant:
    """MOSS 助手核心类"""

    def __init__(self, config_path: str = "config.yaml"):
        # 加载配置
        self.config = self._load_config(config_path)

        # 初始化组件
        self.memory = PersistentMemory(self.config)
        self.user_model_manager = UserModelManager(self.memory)
        self.router = RoleRouter(self.config)

        # 初始化 LLM
        self.llm_client = self._init_llm()

        # 当前会话
        self.current_conversation = {
            "id": self._generate_conversation_id(),
            "timestamp": datetime.now().isoformat(),
            "messages": []
        }

    def _load_config(self, config_path: str) -> Dict[str, Any]:
        """加载配置文件"""
        config_file = Path(config_path)
        if not config_file.exists():
            raise FileNotFoundError(f"配置文件不存在: {config_path}")

        with open(config_file, 'r', encoding='utf-8') as f:
            return yaml.safe_load(f)

    def _init_llm(self):
        """初始化 LLM 客户端"""
        if not ANTHROPIC_AVAILABLE:
            return None

        provider = self.config["llm"]["provider"]
        api_key = os.getenv(self.config["llm"]["api_key_env"])

        if not api_key:
            print("⚠️  警告: 未设置 API Key，请设置环境变量")
            return None

        if provider == "claude":
            return anthropic.Anthropic(api_key=api_key)
        else:
            raise ValueError(f"不支持的 LLM 提供商: {provider}")

    def _generate_conversation_id(self) -> str:
        """生成对话 ID"""
        return f"conv_{datetime.now().strftime('%Y%m%d_%H%M%S')}"

    def start_conversation(self) -> str:
        """开始对话（冷启动）"""
        # 获取用户模型摘要
        summary = self.user_model_manager.get_summary()

        # 添加到消息历史
        self.current_conversation["messages"].append({
            "role": "assistant",
            "content": summary
        })

        return summary

    def chat(self, user_input: str) -> str:
        """处理用户输入"""
        # 步骤 1: 路由到合适的角色
        user_model = self.user_model_manager.get_model()
        routing_result = self.router.route(user_input, user_model)

        role = routing_result["role"]
        role_config = routing_result["role_config"]
        reasoning = routing_result["reasoning"]

        print(f"\n🎭 角色路由: {role_config['name']} ({reasoning})")

        # 步骤 2: 构建对话上下文
        messages = self._build_messages(user_input, role)

        # 步骤 3: 调用 LLM
        response = self._call_llm(messages, role)

        # 步骤 4: 记录交互
        self._log_interaction(user_input, response, role)

        # 步骤 5: 更新用户模型
        interaction = {
            "user_input": user_input,
            "agent_response": response,
            "role": role,
            "timestamp": datetime.now().isoformat()
        }
        self.user_model_manager.update_after_interaction(interaction)

        return response

    def _build_messages(self, user_input: str, role: str) -> list:
        """构建消息列表"""
        # 获取角色的 system prompt
        system_prompt = self.router.get_role_prompt(role)

        # 获取用户模型上下文
        user_model = self.user_model_manager.get_model()
        user_context = self._build_user_context(user_model)

        # 构建完整消息
        messages = [
            {
                "role": "user",
                "content": f"""你是{role}角色。

{system_prompt}

用户信息：
{user_context}

用户输入：
{user_input}

请根据你的角色定位，回应用户。"""
            }
        ]

        return messages

    def _build_user_context(self, user_model: Dict[str, Any]) -> str:
        """构建用户上下文（给 LLM）"""
        context_parts = []

        # 基本信息
        basic_info = user_model.get("basic_info", {})
        if any(basic_info.values()):
            context_parts.append("基本信息:")
            for key, value in basic_info.items():
                if value:
                    context_parts.append(f"  - {key}: {value}")

        # 认知风格
        cognitive = user_model.get("cognitive_style", {})
        if any(cognitive.values()):
            context_parts.append("\n认知风格:")
            for key, values in cognitive.items():
                if values:
                    context_parts.append(f"  - {key}: {', '.join(values)}")

        # 最近话题
        recent_convs = self.memory.load_conversations(limit=3)
        if recent_convs:
            context_parts.append("\n最近讨论的话题:")
            for i, conv in enumerate(recent_convs, 1):
                if conv.get("messages"):
                    first_msg = conv["messages"][0].get("content", "")[:100]
                    context_parts.append(f"  {i}. {first_msg}...")

        # 当前目标
        goals = user_model.get("goals", {})
        if any(goals.values()):
            context_parts.append("\n当前目标:")
            for timeframe, goal_list in goals.items():
                if goal_list:
                    context_parts.append(f"  - {timeframe}: {', '.join(goal_list[:2])}")

        return "\n".join(context_parts)

    def _call_llm(self, messages: list, role: str) -> str:
        """调用 LLM"""
        if not ANTHROPIC_AVAILABLE or not self.llm_client:
            return self._mock_response(role)

        try:
            # 使用 Claude API
            model = self.config["llm"]["model"]
            max_tokens = self.config["llm"]["max_tokens"]

            response = self.llm_client.messages.create(
                model=model,
                max_tokens=max_tokens,
                messages=messages
            )

            return response.content[0].text
        except Exception as e:
            print(f"⚠️  LLM 调用失败: {e}")
            return self._mock_response(role)

    def _mock_response(self, role: str) -> str:
        """模拟响应（用于测试）"""
        mock_responses = {
            "mentor": "作为你的导师，我想先问你几个问题：\n\n1. 你为什么这个选择对你重要？\n2. 你有没有考虑过最坏的情况？\n3. 如果10年后回看这个决定，你会有什么感觉？\n\n我们先把这些想清楚，再做决定。",
            "partner": "这个问题很有意思！让我们一起探索一下。\n\n我注意到你提到了XX，这让我想到另一个角度...你觉得呢？",
            "secretary": "好的，我来帮你处理这个任务。\n\n[执行中...]\n\n任务已完成，还有什么需要我帮忙的吗？",
            "friend": "我能理解你现在的感受。\n\n如果你愿意的话，可以和我说说发生了什么，我会一直在这里听你说的。"
        }

        return mock_responses.get(role, "我需要更多信息来帮助你。")

    def _log_interaction(self, user_input: str, response: str, role: str):
        """记录交互"""
        # 添加到当前对话
        self.current_conversation["messages"].append({
            "role": "user",
            "content": user_input
        })
        self.current_conversation["messages"].append({
            "role": "assistant",
            "content": response
        })

        # 记录到交互日志
        self.memory.log_interaction(
            user_input=user_input,
            agent_response=response,
            role=role,
            metadata={"conversation_id": self.current_conversation["id"]}
        )

    def end_conversation(self):
        """结束对话"""
        # 保存完整对话
        self.memory.save_conversation(
            self.current_conversation["id"],
            self.current_conversation
        )

        # 更新统计
        user_model = self.user_model_manager.get_model()
        user_model["stats"]["total_conversations"] += 1
        self.memory.save_user_model(user_model)

        print(f"\n✓ 对话已保存: {self.current_conversation['id']}")

    def update_user_info(self, key: str, value: Any):
        """更新用户信息"""
        self.user_model_manager.update_basic_info(key, value)

    def add_goal(self, goal: str, timeframe: str = "short_term"):
        """添加目标"""
        self.user_model_manager.add_goal(goal, timeframe)

    def backup(self):
        """备份数据"""
        self.memory.backup()


def main():
    """命令行测试入口"""
    print("=" * 60)
    print("MOSS Assistant - 苏格拉底式辩论伙伴 + 全能个人助理")
    print("=" * 60)

    # 初始化助手
    moss = MOSSAssistant()

    # 开始对话
    greeting = moss.start_conversation()
    print("\n" + greeting)

    # 交互循环
    while True:
        try:
            user_input = input("\n你: ").strip()

            if not user_input:
                continue

            if user_input.lower() in ["退出", "exit", "quit", "q"]:
                print("\n正在保存对话...")
                moss.end_conversation()
                print("再见！👋")
                break

            # 特殊命令
            if user_input.startswith("/info "):
                key, value = user_input[6:].split(" ", 1)
                moss.update_user_info(key, value)
                continue

            if user_input.startswith("/goal "):
                goal = user_input[6:]
                moss.add_goal(goal)
                continue

            if user_input == "/backup":
                moss.backup()
                continue

            # 正常对话
            response = moss.chat(user_input)
            print(f"\nMOSS: {response}")

        except KeyboardInterrupt:
            print("\n\n正在保存对话...")
            moss.end_conversation()
            print("再见！👋")
            break
        except Exception as e:
            print(f"\n❌ 错误: {e}")
            continue


if __name__ == "__main__":
    main()
