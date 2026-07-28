# lib-ps/Detect.ps1 - Detect PowerShell version and Windows environment
# Sets: $script:PSMajorVersion, $script:IsWinGetAvailable, $script:IsAdmin

function Invoke-Detect {
    Write-Header "Detecting Environment"

    $script:PSMajorVersion = $PSVersionTable.PSVersion.Major

    # Check for admin privileges
    $currentPrincipal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    $script:IsAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    # Check winget availability
    $script:IsWinGetAvailable = [bool](Get-Command winget -ErrorAction SilentlyContinue)

    # Check Windows Terminal
    $script:IsWindowsTerminal = [bool]($env:WT_SESSION)

    Write-Info "PowerShell Version : $($PSVersionTable.PSVersion)"
    Write-Info "OS                 : $([System.Environment]::OSVersion.VersionString)"
    Write-Info "Running as Admin   : $($script:IsAdmin)"
    Write-Info "WinGet available   : $($script:IsWinGetAvailable)"
    Write-Info "Windows Terminal   : $($script:IsWindowsTerminal)"

    if (-not $script:IsWindowsTerminal) {
        Write-Warn "Windows Terminal not detected. Some icons may not render correctly."
        Write-Warn "Install it from: https://aka.ms/terminal"
    }
}
