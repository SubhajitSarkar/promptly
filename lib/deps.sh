#!/usr/bin/env bash
# lib/deps.sh - Install zsh and git if missing

install_deps() {
  header "Checking dependencies"

  check_sudo
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
  if ! _pkg_install git; then
    abort_missing_dep "git" "https://git-scm.com/downloads"
  fi
}

_ensure_zsh() {
  if command -v zsh &>/dev/null; then
    success "zsh is already installed ($(zsh --version | head -1))"
    _set_default_shell "$(command -v zsh)"
    return
  fi
  info "Installing zsh..."
  if ! _pkg_install zsh; then
    abort_missing_dep "zsh" "https://www.zsh.org/ or ask your sysadmin to install zsh"
  fi
  _set_default_shell "$(command -v zsh)"
}

_ensure_curl() {
  if command -v curl &>/dev/null; then
    success "curl is already installed"
    return
  fi
  info "Installing curl..."
  if ! _pkg_install curl; then
    abort_missing_dep "curl" "https://curl.se/download.html"
  fi
}

# Sets zsh as the default shell, falling back to rc-file injection if no sudo.
_set_default_shell() {
  local zsh_path="$1"
  [[ "$OS_TYPE" == "linux" || "$OS_TYPE" == "wsl" ]] || return 0

  if [[ "$HAS_SUDO" == true ]]; then
    if ! grep -qF "$zsh_path" /etc/shells; then
      echo "$zsh_path" | try_sudo tee -a /etc/shells >/dev/null
    fi
    info "Setting zsh as default shell (you may be prompted for password)..."
    chsh -s "$zsh_path"
  else
    register_zsh_no_sudo "$zsh_path"
  fi
}

_pkg_install() {
  local pkg="$1"
  case "$PKG_MANAGER" in
    brew)   brew install "$pkg" ;;
    apt)    try_sudo apt-get update -qq && try_sudo apt-get install -y "$pkg" ;;
    dnf)    try_sudo dnf install -y "$pkg" ;;
    pacman) try_sudo pacman -Sy --noconfirm "$pkg" ;;
    zypper) try_sudo zypper install -y "$pkg" ;;
    *)
      error "Unknown package manager. Please install '$pkg' manually."
      return 1
      ;;
  esac
}
