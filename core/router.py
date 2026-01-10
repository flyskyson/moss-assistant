"""
角色路由系统
根据用户输入自动选择合适的角色（导师/伙伴/秘书/朋友）
"""

from typing import Dict, Any, Optional, List
import re


class RoleRouter:
    """角色路由器"""

    def __init__(self, config: Dict[str, Any]):
        self.config = config
        self.roles = config.get("roles", {})

        # 构建关键词到角色的映射
        self._build_keyword_mapping()

    def _build_keyword_mapping(self):
        """构建关键词到角色的映射"""
        self.keyword_to_role = {}
        self.role_order = []  # 角色优先级

        for role_name, role_config in self.roles.items():
            if not role_config.get("enabled", True):
                continue

            self.role_order.append(role_name)

            for keyword in role_config.get("trigger_keywords", []):
                if keyword not in self.keyword_to_role:
                    self.keyword_to_role[keyword] = []
                self.keyword_to_role[keyword].append(role_name)

    def route(self, user_input: str, user_model: Dict[str, Any]) -> Dict[str, Any]:
        """路由到合适的角色"""

        # 步骤 1: 分析输入特征
        input_analysis = self._analyze_input(user_input)

        # 步骤 2: 获取用户当前状态
        user_state = self._get_user_state(user_model)

        # 步骤 3: 匹配角色
        matched_roles = self._match_roles(user_input, input_analysis, user_state)

        # 步骤 4: 如果有多个匹配，选择优先级最高的
        if matched_roles:
            selected_role = matched_roles[0]
        else:
            # 默认使用伙伴角色
            selected_role = "partner"

        # 步骤 5: 构建返回结果
        result = {
            "role": selected_role,
            "role_config": self.roles[selected_role],
            "reasoning": self._explain_routing(user_input, selected_role, input_analysis, user_state)
        }

        return result

    def _analyze_input(self, user_input: str) -> Dict[str, Any]:
        """分析用户输入"""
        return {
            "length": len(user_input),
            "has_question_marks": "？" in user_input or "?" in user_input,
            "has_exclamation": "！" in user_input or "!" in user_input,
            "keywords": self._extract_keywords(user_input),
            "intent_type": self._classify_intent(user_input)
        }

    def _extract_keywords(self, text: str) -> List[str]:
        """提取关键词（简单版本）"""
        # 移除标点符号
        text = re.sub(r'[^\w\s]', ' ', text)
        # 分词（中文按字符，英文按单词）
        words = text.split()
        # 返回长度大于1的词
        return [w for w in words if len(w) > 1]

    def _classify_intent(self, user_input: str) -> str:
        """分类意图"""
        # 简单规则分类
        if any(word in user_input for word in ["帮", "查", "写", "提醒"]):
            return "task"
        elif any(word in user_input for word in ["难过", "焦虑", "疲惫", "迷茫"]):
            return "emotional"
        elif any(word in user_input for word in ["决定", "选择", "创业", "辞职"]):
            return "decision"
        elif any(word in user_input for word in ["讨论", "怎么看", "为什么"]):
            return "exploration"
        else:
            return "general"

    def _get_user_state(self, user_model: Dict[str, Any]) -> Dict[str, Any]:
        """获取用户当前状态"""
        emotional_state = user_model.get("emotional_state", {})
        return {
            "current_mood": emotional_state.get("current_mood", "平静"),
            "stress_level": self._calculate_stress_level(emotional_state),
            "interaction_count": user_model.get("stats", {}).get("total_interactions", 0)
        }

    def _calculate_stress_level(self, emotional_state: Dict[str, Any]) -> float:
        """计算压力水平（0-1）"""
        # 简单实现
        stressors = emotional_state.get("recent_stressors", [])
        return min(len(stressors) * 0.2, 1.0)

    def _match_roles(self, user_input: str, input_analysis: Dict[str, Any], user_state: Dict[str, Any]) -> List[str]:
        """匹配角色"""
        matched = set()

        # 方法 1: 关键词匹配
        for keyword, roles in self.keyword_to_role.items():
            if keyword in user_input:
                matched.update(roles)

        # 方法 2: 意图类型匹配
        intent_type = input_analysis["intent_type"]
        if intent_type == "decision":
            matched.add("mentor")
        elif intent_type == "emotional" or user_state["stress_level"] > 0.7:
            matched.add("friend")
        elif intent_type == "task":
            matched.add("secretary")
        elif intent_type == "exploration":
            matched.add("partner")

        # 按优先级排序
        matched_list = [r for r in self.role_order if r in matched]
        return matched_list

    def _explain_routing(self, user_input: str, role: str, input_analysis: Dict[str, Any], user_state: Dict[str, Any]) -> str:
        """解释路由决策"""
        reasons = []

        # 基于关键词
        for keyword, roles in self.keyword_to_role.items():
            if keyword in user_input and role in roles:
                reasons.append(f"检测到关键词'{keyword}'")

        # 基于意图
        intent = input_analysis["intent_type"]
        if intent == "decision" and role == "mentor":
            reasons.append("识别为重大决策")
        elif intent == "emotional" and role == "friend":
            reasons.append("检测到情绪需求")
        elif intent == "task" and role == "secretary":
            reasons.append("识别为任务执行")
        elif intent == "exploration" and role == "partner":
            reasons.append("识别为探索性话题")

        # 基于用户状态
        if user_state["stress_level"] > 0.7 and role == "friend":
            reasons.append(f"用户压力水平较高 ({user_state['stress_level']:.1f})")

        if reasons:
            return "、".join(reasons)
        else:
            return "默认模式"

    def get_role_prompt(self, role_name: str) -> str:
        """获取角色的 system prompt"""
        if role_name in self.roles:
            return self.roles[role_name].get("system_prompt", "")
        return ""
