#!/usr/bin/env bash
# tests/test_uninstall.sh - Assert uninstall.sh cleans up correctly
# Runs a fresh install first to ensure a clean known state, then uninstalls.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$SCRIPT_DIR/helpers.sh"

# Reset to clean state: remove any previous install artifacts so the
# fresh install below takes a backup of a clean (pre-promptly) .zshrc
rm -f "$HOME/.p10k.zsh"
rm -f "$HOME/.zshrc"
rm -rf "$HOME/.promptly"

# Fresh install to get a clean known state before testing uninstall
bash "$REPO_DIR/install.sh" >/dev/null 2>&1 || true

section "Uninstall — exit code"
assert_exit_0 "uninstall.sh exits 0" bash "$REPO_DIR/uninstall.sh"

section "Uninstall — configs removed"
if [[ ! -f "$HOME/.p10k.zsh" ]]; then
  pass "~/.p10k.zsh removed"
else
  fail "~/.p10k.zsh still exists after uninstall"
fi

section "Uninstall — ~/.zshrc no longer references p10k"
if [[ -f "$HOME/.zshrc" ]]; then
  assert_file_not_contains "p10k source line removed from ~/.zshrc" \
    "$HOME/.zshrc" "source.*\.p10k\.zsh"
  assert_file_not_contains "ZSH_THEME=powerlevel10k removed from ~/.zshrc" \
    "$HOME/.zshrc" "ZSH_THEME=.*powerlevel10k"
else
  pass "~/.zshrc removed entirely (acceptable)"
fi

section "Uninstall — backup files created"
ZSHRC_BACKUPS=$(find "$HOME" -maxdepth 1 -name '.zshrc.bak.*' | wc -l | tr -d ' ')
if (( ZSHRC_BACKUPS >= 1 )); then
  pass "~/.zshrc backup exists ($ZSHRC_BACKUPS found)"
else
  fail "no ~/.zshrc.bak.* backup found"
fi

section "Uninstall — manifest removed"
if [[ ! -f "$HOME/.promptly/manifest.json" ]]; then
  pass "manifest.json removed"
else
  fail "manifest.json still exists after uninstall"
fi

print_summary "test_uninstall"
