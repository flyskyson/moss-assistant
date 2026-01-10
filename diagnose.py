"""
MOSS Assistant 诊断工具
快速检查系统状态和健康状况
"""

import os
import sys
import json
from pathlib import Path
import subprocess


def check_file_exists(filepath: str, name: str) -> bool:
    """检查文件是否存在"""
    if Path(filepath).exists():
        print(f"[OK] {name}: {filepath}")
        return True
    else:
        print(f"[MISSING] {name}: {filepath}")
        return False


def check_process_running(process_name: str) -> bool:
    """检查进程是否运行"""
    try:
        result = subprocess.run(
            f"tasklist | findstr {process_name}",
            shell=True,
            capture_output=True,
            text=True
        )
        if process_name.lower() in result.stdout.lower():
            print(f"[RUNNING] {process_name}")
            return True
        else:
            print(f"[NOT RUNNING] {process_name}")
            return False
    except:
        print(f"[UNKNOWN] {process_name}")
        return False


def check_port_listening(port: int) -> bool:
    """检查端口是否监听"""
    try:
        result = subprocess.run(
            f"netstat -ano | findstr :{port}",
            shell=True,
            capture_output=True,
            text=True
        )
        if f":{port}" in result.stdout and "LISTENING" in result.stdout:
            print(f"[LISTENING] Port {port}")
            return True
        else:
            print(f"[NOT LISTENING] Port {port}")
            return False
    except:
        print(f"[UNKNOWN] Port {port}")
        return False


def diagnose():
    """运行完整诊断"""
    print("=" * 60)
    print("MOSS Assistant 诊断工具")
    print("=" * 60)
    print()

    issues = []

    # 1. 检查核心文件
    print("[1/6] 检查核心文件...")
    print("-" * 60)

    files_to_check = [
        ("config.yaml", "配置文件"),
        ("moss.py", "主程序"),
        ("app.py", "Web UI"),
        ("start_moss.py", "启动脚本"),
        (".env", "环境变量"),
        ("PROJECT_PASSPORT.md", "项目护照"),
    ]

    for filepath, name in files_to_check:
        if not check_file_exists(filepath, name):
            issues.append(f"核心文件缺失: {filepath}")

    print()

    # 2. 检查数据文件
    print("[2/6] 检查数据文件...")
    print("-" * 60)

    data_files = [
        ("data/user_model.json", "用户模型"),
        ("data/conversations.json", "对话历史"),
        ("data/interactions.json", "交互日志"),
    ]

    for filepath, name in data_files:
        if not check_file_exists(filepath, name):
            print(f"[NEW] {name}: {filepath}")

    print()

    # 3. 检查依赖
    print("[3/6] 检查依赖包...")
    print("-" * 60)

    required_packages = [
        "yaml",
        "streamlit",
        "openai",
        "anthropic"
    ]

    for package in required_packages:
        try:
            __import__(package)
            print(f"[OK] {package}")
        except ImportError:
            print(f"[MISSING] {package}")
            issues.append(f"依赖包缺失: {package}")

    print()

    # 4. 检查进程
    print("[4/6] 检查运行状态...")
    print("-" * 60)

    python_running = check_process_running("python.exe")
    streamlit_running = check_process_running("streamlit")

    print()

    # 5. 检查端口
    print("[5/6] 检查网络端口...")
    print("-" * 60)

    port_8501 = check_port_listening(8501)

    print()

    # 6. 检查日志
    print("[6/6] 检查日志文件...")
    print("-" * 60)

    if Path("streamlit.log").exists():
        print("[OK] streamlit.log 存在")
        # 显示最后几行
        with open("streamlit.log", "r", encoding="utf-8") as f:
            lines = f.readlines()
            if len(lines) > 0:
                print(f"\n最后 5 行日志:")
                print("-" * 60)
                for line in lines[-5:]:
                    print(line.rstrip())
    else:
        print("[INFO] streamlit.log 不存在（可能未启动过）")

    print()

    # 总结
    print("=" * 60)
    print("诊断总结")
    print("=" * 60)

    if len(issues) == 0:
        print("[SUCCESS] 所有检查通过！")
        print()
        print("服务状态:")
        if python_running and port_8501:
            print("  [RUNNING] MOSS Assistant 正在运行")
            print("  [URL] http://localhost:8501")
        else:
            print("  [STOPPED] MOSS Assistant 未运行")
            print()
            print("启动命令:")
            print("  python start_moss.py")
    else:
        print(f"[FOUND {len(issues)} ISSUES]")
        print()
        for i, issue in enumerate(issues, 1):
            print(f"  {i}. {issue}")
        print()
        print("建议:")
        print("  1. 安装缺失的依赖: pip install -r requirements.txt")
        print("  2. 检查文件完整性")
        print("  3. 重新启动: python start_moss.py")

    print()
    print("=" * 60)

    return len(issues) == 0


if __name__ == "__main__":
    try:
        success = diagnose()
        sys.exit(0 if success else 1)
    except KeyboardInterrupt:
        print("\n\n诊断已取消")
        sys.exit(1)
    except Exception as e:
        print(f"\n[ERROR] 诊断过程中出错: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
