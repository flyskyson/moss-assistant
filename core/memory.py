"""
持久化记忆系统
确保用户数据在每次对话后都能保存，下次对话时自动加载
"""

import json
import os
from datetime import datetime
from typing import Dict, List, Any, Optional
from pathlib import Path


class PersistentMemory:
    """持久化记忆管理器"""

    def __init__(self, config: Dict[str, Any]):
        self.config = config
        self.memory_path = Path(config["memory"]["path"])
        self.backend = config["memory"]["backend"]

        # 确保目录存在
        self.memory_path.mkdir(parents=True, exist_ok=True)

        # 文件路径
        self.user_model_file = self.memory_path / "user_model.json"
        self.conversations_file = self.memory_path / "conversations.json"
        self.interaction_log_file = self.memory_path / "interactions.json"

        # 初始化存储
        self._init_storage()

    def _init_storage(self):
        """初始化存储文件"""
        for file in [self.user_model_file, self.conversations_file, self.interaction_log_file]:
            if not file.exists():
                with open(file, 'w', encoding='utf-8') as f:
                    json.dump({}, f, ensure_ascii=False, indent=2)

    def load_user_model(self) -> Dict[str, Any]:
        """加载用户模型"""
        try:
            with open(self.user_model_file, 'r', encoding='utf-8') as f:
                user_model = json.load(f)

            # 如果是空的，初始化
            if not user_model:
                user_model = self._init_user_model()

            return user_model
        except Exception as e:
            print(f"加载用户模型失败: {e}")
            return self._init_user_model()

    def save_user_model(self, user_model: Dict[str, Any]):
        """保存用户模型"""
        try:
            # 更新时间戳
            user_model["last_updated"] = datetime.now().isoformat()

            with open(self.user_model_file, 'w', encoding='utf-8') as f:
                json.dump(user_model, f, ensure_ascii=False, indent=2)

            print(f"[成功] 用户模型已保存")
        except Exception as e:
            print(f"保存用户模型失败: {e}")

    def load_conversations(self, limit: int = 10) -> List[Dict[str, Any]]:
        """加载最近的对话历史"""
        try:
            with open(self.conversations_file, 'r', encoding='utf-8') as f:
                all_conversations = json.load(f)

            # 按时间排序，取最近 N 条
            conversations = sorted(
                all_conversations.values(),
                key=lambda x: x.get("timestamp", ""),
                reverse=True
            )[:limit]

            return conversations
        except Exception as e:
            print(f"加载对话历史失败: {e}")
            return []

    def save_conversation(self, conversation_id: str, conversation: Dict[str, Any]):
        """保存一次完整的对话"""
        try:
            # 加载现有对话
            with open(self.conversations_file, 'r', encoding='utf-8') as f:
                all_conversations = json.load(f)

            # 添加新对话
            all_conversations[conversation_id] = conversation

            # 保存
            with open(self.conversations_file, 'w', encoding='utf-8') as f:
                json.dump(all_conversations, f, ensure_ascii=False, indent=2)

            print(f"[成功] 对话已保存: {conversation_id}")
        except Exception as e:
            print(f"保存对话失败: {e}")

    def log_interaction(self, user_input: str, agent_response: str, role: str, metadata: Dict[str, Any]):
        """记录每次交互"""
        try:
            # 加载现有日志
            with open(self.interaction_log_file, 'r', encoding='utf-8') as f:
                logs = json.load(f)
                # 确保是列表
                if isinstance(logs, dict):
                    logs = []
                elif not isinstance(logs, list):
                    logs = []
        except:
            logs = []

        # 添加新日志
        log_entry = {
            "timestamp": datetime.now().isoformat(),
            "user_input": user_input,
            "agent_response": agent_response,
            "role": role,
            "metadata": metadata
        }

        logs.append(log_entry)

        # 保存（保留最近 1000 条）
        logs = logs[-1000:]

        with open(self.interaction_log_file, 'w', encoding='utf-8') as f:
            json.dump(logs, f, ensure_ascii=False, indent=2)

    def search_conversations(self, keyword: str) -> List[Dict[str, Any]]:
        """搜索历史对话（简单版本）"""
        try:
            with open(self.conversations_file, 'r', encoding='utf-8') as f:
                all_conversations = json.load(f)

            results = []
            for conv_id, conv in all_conversations.items():
                # 在用户输入中搜索
                for msg in conv.get("messages", []):
                    if keyword.lower() in msg.get("content", "").lower():
                        results.append(conv)
                        break

            return results
        except Exception as e:
            print(f"搜索对话失败: {e}")
            return []

    def backup(self):
        """备份所有数据"""
        try:
            backup_dir = self.memory_path / "backups"
            backup_dir.mkdir(parents=True, exist_ok=True)

            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            backup_file = backup_dir / f"backup_{timestamp}.json"

            # 收集所有数据
            backup_data = {
                "user_model": self.load_user_model(),
                "conversations": self.load_conversations(limit=1000),
                "timestamp": timestamp
            }

            with open(backup_file, 'w', encoding='utf-8') as f:
                json.dump(backup_data, f, ensure_ascii=False, indent=2)

            print(f"[成功] 备份已创建: {backup_file}")
        except Exception as e:
            print(f"备份失败: {e}")

    def _init_user_model(self) -> Dict[str, Any]:
        """初始化空的用户模型"""
        return {
            "version": "1.0",
            "created_at": datetime.now().isoformat(),
            "last_updated": datetime.now().isoformat(),

            # 基本信息（通过对话逐步收集）
            "basic_info": {
                "name": None,
                "age": None,
                "gender": None,
                "location": None,
                "occupation": None,
                "education": None
            },

            # 认知风格（通过分析对话得出）
            "cognitive_style": {
                "thinking_pattern": [],
                "decision_style": [],
                "learning_style": [],
                "debate_preference": [],
                "data_preference": []
            },

            # 价值观（通过重要决策识别）
            "values": {
                "core_values": [],
                "value_conflicts": [],
                "risk_tolerance": None
            },

            # 知识图谱（已知/学习/盲区）
            "knowledge_graph": {
                "expertise": [],
                "learning": [],
                "blind_spots": []
            },

            # 行为模式（通过时间序列分析）
            "behavioral_patterns": {
                "work_habits": [],
                "decision_cycle": [],
                "stress_indicators": [],
                "growth_indicators": []
            },

            # 当前状态
            "emotional_state": {
                "current_mood": None,
                "recent_stressors": [],
                "emotional_triggers": []
            },

            # 目标追踪
            "goals": {
                "short_term": [],
                "medium_term": [],
                "long_term": [],
                "unknown": []
            },

            # 关系定位
            "relationships": {
                "debate_partner": "建立中",
                "mentor": "建立中",
                "secretary": "建立中",
                "friend": "建立中"
            },

            # 成长轨迹
            "growth_trajectory": {
                "past": [],
                "present": [],
                "potential": []
            },

            # 统计信息
            "stats": {
                "total_conversations": 0,
                "total_interactions": 0,
                "roles_used": {}
            }
        }
