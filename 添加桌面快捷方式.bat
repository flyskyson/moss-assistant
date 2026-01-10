@echo off
chcp 65001 > nul
title 创建桌面快捷方式

cd /d "%~dp0"

echo.
echo ════════════════════════════════════════════════════════
echo.
echo     MOSS Assistant - 创建桌面快捷方式
echo.
echo ════════════════════════════════════════════════════════
echo.

REM 检查 PowerShell
powershell -Command "exit" >nul 2>&1
if errorlevel 1 (
    echo [错误] PowerShell 不可用
    pause
    exit /b 1
)

echo [信息] 正在创建桌面快捷方式...
echo.

REM 运行 PowerShell 脚本
powershell -ExecutionPolicy Bypass -File "%~dp0创建桌面快捷方式.ps1"

if errorlevel 1 (
    echo.
    echo [错误] 快捷方式创建失败
    echo.
    pause
    exit /b 1
)

echo.
exit /b 0
