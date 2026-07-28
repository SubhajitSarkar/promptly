# lib-ps/Profile.ps1 - Idempotent $PROFILE patching

function Patch-Profile {
    Write-Header "Patching PowerShell `$PROFILE"

    _Ensure-ProfileExists
    _Backup-Profile
    _Patch-OhMyPosh
    _Patch-PSReadLine
    _Patch-TerminalIcons

    Write-Success "`$PROFILE patched at: $PROFILE"
}

function _Ensure-ProfileExists {
    if (-not (Test-Path $PROFILE)) {
        New-Item -ItemType File -Path $PROFILE -Force | Out-Null
        Write-Info "Created new `$PROFILE at $PROFILE"
    }
}

function _Backup-Profile {
    $timestamp = Get-Date -Format "yyyyMMddHHmmss"
    $backup    = "${PROFILE}.bak.${timestamp}"
    Copy-Item $PROFILE $backup
    Write-Info "Backed up `$PROFILE to $backup"
}

function _Patch-OhMyPosh {
    $marker  = "oh-my-posh init pwsh"
    $content = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue

    if ($content -match [regex]::Escape($marker)) {
        Write-Success "Oh My Posh init already in `$PROFILE"
        return
    }

    $block = @"

# Oh My Posh - full stack prompt
`$env:POSH_GIT_ENABLED = `$true
oh-my-posh init pwsh --config "`$HOME\.omp_config.json" | Invoke-Expression
"@
    Add-Content -Path $PROFILE -Value $block
    Write-Info "Added Oh My Posh init block"
}

function _Patch-PSReadLine {
    $marker  = "PSReadLine"
    $content = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue

    if ($content -match $marker) {
        Write-Success "PSReadLine config already in `$PROFILE"
        return
    }

    $block = @"

# PSReadLine - syntax highlighting + autosuggestions
Import-Module PSReadLine
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Windows
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key UpArrow   -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
"@
    Add-Content -Path $PROFILE -Value $block
    Write-Info "Added PSReadLine config block"
}

function _Patch-TerminalIcons {
    $marker  = "Terminal-Icons"
    $content = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue

    if ($content -match $marker) {
        Write-Success "Terminal-Icons already in `$PROFILE"
        return
    }

    Add-Content -Path $PROFILE -Value "`n# File icons in terminal`nImport-Module Terminal-Icons"
    Write-Info "Added Terminal-Icons import"
}
