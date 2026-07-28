# lib-ps/Deps.ps1 - Install core dependencies via winget

function Install-Deps {
    Write-Header "Checking Dependencies"

    _Ensure-PS7
    _Ensure-WinGet
    _Ensure-Git
    _Ensure-Font
}

function _Ensure-PS7 {
    if ($script:PSMajorVersion -ge 7) {
        Write-Success "PowerShell 7+ detected (v$($PSVersionTable.PSVersion))"
        return
    }
    Write-Warn "PowerShell 5 detected. PowerShell 7 is required for best experience."
    Write-Info "Installing PowerShell 7 via winget..."
    winget install --id Microsoft.PowerShell --source winget --accept-package-agreements --accept-source-agreements
    Write-Success "PowerShell 7 installed. Please re-run this script in a new pwsh terminal."
    exit 0
}

function _Ensure-WinGet {
    if ($script:IsWinGetAvailable) {
        Write-Success "winget is available"
        return
    }
    Write-Warn "winget not found. Installing App Installer from Microsoft Store..."
    Start-Process "ms-windows-store://pdp/?ProductId=9NBLGGH4NNS1"
    Write-Err "Please install 'App Installer' from the Store, then re-run this script."
    exit 1
}

function _Ensure-Git {
    if (Get-Command git -ErrorAction SilentlyContinue) {
        Write-Success "git already installed ($(git --version))"
        return
    }
    Write-Info "Installing Git..."
    winget install --id Git.Git --source winget --accept-package-agreements --accept-source-agreements
    Write-Success "Git installed"
}

function _Ensure-Font {
    # Check if MesloLGS NF is already installed
    $fonts = [System.Drawing.Text.InstalledFontCollection]::new().Families.Name
    if ($fonts -contains "MesloLGS NF") {
        Write-Success "MesloLGS NF font already installed"
        return
    }
    Write-Info "Installing MesloLGS NF Nerd Font via winget..."
    winget install --id DEVCOM.JetBrainsMonoNerdFont --source winget `
        --accept-package-agreements --accept-source-agreements -e 2>$null

    # Fallback: open download page if winget font install fails
    if ($LASTEXITCODE -ne 0) {
        Write-Warn "Automatic font install failed. Opening download page..."
        Start-Process "https://github.com/romkatv/powerlevel10k#meslo-nerd-font-patched-for-powerlevel10k"
        Write-Warn "Install all 4 MesloLGS NF variants, then set your terminal font."
    } else {
        Write-Success "Nerd Font installed"
    }
}
