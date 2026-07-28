# Uninstall

## Automatic uninstall

If you installed using the scripts, the uninstaller can fully revert your system to its previous state.

### macOS / Linux / WSL

```bash
bash uninstall.sh
```

### Windows (PowerShell 7)

```powershell
.\uninstall.ps1
```

The uninstaller reads `~/.simple-zsh-setup/manifest.json` (written during install) to know exactly:
- Which backup to restore for `~/.zshrc` and `~/.p10k.zsh` (or `$PROFILE` and `~/.omp_config.json` on Windows)
- Whether oh-my-zsh / Powerlevel10k / plugins were installed fresh or were pre-existing (pre-existing ones are left untouched)
- Whether the no-sudo zsh launch fallback was added to `~/.bashrc` or `~/.profile`

After uninstall, open a new terminal or run `source ~/.zshrc` (or `. $PROFILE` on Windows).

---

## Manual uninstall

If the manifest is missing (e.g. you deleted `~/.simple-zsh-setup/`), follow these steps manually.

### macOS / Linux / WSL

**1. Restore ~/.zshrc**

Check for timestamped backups and restore the one from before the install:

```bash
ls ~/.zshrc.bak.*
cp ~/.zshrc.bak.<timestamp> ~/.zshrc
```

**2. Restore ~/.p10k.zsh**

```bash
ls ~/.p10k.zsh.bak.*
cp ~/.p10k.zsh.bak.<timestamp> ~/.p10k.zsh
# Or remove it entirely if you didn't have one before
rm ~/.p10k.zsh
```

**3. Remove Powerlevel10k**

```bash
rm -rf "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
```

**4. Remove plugins installed by this script**

```bash
rm -rf "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
rm -rf "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
rm -rf "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-nvm"
```

**5. Remove oh-my-zsh (only if you didn't have it before)**

```bash
ZSH="$HOME/.oh-my-zsh" bash "$HOME/.oh-my-zsh/tools/uninstall.sh" --unattended
```

**6. Remove the no-sudo zsh launch fallback (if applicable)**

If you didn't have sudo during install, a block was added to `~/.bashrc` or `~/.profile`. Remove the lines between and including:

```
# simple-zsh-setup: launch zsh
...
fi
```

### Windows

**1. Restore $PROFILE**

```powershell
ls $PROFILE.bak.*
Copy-Item "$PROFILE.bak.<timestamp>" $PROFILE
```

**2. Restore ~/.omp_config.json**

```powershell
ls ~/.omp_config.json.bak.*
Copy-Item "~/.omp_config.json.bak.<timestamp>" ~/.omp_config.json
# Or remove it if you didn't have one before
Remove-Item ~/.omp_config.json
```

**3. Remove Oh My Posh (only if you didn't have it before)**

```powershell
winget uninstall --id JanDeDobbeleer.OhMyPosh
```

**4. Remove PSReadLine and Terminal-Icons (only if you didn't have them before)**

```powershell
Uninstall-Module -Name PSReadLine -Force
Uninstall-Module -Name Terminal-Icons -Force
```
