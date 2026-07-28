#!/usr/bin/env bash
# lib/p10k.sh - Clone Powerlevel10k and deploy p10k.zsh config

P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
P10K_CONFIG_SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/config/p10k.zsh"
P10K_CONFIG_DEST="$HOME/.p10k.zsh"

install_p10k() {
  header "Setting up Powerlevel10k"

  if [[ -d "$P10K_DIR" ]]; then
    success "Powerlevel10k already cloned"
    manifest_set_bool "p10k_was_preexisting" "true"
  else
    info "Cloning Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
    manifest_set_bool "p10k_was_preexisting" "false"
    success "Powerlevel10k cloned"
  fi

  _deploy_p10k_config
  _font_notice
}

_deploy_p10k_config() {
  if [[ ! -f "$P10K_CONFIG_SRC" ]]; then
    error "p10k config not found at: $P10K_CONFIG_SRC"
    exit 1
  fi

  if [[ -f "$P10K_CONFIG_DEST" ]]; then
    local backup="${P10K_CONFIG_DEST}.bak.$(date +%Y%m%d%H%M%S)"
    warn "Existing $HOME/.p10k.zsh found - backing up to $backup"
    cp "$P10K_CONFIG_DEST" "$backup"
    manifest_set "p10k_backup" "$backup"
  fi

  cp "$P10K_CONFIG_SRC" "$P10K_CONFIG_DEST"
  success "$HOME/.p10k.zsh deployed"
}

_font_notice() {
  divider
  if [[ "$OS_TYPE" == "wsl" ]]; then
    warn "WSL detected: Install MesloLGS NF font on your Windows host terminal manually."
    warn "Download from: https://github.com/romkatv/powerlevel10k#meslo-nerd-font-patched-for-powerlevel10k"
  else
    info "Font: Ensure 'MesloLGS NF' is installed and set in your terminal."
    info "Download: https://github.com/romkatv/powerlevel10k#meslo-nerd-font-patched-for-powerlevel10k"
  fi
  divider
}
