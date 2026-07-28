#!/usr/bin/env bash
# lib/deps.sh - Install zsh and git if missing

install_deps() {
  header "Checking dependencies"

  _ensure_git
  _ensure_zsh
  _ensure_curl
}

_ensure_git() {
  if command -v git &>/dev/null; then
    success "git is already installed ($(git --version))"
    return
  fi
  info "Installing git..."
  _pkg_install git
}

_ensure_zsh() {
  if command -v zsh &>/dev/null; then
    success "zsh is already installed ($(zsh --version | head -1))"
    return
  fi
  info "Installing zsh..."
  _pkg_install zsh

  # Set zsh as default shell on Linux/WSL
  if [[ "$OS_TYPE" == "linux" || "$OS_TYPE" == "wsl" ]]; then
    local zsh_path
    zsh_path="$(command -v zsh)"
    if ! grep -qF "$zsh_path" /etc/shells; then
      echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
    fi
    info "Setting zsh as default shell (you may be prompted for password)..."
    chsh -s "$zsh_path"
  fi
}

_ensure_curl() {
  if command -v curl &>/dev/null; then
    success "curl is already installed"
    return
  fi
  info "Installing curl..."
  _pkg_install curl
}

_pkg_install() {
  local pkg="$1"
  case "$PKG_MANAGER" in
    brew)   brew install "$pkg" ;;
    apt)    sudo apt-get update -qq && sudo apt-get install -y "$pkg" ;;
    dnf)    sudo dnf install -y "$pkg" ;;
    pacman) sudo pacman -Sy --noconfirm "$pkg" ;;
    zypper) sudo zypper install -y "$pkg" ;;
    *)
      error "Unknown package manager. Please install '$pkg' manually."
      exit 1
      ;;
  esac
}
