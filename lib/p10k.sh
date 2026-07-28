#!/usr/bin/env bash
# lib/p10k.sh - Clone Powerlevel10k and assemble p10k.zsh from selected segments

P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
P10K_CONFIG_DEST="$HOME/.p10k.zsh"
_SEGMENTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../config/segments/zsh/p10k" && pwd)"
_BASE_CONFIG="$(cd "$(dirname "${BASH_SOURCE[0]}")/../config/base" && pwd)/p10k_base.zsh"
_ICONS_TSV="$(cd "$(dirname "${BASH_SOURCE[0]}")/../config" && pwd)/icons.tsv"

# Load icon registry into associative array: _ICONS[key:mode] = icon
declare -A _ICONS=()
_load_icons() {
  while IFS=$'\t' read -r key nerd emoji unicode ascii; do
    [[ "$key" == '#'* || -z "$key" ]] && continue
    _ICONS["${key}:nerd"]="$nerd"
    _ICONS["${key}:emoji"]="$emoji"
    _ICONS["${key}:unicode"]="$unicode"
    _ICONS["${key}:ascii"]="$ascii"
  done < "$_ICONS_TSV"
}

# Maps segment key -> right prompt element names (space-separated)
declare -A _SEGMENT_ELEMENTS=(
  # Languages
  [node]="node_version nvm package"
  [python]="pyenv virtualenv"
  [go]="goenv"
  [rust]="rust_version"
  [ruby]="rbenv"
  [java]="java_version"
  [php]="php_version"
  [dotnet]="dotnet_version"
  [swift]="swift_version"
  # Cloud & DevOps
  [aws]="aws"
  [azure]="azure"
  [gcp]="gcloud"
  [docker]="docker_context"
  [terraform]="terraform"
  [kubectl]="kubecontext"
  # System
  [execution_time]="command_execution_time"
  [time]="time"
  [battery]="battery"
  [disk_usage]="disk_usage"
  [ram]="ram"
  [load]="load"
  [vpn]="vpn_ip"
)

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
  if [[ ! -f "$_BASE_CONFIG" ]]; then
    error "p10k base config not found at: $_BASE_CONFIG"
    exit 1
  fi

  if [[ -f "$P10K_CONFIG_DEST" ]]; then
    local backup="${P10K_CONFIG_DEST}.bak.$(date +%Y%m%d%H%M%S)"
    warn "Existing $HOME/.p10k.zsh found — backing up to $backup"
    cp "$P10K_CONFIG_DEST" "$backup"
    manifest_set "p10k_backup" "$backup"
  fi

  _assemble_p10k_config
  success "$HOME/.p10k.zsh assembled with segments: ${SELECTED_SEGMENTS[*]:-none}"
}

_assemble_p10k_config() {
  _load_icons

  local segment_elements=""
  local segment_configs=""
  local p10k_mode
  case "${ICON_MODE:-nerd}" in
    nerd)    p10k_mode="nerdfont-complete" ;;
    *)       p10k_mode="ascii" ;;
  esac

  for key in "${SELECTED_SEGMENTS[@]}"; do
    local elements="${_SEGMENT_ELEMENTS[$key]:-}"
    local seg_file="$_SEGMENTS_DIR/${key}.zsh"
    local icon="${_ICONS[${key}:${ICON_MODE:-nerd}]:-}"

    if [[ -n "$elements" ]]; then
      for el in $elements; do
        segment_elements+="    $el"$'\n'
      done
    fi

    if [[ -f "$seg_file" ]]; then
      segment_configs+=$'\n'
      segment_configs+="  # ─── $(echo "$key" | tr '[:lower:]' '[:upper:]') ───"$'\n'
      local seg_content
      seg_content="$(grep -v '^#' "$seg_file" | grep -v '^$' | sed "s|##ICON##|${icon}|g")"
      while IFS= read -r line; do
        segment_configs+="  $line"$'\n'
      done <<< "$seg_content"
    fi
  done

  # Use python3 for all substitutions — bash ${var/##.../} misparses ## as
  # prefix-strip, and sed -e breaks on multi-line replacement values
  python3 - "$_BASE_CONFIG" "$P10K_CONFIG_DEST" \
    "$p10k_mode" "$segment_elements" "$segment_configs" <<'PYEOF'
import sys
src, dst, mode, segs, cfgs = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5]
with open(src) as f:
    content = f.read()
content = content.replace('##MODE##', mode)
content = content.replace('##SEGMENTS##', segs)
content = content.replace('##SEGMENT_CONFIGS##', cfgs)
with open(dst, 'w') as f:
    f.write(content)
PYEOF
}

_font_notice() {
  divider
  if [[ "$OS_TYPE" == "wsl" ]]; then
    warn "WSL detected: Install MesloLGS NF font on your Windows host terminal manually."
    warn "Download from: https://github.com/romkatv/powerlevel10k#meslo-nerd-font-patched-for-powerlevel10k"
  else
    info "Font: Ensure 'MesloLGS NF' is installed and set in your terminal."
    info "See docs/FONT_SETUP.md for instructions."
  fi
  divider
}
