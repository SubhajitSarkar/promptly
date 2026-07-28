#!/usr/bin/env bash
# lib/picker.sh - Interactive spacebar checklist for segment selection
# Usage: pick_segments - sets SELECTED_SEGMENTS array

# Each entry: "key|label|description|default(on/off)"
_SEGMENT_DEFS=(
  # ── Languages ────────────────────────────────────────────────────────────
  "node|Node / NVM|Node.js version in JS/TS projects|on"
  "python|Python / Virtualenv|Python version and active venv|on"
  "go|Go|Go version in projects with go.mod|on"
  "rust|Rust|Rust version in projects with Cargo.toml|on"
  "ruby|Ruby|Ruby version in projects with Gemfile|off"
  "java|Java|Java version in projects with pom.xml / build.gradle|off"
  "php|PHP|PHP version in projects with composer.json|off"
  "dotnet|.NET|.NET SDK version in projects with *.csproj / *.sln|off"
  "swift|Swift|Swift version in projects with Package.swift|off"
  # ── Cloud & DevOps ────────────────────────────────────────────────────────
  "aws|AWS|Current AWS profile and region|off"
  "azure|Azure|Current Azure subscription|off"
  "gcp|GCP|Current Google Cloud project|off"
  "docker|Docker|Current Docker context|off"
  "terraform|Terraform|Current Terraform workspace|off"
  "kubectl|Kubectl|Current Kubernetes context and namespace|off"
  # ── System ────────────────────────────────────────────────────────────────
  "execution_time|Execution Time|How long the last command took (>3s)|on"
  "time|Clock|Current time on the right side|on"
  "battery|Battery|Battery level when below 30% or charging|off"
  "disk_usage|Disk Usage|Disk usage, warns above 90%|off"
  "ram|RAM|Available RAM|off"
  "load|CPU Load|System CPU load average|off"
  "vpn|VPN|VPN connection name when active|off"
)

pick_segments() {
  # If not a TTY (e.g. piped install), select all defaults and skip icon detection
  if [[ ! -t 0 ]]; then
    ICON_MODE=nerd
    SELECTED_SEGMENTS=()
    for def in "${_SEGMENT_DEFS[@]}"; do
      local key default
      key="$(echo "$def" | cut -d'|' -f1)"
      default="$(echo "$def" | cut -d'|' -f4)"
      [[ "$default" == "on" ]] && SELECTED_SEGMENTS+=("$key") || true
    done
    return
  fi

  _detect_icon_mode
  local -a keys labels descs selected
  for def in "${_SEGMENT_DEFS[@]}"; do
    keys+=("$(echo "$def" | cut -d'|' -f1)")
    labels+=("$(echo "$def" | cut -d'|' -f2)")
    descs+=("$(echo "$def" | cut -d'|' -f3)")
    selected+=("$(echo "$def" | cut -d'|' -f4)")
  done

  local count=${#keys[@]}
  local cursor=0

  # Save terminal state
  tput civis 2>/dev/null  # hide cursor
  tput smcup 2>/dev/null  # save screen

  _picker_draw() {
    tput cup 0 0
    echo ""
    echo -e "  ${BOLD}Select prompt segments${RESET} (↑↓ move, Space toggle, Enter confirm)"
    echo -e "  ${CYAN}────────────────────────────────────────────────${RESET}"
    for (( i=0; i<count; i++ )); do
      local checkbox
      [[ "${selected[$i]}" == "on" ]] && checkbox="${GREEN}[✔]${RESET}" || checkbox="[ ]"
      if (( i == cursor )); then
        echo -e "  ${BOLD}▶ $checkbox ${labels[$i]}${RESET}  ${YELLOW}${descs[$i]}${RESET}"
      else
        echo -e "    $checkbox ${labels[$i]}  ${YELLOW}${descs[$i]}${RESET}"
      fi
    done
    echo -e "  ${CYAN}────────────────────────────────────────────────${RESET}"
  }

  _picker_draw
  while true; do
    local key
    IFS= read -rsn1 key
    case "$key" in
      $'\x1b')
        read -rsn2 -t 0.1 key
        case "$key" in
          '[A') (( cursor > 0 )) && (( cursor-- )) ;;          # up
          '[B') (( cursor < count-1 )) && (( cursor++ )) ;;    # down
        esac
        ;;
      ' ')
        [[ "${selected[$cursor]}" == "on" ]] && selected[$cursor]="off" || selected[$cursor]="on"
        ;;
      '')
        break  # Enter
        ;;
    esac
    _picker_draw
  done

  # Restore terminal state
  tput rmcup 2>/dev/null  # restore screen
  tput cnorm 2>/dev/null  # show cursor

  SELECTED_SEGMENTS=()
  for (( i=0; i<count; i++ )); do
    [[ "${selected[$i]}" == "on" ]] && SELECTED_SEGMENTS+=("${keys[$i]}")
  done

  echo ""
  info "Selected segments: ${SELECTED_SEGMENTS[*]:-none}"
}

_detect_icon_mode() {
  echo ""
  echo -e "  ${BOLD}Do you have a Nerd Font installed in your terminal?${RESET}"
  echo -e "  ${YELLOW}(e.g. MesloLGS NF — see docs/FONT_SETUP.md)${RESET}"
  echo ""
  while true; do
    read -rp "  Nerd Font installed? [y/n]: " answer
    case "$answer" in
      [Yy]*) ICON_MODE=nerd; info "Using Nerd Font icons"; echo ""; return ;;
      [Nn]*) break ;;
      *) echo "  Please answer y or n" ;;
    esac
  done

  echo ""
  echo -e "  Can you see this emoji clearly? 👉 🚀 🐍 ☁"
  echo -e "  ${YELLOW}(If they show as boxes or question marks, answer n)${RESET}"
  echo ""
  while true; do
    read -rp "  Emoji visible? [y/n]: " answer
    case "$answer" in
      [Yy]*) ICON_MODE=emoji;   info "Using emoji icons";   echo ""; return ;;
      [Nn]*) break ;;
      *) echo "  Please answer y or n" ;;
    esac
  done

  echo ""
  echo -e "  Can you see these symbols clearly? 👉 ⬡ ☸ ⚙ ○"
  echo -e "  ${YELLOW}(Basic Unicode - works on most modern terminals)${RESET}"
  echo ""
  while true; do
    read -rp "  Symbols visible? [y/n]: " answer
    case "$answer" in
      [Yy]*) ICON_MODE=unicode; info "Using Unicode symbols"; echo ""; return ;;
      [Nn]*) break ;;
      *) echo "  Please answer y or n" ;;
    esac
  done

  ICON_MODE=ascii
  info "Using ASCII fallback icons"
  echo ""
}
