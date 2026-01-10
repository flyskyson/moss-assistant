@echo off
chcp 65001 > nul
cd /d "%~dp0"

echo.
echo ========================================
echo  MOSS Assistant
echo ========================================
echo.

python --version >nul 2>&1
if errorlevel 1 (
    echo Error: Python not found
    echo Please install Python 3.8+
    pause
    exit /b 1
)

echo Starting MOSS Assistant...
echo.
echo URL: http://localhost:8501
echo.
echo Press Ctrl+C to stop
echo.
echo ========================================
echo.

python -m streamlit run app.py

pause
