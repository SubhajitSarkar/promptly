# uninstall.ps1 - Revert all changes made by install.ps1
# Reads ~/.promptly/manifest.json to know exactly what to undo

#Requires -Version 5.1

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

if (-not $IsWindows -and $PSVersionTable.PSVersion.Major -ge 6) {
    Write-Host "[ERROR] This script is for Windows only." -ForegroundColor Red
    Write-Host "        For macOS/Linux/WSL, run: bash uninstall.sh" -ForegroundColor Yellow
    exit 1
}

. "$ScriptDir\lib-ps\Logger.ps1"
. "$ScriptDir\lib-ps\Manifest.ps1"
. "$ScriptDir\lib-ps\Uninstall.ps1"

Clear-Host
Write-Host ""
Write-Host "  +==================================================+" -ForegroundColor Cyan
Write-Host "  |   promptly Uninstaller (Windows)                  |" -ForegroundColor Cyan
Write-Host "  |   Reverting to your previous state               |" -ForegroundColor Cyan
Write-Host "+==================================================+" -ForegroundColor Cyan
Write-Host ""

Invoke-Uninstall

Write-Host ""
Write-Divider
Write-Success "Uninstall complete - your previous state has been restored."
Write-Divider
Write-Host ""
Write-Host "  Restart your terminal to apply changes."
Write-Host ""
