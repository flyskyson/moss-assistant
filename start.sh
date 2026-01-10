#!/bin/bash

echo "================================================"
echo " MOSS Assistant - 启动脚本"
echo "================================================"
echo ""

# 检查 Python
if ! command -v python3 &> /dev/null; then
    echo "[错误] 未检测到 Python3，请先安装 Python 3.8+"
    exit 1
fi

# 检查虚拟环境
if [ ! -d "venv" ]; then
    echo "[信息] 创建虚拟环境..."
    python3 -m venv venv
fi

# 激活虚拟环境
echo "[信息] 激活虚拟环境..."
source venv/bin/activate

# 安装依赖
echo "[信息] 检查并安装依赖..."
pip install -q -r requirements.txt

# 检查环境变量
if [ -z "$ANTHROPIC_API_KEY" ]; then
    echo ""
    echo "[警告] 未设置 ANTHROPIC_API_KEY 环境变量"
    echo "[提示] 请先设置 API Key："
    echo "  export ANTHROPIC_API_KEY=your-key-here"
    echo ""
    read -p "是否继续启动？(y/n): " continue
    if [ "$continue" != "y" ]; then
        exit 1
    fi
fi

# 选择启动模式
echo ""
echo "请选择启动模式："
echo "1. Web UI 模式 (推荐)"
echo "2. 命令行模式"
echo ""
read -p "请输入选择 (1/2): " mode

if [ "$mode" == "1" ]; then
    echo ""
    echo "[信息] 启动 Web UI..."
    echo "[提示] 浏览器将自动打开 http://localhost:8501"
    echo ""
    streamlit run app.py
elif [ "$mode" == "2" ]; then
    echo ""
    echo "[信息] 启动命令行模式..."
    echo ""
    python moss.py
else
    echo "[错误] 无效的选择"
    exit 1
fi
