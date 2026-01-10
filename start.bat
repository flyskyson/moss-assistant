@echo off
echo ================================================
echo  MOSS Assistant - 启动脚本
echo ================================================
echo.

REM 检查 Python 是否安装
python --version >nul 2>&1
if errorlevel 1 (
    echo [错误] 未检测到 Python，请先安装 Python 3.8+
    pause
    exit /b 1
)

REM 检查虚拟环境
if not exist "venv" (
    echo [信息] 创建虚拟环境...
    python -m venv venv
)

REM 激活虚拟环境
echo [信息] 激活虚拟环境...
call venv\Scripts\activate.bat

REM 安装依赖
echo [信息] 检查并安装依赖...
pip install -q -r requirements.txt

REM 检查环境变量
if not defined ANTHROPIC_API_KEY (
    echo.
    echo [警告] 未设置 ANTHROPIC_API_KEY 环境变量
    echo [提示] 请先设置 API Key：
    echo   set ANTHROPIC_API_KEY=your-key-here
    echo.
    set /p continue="是否继续启动？(Y/N): "
    if /i not "%continue%"=="Y" (
        exit /b 1
    )
)

REM 选择启动模式
echo.
echo 请选择启动模式：
echo 1. Web UI 模式 (推荐)
echo 2. 命令行模式
echo.
set /p mode="请输入选择 (1/2): "

if "%mode%"=="1" (
    echo.
    echo [信息] 启动 Web UI...
    echo [提示] 浏览器将自动打开 http://localhost:8501
    echo.
    streamlit run app.py
) else if "%mode%"=="2" (
    echo.
    echo [信息] 启动命令行模式...
    echo.
    python moss.py
) else (
    echo [错误] 无效的选择
    pause
    exit /b 1
)
