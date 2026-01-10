@echo off
echo ================================================
echo  MOSS Assistant - 启动脚本 (DeepSeek 版)
echo ================================================
echo.

REM 检查 Python
python --version >nul 2>&1
if errorlevel 1 (
    echo [错误] 未检测到 Python，请先安装 Python 3.8+
    pause
    exit /b 1
)

REM 设置环境变量
echo [信息] 加载环境变量...
for /f "tokens=1,2 delims==" %%a in (.env) do (
    if not "%%a"=="" if not "%%a:~0,1%"=="#" (
        set %%a=%%b
    )
)

echo [信息] API Key 已加载
echo.

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

REM 检查是否需要安装 openai 库
pip show openai >nul 2>&1
if errorlevel 1 (
    echo [信息] 安装 openai 库（DeepSeek 需要）...
    pip install openai
)

echo.
echo ================================================
echo  启动 MOSS Assistant
echo ================================================
echo.

REM 启动 Web UI
echo [提示] 浏览器将自动打开 http://localhost:8501
echo [提示] 按 Ctrl+C 停止服务
echo.
streamlit run app.py

pause
