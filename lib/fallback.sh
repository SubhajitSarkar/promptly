#!/usr/bin/env bash
# lib/fallback.sh - Fallback handlers for environments without sudo access

HAS_SUDO=false

check_sudo() {
  if sudo -n true 2>/dev/null; then
    HAS_SUDO=true
  else
    HAS_SUDO=false
    warn "No sudo access detected — will skip system-level installs and use fallbacks where possible."
  fi
}

# Wraps any sudo command: runs it if sudo is available, otherwise warns and returns 1
try_sudo() {
  if [[ "$HAS_SUDO" == true ]]; then
    sudo "$@"
  else
    warn "Skipped (no sudo): sudo $*"
    return 1
  fi
}

# Called when a required binary is missing and cannot be installed without sudo.
# Prints a clear message and exits.
abort_missing_dep() {
  local pkg="$1"
  local install_hint="$2"
  error "'$pkg' is not installed and could not be installed without sudo."
  error "Please ask your system administrator to install '$pkg', or install it manually:"
  error "  $install_hint"
  exit 1
}

# Instead of writing to /etc/shells (requires sudo), register zsh as the
# default shell by appending an exec fallback to the user's login shell rc file.
register_zsh_no_sudo() {
  local zsh_path="$1"
  local login_rc

  # Determine the current login shell rc file
  case "${SHELL:-}" in
    */bash) login_rc="$HOME/.bashrc" ;;
    */sh)   login_rc="$HOME/.profile" ;;
    *)      login_rc="$HOME/.profile" ;;
  esac

  local marker="# simple-zsh-setup: launch zsh"
  if grep -qF "$marker" "$login_rc" 2>/dev/null; then
    success "zsh launch fallback already present in $login_rc"
    return
  fi

  cat >> "$login_rc" <<EOF

$marker
if [ -x "$zsh_path" ] && [ "\$TERM_PROGRAM" != "" ]; then
  exec "$zsh_path" -l
fi
EOF
  warn "Could not set zsh as default shell (no sudo)."
  warn "Added zsh auto-launch to $login_rc as a fallback."
  warn "To permanently change your shell later, run: chsh -s $zsh_path"
}
