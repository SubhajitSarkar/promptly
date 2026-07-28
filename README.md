# simple-zsh-setup

Automated terminal prompt setup for full stack developers.

| Platform                      | Script            | Prompt              |
| ----------------------------- | ----------------- | ------------------- |
| macOS                         | `bash install.sh` | Powerlevel10k (zsh) |
| Linux (apt/dnf/pacman/zypper) | `bash install.sh` | Powerlevel10k (zsh) |
| WSL2                          | `bash install.sh` | Powerlevel10k (zsh) |
| Windows (PowerShell 7+)       | `.\install.ps1`   | Oh My Posh          |

## What it installs

### macOS / Linux / WSL (`install.sh`)

- zsh (if not present)
- oh-my-zsh
- Plugins: `zsh-autosuggestions`, `zsh-syntax-highlighting`, `zsh-nvm`, `z`, `npm`
- Powerlevel10k theme
- Full stack `~/.p10k.zsh` config

### Windows (`install.ps1`)

- PowerShell 7 (if on PS5)
- Oh My Posh
- PSReadLine (syntax highlighting + autosuggestions)
- Terminal-Icons (file icons)
- Full stack `~/.omp_config.json` theme

## Usage

### macOS / Linux / WSL

```bash
git clone git@github.com:SubhajitSarkar/simple-zsh-setup.git
cd simple-zsh-setup
chmod +x install.sh
./install.sh
```

### Windows (PowerShell 7)

```powershell
git clone git@github.com:SubhajitSarkar/simple-zsh-setup.git
cd simple-zsh-setup
.\install.ps1
```

## After install

1. **Install the font** - see [docs/FONT_SETUP.md](docs/FONT_SETUP.md) _(the script does not do this automatically)_
2. macOS/Linux: `source ~/.zshrc` or open a new terminal
3. Windows: `. $PROFILE` or open a new terminal

## Reconfigure Prompt

Run the interactive wizard anytime to reconfigure your prompt:

```bash
p10k configure
```

This re-runs the full setup wizard - style, icons, segments, colors - and overwrites `~/.p10k.zsh`.

## Font Setup

The script does **not** install the font automatically. See **[docs/FONT_SETUP.md](docs/FONT_SETUP.md)** for download links and setup instructions for all terminals and IDEs.

## Prompt segments (right side)

| Segment                 | Shows when                              |
| ----------------------- | --------------------------------------- |
| `node` / `nvm`          | Inside a JS/TS project                  |
| `python` / `virtualenv` | Python version active or venv activated |
| `go`                    | Inside a Go project (`go.mod`)          |
| `rust`                  | Inside a Rust project (`Cargo.toml`)    |
| `execution time`        | Command took > 3 seconds                |
| `git`                   | Inside any git repository               |

## Structure

```
simple-zsh-setup/
├── install.sh          # Entry point - macOS / Linux / WSL
├── install.ps1         # Entry point - Windows PowerShell
├── lib/                # Bash modules
│   ├── logger.sh
│   ├── detect.sh
│   ├── deps.sh
│   ├── omz.sh
│   ├── p10k.sh
│   └── zshrc.sh
├── lib-ps/             # PowerShell modules
│   ├── Logger.ps1
│   ├── Detect.ps1
│   ├── Deps.ps1
│   ├── OhMyPosh.ps1
│   └── Profile.ps1
└── config/
    ├── p10k.zsh        # Powerlevel10k config (zsh)
    └── omp_config.json # Oh My Posh config (PowerShell)
```

## Re-run safety

Both scripts are fully idempotent - safe to re-run. They will:

- Skip already-installed components
- Back up existing configs with timestamps before modifying

## Rollback

Backups are created automatically:

```bash
# zsh
~/.zshrc.bak.<timestamp>
~/.p10k.zsh.bak.<timestamp>

# PowerShell
$PROFILE.bak.<timestamp>
~/.omp_config.json.bak.<timestamp>
```
