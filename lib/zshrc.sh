#!/usr/bin/env bash
# lib/zshrc.sh - Idempotent ~/.zshrc patching

ZSHRC="$HOME/.zshrc"

patch_zshrc() {
  header "Patching ~/.zshrc"

  _backup_zshrc
  _ensure_omz_exists
  _patch_theme
  _patch_instant_prompt
  _patch_plugins
  _patch_nvm
  _patch_p10k_source

  success "~/.zshrc patched"
}

_backup_zshrc() {
  if [[ -f "$ZSHRC" ]]; then
    local backup="${ZSHRC}.bak.$(date +%Y%m%d%H%M%S)"
    cp "$ZSHRC" "$backup"
    info "Backed up $HOME/.zshrc to $backup"
  else
    touch "$ZSHRC"
    info "Created new ~/.zshrc"
  fi
}

_ensure_omz_exists() {
  # If oh-my-zsh source line is missing, add it
  if ! grep -q 'source.*oh-my-zsh.sh' "$ZSHRC"; then
    cat >> "$ZSHRC" <<'EOF'

export ZSH="$HOME/.oh-my-zsh"
source $ZSH/oh-my-zsh.sh
EOF
    info "Added oh-my-zsh source block"
  fi
}

_patch_theme() {
  if grep -q 'powerlevel10k/powerlevel10k' "$ZSHRC"; then
    success "Theme already set to powerlevel10k"
    return
  fi
  # Replace any existing ZSH_THEME line, or append
  if grep -q '^ZSH_THEME=' "$ZSHRC"; then
    sed -i.tmp 's|^ZSH_THEME=.*|ZSH_THEME="powerlevel10k/powerlevel10k"\nPOWERLEVEL9K_INSTANT_PROMPT=quiet|' "$ZSHRC"
    rm -f "${ZSHRC}.tmp"
    info "Replaced ZSH_THEME with powerlevel10k"
  else
    printf '\nZSH_THEME="powerlevel10k/powerlevel10k"\nPOWERLEVEL9K_INSTANT_PROMPT=quiet\n' >> "$ZSHRC"
    info "Appended ZSH_THEME=powerlevel10k"
  fi
}

_patch_instant_prompt() {
  local marker='p10k-instant-prompt'
  if grep -q "$marker" "$ZSHRC"; then
    success "Instant prompt block already present"
    return
  fi
  # Prepend instant prompt block to top of file
  local tmp
  tmp="$(mktemp)"
  cat > "$tmp" <<'EOF'
# Enable Powerlevel10k instant prompt (must stay at the very top)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

EOF
  cat "$ZSHRC" >> "$tmp"
  mv "$tmp" "$ZSHRC"
  info "Prepended instant prompt block"
}

_patch_plugins() {
  local required_plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-nvm z npm)

  if ! grep -q '^plugins=' "$ZSHRC"; then
    echo "plugins=(${required_plugins[*]})" >> "$ZSHRC"
    info "Added plugins line"
    return
  fi

  local current_line
  current_line="$(grep '^plugins=' "$ZSHRC")"
  local new_line="$current_line"

  for plugin in "${required_plugins[@]}"; do
    if ! echo "$current_line" | grep -qw "$plugin"; then
      # Insert plugin before closing )
      new_line="${new_line/)/  $plugin\n)}"
      info "Adding missing plugin: $plugin"
    fi
  done

  if [[ "$new_line" != "$current_line" ]]; then
    # Escape for sed
    local escaped_current
    escaped_current="$(printf '%s\n' "$current_line" | sed 's/[[\.*^$()+?{|]/\\&/g')"
    sed -i.tmp "s|${escaped_current}|${new_line}|" "$ZSHRC"
    rm -f "${ZSHRC}.tmp"
  else
    success "All plugins already present"
  fi
}

_patch_nvm() {
  # Silence nvm use if present
  if grep -q 'nvm use' "$ZSHRC"; then
    sed -i.tmp 's|nvm use \([^ ]*\)$|nvm use \1 --silent 2>/dev/null|' "$ZSHRC"
    rm -f "${ZSHRC}.tmp"
    info "Silenced nvm use output"
  fi
}

_patch_p10k_source() {
  local marker='source.*\.p10k\.zsh'
  if grep -qE "$marker" "$ZSHRC"; then
    success "p10k source line already present"
    return
  fi
  printf '\n# Load Powerlevel10k config\n[[ ! -f %s/.p10k.zsh ]] || source %s/.p10k.zsh\n' "$HOME" "$HOME" >> "$ZSHRC"
  info "Appended p10k source line"
}
