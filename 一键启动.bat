@echo off
chcp 65001 > nul
title MOSS Assistant - 一键启动

REM ============================================================
REM MOSS Assistant - 一键启动脚本
REM ============================================================
REM 功能：
REM   1. 智能环境检测
REM   2. 自动加载环境变量
REM   3. 检查并安装依赖
REM   4. 健康检查
REM   5. 启动服务并自动打开浏览器
REM ============================================================

echo.
echo ╔════════════════════════════════════════════════════════╗
echo ║     🤖 MOSS Assistant - 一键启动 v2.0                ║
echo ║     苏格拉底式辩论伙伴 + 全能个人助理                 ║
echo ╚════════════════════════════════════════════════════════╝
echo.

REM ========================================
REM 步骤 1: 环境检测
REM ========================================
echo [1/6] 检测运行环境...
echo.

REM 检查 Python
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ 错误: 未检测到 Python
    echo 💡 请先安装 Python 3.8 或更高版本
    echo    下载地址: https://www.python.org/downloads/
    echo.
    pause
    exit /b 1
)

for /f "tokens=2" %%i in ('python --version 2^>^&1') do set PYTHON_VERSION=%%i
echo ✅ Python 版本: %PYTHON_VERSION%
echo.

REM 检查 pip
python -m pip --version >nul 2>&1
if errorlevel 1 (
    echo ❌ 错误: pip 未安装
    echo 💡 请尝试重新安装 Python
    echo.
    pause
    exit /b 1
)

echo ✅ pip 已就绪
echo.

REM ========================================
REM 步骤 2: 加载环境变量
REM ========================================
echo [2/6] 加载环境变量...
echo.

REM 检查 .env 文件
if exist ".env" (
    echo ✅ 发现 .env 文件
    REM 读取 .env 文件中的 DEEPSEEK_API_KEY
    for /f "tokens=1,2 delims==" %%a in ('type .env ^| findstr /b "DEEPSEEK_API_KEY"') do (
        set %%a=%%b
    )
    if defined DEEPSEEK_API_KEY (
        echo ✅ DeepSeek API Key: %DEEPSEEK_API_KEY:~0,10%...
    ) else (
        echo ⚠️  警告: .env 文件中未找到 DEEPSEEK_API_KEY
    )
) else (
    echo ⚠️  警告: .env 文件不存在
    echo 💡 提示: 如果 API Key 未设置，MOSS 将使用模拟响应模式
)

echo.

REM ========================================
REM 步骤 3: 检查并安装依赖
REM ========================================
echo [3/6] 检查项目依赖...
echo.

REM 检查 requirements.txt
if not exist "requirements.txt" (
    echo ❌ 错误: requirements.txt 文件不存在
    echo 💡 请确保在 MOSS Assistant 项目根目录下运行此脚本
    echo.
    pause
    exit /b 1
)

REM 检查关键依赖
python -c "import streamlit" >nul 2>&1
if errorlevel 1 (
    echo 📦 安装项目依赖...
    echo.
    python -m pip install -r requirements.txt
    if errorlevel 1 (
        echo ❌ 错误: 依赖安装失败
        echo 💡 请检查网络连接或手动运行: pip install -r requirements.txt
        echo.
        pause
        exit /b 1
    )
    echo.
    echo ✅ 依赖安装完成
) else (
    echo ✅ 核心依赖已安装
)

echo.

REM ========================================
REM 步骤 4: 检查核心文件
REM ========================================
echo [4/6] 检查核心文件...
echo.

set MISSING_FILES=0

if not exist "moss.py" (
    echo ❌ 缺少核心文件: moss.py
    set /a MISSING_FILES+=1
)

if not exist "app.py" (
    echo ❌ 缺少核心文件: app.py
    set /a MISSING_FILES+=1
)

if not exist "config.yaml" (
    echo ❌ 缺少配置文件: config.yaml
    set /a MISSING_FILES+=1
)

if not exist "core" (
    echo ❌ 缺少核心目录: core/
    set /a MISSING_FILES+=1
)

if %MISSING_FILES% GTR 0 (
    echo.
    echo ❌ 错误: 项目文件不完整，缺少 %MISSING_FILES% 个文件/目录
    echo 💡 请重新克隆项目或检查文件完整性
    echo.
    pause
    exit /b 1
)

echo ✅ 核心文件检查通过
echo.

REM ========================================
REM 步骤 5: 数据目录检查
REM ========================================
echo [5/6] 检查数据目录...
echo.

if not exist "data" (
    echo 📁 创建数据目录...
    mkdir data
    echo ✅ data/ 目录已创建
) else (
    echo ✅ data/ 目录存在
)

if not exist "data\logs" (
    mkdir data\logs
)

echo ✅ 数据目录就绪
echo.

REM ========================================
REM 步骤 6: 启动服务
REM ========================================
echo [6/6] 启动 MOSS Assistant...
echo.
echo ════════════════════════════════════════════════════════
echo.
echo 🌐 访问地址: http://localhost:8501
echo 📱 移动端: http://localhost:8501
echo.
echo 💡 提示:
echo    - 浏览器将自动打开（如果没有，请手动访问上面的地址）
echo    - 按 Ctrl+C 停止服务
echo    - 关闭此窗口也会停止服务
echo.
echo ════════════════════════════════════════════════════════
echo.

REM 等待 2 秒
timeout /t 2 /nobreak >nul

REM 启动 Streamlit（会自动打开浏览器）
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
