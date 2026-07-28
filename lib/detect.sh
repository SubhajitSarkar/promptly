#!/usr/bin/env bash
# lib/detect.sh - OS and environment detection
# Sets: OS_TYPE, DISTRO, PKG_MANAGER

detect_os() {
  # Windows / PowerShell (native, not WSL)
  if [[ -n "${OS:-}" && "${OS}" == "Windows_NT" ]] || \
     [[ -n "${WINDIR:-}" ]] || \
     [[ "$(uname -s 2>/dev/null)" == MINGW* ]] || \
     [[ "$(uname -s 2>/dev/null)" == CYGWIN* ]]; then
    OS_TYPE="windows"
    return
  fi

  local kernel
  kernel="$(uname -s)"

  case "$kernel" in
    Darwin)
      OS_TYPE="macos"
      PKG_MANAGER="brew"
      ;;
    Linux)
      # Distinguish WSL from native Linux
      if grep -qiE "(microsoft|wsl)" /proc/version 2>/dev/null; then
        OS_TYPE="wsl"
      else
        OS_TYPE="linux"
      fi
      _detect_linux_distro
      ;;
    *)
      OS_TYPE="unknown"
      ;;
  esac
}

_detect_linux_distro() {
  if command -v apt-get &>/dev/null; then
    DISTRO="debian"
    PKG_MANAGER="apt"
  elif command -v dnf &>/dev/null; then
    DISTRO="fedora"
    PKG_MANAGER="dnf"
  elif command -v pacman &>/dev/null; then
    DISTRO="arch"
    PKG_MANAGER="pacman"
  elif command -v zypper &>/dev/null; then
    DISTRO="opensuse"
    PKG_MANAGER="zypper"
  else
    DISTRO="unknown"
    PKG_MANAGER="unknown"
  fi
}

print_detected_env() {
  info "OS Type    : ${OS_TYPE}"
  [[ -n "${DISTRO:-}" ]]      && info "Distro     : ${DISTRO}"
  [[ -n "${PKG_MANAGER:-}" ]] && info "Pkg Manager: ${PKG_MANAGER}"
}
