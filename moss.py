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

try:
    from openai import OpenAI
    OPENAI_AVAILABLE = True
except ImportError:
    OPENAI_AVAILABLE = False

from core.memory import PersistentMemory
from core.user_model import UserModelManager
from core.router import RoleRouter
from core.integrations import ExternalAgentManager


class MOSSAssistant:
    """MOSS 助手核心类"""

    def __init__(self, config_path: str = "config.yaml"):
        # 加载配置
        self.config = self._load_config(config_path)

        # 初始化组件
        self.memory = PersistentMemory(self.config)
        self.user_model_manager = UserModelManager(self.memory)
        self.router = RoleRouter(self.config)
        self.external_agents = ExternalAgentManager()  # 外部智能体管理器

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
        provider = self.config["llm"]["provider"]
        api_key = os.getenv(self.config["llm"]["api_key_env"])

        if not api_key:
            print("[警告]  警告: 未设置 API Key，请设置环境变量")
            print(f"   环境变量名: {self.config['llm']['api_key_env']}")
            return None

        if provider == "claude":
            if not ANTHROPIC_AVAILABLE:
                print("[警告]  警告: 需要安装 anthropic 库")
                return None
            return anthropic.Anthropic(api_key=api_key)

        elif provider in ["openai", "deepseek"]:
            if not OPENAI_AVAILABLE:
                print("[警告]  警告: 需要安装 openai 库")
                return None

            # DeepSeek 使用 OpenAI 兼容的 API
            base_url = self.config["llm"].get("base_url")
            if provider == "deepseek":
                base_url = base_url or "https://api.deepseek.com"

            return OpenAI(
                api_key=api_key,
                base_url=base_url
            )

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

    def _check_and_call_tools(self, user_input: str) -> str:
        """
        检查是否需要调用工具，并执行

        Args:
            user_input: 用户输入

        Returns:
            工具调用结果，如果不需要调用则返回 None
        """
        # 定义工具调用关键词
        tool_keywords = {
            "scan_workspace": ["扫描工作区", "扫描项目", "工作区现状", "生成报告", "健康报告", "诊断报告"],
            "query_projects": ["项目列表", "查看项目", "项目状态", "所有项目"],
            "get_memory": ["读取记忆", "AI记忆", "我的档案"],
            "get_structure": ["项目结构", "文件结构", "目录结构"],
        }

        # 检查是否需要调用工具
        should_call_tool = False
        tool_type = None

        for tool_name, keywords in tool_keywords.items():
            if any(keyword in user_input for keyword in keywords):
                should_call_tool = True
                tool_type = tool_name
                break

        if should_call_tool:
            try:
                from core.workspace_integration import OfficeWorkspaceIntegration
                import json

                # 初始化工作区集成
                workspace = OfficeWorkspaceIntegration()

                if not workspace.enabled:
                    return "工作区路径不存在或无法访问，请检查路径是否正确"

                # 根据工具类型调用不同方法
                if tool_type == "scan_workspace":
                    # 调用超级管家扫描
                    result = workspace.get_project_structure()

                    if result.get("success"):
                        source = result.get("source", "未知")

                        if source == "超级管家" and "data" in result:
                            # 超级管家返回的完整数据
                            data = result["data"]

                            report_lines = [
                                "=== 工作区扫描报告（超级管家）===",
                                f"生成时间: {data.get('timestamp', '未知')}",
                                f"工作区路径: {data.get('workspace_path', '未知')}",
                                ""
                            ]

                            # MCP服务器
                            if "mcp_servers" in data:
                                mcp = data["mcp_servers"]
                                report_lines.extend([
                                    "【MCP服务器】",
                                    f"状态: {mcp.get('status', '未知')}",
                                    f"数量: {mcp.get('count', 0)} 个"
                                ])
                                for server in mcp.get("servers", []):
                                    report_lines.append(f"  - {server.get('name', '未知')}")
                                report_lines.append("")

                            # 数据新鲜度
                            if "data_freshness" in data:
                                fresh = data["data_freshness"]
                                if fresh.get("index_exists"):
                                    report_lines.extend([
                                        "【数据状态】",
                                        f"最后扫描: {fresh.get('last_scan', '未知')}",
                                        f"数据年龄: {fresh.get('age_hours', 0)} 小时",
                                        f"新鲜度: {fresh.get('freshness', '未知')}",
                                        f"建议: {fresh.get('recommendation', '无')}",
                                        ""
                                    ])

                            # 项目
                            if "projects" in data:
                                projects = data["projects"]
                                report_lines.extend([
                                    "【项目资产】",
                                    f"活跃项目: {projects.get('active_count', 0)} 个"
                                ])

                                for p in projects.get("active", []):
                                    report_lines.append(
                                        f"  - {p.get('name', '未知'):30s} | "
                                        f"{p.get('last_modified', '未知')} | "
                                        f"{p.get('py_files', 0)}个文件"
                                    )

                                report_lines.append(
                                    f"归档项目: {projects.get('archived_count', 0)} 个"
                                )
                                for p in projects.get("archived", []):
                                    report_lines.append(f"  - {p.get('name', '未知')}")
                                report_lines.append("")

                            # 工具
                            if "tools" in data:
                                tools = data["tools"]
                                if "error" not in tools:
                                    report_lines.extend([
                                        "【工具脚本】",
                                        f"Python工具: {tools.get('python_tools_count', 0)} 个",
                                        f"批处理脚本: {tools.get('batch_scripts_count', 0)} 个",
                                        ""
                                    ])

                            # 笔记
                            if "notes" in data:
                                notes = data["notes"]
                                report_lines.extend([
                                    "【笔记和文档】",
                                    f"分类数量: {notes.get('total_categories', 0)} 个"
                                ])
                                for cat in notes.get("categories", []):
                                    report_lines.append(
                                        f"  - {cat.get('type', '未知')}: "
                                        f"{cat.get('count', 0)}个文件 "
                                        f"({cat.get('location', '未知')})"
                                    )
                                report_lines.append("")

                            return "\n".join(report_lines)

                        else:
                            # 降级方案：使用简单扫描
                            structure = result.get("structure", {})
                            report_lines = [
                                "=== 工作区扫描结果 ===",
                                f"扫描路径: {result.get('workspace_path')}",
                                f"扫描时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
                                ""
                            ]

                            for dir_name, info in structure.items():
                                report_lines.extend([
                                    f"📁 {dir_name}",
                                    f"   - 文件数: {info['file_count']}",
                                    f"   - 目录数: {info['dir_count']}",
                                    f"   - 大小: {info['size_mb']:.2f} MB",
                                    ""
                                ])

                            return "\n".join(report_lines)
                    else:
                        return f"扫描失败: {result.get('error', '未知错误')}"

                elif tool_type == "query_projects":
                    # 查询项目状态
                    result = workspace.query_projects()

                    if result.get("success"):
                        return f"【项目查询结果】\n\n{result.get('output', '')}"
                    else:
                        return f"查询失败: {result.get('error', '未知错误')}"

                elif tool_type == "get_memory":
                    # 读取AI记忆
                    result = workspace.get_memory_info()

                    if result.get("success"):
                        content = result.get("content", "")
                        # 只返回前1000个字符，避免太长
                        preview = content[:1000]
                        if len(content) > 1000:
                            preview += "\n\n...(内容过长，已截断)"
                        return f"【AI记忆内容】\n\n文件路径: {result.get('file_path')}\n\n{preview}"
                    else:
                        return f"读取失败: {result.get('error', '未知错误')}"

                elif tool_type == "get_structure":
                    # 获取项目结构
                    result = workspace.get_project_structure()
                    if result.get("success"):
                        return json.dumps(result, indent=2, ensure_ascii=False)
                    else:
                        return f"获取结构失败: {result.get('error', '未知错误')}"

            except Exception as e:
                import traceback
                return f"工具调用出错: {str(e)}\n\n详细错误:\n{traceback.format_exc()}"

        return None

    def chat(self, user_input: str) -> str:
        """处理用户输入"""
        # 步骤 0: 检查是否需要调用工具
        tool_result = self._check_and_call_tools(user_input)
        if tool_result:
            # 如果工具调用成功，将工具结果注入到对话中
            enhanced_input = f"{user_input}\n\n【工具调用结果】\n{tool_result}"
        else:
            enhanced_input = user_input

        # 步骤 1: 路由到合适的角色
        user_model = self.user_model_manager.get_model()
        routing_result = self.router.route(enhanced_input, user_model)

        role = routing_result["role"]
        role_config = routing_result["role_config"]
        reasoning = routing_result["reasoning"]

        print(f"\n[角色路由] {role_config['name']} ({reasoning})")

        # 步骤 2: 构建对话上下文
        messages = self._build_messages(enhanced_input, role)

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
        if not self.llm_client:
            return self._mock_response(role)

        try:
            provider = self.config["llm"]["provider"]
            model = self.config["llm"]["model"]
            max_tokens = self.config["llm"]["max_tokens"]

            if provider == "claude":
                # 使用 Claude API
                response = self.llm_client.messages.create(
                    model=model,
                    max_tokens=max_tokens,
                    messages=messages
                )
                return response.content[0].text

            elif provider in ["openai", "deepseek"]:
                # 使用 OpenAI 兼容 API
                response = self.llm_client.chat.completions.create(
                    model=model,
                    messages=messages,
                    max_tokens=max_tokens
                )
                return response.choices[0].message.content

            else:
                return self._mock_response(role)

        except Exception as e:
            print(f"[警告]  LLM 调用失败: {e}")
            import traceback
            traceback.print_exc()
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

        print(f"\n[成功] 对话已保存: {self.current_conversation['id']}")

    def update_user_info(self, key: str, value: Any):
        """更新用户信息"""
        self.user_model_manager.update_basic_info(key, value)

    def add_goal(self, goal: str, timeframe: str = "short_term"):
        """添加目标"""
        self.user_model_manager.add_goal(goal, timeframe)

    def backup(self):
        """备份数据"""
        self.memory.backup()

    def call_external_agent(self, agent_id: str, method: str, *args, **kwargs) -> Dict[str, Any]:
        """
        调用外部智能体

        Args:
            agent_id: 智能体 ID (如 "workspace_manager")
            method: 方法名
            *args: 位置参数
            **kwargs: 关键字参数

        Returns:
            执行结果
        """
        return self.external_agents.call_agent(agent_id, method, *args, **kwargs)

    def register_agent(self, agent_id: str, config: Dict[str, Any]):
        """
        注册新的外部智能体

        Args:
            agent_id: 智能体 ID
            config: 配置信息
        """
        self.external_agents.register_agent(agent_id, config)


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
