"""
MOSS Assistant 启动器
自动加载环境变量并启动 Streamlit
"""

import os
import sys
import subprocess
from pathlib import Path

# 设置输出编码为 UTF-8
if sys.platform == "win32":
    import codecs
    sys.stdout = codecs.getwriter("utf-8")(sys.stdout.buffer, 'strict')
    sys.stderr = codecs.getwriter("utf-8")(sys.stderr.buffer, 'strict')


def load_env(env_file=".env"):
    """加载 .env 文件"""
    if not Path(env_file).exists():
        print(f"⚠️  警告: {env_file} 文件不存在")
        return

    with open(env_file, 'r', encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith('#') and '=' in line:
                key, value = line.split('=', 1)
                os.environ[key.strip()] = value.strip()
                print(f"✓ 已加载: {key}")


def main():
    print("=" * 60)
    print("MOSS Assistant - 启动器")
    print("=" * 60)
    print()

    # 加载环境变量
    print("[1/3] 加载环境变量...")
    load_env()

    # 检查 API Key
    api_key = os.getenv("DEEPSEEK_API_KEY")
    if api_key:
        print(f"✓ DeepSeek API Key: {api_key[:10]}...")
    else:
        print("⚠️  警告: 未找到 DEEPSEEK_API_KEY")

    print()

    # 启动 Streamlit
    print("[2/3] 启动 Streamlit...")
    print("[3/3] 打开浏览器...")
    print()
    print("=" * 60)
    print("MOSS Assistant 已启动！")
    print("=" * 60)
    print()
    print("🌐 访问地址: http://localhost:8501")
    print("⏹️  停止服务: 按 Ctrl+C")
    print()
    print("-" * 60)
    print()

    try:
        subprocess.run([
            sys.executable, "-m", "streamlit", "run", "app.py"
        ])
    except KeyboardInterrupt:
        print("\n\n👋 MOSS Assistant 已停止")


if __name__ == "__main__":
    main()
