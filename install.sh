#!/usr/bin/env bash
# install.sh - Entry point for zsh + Powerlevel10k full stack setup
# Supports: macOS, Linux (apt/dnf/pacman/zypper), WSL
# Windows/PowerShell: prints "Coming Soon" and exits

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ─── Load modules ─────────────────────────────────────────────────────────────
# shellcheck source=lib/logger.sh
source "$SCRIPT_DIR/lib/logger.sh"
# shellcheck source=lib/detect.sh
source "$SCRIPT_DIR/lib/detect.sh"
# shellcheck source=lib/fallback.sh
source "$SCRIPT_DIR/lib/fallback.sh"

# ─── OS Detection ─────────────────────────────────────────────────────────────
detect_os

if [[ "$OS_TYPE" == "windows" ]]; then
  echo ""
  echo "  ╔══════════════════════════════════════════════════╗"
  echo "  ║   Windows detected - use the PowerShell script   ║"
  echo "  ║                                                  ║"
  echo "  ║   Run in PowerShell 7:                           ║"
  echo "  ║   .\install.ps1                                  ║"
  echo "  ║                                                  ║"
  echo "  ║   For WSL: open your WSL terminal and re-run     ║"
  echo "  ║   bash install.sh                                ║"
  echo "  ╚══════════════════════════════════════════════════╝"
  echo ""
  exit 0
fi

if [[ "$OS_TYPE" == "unknown" ]]; then
  error "Unsupported OS. Exiting."
  exit 1
fi

# ─── Load remaining modules ───────────────────────────────────────────────────
# shellcheck source=lib/deps.sh
source "$SCRIPT_DIR/lib/deps.sh"
# shellcheck source=lib/omz.sh
source "$SCRIPT_DIR/lib/omz.sh"
# shellcheck source=lib/p10k.sh
source "$SCRIPT_DIR/lib/p10k.sh"
# shellcheck source=lib/zshrc.sh
source "$SCRIPT_DIR/lib/zshrc.sh"
# shellcheck source=lib/manifest.sh
source "$SCRIPT_DIR/lib/manifest.sh"

# ─── Banner ───────────────────────────────────────────────────────────────────
clear
echo ""
echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║     🚀 Zsh + Powerlevel10k Setup Script          ║"
echo "  ║     Full Stack: Node, Python, Go, Rust, TS       ║"
echo "  ╚══════════════════════════════════════════════════╝"
echo ""

header "Detected Environment"
print_detected_env

# ─── Init manifest ────────────────────────────────────────────────────────────
manifest_init

# ─── Run setup steps ──────────────────────────────────────────────────────────
install_deps
install_omz
install_p10k
patch_zshrc

# ─── Done ─────────────────────────────────────────────────────────────────────
echo ""
divider
success "Setup complete!"
divider
echo ""
echo -e "  ${BOLD}Next steps:${RESET}"
echo -e "  1. Install the font - see ${CYAN}docs/FONT_SETUP.md${RESET}"
echo -e "  2. Run: ${CYAN}source ~/.zshrc${RESET}"
echo -e "  3. Or open a new terminal tab"
echo ""
echo -e "  ${YELLOW}Tip:${RESET} Run ${CYAN}p10k configure${RESET} anytime to re-run the wizard"
echo -e "  ${YELLOW}Tip:${RESET} Run ${CYAN}bash uninstall.sh${RESET} to revert all changes"
echo ""
