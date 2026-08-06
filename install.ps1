# install.ps1 - Entry point for Oh My Posh full stack setup on Windows
# Supports: Windows PowerShell 7+ (native)
# For macOS/Linux/WSL: use install.sh instead
#
# Usage:
#   .\install.ps1
#   Or remote: irm <raw-url>/install.ps1 | iex

#Requires -Version 5.1

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# ─── Guard: must be Windows ───────────────────────────────────────────────────
# $IsWindows only exists in PS6+; on PS5 we are always on Windows
$_isWindows = if ($PSVersionTable.PSVersion.Major -ge 6) { $IsWindows } else { $true }
if (-not $_isWindows) {
    Write-Host "[ERROR] This script is for Windows only." -ForegroundColor Red
    Write-Host "        For macOS/Linux/WSL, run: bash install.sh" -ForegroundColor Yellow
    exit 1
}

# ─── Load modules ─────────────────────────────────────────────────────────────
. "$ScriptDir\lib-ps\Logger.ps1"
. "$ScriptDir\lib-ps\Detect.ps1"
. "$ScriptDir\lib-ps\Deps.ps1"
. "$ScriptDir\lib-ps\OhMyPosh.ps1"
. "$ScriptDir\lib-ps\Profile.ps1"
. "$ScriptDir\lib-ps\Manifest.ps1"
. "$ScriptDir\lib-ps\Picker.ps1"

# ─── Banner ───────────────────────────────────────────────────────────────────
Clear-Console
Write-Host ""
Write-Host "  +==================================================+" -ForegroundColor Cyan
Write-Host "  |   🚀 Oh My Posh Full Stack Setup (Windows)       |" -ForegroundColor Cyan
Write-Host "  |   Node, Python, Go, Rust, TS/JS                  |" -ForegroundColor Cyan
Write-Host "  +==================================================+" -ForegroundColor Cyan
Write-Host ""

# ─── Execution Policy check ───────────────────────────────────────────────────
$policy = Get-ExecutionPolicy -Scope CurrentUser
if ($policy -eq "Restricted" -or $policy -eq "AllSigned") {
    Write-Warn "Execution policy is '$policy'. Updating to RemoteSigned for CurrentUser..."
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Write-Success "Execution policy updated"
}

# ─── Run setup steps ──────────────────────────────────────────────────────────
Invoke-Detect
Manifest-Init
Invoke-DetectIconMode
Invoke-SegmentPicker
Manifest-Set "selected_segments" ($script:SelectedSegments -join ' ')
Manifest-Set "icon_mode" $script:IconMode
Install-Deps
Install-OhMyPosh
Patch-Profile

# ─── Done ─────────────────────────────────────────────────────────────────────
Write-Host ""
Write-Divider
Write-Success "Setup complete!"
Write-Divider
Write-Host ""
Write-Host "  Next steps:" -ForegroundColor White
Write-Host "  1. Install the font - see " -NoNewline; Write-Host "docs/FONT_SETUP.md" -ForegroundColor Cyan
Write-Host "  2. Restart your terminal or run: " -NoNewline; Write-Host ". `$PROFILE" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Tip: Run " -NoNewline; Write-Host ".\uninstall.ps1" -ForegroundColor Cyan -NoNewline
Write-Host " to revert all changes"
Write-Host ""
