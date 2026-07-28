# promptly — Test Suite

## What is tested

| Suite | What it covers |
|---|---|
| `test_assembly` | Segment assembler unit tests — no network, no install needed |
| `test_install` | Full install assertions — files, dirs, config content, no leftover placeholders |
| `test_manifest` | manifest.json validity, field types, allowed values |
| `test_idempotency` | Second run exits 0, no duplicate lines in ~/.zshrc, backup created |
| `test_uninstall` | Uninstall cleans up configs, removes manifest, creates backups |

## Run all tests (all distros, in parallel)

```bash
docker compose -f docker-compose.test.yml up --build
```

## Run a single distro

```bash
# Ubuntu only
docker compose -f docker-compose.test.yml up --build ubuntu

# Fedora only
docker compose -f docker-compose.test.yml up --build fedora

# Arch only
docker compose -f docker-compose.test.yml up --build arch
```

## Run assembly unit tests locally (no Docker needed)

The assembly tests have no network dependency and run directly on your machine:

```bash
bash tests/test_assembly.sh
```

## Clean up containers and images after testing

```bash
docker compose -f docker-compose.test.yml down --rmi all
```

---

## Testing on Windows

The PowerShell path (`install.ps1`) cannot run inside a Linux Docker container.
Here are your options, from easiest to most automated:

### Option 1 — Run manually in a Windows VM or machine (quickest)

1. Open PowerShell 7
2. Clone the repo and run:
   ```powershell
   git clone git@github.com:SubhajitSarkar/promptly.git
   cd promptly
   .\\install.ps1
   ```
3. Verify manually:
   - `~/.omp_config.json` exists
   - `$PROFILE` contains `oh-my-posh init` line
   - `~/.promptly/manifest.json` exists and is valid JSON

### Option 2 — Windows Docker container (requires Docker Desktop on Windows)

Windows containers are only available when Docker Desktop is running in
**Windows container mode** (not Linux container mode).

Switch to Windows containers in Docker Desktop, then:

```powershell
docker build -f tests/Dockerfile.windows -t promptly-test-windows .
docker run --rm promptly-test-windows
```

> Note: Windows container images are large (~5 GB) and slow to pull.
> Only worth setting up if you need this in CI.

### Option 3 — GitHub Actions (recommended for CI)

Add a Windows runner job to your workflow:

```yaml
# .github/workflows/test.yml
jobs:
  test-windows:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install PowerShell 7
        shell: pwsh
        run: |
          .\\install.ps1
      - name: Verify outputs
        shell: pwsh
        run: |
          if (-not (Test-Path "$HOME\\.omp_config.json")) { exit 1 }
          if (-not (Test-Path "$HOME\\.promptly\\manifest.json")) { exit 1 }
          $json = Get-Content "$HOME\\.promptly\\manifest.json" | ConvertFrom-Json
          if ($json.os_type -ne "windows") { exit 1 }
          Write-Host "All checks passed"
```

GitHub Actions `windows-latest` runners have PowerShell 7, winget, and
internet access — it is the closest thing to a real Windows machine in CI.

---

## What cannot be tested automatically (on any platform)

| What | Why |
|---|---|
| Prompt renders correctly | Needs a real terminal with font rendering |
| Interactive picker UI | Needs keyboard input |
| Nerd Font icons display | Needs a GUI terminal |
| `p10k configure` wizard | Interactive only |
