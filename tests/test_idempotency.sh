#!/usr/bin/env bash
# tests/test_idempotency.sh - Run install.sh twice, assert second run is clean
# Run inside a Docker container — install.sh must have already run once.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

section "Second run — exit code"
assert_exit_0 "install.sh exits 0 on second run" \
  bash "$REPO_DIR/install.sh"

section "Second run — no duplicate lines in ~/.zshrc"
assert_equals "ZSH_THEME appears exactly once" \
  "1" "$(grep -c 'ZSH_THEME=.*powerlevel10k' "$HOME/.zshrc")"

assert_equals "p10k source line appears exactly once" \
  "1" "$(grep -c 'source.*\.p10k\.zsh' "$HOME/.zshrc")"

assert_equals "instant prompt block appears exactly once" \
  "2" "$(grep -c 'p10k-instant-prompt' "$HOME/.zshrc")"

section "Second run — backup created for ~/.p10k.zsh"
BACKUP_COUNT=$(find "$HOME" -maxdepth 1 -name '.p10k.zsh.bak.*' | wc -l | tr -d ' ')
if (( BACKUP_COUNT >= 1 )); then
  pass "~/.p10k.zsh backup created on second run ($BACKUP_COUNT found)"
else
  fail "expected a .p10k.zsh.bak.* file but none found"
fi

section "Second run — manifest still valid"
assert_json_valid "manifest.json still valid after second run" \
  "$HOME/.promptly/manifest.json"

print_summary "test_idempotency"
