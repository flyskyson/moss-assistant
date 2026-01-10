@echo off
chcp 65001 > nul
echo ================================================
echo  MOSS Assistant 启动脚本
echo ================================================
echo.

REM 设置环境变量
set "DEEPSEEK_API_KEY=sk-263512fcfa5348c1ad321d98616c3f85"

echo [信息] API Key 已设置
echo.
echo 正在启动 MOSS Assistant...
echo.
echo 请在浏览器中访问: http://localhost:8501
echo.
echo 按 Ctrl+C 停止服务
echo.
echo ================================================
echo.

REM 启动 Streamlit
python -m streamlit run app.py

pause
