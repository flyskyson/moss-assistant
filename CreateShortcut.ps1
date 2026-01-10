# Create Desktop Shortcut for MOSS Assistant

$ErrorActionPreference = "Stop"

$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ScriptPath

$ShortcutName = "MOSS Assistant"
$TargetPath = Join-Path $ScriptPath "StartMOSS.bat"
$Description = "MOSS Assistant - AI Assistant"

$DesktopPath = [Environment]::GetFolderPath("Desktop")
$ShortcutPath = Join-Path $DesktopPath "$ShortcutName.lnk"

if (-not (Test-Path $TargetPath)) {
    Write-Host "Error: StartMOSS.bat not found" -ForegroundColor Red
    Write-Host "Path: $TargetPath" -ForegroundColor Yellow
    pause
    exit 1
}

$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = $TargetPath
$Shortcut.WorkingDirectory = $ScriptPath
$Shortcut.Description = $Description
$Shortcut.Save()

[System.Runtime.Interopservices.Marshal]::ReleaseComObject($Shortcut) | Out-Null
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($WScriptShell) | Out-Null

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Desktop shortcut created successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Location: $ShortcutPath" -ForegroundColor White
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
