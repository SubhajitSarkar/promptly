# lib-ps/Logger.ps1 - Colored output helpers for PowerShell

function Write-Info    { param([string]$Message) Write-Host "[INFO]  $Message" -ForegroundColor Cyan }
function Write-Success { param([string]$Message) Write-Host "[OK]    $Message" -ForegroundColor Green }
function Write-Warn    { param([string]$Message) Write-Host "[WARN]  $Message" -ForegroundColor Yellow }
function Write-Err     { param([string]$Message) Write-Host "[ERROR] $Message" -ForegroundColor Red }
function Write-Header  { param([string]$Message) Write-Host "`n==> $Message" -ForegroundColor Cyan }
function Write-Divider { Write-Host "────────────────────────────────────────" -ForegroundColor Cyan }
