# lib-ps/Uninstall.ps1 - Revert all changes made by install.ps1

function Invoke-Uninstall {
    $manifestFile = Join-Path $HOME ".promptly\manifest.json"

    if (-not (Test-Path $manifestFile)) {
        Write-Err "No manifest found at $manifestFile"
        Write-Err "Cannot safely uninstall without it. See docs/UNINSTALL.md for manual steps."
        exit 1
    }

    $m = Get-Content $manifestFile -Raw | ConvertFrom-Json

    # ─── Restore $PROFILE ─────────────────────────────────────────────────────
    Write-Header "Restoring `$PROFILE"
    if ($m.profile_backup -and (Test-Path $m.profile_backup)) {
        Copy-Item $m.profile_backup $PROFILE -Force
        Write-Success "Restored `$PROFILE from $($m.profile_backup)"
    } else {
        Write-Warn "No `$PROFILE backup found in manifest — removing current `$PROFILE"
        Remove-Item $PROFILE -ErrorAction SilentlyContinue
    }

    # ─── Restore ~/.omp_config.json ───────────────────────────────────────────
    Write-Header "Restoring ~/.omp_config.json"
    $ompDest = Join-Path $HOME ".omp_config.json"
    if ($m.omp_config_backup -and (Test-Path $m.omp_config_backup)) {
        Copy-Item $m.omp_config_backup $ompDest -Force
        Write-Success "Restored ~/.omp_config.json from $($m.omp_config_backup)"
    } else {
        Remove-Item $ompDest -ErrorAction SilentlyContinue
        Write-Info "No previous ~/.omp_config.json — removed"
    }

    # ─── Remove Oh My Posh (only if this script installed it) ─────────────────
    Write-Header "Removing Oh My Posh"
    if (-not $m.omp_was_preexisting -and (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
        winget uninstall --id JanDeDobbeleer.OhMyPosh --accept-source-agreements
        Write-Success "Removed Oh My Posh"
    } else {
        Write-Info "Oh My Posh was pre-existing — leaving it in place"
    }

    # ─── Remove PSReadLine (only if this script installed it) ─────────────────
    Write-Header "Removing PSReadLine"
    if (-not $m.psreadline_was_preexisting) {
        Uninstall-Module -Name PSReadLine -Force -ErrorAction SilentlyContinue
        Write-Success "Removed PSReadLine"
    } else {
        Write-Info "PSReadLine was pre-existing — leaving it in place"
    }

    # ─── Remove Terminal-Icons (only if this script installed it) ─────────────
    Write-Header "Removing Terminal-Icons"
    if (-not $m.terminalicons_was_preexisting) {
        Uninstall-Module -Name Terminal-Icons -Force -ErrorAction SilentlyContinue
        Write-Success "Removed Terminal-Icons"
    } else {
        Write-Info "Terminal-Icons was pre-existing — leaving it in place"
    }

    # ─── Remove manifest ──────────────────────────────────────────────────────
    $manifestDir = Join-Path $HOME ".promptly"
    Remove-Item $manifestDir -Recurse -Force -ErrorAction SilentlyContinue
    Write-Success "Removed manifest"
}
