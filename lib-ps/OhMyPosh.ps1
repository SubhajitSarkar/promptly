# lib-ps/OhMyPosh.ps1 - Install Oh My Posh, PSReadLine, Terminal-Icons
# and deploy the full stack omp_config.json theme

function Install-OhMyPosh {
    Write-Header "Setting up Oh My Posh"

    _Ensure-OhMyPosh
    _Ensure-PSReadLine
    _Ensure-TerminalIcons
    _Deploy-OmpTheme
}

function _Ensure-OhMyPosh {
    if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
        Write-Success "Oh My Posh already installed ($(oh-my-posh version))"
        Manifest-SetBool "omp_was_preexisting" $true
        return
    }
    Write-Info "Installing Oh My Posh..."
    winget install --id JanDeDobbeleer.OhMyPosh --source winget `
        --accept-package-agreements --accept-source-agreements
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("Path", "User")
    Manifest-SetBool "omp_was_preexisting" $false
    Write-Success "Oh My Posh installed"
}

function _Ensure-PSReadLine {
    $module = Get-Module -ListAvailable -Name PSReadLine | Sort-Object Version -Descending | Select-Object -First 1
    if ($module -and $module.Version -ge [version]"2.3.0") {
        Write-Success "PSReadLine $($module.Version) already installed"
        Manifest-SetBool "psreadline_was_preexisting" $true
        return
    }
    Write-Info "Installing PSReadLine..."
    Install-Module -Name PSReadLine -Force -SkipPublisherCheck -Scope CurrentUser
    Manifest-SetBool "psreadline_was_preexisting" $false
    Write-Success "PSReadLine installed"
}

function _Ensure-TerminalIcons {
    if (Get-Module -ListAvailable -Name Terminal-Icons) {
        Write-Success "Terminal-Icons already installed"
        Manifest-SetBool "terminalicons_was_preexisting" $true
        return
    }
    Write-Info "Installing Terminal-Icons..."
    Install-Module -Name Terminal-Icons -Repository PSGallery -Force -Scope CurrentUser
    Manifest-SetBool "terminalicons_was_preexisting" $false
    Write-Success "Terminal-Icons installed"
}

function _Deploy-OmpTheme {
    $configSrc  = Join-Path $PSScriptRoot "..\config\omp_config.json"
    $configDest = Join-Path $HOME ".omp_config.json"

    if (-not (Test-Path $configSrc)) {
        Write-Err "omp_config.json not found at: $configSrc"
        exit 1
    }

    if (Test-Path $configDest) {
        $timestamp  = Get-Date -Format "yyyyMMddHHmmss"
        $backup     = "${configDest}.bak.${timestamp}"
        Write-Warn "Existing ~/.omp_config.json found - backing up to $backup"
        Copy-Item $configDest $backup
        Manifest-Set "omp_config_backup" $backup
    }

    Copy-Item $configSrc $configDest
    Write-Success "~/.omp_config.json deployed"
}
