#!/usr/bin/env bash
# lib/manifest.sh - Records install state to ~/.simple-zsh-setup/manifest.json

MANIFEST_DIR="$HOME/.simple-zsh-setup"
MANIFEST_FILE="$MANIFEST_DIR/manifest.json"

# Called once at the start of install to initialise the manifest
manifest_init() {
  mkdir -p "$MANIFEST_DIR"
  cat > "$MANIFEST_FILE" <<EOF
{
  "installed_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "os_type": "$OS_TYPE",
  "zshrc_backup": "",
  "p10k_backup": "",
  "omz_was_preexisting": false,
  "zsh_was_preexisting": false,
  "fallback_rc": "",
  "plugins_installed": [],
  "p10k_was_preexisting": false
}
EOF
}

# Update a top-level string key in the manifest
manifest_set() {
  local key="$1"
  local value="$2"
  local tmp
  tmp="$(mktemp)"
  sed "s|\"${key}\": \"[^\"]*\"|\"${key}\": \"${value}\"|" "$MANIFEST_FILE" > "$tmp"
  mv "$tmp" "$MANIFEST_FILE"
}

# Update a top-level boolean key in the manifest
manifest_set_bool() {
  local key="$1"
  local value="$2"  # true or false
  local tmp
  tmp="$(mktemp)"
  sed "s|\"${key}\": [a-z]*|\"${key}\": ${value}|" "$MANIFEST_FILE" > "$tmp"
  mv "$tmp" "$MANIFEST_FILE"
}

# Append a plugin name to the plugins_installed array
manifest_add_plugin() {
  local plugin="$1"
  local tmp
  tmp="$(mktemp)"
  sed "s|\"plugins_installed\": \[|\"plugins_installed\": [\"${plugin}\"|;s|\"${plugin}\"\(, \"\)|\"\1|;s|\[\"${plugin}\"\([^]]\)|\[\"${plugin}\", \1|" "$MANIFEST_FILE" > "$tmp"
  # Simpler: use awk to append to the array
  awk -v p="$plugin" '
    /"plugins_installed": \[\]/ { sub(/\[\]/, "[\"" p "\"]"); print; next }
    /"plugins_installed": \[/   { sub(/\[/, "[\"" p "\", "); print; next }
    { print }
  ' "$MANIFEST_FILE" > "$tmp"
  mv "$tmp" "$MANIFEST_FILE"
}
