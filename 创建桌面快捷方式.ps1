# MOSS Assistant - 创建桌面快捷方式脚本

$ErrorActionPreference = "Stop"

# 获取脚本所在目录
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ScriptPath

# 定义快捷方式信息
$ShortcutName = "MOSS Assistant"
$TargetPath = Join-Path $ScriptPath "快速启动.bat"
$Description = "MOSS Assistant - 苏格拉底式辩论伙伴 + 全能个人助理"

# 获取桌面路径
$DesktopPath = [Environment]::GetFolderPath("Desktop")
$ShortcutPath = Join-Path $DesktopPath "$ShortcutName.lnk"

# 检查目标文件是否存在
if (-not (Test-Path $TargetPath)) {
    Write-Host "❌ 错误: 找不到 $TargetPath" -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 请确保此脚本在 MOSS Assistant 项目根目录下运行" -ForegroundColor Yellow
    Write-Host ""
    pause
    exit 1
}

# 创建 WScript.Shell 对象
$WScriptShell = New-Object -ComObject WScript.Shell

# 创建快捷方式
$Shortcut = $WScriptShell.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = $TargetPath
$Shortcut.WorkingDirectory = $ScriptPath
$Shortcut.Description = $Description
$Shortcut.Save()

# 释放 COM 对象
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($Shortcut) | Out-Null
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($WScriptShell) | Out-Null

# 显示成功信息
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "✅ 桌面快捷方式创建成功！" -ForegroundColor Green
Write-Host ""
Write-Host "快捷方式位置:" -ForegroundColor Cyan
Write-Host "  $ShortcutPath" -ForegroundColor White
Write-Host ""
Write-Host "使用方法:" -ForegroundColor Cyan
Write-Host "  1. 在桌面上找到 'MOSS Assistant' 图标" -ForegroundColor White
Write-Host "  2. 双击运行即可启动 MOSS" -ForegroundColor White
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "按任意键退出..." -ForegroundColor Gray
pause | Out-Null
