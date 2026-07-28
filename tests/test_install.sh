#!/usr/bin/env bash
# tests/test_install.sh - Assert install.sh produces expected files and config
# Run inside a Docker container after install.sh has completed.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

MANIFEST="$HOME/.promptly/manifest.json"

# ─── Oh My Zsh ────────────────────────────────────────────────────────────────
section "Oh My Zsh"
assert_dir_exists  "~/.oh-my-zsh installed"                "$HOME/.oh-my-zsh"
assert_dir_exists  "zsh-autosuggestions plugin installed"   "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
assert_dir_exists  "zsh-syntax-highlighting plugin installed" "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
assert_dir_exists  "zsh-nvm plugin installed"              "$HOME/.oh-my-zsh/custom/plugins/zsh-nvm"

# ─── Powerlevel10k ────────────────────────────────────────────────────────────
section "Powerlevel10k"
assert_dir_exists  "p10k theme cloned"  "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
assert_file_exists "~/.p10k.zsh assembled" "$HOME/.p10k.zsh"

# ─── ~/.p10k.zsh content ──────────────────────────────────────────────────────
section "~/.p10k.zsh content"
assert_file_contains "POWERLEVEL9K_MODE set"            "$HOME/.p10k.zsh" "POWERLEVEL9K_MODE="
assert_file_contains "left prompt elements present"     "$HOME/.p10k.zsh" "POWERLEVEL9K_LEFT_PROMPT_ELEMENTS"
assert_file_contains "right prompt elements present"    "$HOME/.p10k.zsh" "POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS"
assert_file_contains "dir segment present"              "$HOME/.p10k.zsh" "POWERLEVEL9K_DIR_FOREGROUND"
assert_file_contains "vcs segment present"              "$HOME/.p10k.zsh" "POWERLEVEL9K_VCS_CLEAN_FOREGROUND"
assert_file_contains "prompt char present"              "$HOME/.p10k.zsh" "POWERLEVEL9K_PROMPT_CHAR"
assert_file_contains "node segment assembled"           "$HOME/.p10k.zsh" "POWERLEVEL9K_NODE_VERSION_FOREGROUND"
assert_file_contains "python segment assembled"         "$HOME/.p10k.zsh" "POWERLEVEL9K_PYENV_FOREGROUND"
assert_file_contains "execution_time segment assembled" "$HOME/.p10k.zsh" "POWERLEVEL9K_COMMAND_EXECUTION_TIME"
assert_file_not_contains "no ##ICON## placeholders left"  "$HOME/.p10k.zsh" "##ICON##"
assert_file_not_contains "no ##SEGMENTS## placeholder left" "$HOME/.p10k.zsh" "##SEGMENTS##"
assert_file_not_contains "no ##MODE## placeholder left"   "$HOME/.p10k.zsh" "##MODE##"

# ─── ~/.zshrc ─────────────────────────────────────────────────────────────────
section "~/.zshrc"
assert_file_exists     "~/.zshrc exists"                    "$HOME/.zshrc"
assert_file_contains   "oh-my-zsh sourced"                  "$HOME/.zshrc" "oh-my-zsh.sh"
assert_file_contains   "ZSH_THEME set to powerlevel10k"     "$HOME/.zshrc" "ZSH_THEME=.powerlevel10k"
assert_file_contains   "plugins line present"               "$HOME/.zshrc" "^plugins="
assert_file_contains   "zsh-autosuggestions in plugins"     "$HOME/.zshrc" "zsh-autosuggestions"
assert_file_contains   "zsh-syntax-highlighting in plugins" "$HOME/.zshrc" "zsh-syntax-highlighting"
assert_file_contains   "p10k source line present"           "$HOME/.zshrc" "source.*\.p10k\.zsh"
assert_file_contains   "instant prompt block present"       "$HOME/.zshrc" "p10k-instant-prompt"

# ─── Manifest ─────────────────────────────────────────────────────────────────
section "Manifest"
assert_file_exists  "manifest.json created"   "$MANIFEST"
assert_json_valid   "manifest.json is valid JSON" "$MANIFEST"
assert_json_field   "os_type recorded"        "$MANIFEST" "os_type"    "linux"
assert_json_field   "icon_mode recorded"      "$MANIFEST" "icon_mode"  "nerd"

print_summary "test_install"
