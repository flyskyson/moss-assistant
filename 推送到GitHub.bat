@echo off
chcp 65001 > nul
title 推送到 GitHub

echo.
echo ============================================================
echo  MOSS Assistant - 推送到 GitHub
echo ============================================================
echo.

echo 步骤 1: 请先在 GitHub 上创建仓库
echo.
echo 1. 访问: https://github.com/new
echo 2. 仓库名称: moss-assistant
echo 3. 不要初始化 README
echo 4. 点击创建
echo.
echo 创建后，复制仓库 URL，格式类似:
echo https://github.com/你的用户名/moss-assistant.git
echo.
echo ============================================================
echo.

pause

echo.
echo 请输入 GitHub 仓库 URL:
echo.
set /p REPO_URL="仓库 URL: "

echo.
echo 添加远程仓库...
git remote add origin %REPO_URL%

echo.
echo 推送到 GitHub...
echo.

git branch -M master
git push -u origin master

echo.
echo ============================================================
echo  推送完成！
echo ============================================================
echo.
echo 你的代码已备份到: %REPO_URL%
echo.
pause
