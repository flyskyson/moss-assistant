"""
MOSS Assistant - Office Workspace 深度集成全面测试
智能管家测试脚本

测试范围：
1. 工作区集成功能测试
2. 超级管家调用测试
3. 工具关键词检测测试
4. 数据真实性验证测试
5. 管家/秘书模式响应测试
6. 边界条件和错误处理测试
"""

import os
import sys
import json
import subprocess
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Any, Tuple


class MOSSIntegrationTester:
    """MOSS 集成测试套件"""

    def __init__(self):
        self.moss_path = Path(__file__).parent
        self.workspace_path = Path("C:/Users/flyskyson/Office_Agent_Workspace")
        self.test_results = []
        self.pass_count = 0
        self.fail_count = 0
        self.warning_count = 0

    def log_test(self, test_name: str, status: str, details: str = ""):
        """记录测试结果"""
        result = {
            "test_name": test_name,
            "status": status,  # PASS, FAIL, WARNING
            "details": details,
            "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        }
        self.test_results.append(result)

        if status == "PASS":
            self.pass_count += 1
            print(f"[PASS] {test_name}")
        elif status == "FAIL":
            self.fail_count += 1
            print(f"[FAIL] {test_name}")
            if details:
                print(f"   Reason: {details}")
        elif status == "WARNING":
            self.warning_count += 1
            print(f"[WARN] {test_name}")
            if details:
                print(f"   Note: {details}")

    def test_01_workspace_path_exists(self):
        """测试 1: 工作区路径是否存在"""
        if self.workspace_path.exists():
            self.log_test(
                "工作区路径检查",
                "PASS",
                f"路径存在: {self.workspace_path}"
            )
            return True
        else:
            self.log_test(
                "工作区路径检查",
                "FAIL",
                f"路径不存在: {self.workspace_path}"
            )
            return False

    def test_02_workspace_integration_class(self):
        """测试 2: workspace_integration 类是否能正常导入和初始化"""
        try:
            sys.path.insert(0, str(self.moss_path))
            from core.workspace_integration import OfficeWorkspaceIntegration

            workspace = OfficeWorkspaceIntegration()
            self.log_test(
                "WorkspaceIntegration 类初始化",
                "PASS",
                f"enabled={workspace.enabled}"
            )
            return True
        except Exception as e:
            self.log_test(
                "WorkspaceIntegration 类初始化",
                "FAIL",
                str(e)
            )
            return False

    def test_03_super_butler_script_exists(self):
        """测试 3: 超级管家脚本是否存在"""
        super_butler = self.workspace_path / "超级管家.py"

        if super_butler.exists():
            self.log_test(
                "超级管家脚本检查",
                "PASS",
                f"文件存在: {super_butler}"
            )
            return True
        else:
            self.log_test(
                "超级管家脚本检查",
                "FAIL",
                "超级管家.py 不存在"
            )
            return False

    def test_04_query_projects_script_exists(self):
        """测试 4: 智能管家项目查询脚本是否存在"""
        query_script = self.workspace_path / "智能管家项目查询.py"

        if query_script.exists():
            self.log_test(
                "智能管家项目查询脚本检查",
                "PASS",
                f"文件存在: {query_script}"
            )
            return True
        else:
            self.log_test(
                "智能管家项目查询脚本检查",
                "FAIL",
                "智能管家项目查询.py 不存在"
            )
            return False

    def test_05_ai_memory_exists(self):
        """测试 5: AI_MEMORY.md 是否存在"""
        memory_file = self.workspace_path / "06_Learning_Journal" / "AI_MEMORY.md"

        if memory_file.exists():
            self.log_test(
                "AI_MEMORY.md 检查",
                "PASS",
                f"文件存在: {memory_file}"
            )
            return True
        else:
            self.log_test(
                "AI_MEMORY.md 检查",
                "WARNING",
                "AI_MEMORY.md 不存在（可选）"
            )
            return False

    def test_06_workspace_index_exists(self):
        """测试 6: 工作区索引文件是否存在"""
        index_file = (self.workspace_path /
                     "06_Learning_Journal" /
                     "workspace_memory" /
                     "workspace_index_latest.json")

        if index_file.exists():
            self.log_test(
                "工作区索引文件检查",
                "PASS",
                f"文件存在: {index_file}"
            )
            return True
        else:
            self.log_test(
                "工作区索引文件检查",
                "WARNING",
                "workspace_index_latest.json 不存在（可选）"
            )
            return False

    def test_07_get_project_structure_method(self):
        """测试 7: get_project_structure() 方法"""
        try:
            from core.workspace_integration import OfficeWorkspaceIntegration

            workspace = OfficeWorkspaceIntegration()
            result = workspace.get_project_structure()

            if result.get("success"):
                source = result.get("source", "未知")
                self.log_test(
                    "get_project_structure() 方法调用",
                    "PASS",
                    f"数据来源: {source}"
                )
                return True, result
            else:
                self.log_test(
                    "get_project_structure() 方法调用",
                    "FAIL",
                    result.get("error", "未知错误")
                )
                return False, result
        except Exception as e:
            self.log_test(
                "get_project_structure() 方法调用",
                "FAIL",
                str(e)
            )
            return False, None

    def test_08_query_projects_method(self):
        """测试 8: query_projects() 方法"""
        try:
            from core.workspace_integration import OfficeWorkspaceIntegration

            workspace = OfficeWorkspaceIntegration()
            result = workspace.query_projects()

            if result.get("success"):
                output = result.get("output", "")
                preview = output[:200] if len(output) > 200 else output
                self.log_test(
                    "query_projects() 方法调用",
                    "PASS",
                    f"输出预览: {preview}..."
                )
                return True, result
            else:
                self.log_test(
                    "query_projects() 方法调用",
                    "FAIL",
                    result.get("error", "未知错误")
                )
                return False, result
        except Exception as e:
            self.log_test(
                "query_projects() 方法调用",
                "FAIL",
                str(e)
            )
            return False, None

    def test_09_get_memory_info_method(self):
        """测试 9: get_memory_info() 方法"""
        try:
            from core.workspace_integration import OfficeWorkspaceIntegration

            workspace = OfficeWorkspaceIntegration()
            result = workspace.get_memory_info()

            if result.get("success"):
                content = result.get("content", "")
                preview = content[:100] if len(content) > 100 else content
                self.log_test(
                    "get_memory_info() 方法调用",
                    "PASS",
                    f"内容预览: {preview}..."
                )
                return True, result
            else:
                error = result.get("error", "")
                if "不存在" in error:
                    self.log_test(
                        "get_memory_info() 方法调用",
                        "WARNING",
                        "AI_MEMORY.md 文件不存在（可选）"
                    )
                else:
                    self.log_test(
                        "get_memory_info() 方法调用",
                        "FAIL",
                        error
                    )
                return False, result
        except Exception as e:
            self.log_test(
                "get_memory_info() 方法调用",
                "FAIL",
                str(e)
            )
            return False, None

    def test_10_get_workspace_index_method(self):
        """测试 10: get_workspace_index() 方法"""
        try:
            from core.workspace_integration import OfficeWorkspaceIntegration

            workspace = OfficeWorkspaceIntegration()
            result = workspace.get_workspace_index()

            if result.get("success"):
                data = result.get("data", {})
                self.log_test(
                    "get_workspace_index() 方法调用",
                    "PASS",
                    f"扫描时间: {data.get('scan_time', '未知')}"
                )
                return True, result
            else:
                error = result.get("error", "")
                if "不存在" in error:
                    self.log_test(
                        "get_workspace_index() 方法调用",
                        "WARNING",
                        "workspace_index_latest.json 不存在（可选）"
                    )
                else:
                    self.log_test(
                        "get_workspace_index() 方法调用",
                        "FAIL",
                        error
                    )
                return False, result
        except Exception as e:
            self.log_test(
                "get_workspace_index() 方法调用",
                "FAIL",
                str(e)
            )
            return False, None

    def test_11_tool_keyword_detection(self):
        """测试 11: 工具关键词检测"""
        try:
            from moss import MOSSAssistant

            moss = MOSSAssistant()

            # 测试用例：(输入, 预期工具类型)
            test_cases = [
                ("请扫描工作区", "scan_workspace"),
                ("生成健康报告", "scan_workspace"),
                ("查看项目列表", "query_projects"),
                ("读取我的AI记忆", "get_memory"),
                ("项目结构是什么", "get_structure"),
            ]

            all_passed = True
            for user_input, expected_tool in test_cases:
                # 调用内部方法检测
                tool_result = moss._check_and_call_tools(user_input)

                if tool_result is not None:
                    status = "PASS"
                else:
                    # 某些工具可能不存在，这也是可以接受的
                    if expected_tool in ["get_memory", "get_structure"]:
                        status = "WARNING"
                    else:
                        status = "FAIL"
                        all_passed = False

                self.log_test(
                    f"关键词检测: '{user_input}' -> {expected_tool}",
                    status,
                    f"工具调用: {'成功' if tool_result else '失败/无工具'}"
                )

            return all_passed
        except Exception as e:
            self.log_test(
                "工具关键词检测",
                "FAIL",
                str(e)
            )
            return False

    def test_12_moss_chat_integration(self):
        """测试 12: MOSS chat() 方法集成"""
        try:
            from moss import MOSSAssistant

            moss = MOSSAssistant()

            # 测试对话
            test_input = "请扫描当前工作区并出具诊断报告"
            response = moss.chat(test_input)

            if response and len(response) > 0:
                # 检查是否包含真实数据
                has_real_data = (
                    "Office_Agent_Workspace" in response or
                    "01_Active_Projects" in response or
                    "文件" in response
                )

                if has_real_data:
                    self.log_test(
                        "MOSS chat() 方法集成测试",
                        "PASS",
                        f"响应长度: {len(response)} 字符，包含真实数据"
                    )
                    return True
                else:
                    self.log_test(
                        "MOSS chat() 方法集成测试",
                        "WARNING",
                        "响应成功但可能未包含工具数据"
                    )
                    return False
            else:
                self.log_test(
                    "MOSS chat() 方法集成测试",
                    "FAIL",
                    "MOSS 未返回响应"
                )
                return False
        except Exception as e:
            self.log_test(
                "MOSS chat() 方法集成测试",
                "FAIL",
                str(e)
            )
            return False

    def test_13_data_authenticity_check(self):
        """测试 13: 数据真实性验证"""
        try:
            from moss import MOSSAssistant

            moss = MOSSAssistant()

            # 测试是否会编造数据
            test_input = "请扫描当前工作区并出具诊断报告"
            response = moss.chat(test_input)

            # 检查是否包含编造数据的典型特征
            fabrications = [
                "未读邮件：",  # 编造的邮件数量
                "明日 14:00",  # 编造的会议时间
                "待处理邮件 89 封",  # 特定的编造数字
                "项目\"Ares\"",  # 编造的项目名
            ]

            has_fabrication = any(fab in response for fab in fabrications)

            if not has_fabrication:
                # 检查是否包含真实数据的特征
                has_real_indicators = (
                    "真实" in response or
                    "扫描" in response or
                    "实际" in response or
                    "Office_Agent_Workspace" in response
                )

                if has_real_indicators:
                    self.log_test(
                        "数据真实性验证",
                        "PASS",
                        "未检测到编造数据，包含真实性指标"
                    )
                    return True
                else:
                    self.log_test(
                        "数据真实性验证",
                        "WARNING",
                        "未检测到编造数据，但也缺少真实性指标"
                    )
                    return False
            else:
                self.log_test(
                    "数据真实性验证",
                    "FAIL",
                    "检测到可能的编造数据"
                )
                return False
        except Exception as e:
            self.log_test(
                "数据真实性验证",
                "FAIL",
                str(e)
            )
            return False

    def test_14_config_prompts_integrity(self):
        """测试 14: 配置文件中的数据真实性约束"""
        try:
            import yaml

            config_file = self.moss_path / "config.yaml"

            with open(config_file, 'r', encoding='utf-8') as f:
                config = yaml.safe_load(f)

            # 检查管家角色的 Prompt
            steward_prompt = config['roles']['steward']['system_prompt']
            has_data_constraint = (
                "数据真实性" in steward_prompt or
                "绝不编造" in steward_prompt or
                "只报告真实" in steward_prompt
            )

            if has_data_constraint:
                self.log_test(
                    "管家 Prompt 数据真实性约束",
                    "PASS",
                    "包含数据真实性约束"
                )
            else:
                self.log_test(
                    "管家 Prompt 数据真实性约束",
                    "WARNING",
                    "缺少明确的数据真实性约束"
                )

            # 检查秘书角色的 Prompt
            secretary_prompt = config['roles']['secretary']['system_prompt']
            has_secretary_constraint = (
                "数据真实性" in secretary_prompt or
                "绝不编造" in secretary_prompt or
                "只报告可验证" in secretary_prompt
            )

            if has_secretary_constraint:
                self.log_test(
                    "秘书 Prompt 数据真实性约束",
                    "PASS",
                    "包含数据真实性约束"
                )
            else:
                self.log_test(
                    "秘书 Prompt 数据真实性约束",
                    "WARNING",
                    "缺少明确的数据真实性约束"
                )

            return has_data_constraint and has_secretary_constraint
        except Exception as e:
            self.log_test(
                "配置文件 Prompt 检查",
                "FAIL",
                str(e)
            )
            return False

    def test_15_interactions_logging(self):
        """测试 15: 交互日志记录"""
        try:
            interactions_file = self.moss_path / "data" / "interactions.json"

            if not interactions_file.exists():
                self.log_test(
                    "交互日志文件检查",
                    "WARNING",
                    "interactions.json 不存在（首次运行正常）"
                )
                return False

            with open(interactions_file, 'r', encoding='utf-8') as f:
                interactions = json.load(f)

            if len(interactions) > 0:
                last_interaction = interactions[-1]

                # 检查必需字段
                required_fields = ['timestamp', 'user_input', 'agent_response', 'role']
                has_all_fields = all(field in last_interaction for field in required_fields)

                if has_all_fields:
                    self.log_test(
                        "交互日志格式检查",
                        "PASS",
                        f"共 {len(interactions)} 条记录，格式正确"
                    )
                    return True
                else:
                    self.log_test(
                        "交互日志格式检查",
                        "FAIL",
                        f"缺少必需字段: {[f for f in required_fields if f not in last_interaction]}"
                    )
                    return False
            else:
                self.log_test(
                    "交互日志格式检查",
                    "WARNING",
                    "日志文件为空"
                )
                return False
        except Exception as e:
            self.log_test(
                "交互日志检查",
                "FAIL",
                str(e)
            )
            return False

    def run_all_tests(self):
        """运行所有测试"""
        print("=" * 70)
        print("MOSS Assistant - Office Workspace 深度集成全面测试")
        print("=" * 70)
        print(f"测试时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print(f"MOSS 路径: {self.moss_path}")
        print(f"工作区路径: {self.workspace_path}")
        print("=" * 70)
        print()

        # 运行所有测试
        print("【阶段 1: 基础设施检查】")
        print("-" * 70)
        self.test_01_workspace_path_exists()
        self.test_02_workspace_integration_class()
        self.test_03_super_butler_script_exists()
        self.test_04_query_projects_script_exists()
        self.test_05_ai_memory_exists()
        self.test_06_workspace_index_exists()
        print()

        print("【阶段 2: 核心功能测试】")
        print("-" * 70)
        self.test_07_get_project_structure_method()
        self.test_08_query_projects_method()
        self.test_09_get_memory_info_method()
        self.test_10_get_workspace_index_method()
        print()

        print("【阶段 3: 集成测试】")
        print("-" * 70)
        self.test_11_tool_keyword_detection()
        self.test_12_moss_chat_integration()
        print()

        print("【阶段 4: 质量验证】")
        print("-" * 70)
        self.test_13_data_authenticity_check()
        self.test_14_config_prompts_integrity()
        self.test_15_interactions_logging()
        print()

        # 生成测试报告
        self.generate_report()

    def generate_report(self):
        """生成测试报告"""
        print("=" * 70)
        print("【测试报告总结】")
        print("=" * 70)

        total = self.pass_count + self.fail_count + self.warning_count
        pass_rate = (self.pass_count / total * 100) if total > 0 else 0

        print(f"Total Tests: {total}")
        print(f"[PASS] {self.pass_count} ({pass_rate:.1f}%)")
        print(f"[FAIL] {self.fail_count}")
        print(f"[WARN] {self.warning_count}")
        print()

        # 评级
        if pass_rate >= 90:
            grade = "A (Excellent)"
        elif pass_rate >= 80:
            grade = "B (Good)"
        elif pass_rate >= 70:
            grade = "C (Pass)"
        else:
            grade = "D (Needs Improvement)"

        print(f"Overall Grade: {grade}")
        print()

        # 详细结果
        print("Detailed Test Results:")
        print("-" * 70)

        for result in self.test_results:
            status_icon = {
                "PASS": "[PASS]",
                "FAIL": "[FAIL]",
                "WARNING": "[WARN]"
            }.get(result["status"], "[?]")

            print(f"{status_icon} {result['test_name']}")
            if result['details']:
                print(f"      -> {result['details']}")
            print(f"      -> Time: {result['timestamp']}")
            print()

        # 保存 JSON 报告
        report_path = self.moss_path / "data" / "test_report.json"
        report_path.parent.mkdir(exist_ok=True)

        report_data = {
            "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            "summary": {
                "total": total,
                "pass": self.pass_count,
                "fail": self.fail_count,
                "warning": self.warning_count,
                "pass_rate": pass_rate,
                "grade": grade
            },
            "tests": self.test_results
        }

        with open(report_path, 'w', encoding='utf-8') as f:
            json.dump(report_data, f, indent=2, ensure_ascii=False)

        print(f"完整报告已保存至: {report_path}")
        print("=" * 70)


if __name__ == "__main__":
    tester = MOSSIntegrationTester()
    tester.run_all_tests()
