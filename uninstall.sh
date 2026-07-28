#!/usr/bin/env bash
# uninstall.sh - Entry point for reverting the zsh + Powerlevel10k setup
# Supports: macOS, Linux (apt/dnf/pacman/zypper), WSL

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ─── Load modules ─────────────────────────────────────────────────────────────
# shellcheck source=lib/logger.sh
source "$SCRIPT_DIR/lib/logger.sh"
# shellcheck source=lib/detect.sh
source "$SCRIPT_DIR/lib/detect.sh"
# shellcheck source=lib/fallback.sh
source "$SCRIPT_DIR/lib/fallback.sh"
# shellcheck source=lib/manifest.sh
source "$SCRIPT_DIR/lib/manifest.sh"
# shellcheck source=lib/uninstall.sh
source "$SCRIPT_DIR/lib/uninstall.sh"

# ─── Banner ───────────────────────────────────────────────────────────────────
clear
echo ""
echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║     🗑  promptly Uninstaller                     ║"
echo "  ║     Reverting to your previous state             ║"
echo "  ╚══════════════════════════════════════════════════╝"
echo ""

# ─── Run uninstall ────────────────────────────────────────────────────────────
run_uninstall

# ─── Done ─────────────────────────────────────────────────────────────────────
echo ""
divider
success "Uninstall complete - your previous state has been restored."
divider
echo ""
echo -e "  Open a new terminal or run: source ~/.zshrc"
echo ""
