"""
用户模型管理器
持续构建用户的数字孪生
"""

from typing import Dict, Any, List
from datetime import datetime


class UserModelManager:
    """用户模型管理器"""

    def __init__(self, memory):
        self.memory = memory
        self.user_model = self.memory.load_user_model()

    def get_model(self) -> Dict[str, Any]:
        """获取当前用户模型"""
        return self.user_model

    def update_after_interaction(self, interaction: Dict[str, Any]):
        """每次交互后更新用户模型"""
        # 1. 更新统计信息
        self._update_stats(interaction)

        # 2. 检测价值观变化
        self._detect_value_shift(interaction)

        # 3. 识别新的盲区
        self._detect_blind_spots(interaction)

        # 4. 追踪成长轨迹
        self._track_growth(interaction)

        # 5. 记录情绪状态
        self._update_emotional_state(interaction)

        # 6. 发现行为模式
        self._detect_behavioral_patterns(interaction)

        # 7. 保存到磁盘
        self.memory.save_user_model(self.user_model)

    def _update_stats(self, interaction: Dict[str, Any]):
        """更新统计信息"""
        self.user_model["stats"]["total_interactions"] += 1

        role = interaction.get("role", "unknown")
        if role not in self.user_model["stats"]["roles_used"]:
            self.user_model["stats"]["roles_used"][role] = 0
        self.user_model["stats"]["roles_used"][role] += 1

    def _detect_value_shift(self, interaction: Dict[str, Any]):
        """检测价值观变化"""
        # 这里可以添加更复杂的逻辑
        # 例如：对比前后观点，识别价值观变化
        pass

    def _detect_blind_spots(self, interaction: Dict[str, Any]):
        """识别认知盲区"""
        # 可以通过分析用户的问题和困惑来识别盲区
        user_input = interaction.get("user_input", "")

        # 简单示例：如果用户说"我不懂XX"，则记录为盲区
        if "我不懂" in user_input or "我不了解" in user_input:
            # 提取主题（这里需要 NLP，简单处理）
            self.user_model["knowledge_graph"]["blind_spots"].append({
                "topic": user_input[:50],  # 简单截取
                "timestamp": datetime.now().isoformat()
            })

    def _track_growth(self, interaction: Dict[str, Any]):
        """追踪成长轨迹"""
        # 如果用户承认错误或修正观点，记录为成长
        user_input = interaction.get("user_input", "")

        growth_indicators = ["你说得对", "我明白了", "我错了", "我之前没想清楚"]
        if any(indicator in user_input for indicator in growth_indicators):
            self.user_model["growth_trajectory"]["present"].append({
                "insight": user_input[:100],
                "timestamp": datetime.now().isoformat()
            })

    def _update_emotional_state(self, interaction: Dict[str, Any]):
        """更新情绪状态"""
        user_input = interaction.get("user_input", "")

        # 简单的情绪关键词检测
        negative_emotions = ["难过", "焦虑", "疲惫", "迷茫", "压力大", "痛苦"]
        positive_emotions = ["开心", "兴奋", "期待", "有信心"]

        has_negative = any(emotion in user_input for emotion in negative_emotions)
        has_positive = any(emotion in user_input for emotion in positive_emotions)

        if has_negative:
            self.user_model["emotional_state"]["current_mood"] = "低落"
        elif has_positive:
            self.user_model["emotional_state"]["current_mood"] = "积极"
        else:
            self.user_model["emotional_state"]["current_mood"] = "平静"

    def _detect_behavioral_patterns(self, interaction: Dict[str, Any]):
        """检测行为模式"""
        # 这里可以添加时间分析、频率分析等
        # 例如：用户喜欢在什么时间讨论什么话题
        pass

    def get_summary(self) -> str:
        """生成用户模型摘要（用于冷启动）"""
        stats = self.user_model["stats"]
        total_interactions = stats.get("total_interactions", 0)
        roles_used = stats.get("roles_used", {})

        # 获取最近的话题
        recent_conversations = self.memory.load_conversations(limit=3)
        recent_topics = []
        for conv in recent_conversations:
            if conv.get("messages"):
                first_msg = conv["messages"][0].get("content", "")[:50]
                recent_topics.append(first_msg)

        summary = f"""我是你的 MOSS 助手。

这是我们第 {total_interactions + 1} 次对话。

我已经了解到的信息：
"""

        # 添加基本信息
        basic_info = self.user_model.get("basic_info", {})
        if any(basic_info.values()):
            summary += "\n【基本信息】\n"
            for key, value in basic_info.items():
                if value:
                    summary += f"- {key}: {value}\n"

        # 添加认知风格
        cognitive_style = self.user_model.get("cognitive_style", {})
        if any(cognitive_style.values()):
            summary += "\n【认知风格】\n"
            summary += f"- 思维模式: {', '.join(cognitive_style.get('thinking_pattern', []))}\n"
            summary += f"- 辩论偏好: {', '.join(cognitive_style.get('debate_preference', []))}\n"

        # 添加最近话题
        if recent_topics:
            summary += "\n【最近讨论的话题】\n"
            for i, topic in enumerate(recent_topics, 1):
                summary += f"{i}. {topic}...\n"

        # 添加当前目标
        goals = self.user_model.get("goals", {})
        if any(goals.values()):
            summary += "\n【当前目标】\n"
            if goals.get("short_term"):
                summary += f"- 短期: {', '.join(goals['short_term'][:2])}\n"
            if goals.get("medium_term"):
                summary += f"- 中期: {', '.join(goals['medium_term'][:2])}\n"

        summary += "\n准备好开始今天的对话了吗？"

        return summary

    def update_basic_info(self, key: str, value: Any):
        """更新基本信息"""
        if key in self.user_model["basic_info"]:
            self.user_model["basic_info"][key] = value
            self.memory.save_user_model(self.user_model)
            print(f"✓ 已更新: {key} = {value}")

    def add_goal(self, goal: str, timeframe: str = "short_term"):
        """添加目标"""
        if timeframe in self.user_model["goals"]:
            self.user_model["goals"][timeframe].append(goal)
            self.memory.save_user_model(self.user_model)
            print(f"✓ 已添加{timeframe}目标: {goal}")
