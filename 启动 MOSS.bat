@echo off
chcp 65001 > nul
title MOSS Assistant

REM ============================================================
REM MOSS Assistant - 快速启动
REM ============================================================

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

python launcher.py

if errorlevel 1 (
    echo.
    echo ❌ 启动失败
    echo.
    pause
)
