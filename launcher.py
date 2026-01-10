"""
MOSS Assistant - 智能启动器
提供完整的环境检测、依赖安装、健康检查和启动功能
"""

import os
import sys
import subprocess
import webbrowser
from pathlib import Path
from datetime import datetime
import time

# Windows UTF-8 支持
if sys.platform == "win32":
    import codecs
    sys.stdout = codecs.getwriter("utf-8")(sys.stdout.buffer, 'strict')
    sys.stderr = codecs.getwriter("utf-8")(sys.stderr.buffer, 'strict')


class MOSSLauncher:
    """MOSS Assistant 智能启动器"""

    def __init__(self):
        self.project_root = Path(__file__).parent
        self.errors = []
        self.warnings = []

    def print_header(self):
        """打印启动头部"""
        print()
        print("╔════════════════════════════════════════════════════════╗")
        print("║     🤖 MOSS Assistant - 智能启动器 v2.0              ║")
        print("║     苏格拉底式辩论伙伴 + 全能个人助理                 ║")
        print("╚════════════════════════════════════════════════════════╝")
        print()

    def check_python(self):
        """检查 Python 环境"""
        print("[1/7] 检测运行环境...")
        print()

        # 检查 Python 版本
        version = sys.version_info
        if version.major < 3 or (version.major == 3 and version.minor < 8):
            self.errors.append(f"Python 版本过低: {version.major}.{version.minor}")
            print(f"❌ Python 版本: {version.major}.{version.minor}.{version.micro}")
            print("💡 需要 Python 3.8 或更高版本")
            return False

        print(f"✅ Python 版本: {version.major}.{version.minor}.{version.micro}")

        # 检查 pip
        try:
            import pip
            print("✅ pip 已就绪")
        except ImportError:
            self.errors.append("pip 未安装")
            print("❌ pip 未安装")
            return False

        print()
        return True

    def load_env(self):
        """加载环境变量"""
        print("[2/7] 加载环境变量...")
        print()

        env_file = self.project_root / ".env"
        if env_file.exists():
            print("✅ 发现 .env 文件")

            with open(env_file, 'r', encoding='utf-8') as f:
                for line in f:
                    line = line.strip()
                    if line and not line.startswith('#') and '=' in line:
                        key, value = line.split('=', 1)
                        os.environ[key.strip()] = value.strip()

            # 检查 API Key
            api_key = os.getenv("DEEPSEEK_API_KEY")
            if api_key:
                print(f"✅ DeepSeek API Key: {api_key[:10]}...")
            else:
                self.warnings.append(".env 文件中未找到 DEEPSEEK_API_KEY")
                print("⚠️  警告: .env 文件中未找到 DEEPSEEK_API_KEY")
        else:
            self.warnings.append(".env 文件不存在")
            print("⚠️  警告: .env 文件不存在")
            print("💡 提示: 如果 API Key 未设置，MOSS 将使用模拟响应模式")

        print()
        return True

    def check_dependencies(self):
        """检查并安装依赖"""
        print("[3/7] 检查项目依赖...")
        print()

        req_file = self.project_root / "requirements.txt"
        if not req_file.exists():
            self.errors.append("requirements.txt 文件不存在")
            print("❌ 错误: requirements.txt 文件不存在")
            print("💡 请确保在 MOSS Assistant 项目根目录下运行此脚本")
            return False

        # 检查关键依赖
        missing_deps = []
        required_packages = ['streamlit', 'yaml', 'openai']

        for package in required_packages:
            try:
                __import__(package)
            except ImportError:
                missing_deps.append(package)

        if missing_deps:
            print(f"📦 安装缺失的依赖: {', '.join(missing_deps)}")
            print()

            try:
                subprocess.run(
                    [sys.executable, "-m", "pip", "install", "-r", "requirements.txt"],
                    check=True,
                    capture_output=False
                )
                print()
                print("✅ 依赖安装完成")
            except subprocess.CalledProcessError:
                self.errors.append("依赖安装失败")
                print("❌ 错误: 依赖安装失败")
                print("💡 请检查网络连接或手动运行: pip install -r requirements.txt")
                return False
        else:
            print("✅ 核心依赖已安装")

        print()
        return True

    def check_core_files(self):
        """检查核心文件"""
        print("[4/7] 检查核心文件...")
        print()

        required_files = [
            "moss.py",
            "app.py",
            "config.yaml",
        ]

        required_dirs = [
            "core",
        ]

        missing = []

        for file in required_files:
            if not (self.project_root / file).exists():
                print(f"❌ 缺少核心文件: {file}")
                missing.append(file)

        for dir_name in required_dirs:
            if not (self.project_root / dir_name).exists():
                print(f"❌ 缺少核心目录: {dir_name}/")
                missing.append(dir_name)

        if missing:
            self.errors.append(f"项目文件不完整，缺少 {len(missing)} 个文件/目录")
            print()
            print(f"❌ 错误: 项目文件不完整，缺少 {len(missing)} 个文件/目录")
            print("💡 请重新克隆项目或检查文件完整性")
            return False

        print("✅ 核心文件检查通过")
        print()
        return True

    def check_data_dir(self):
        """检查并创建数据目录"""
        print("[5/7] 检查数据目录...")
        print()

        data_dir = self.project_root / "data"
        logs_dir = data_dir / "logs"

        if not data_dir.exists():
            print("📁 创建数据目录...")
            data_dir.mkdir(parents=True, exist_ok=True)
            print("✅ data/ 目录已创建")
        else:
            print("✅ data/ 目录存在")

        if not logs_dir.exists():
            logs_dir.mkdir(parents=True, exist_ok=True)

        print("✅ 数据目录就绪")
        print()
        return True

    def health_check(self):
        """健康检查"""
        print("[6/7] 健康检查...")
        print()

        checks_passed = 0
        total_checks = 0

        # 检查配置文件
        total_checks += 1
        config_file = self.project_root / "config.yaml"
        if config_file.exists():
            try:
                import yaml
                with open(config_file, 'r', encoding='utf-8') as f:
                    config = yaml.safe_load(f)
                print("✅ 配置文件有效")
                checks_passed += 1
            except Exception as e:
                print(f"⚠️  配置文件解析错误: {e}")
        else:
            print("❌ 配置文件不存在")

        # 检查 API Key
        total_checks += 1
        api_key = os.getenv("DEEPSEEK_API_KEY")
        if api_key:
            print("✅ API Key 已设置")
            checks_passed += 1
        else:
            print("⚠️  API Key 未设置（将使用模拟模式）")

        # 检查端口
        total_checks += 1
        import socket
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        result = sock.connect_ex(('localhost', 8501))
        sock.close()
        if result != 0:
            print("✅ 端口 8501 可用")
            checks_passed += 1
        else:
            print("⚠️  端口 8501 已被占用")
            self.warnings.append("端口 8501 已被占用")

        print()
        print(f"健康检查: {checks_passed}/{total_checks} 项通过")
        print()
        return True

    def launch_moss(self):
        """启动 MOSS"""
        print("[7/7] 启动 MOSS Assistant...")
        print()
        print("════════════════════════════════════════════════════════")
        print()
        print("🌐 访问地址: http://localhost:8501")
        print("📱 移动端: http://localhost:8501")
        print()
        print("💡 提示:")
        print("   - 浏览器将自动打开（如果没有，请手动访问上面的地址）")
        print("   - 按 Ctrl+C 停止服务")
        print("   - 关闭此窗口也会停止服务")
        print()
        print("════════════════════════════════════════════════════════")
        print()

        # 等待 2 秒
        time.sleep(2)

        # 启动 Streamlit（会自动打开浏览器）
        try:
            subprocess.run(
                [sys.executable, "-m", "streamlit", "run", "app.py"],
                cwd=self.project_root
            )
        except KeyboardInterrupt:
            print()
            print()
            print("════════════════════════════════════════════════════════")
            print()
            print("👋 MOSS Assistant 已停止")
            print()
            print("💡 感谢使用！如需重新启动，请再次运行启动脚本")
            print()
            print("════════════════════════════════════════════════════════")
            print()

    def run(self):
        """运行启动流程"""
        self.print_header()

        # 执行检查步骤
        steps = [
            self.check_python,
            self.load_env,
            self.check_dependencies,
            self.check_core_files,
            self.check_data_dir,
            self.health_check,
        ]

        for step in steps:
            if not step():
                # 如果有严重错误，停止启动
                if self.errors:
                    print()
                    print("════════════════════════════════════════════════════════")
                    print()
                    print("❌ 启动失败！")
                    print()
                    if self.errors:
                        print("错误:")
                        for error in self.errors:
                            print(f"  • {error}")
                        print()

                    if self.warnings:
                        print("警告:")
                        for warning in self.warnings:
                            print(f"  • {warning}")
                        print()

                    print("════════════════════════════════════════════════════════")
                    print()
                    input("按回车键退出...")
                    sys.exit(1)

        # 如果有警告，显示但继续
        if self.warnings:
            print("⚠️  警告:")
            for warning in self.warnings:
                print(f"   {warning}")
            print()

        # 所有检查通过，启动 MOSS
        self.launch_moss()


def main():
    """主函数"""
    launcher = MOSSLauncher()
    launcher.run()


if __name__ == "__main__":
    main()
