@echo off
chcp 65001 > nul
cd /d "%~dp0"

echo.
echo ========================================
echo  MOSS Assistant - 启动中...
echo ========================================
echo.

REM 检查 Python
python --version >nul 2>&1
if errorlevel 1 (
    echo [错误] 未检测到 Python
    echo 请先安装 Python 3.8+
    pause
    exit /b 1
)

REM 检查并启动 Streamlit
echo [信息] 正在启动 MOSS Assistant...
echo.
echo 访问地址: http://localhost:8501
echo.
echo 按 Ctrl+C 停止服务
echo.
echo ========================================
echo.

python -m streamlit run app.py

pause
