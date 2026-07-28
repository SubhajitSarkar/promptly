#!/usr/bin/env bash
# lib/uninstall.sh - Uninstall logic for macOS / Linux / WSL

MANIFEST_FILE="$HOME/.promptly/manifest.json"
OMZ_DIR="${ZSH:-$HOME/.oh-my-zsh}"
OMZ_CUSTOM="${ZSH_CUSTOM:-$OMZ_DIR/custom}"
P10K_DIR="$OMZ_CUSTOM/themes/powerlevel10k"

_read_manifest_str() {
  local key="$1"
  grep "\"${key}\":" "$MANIFEST_FILE" | sed 's/.*": "\(.*\)".*/\1/'
}

_read_manifest_bool() {
  local key="$1"
  grep "\"${key}\":" "$MANIFEST_FILE" | grep -q "true" && echo "true" || echo "false"
}

_read_manifest_plugins() {
  grep '"plugins_installed"' "$MANIFEST_FILE" | sed 's/.*\[\(.*\)\].*/\1/' | tr ',' '\n' | tr -d ' "' | grep -v '^$'
}

run_uninstall() {
  if [[ ! -f "$MANIFEST_FILE" ]]; then
    error "No manifest found at $MANIFEST_FILE"
    error "Cannot safely uninstall without it. See docs/UNINSTALL.md for manual steps."
    exit 1
  fi

  detect_os
  check_sudo

  local zshrc_backup p10k_backup omz_preexisting p10k_preexisting fallback_rc
  zshrc_backup="$(_read_manifest_str zshrc_backup)"
  p10k_backup="$(_read_manifest_str p10k_backup)"
  omz_preexisting="$(_read_manifest_bool omz_was_preexisting)"
  p10k_preexisting="$(_read_manifest_bool p10k_was_preexisting)"
  fallback_rc="$(_read_manifest_str fallback_rc)"

  _restore_zshrc "$zshrc_backup"
  _restore_p10k "$p10k_backup"
  _remove_plugins
  _remove_p10k "$p10k_preexisting"
  _remove_omz "$omz_preexisting"
  _remove_fallback_rc "$fallback_rc"
  _remove_manifest
}

_restore_zshrc() {
  local backup="$1"
  header "Restoring ~/.zshrc"
  if [[ -n "$backup" && -f "$backup" ]]; then
    cp "$backup" "$HOME/.zshrc"
    success "Restored ~/.zshrc from $backup"
  else
    warn "No ~/.zshrc backup found in manifest - removing current ~/.zshrc"
    rm -f "$HOME/.zshrc"
  fi
}

_restore_p10k() {
  local backup="$1"
  header "Restoring ~/.p10k.zsh"
  if [[ -n "$backup" && -f "$backup" ]]; then
    cp "$backup" "$HOME/.p10k.zsh"
    success "Restored ~/.p10k.zsh from $backup"
  else
    rm -f "$HOME/.p10k.zsh"
    info "No previous ~/.p10k.zsh - removed"
  fi
}

_remove_plugins() {
  header "Removing installed plugins"
  while IFS= read -r plugin; do
    [[ -z "$plugin" ]] && continue
    local dest="$OMZ_CUSTOM/plugins/$plugin"
    if [[ -d "$dest" ]]; then
      rm -rf "$dest"
      success "Removed plugin: $plugin"
    else
      info "Plugin not found, skipping: $plugin"
    fi
  done < <(_read_manifest_plugins)
}

_remove_p10k() {
  local preexisting="$1"
  header "Removing Powerlevel10k"
  if [[ "$preexisting" == "false" && -d "$P10K_DIR" ]]; then
    rm -rf "$P10K_DIR"
    success "Removed Powerlevel10k"
  else
    info "Powerlevel10k was pre-existing - leaving it in place"
  fi
}

_remove_omz() {
  local preexisting="$1"
  header "Removing Oh My Zsh"
  if [[ "$preexisting" == "false" && -d "$OMZ_DIR" ]]; then
    if [[ -f "$OMZ_DIR/tools/uninstall.sh" ]]; then
      ZSH="$OMZ_DIR" bash "$OMZ_DIR/tools/uninstall.sh" --unattended
    else
      rm -rf "$OMZ_DIR"
    fi
    success "Removed Oh My Zsh"
  else
    info "Oh My Zsh was pre-existing - leaving it in place"
  fi
}

_remove_fallback_rc() {
  local rc="$1"
  [[ -z "$rc" || ! -f "$rc" ]] && return
  header "Removing zsh fallback from $rc"
  local tmp
  tmp="$(mktemp)"
  sed '/# promptly: launch zsh/,/^fi$/d' "$rc" > "$tmp"
  mv "$tmp" "$rc"
  success "Removed zsh launch fallback from $rc"
}

_remove_manifest() {
  rm -rf "$HOME/.promptly"
  success "Removed manifest"
}
