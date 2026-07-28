# lib-ps/Picker.ps1 - Interactive spacebar checklist for segment selection

$script:SegmentDefs = @(
  # Languages
  @{ Key="node";           Label="Node / NVM";          Desc="Node.js version in JS/TS projects";                    Default=$true  }
  @{ Key="python";         Label="Python / Virtualenv"; Desc="Python version and active venv";                       Default=$true  }
  @{ Key="go";             Label="Go";                  Desc="Go version in projects with go.mod";                   Default=$true  }
  @{ Key="rust";           Label="Rust";                Desc="Rust version in projects with Cargo.toml";             Default=$true  }
  @{ Key="ruby";           Label="Ruby";                Desc="Ruby version in projects with Gemfile";                Default=$false }
  @{ Key="java";           Label="Java";                Desc="Java version in projects with pom.xml / build.gradle"; Default=$false }
  @{ Key="php";            Label="PHP";                 Desc="PHP version in projects with composer.json";           Default=$false }
  @{ Key="dotnet";         Label=".NET";                Desc=".NET SDK version in projects with *.csproj / *.sln";   Default=$false }
  @{ Key="swift";          Label="Swift";               Desc="Swift version in projects with Package.swift";         Default=$false }
  # Cloud & DevOps
  @{ Key="aws";            Label="AWS";                 Desc="Current AWS profile and region";                      Default=$false }
  @{ Key="azure";          Label="Azure";               Desc="Current Azure subscription";                          Default=$false }
  @{ Key="gcp";            Label="GCP";                 Desc="Current Google Cloud project";                        Default=$false }
  @{ Key="docker";         Label="Docker";              Desc="Current Docker context";                              Default=$false }
  @{ Key="terraform";      Label="Terraform";           Desc="Current Terraform workspace";                         Default=$false }
  @{ Key="kubectl";        Label="Kubectl";             Desc="Current Kubernetes context and namespace";            Default=$false }
  # System
  @{ Key="execution_time"; Label="Execution Time";      Desc="How long the last command took (>3s)";                Default=$true  }
  @{ Key="time";           Label="Clock";               Desc="Current time on the right side";                     Default=$true  }
  @{ Key="battery";        Label="Battery";             Desc="Battery level when below 30% or charging";           Default=$false }
  @{ Key="disk_usage";     Label="Disk Usage";          Desc="Disk usage, warns above 90%";                        Default=$false }
)

function Invoke-SegmentPicker {
    if ($env:PROMPTLY_SKIP_PICKER -eq "1") {
        $script:SelectedSegments = @($script:SegmentDefs | Where-Object { $_.Default } | ForEach-Object { $_.Key })
        Write-Info "Picker skipped — using defaults: $($script:SelectedSegments -join ', ')"
        return
    }

    $defs    = $script:SegmentDefs
    $count   = $defs.Count
    $cursor  = 0
    $selected = $defs | ForEach-Object { $_.Default }

    $draw = {
        [Console]::SetCursorPosition(0, 0)
        Write-Host ""
        Write-Host "  Select prompt segments (Up/Down move, Space toggle, Enter confirm)" -ForegroundColor Cyan
        Write-Host "  ────────────────────────────────────────────────" -ForegroundColor Cyan
        for ($i = 0; $i -lt $count; $i++) {
            $box    = if ($selected[$i]) { "[x]" } else { "[ ]" }
            $prefix = if ($i -eq $cursor) { "  > " } else { "    " }
            $color  = if ($i -eq $cursor) { "White" } else { "Gray" }
            Write-Host "$prefix$box $($defs[$i].Label)  " -ForegroundColor $color -NoNewline
            Write-Host $defs[$i].Desc -ForegroundColor Yellow
        }
        Write-Host "  ────────────────────────────────────────────────" -ForegroundColor Cyan
    }

    [Console]::CursorVisible = $false
    if ($Host.UI.RawUI.WindowSize.Width -gt 0) { Clear-Host }
    & $draw

    while ($true) {
        $k = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        switch ($k.VirtualKeyCode) {
            38 { if ($cursor -gt 0)          { $cursor-- } }   # Up
            40 { if ($cursor -lt $count - 1) { $cursor++ } }   # Down
            32 { $selected[$cursor] = -not $selected[$cursor] } # Space
            13 { [Console]::CursorVisible = $true; break }      # Enter
        }
        if ($k.VirtualKeyCode -eq 13) { break }
        & $draw
    }

    $script:SelectedSegments = @()
    for ($i = 0; $i -lt $count; $i++) {
        if ($selected[$i]) { $script:SelectedSegments += $defs[$i].Key }
    }

    Write-Info "Selected segments: $($script:SelectedSegments -join ', ')"
}

function Invoke-DetectIconMode {
    if ($env:PROMPTLY_ICON_MODE -in @("nerd","emoji","unicode","ascii")) {
        $script:IconMode = $env:PROMPTLY_ICON_MODE
        Write-Info "Icon mode preset: $($script:IconMode)"
        return
    }

    Write-Host ""
    Write-Host "  Do you have a Nerd Font installed in your terminal?" -ForegroundColor White
    Write-Host "  (e.g. MesloLGS NF - see docs/FONT_SETUP.md)" -ForegroundColor Yellow
    Write-Host ""
    $answer = Read-Host "  Nerd Font installed? [y/n]"
    if ($answer -match '^[Yy]') {
        $script:IconMode = "nerd"
        Write-Info "Using Nerd Font icons"
        Write-Host ""
        return
    }

    Write-Host ""
    Write-Host "  Can you see these emoji clearly? 👉 🚀 🐍 ☁" -ForegroundColor White
    Write-Host "  (If they show as boxes or question marks, answer n)" -ForegroundColor Yellow
    Write-Host ""
    $answer = Read-Host "  Emoji visible? [y/n]"
    if ($answer -match '^[Yy]') {
        $script:IconMode = "emoji"
        Write-Info "Using emoji icons"
        Write-Host ""
        return
    }

    Write-Host ""
    Write-Host "  Can you see these symbols clearly? 👉 ⬡ ☸ ⚙ ○" -ForegroundColor White
    Write-Host "  (Basic Unicode - works on most modern terminals)" -ForegroundColor Yellow
    Write-Host ""
    $answer = Read-Host "  Symbols visible? [y/n]"
    if ($answer -match '^[Yy]') {
        $script:IconMode = "unicode"
        Write-Info "Using Unicode symbols"
        Write-Host ""
        return
    }

    $script:IconMode = "ascii"
    Write-Info "Using ASCII fallback icons"
    Write-Host ""
}
