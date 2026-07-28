# lib-ps/Manifest.ps1 - Records install state to ~/.simple-zsh-setup/manifest.json

$ManifestDir  = Join-Path $HOME ".simple-zsh-setup"
$ManifestFile = Join-Path $ManifestDir "manifest.json"

function Manifest-Init {
    if (-not (Test-Path $ManifestDir)) {
        New-Item -ItemType Directory -Path $ManifestDir -Force | Out-Null
    }
    $manifest = [ordered]@{
        installed_at            = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
        os_type                 = "windows"
        profile_backup          = ""
        omp_config_backup       = ""
        omp_was_preexisting     = $false
        psreadline_was_preexisting    = $false
        terminalicons_was_preexisting = $false
    }
    $manifest | ConvertTo-Json | Set-Content -Path $ManifestFile -Encoding UTF8
}

function Manifest-Set {
    param([string]$Key, [string]$Value)
    $data = Get-Content $ManifestFile -Raw | ConvertFrom-Json
    $data.$Key = $Value
    $data | ConvertTo-Json | Set-Content -Path $ManifestFile -Encoding UTF8
}

function Manifest-SetBool {
    param([string]$Key, [bool]$Value)
    $data = Get-Content $ManifestFile -Raw | ConvertFrom-Json
    $data.$Key = $Value
    $data | ConvertTo-Json | Set-Content -Path $ManifestFile -Encoding UTF8
}

function Manifest-Get {
    param([string]$Key)
    $data = Get-Content $ManifestFile -Raw | ConvertFrom-Json
    return $data.$Key
}
