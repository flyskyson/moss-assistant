@echo off
chcp 65001 > nul
title MOSS Assistant

REM 切换到脚本所在目录
cd /d "%~dp0"

REM 清屏
cls

echo.
echo ════════════════════════════════════════════════════════
echo.
echo          🤖 MOSS Assistant
echo.
echo ════════════════════════════════════════════════════════
echo.
echo 正在启动...
echo.

REM 检查 Python 是否安装
python --version >nul 2>&1
if errorlevel 1 (
    echo.
    echo ❌ 错误: 未检测到 Python
    echo 💡 请先安装 Python 3.8 或更高版本
    echo    下载: https://www.python.org/downloads/
    echo.
    pause
    exit /b 1
)

REM 显示 Python 版本
for /f "tokens=2" %%i in ('python --version 2^>^&1') do set PY_VERSION=%%i
echo ✅ Python 版本: %PY_VERSION%
echo.

REM 检查核心文件
if not exist "app.py" (
    echo ❌ 错误: 找不到 app.py
    echo 💡 请确保在 MOSS Assistant 项目根目录下运行
    echo.
    pause
    exit /b 1
)

if not exist "moss.py" (
    echo ❌ 错误: 找不到 moss.py
    echo 💡 请确保在 MOSS Assistant 项目根目录下运行
    echo.
    pause
    exit /b 1
)

echo ✅ 核心文件检查通过
echo.

REM 启动信息
echo ════════════════════════════════════════════════════════
echo.
echo 🌐 访问地址: http://localhost:8501
echo.
echo 💡 提示:
echo    - 浏览器将自动打开
echo    - 按 Ctrl+C 停止服务
echo    - 关闭此窗口也会停止服务
echo.
echo ════════════════════════════════════════════════════════
echo.

REM 等待 2 秒
timeout /t 2 /nobreak >nul

REM 启动 Streamlit
python -m streamlit run app.py

REM 如果 Streamlit 退出
echo.
echo ════════════════════════════════════════════════════════
echo.
echo 👋 MOSS Assistant 已停止
echo.
echo 💡 感谢使用！如需重新启动，请双击此脚本
echo.
echo ════════════════════════════════════════════════════════
echo.
pause
