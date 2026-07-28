#!/usr/bin/env bash
# lib/omz.sh - Install oh-my-zsh and required plugins

OMZ_DIR="${ZSH:-$HOME/.oh-my-zsh}"
OMZ_CUSTOM="${ZSH_CUSTOM:-$OMZ_DIR/custom}"

install_omz() {
  header "Setting up Oh My Zsh"

  if [[ -d "$OMZ_DIR" ]]; then
    success "oh-my-zsh already installed at $OMZ_DIR"
    manifest_set_bool "omz_was_preexisting" "true"
  else
    info "Installing oh-my-zsh..."
    RUNZSH=no CHSH=no \
      sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    manifest_set_bool "omz_was_preexisting" "false"
    success "oh-my-zsh installed"
  fi

  _install_plugin "zsh-autosuggestions" \
    "https://github.com/zsh-users/zsh-autosuggestions"

  _install_plugin "zsh-syntax-highlighting" \
    "https://github.com/zsh-users/zsh-syntax-highlighting"

  _install_plugin "zsh-nvm" \
    "https://github.com/lukechilds/zsh-nvm"
}

_install_plugin() {
  local name="$1"
  local repo="$2"
  local dest="$OMZ_CUSTOM/plugins/$name"

  if [[ -d "$dest" ]]; then
    success "Plugin '$name' already installed"
  else
    info "Installing plugin: $name..."
    git clone --depth=1 "$repo" "$dest"
    manifest_add_plugin "$name"
    success "Plugin '$name' installed"
  fi
}
