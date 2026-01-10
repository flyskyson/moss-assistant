"""
MOSS Assistant - 启动方式测试脚本
用于验证所有启动方式的可用性
"""

import os
import sys
from pathlib import Path

# Windows UTF-8 支持
if sys.platform == "win32":
    import codecs
    sys.stdout = codecs.getwriter("utf-8")(sys.stdout.buffer, 'strict')
    sys.stderr = codecs.getwriter("utf-8")(sys.stderr.buffer, 'strict')


def print_header(title):
    """打印标题"""
    print()
    print("=" * 60)
    print(f"  {title}")
    print("=" * 60)
    print()


def check_file(filepath, description):
    """检查文件是否存在"""
    path = Path(filepath)
    if path.exists():
        size = path.stat().st_size
        print(f"✅ {description}")
        print(f"   位置: {filepath}")
        print(f"   大小: {size} 字节")
        return True
    else:
        print(f"❌ {description}")
        print(f"   位置: {filepath}")
        print(f"   状态: 文件不存在")
        return False


def check_executable(filepath, description):
    """检查文件是否可执行（Linux/Mac）"""
    if sys.platform == "win32":
        return True  # Windows 不检查执行权限

    path = Path(filepath)
    if path.exists():
        if os.access(path, os.X_OK):
            print(f"✅ {description} (可执行)")
            return True
        else:
            print(f"⚠️  {description} (不可执行，需要 chmod +x)")
            return False
    else:
        return False


def main():
    """主测试函数"""
    print_header("MOSS Assistant - 启动方式测试")

    project_root = Path(__file__).parent
    os.chdir(project_root)

    # 测试结果
    results = {
        "passed": 0,
        "failed": 0,
        "warnings": 0
    }

    # 1. 检查核心文件
    print("[1/4] 检查核心启动文件")
    print()

    files_to_check = [
        ("launcher.py", "智能启动器 (Python)"),
        ("start_moss.py", "传统启动器 (Python)"),
        ("app.py", "Streamlit 应用"),
        ("moss.py", "MOSS 核心程序"),
        ("config.yaml", "配置文件"),
    ]

    for filepath, description in files_to_check:
        if check_file(filepath, description):
            results["passed"] += 1
        else:
            results["failed"] += 1
        print()

    # 2. 检查 Windows 启动脚本
    print("[2/4] 检查 Windows 启动脚本")
    print()

    windows_files = [
        ("一键启动.bat", "一键启动脚本 (Windows)"),
        ("启动 MOSS.bat", "快速启动脚本 (Windows)"),
        ("start.bat", "传统启动脚本 (Windows)"),
    ]

    for filepath, description in windows_files:
        if check_file(filepath, description):
            results["passed"] += 1
        else:
            results["failed"] += 1
        print()

    # 3. 检查 Linux/Mac 启动脚本
    print("[3/4] 检查 Linux/Mac 启动脚本")
    print()

    unix_files = [
        ("一键启动.sh", "一键启动脚本 (Linux/Mac)"),
        ("start.sh", "传统启动脚本 (Linux/Mac)"),
    ]

    for filepath, description in unix_files:
        if check_file(filepath, description):
            results["passed"] += 1
            if not check_executable(filepath, description):
                results["warnings"] += 1
        else:
            results["failed"] += 1
        print()

    # 4. 检查文档
    print("[4/4] 检查文档")
    print()

    docs = [
        ("启动指南.md", "启动指南"),
        ("启动方式总结.md", "启动方式快速参考"),
        ("桌面快捷方式说明.md", "桌面快捷方式说明"),
        ("PROJECT_PASSPORT.md", "项目护照"),
    ]

    for filepath, description in docs:
        if check_file(filepath, description):
            results["passed"] += 1
        else:
            results["warnings"] += 1
        print()

    # 5. 检查目录结构
    print("[5/5] 检查目录结构")
    print()

    dirs_to_check = [
        ("core", "核心模块目录"),
        ("data", "数据目录"),
        ("docs", "文档目录"),
    ]

    for dirpath, description in dirs_to_check:
        path = Path(dirpath)
        if path.exists() and path.is_dir():
            print(f"✅ {description}")
            print(f"   位置: {dirpath}")
            results["passed"] += 1
        else:
            print(f"⚠️  {description}")
            print(f"   位置: {dirpath}")
            print(f"   状态: 目录不存在")
            results["warnings"] += 1
        print()

    # 6. 总结
    print_header("测试结果总结")

    total = results["passed"] + results["failed"] + results["warnings"]

    print(f"✅ 通过: {results['passed']} 项")
    print(f"❌ 失败: {results['failed']} 项")
    print(f"⚠️  警告: {results['warnings']} 项")
    print(f"📊 总计: {total} 项")
    print()

    # 7. 推荐
    print("=" * 60)
    print("  推荐的启动方式")
    print("=" * 60)
    print()

    if sys.platform == "win32":
        if Path("一键启动.bat").exists():
            print("🌟 首选: 一键启动.bat")
            print("   原因: 完整检查，美观界面，自动修复")
            print()

        if Path("启动 MOSS.bat").exists():
            print("⚡ 备选: 启动 MOSS.bat")
            print("   原因: 快速简洁，适合频繁使用")
            print()

        if Path("launcher.py").exists():
            print("🐍 开发: launcher.py")
            print("   原因: Python 原生，可定制，跨平台")
            print()
    else:
        if Path("一键启动.sh").exists():
            print("🌟 首选: ./一键启动.sh")
            print("   原因: 完整检查，彩色输出，自动修复")
            print()

        if Path("launcher.py").exists():
            print("🐍 备选: python launcher.py")
            print("   原因: Python 原生，可定制，跨平台")
            print()

    # 8. 下一步
    print("=" * 60)
    print("  下一步")
    print("=" * 60)
    print()

    if results["failed"] > 0:
        print("⚠️  检测到缺失文件，建议检查项目完整性")
        print()
        print("💡 可以尝试:")
        print("   1. 重新克隆项目")
        print("   2. 从备份恢复")
        print("   3. 检查文件是否被误删")
        print()

    if results["warnings"] > 0:
        print("💡 建议:")
        print("   1. 为 Linux/Mac 脚本添加执行权限:")
        print("      chmod +x 一键启动.sh")
        print("   2. 查看完整文档了解详情")
        print()

    if results["failed"] == 0 and results["warnings"] == 0:
        print("🎉 完美！所有检查都通过了！")
        print()
        print("✨ 你现在可以:")
        print("   1. 使用推荐的方式启动 MOSS")
        print("   2. 创建桌面快捷方式（查看桌面快捷方式说明.md）")
        print("   3. 开始使用 MOSS Assistant")
        print()

    print("=" * 60)
    print()


if __name__ == "__main__":
    main()
