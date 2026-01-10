"""
MOSS Assistant 基础测试
"""

import sys
import os
from pathlib import Path

# 添加项目路径
sys.path.insert(0, str(Path(__file__).parent.parent))

from core.memory import PersistentMemory
from core.router import RoleRouter
from core.user_model import UserModelManager


def test_memory():
    """测试记忆系统"""
    print("\n[测试 1] 记忆系统")
    print("-" * 50)

    config = {
        "memory": {
            "backend": "json",
            "path": "./data/test"
        }
    }

    memory = PersistentMemory(config)

    # 测试用户模型
    user_model = memory.load_user_model()
    print(f"✓ 用户模型加载成功")
    print(f"  - 版本: {user_model.get('version')}")

    # 测试保存
    memory.save_user_model(user_model)
    print(f"✓ 用户模型保存成功")

    # 测试对话保存
    test_conversation = {
        "id": "test_conv_001",
        "timestamp": "2025-01-10T12:00:00",
        "messages": [
            {"role": "user", "content": "测试消息"}
        ]
    }
    memory.save_conversation("test_conv_001", test_conversation)
    print(f"✓ 对话保存成功")

    # 测试加载
    conversations = memory.load_conversations(limit=1)
    print(f"✓ 对话加载成功 (共 {len(conversations)} 条)")


def test_router():
    """测试角色路由"""
    print("\n[测试 2] 角色路由")
    print("-" * 50)

    config = {
        "roles": {
            "mentor": {
                "enabled": True,
                "trigger_keywords": ["决定", "选择", "创业"]
            },
            "partner": {
                "enabled": True,
                "trigger_keywords": ["讨论", "怎么看", "为什么"]
            },
            "secretary": {
                "enabled": True,
                "trigger_keywords": ["查", "写", "提醒"]
            },
            "friend": {
                "enabled": True,
                "trigger_keywords": ["难过", "焦虑", "迷茫"]
            }
        }
    }

    router = RoleRouter(config)

    # 测试不同输入
    test_cases = [
        ("我想辞职创业", "mentor"),
        ("你怎么看女权问题？", "partner"),
        ("帮我查一下天气", "secretary"),
        ("最近感觉很迷茫", "friend")
    ]

    for user_input, expected_role in test_cases:
        result = router.route(user_input, {})
        actual_role = result["role"]
        status = "✓" if actual_role == expected_role else "✗"
        print(f"{status} '{user_input}' -> {actual_role} (期望: {expected_role})")


def test_user_model():
    """测试用户模型"""
    print("\n[测试 3] 用户模型")
    print("-" * 50)

    config = {
        "memory": {
            "backend": "json",
            "path": "./data/test"
        }
    }

    memory = PersistentMemory(config)
    manager = UserModelManager(memory)

    # 测试获取模型
    user_model = manager.get_model()
    print(f"✓ 用户模型获取成功")

    # 测试更新基本信息
    manager.update_basic_info("name", "测试用户")
    manager.update_basic_info("age", 30)

    # 验证更新
    updated_model = manager.get_model()
    assert updated_model["basic_info"]["name"] == "测试用户"
    assert updated_model["basic_info"]["age"] == 30
    print(f"✓ 基本信息更新成功")

    # 测试添加目标
    manager.add_goal("学好 Python", "short_term")
    manager.add_goal("创业", "long_term")

    # 验证目标
    updated_model = manager.get_model()
    assert "学好 Python" in updated_model["goals"]["short_term"]
    assert "创业" in updated_model["goals"]["long_term"]
    print(f"✓ 目标添加成功")

    # 测试摘要生成
    summary = manager.get_summary()
    print(f"✓ 摘要生成成功")
    print(f"\n[摘要预览]")
    print(summary[:200] + "...")


def main():
    """运行所有测试"""
    print("=" * 50)
    print("MOSS Assistant - 基础测试")
    print("=" * 50)

    try:
        test_memory()
        test_router()
        test_user_model()

        print("\n" + "=" * 50)
        print("✓ 所有测试通过！")
        print("=" * 50)

    except AssertionError as e:
        print(f"\n✗ 测试失败: {e}")
        return 1
    except Exception as e:
        print(f"\n✗ 错误: {e}")
        import traceback
        traceback.print_exc()
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())
