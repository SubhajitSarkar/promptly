#!/usr/bin/env bash
# tests/test_assembly.sh - Unit tests for the p10k config assembler
# Tests _assemble_p10k_config directly with fixed inputs — no network, no installs.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$SCRIPT_DIR/helpers.sh"

# ─── Bootstrap just enough to run the assembler ───────────────────────────────
source "$REPO_DIR/lib/logger.sh"
# Set OS_TYPE so manifest_init doesn't hit an unbound variable under set -u
source "$REPO_DIR/lib/detect.sh"
detect_os
source "$REPO_DIR/lib/manifest.sh"
manifest_init  # needed so manifest_set calls don't fail

# Stub out functions the assembler calls but we don't need here
manifest_set()      { :; }
manifest_set_bool() { :; }

source "$REPO_DIR/lib/p10k.sh"

OUT="$(mktemp)"
P10K_CONFIG_DEST="$OUT"

# ─── Helper: run assembler with given segments + mode, return output path ─────
run_assembler() {
  local mode="$1"; shift
  ICON_MODE="$mode"
  SELECTED_SEGMENTS=("$@")
  _assemble_p10k_config
  echo "$OUT"
}

# ─── nerd mode — default segments ─────────────────────────────────────────────
section "Assembly — nerd mode, default segments"
run_assembler nerd node python go rust execution_time time >/dev/null

assert_file_contains "POWERLEVEL9K_MODE=nerdfont-complete" "$OUT" "POWERLEVEL9K_MODE=nerdfont-complete"
assert_file_contains "node segment config present"         "$OUT" "POWERLEVEL9K_NODE_VERSION_FOREGROUND"
assert_file_contains "python segment config present"       "$OUT" "POWERLEVEL9K_PYENV_FOREGROUND"
assert_file_contains "go segment config present"           "$OUT" "POWERLEVEL9K_GOENV_FOREGROUND"
assert_file_contains "rust segment config present"         "$OUT" "POWERLEVEL9K_RUST_VERSION_FOREGROUND"
assert_file_contains "execution_time segment present"      "$OUT" "POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD"
assert_file_contains "time segment present"                "$OUT" "POWERLEVEL9K_TIME_FORMAT"
assert_file_contains "node in right prompt elements"       "$OUT" "node_version"
assert_file_contains "pyenv in right prompt elements"      "$OUT" "pyenv"
assert_file_not_contains "no ##ICON## placeholders"        "$OUT" "##ICON##"
assert_file_not_contains "no ##SEGMENTS## placeholder"     "$OUT" "##SEGMENTS##"
assert_file_not_contains "no ##MODE## placeholder"         "$OUT" "##MODE##"

# ─── ascii mode ───────────────────────────────────────────────────────────────
section "Assembly — ascii mode"
run_assembler ascii node python >/dev/null

assert_file_contains "POWERLEVEL9K_MODE=ascii in ascii mode" "$OUT" "POWERLEVEL9K_MODE=ascii"
assert_file_not_contains "no ##ICON## placeholders in ascii mode" "$OUT" "##ICON##"

# ─── emoji mode ───────────────────────────────────────────────────────────────
section "Assembly — emoji mode"
run_assembler emoji node >/dev/null

assert_file_contains "POWERLEVEL9K_MODE=ascii in emoji mode" "$OUT" "POWERLEVEL9K_MODE=ascii"
assert_file_not_contains "no ##ICON## placeholders in emoji mode" "$OUT" "##ICON##"

# ─── unicode mode ─────────────────────────────────────────────────────────────
section "Assembly — unicode mode"
run_assembler unicode node >/dev/null

assert_file_not_contains "no ##ICON## placeholders in unicode mode" "$OUT" "##ICON##"

# ─── empty segment selection ──────────────────────────────────────────────────
section "Assembly — no segments selected"
run_assembler nerd >/dev/null

assert_file_contains "base layout still present with no segments" "$OUT" "POWERLEVEL9K_LEFT_PROMPT_ELEMENTS"
assert_file_not_contains "no ##SEGMENTS## placeholder"            "$OUT" "##SEGMENTS##"

# ─── cloud segments ───────────────────────────────────────────────────────────
section "Assembly — cloud & devops segments"
run_assembler nerd aws docker kubectl terraform >/dev/null

assert_file_contains "aws segment present"       "$OUT" "POWERLEVEL9K_AWS_SHOW_ON_COMMAND"
assert_file_contains "docker segment present"    "$OUT" "POWERLEVEL9K_DOCKER_CONTEXT_FOREGROUND"
assert_file_contains "kubectl segment present"   "$OUT" "POWERLEVEL9K_KUBECONTEXT_CLASSES"
assert_file_contains "terraform segment present" "$OUT" "POWERLEVEL9K_TERRAFORM_CLASSES"

# ─── icons.tsv — all 22 segments have icon entries ────────────────────────────
section "icons.tsv — completeness"
ICONS_TSV="$REPO_DIR/config/icons.tsv"
ALL_KEYS=(node python go rust ruby java php dotnet swift
          aws azure gcp docker terraform kubectl
          execution_time time battery disk_usage ram load vpn)

for key in "${ALL_KEYS[@]}"; do
  if grep -q "^${key}"$'\t' "$ICONS_TSV"; then
    pass "icons.tsv has entry for: $key"
  else
    fail "icons.tsv missing entry for: $key"
  fi
done

# ─── icons.tsv — each row has 5 columns ───────────────────────────────────────
section "icons.tsv — column count"
while IFS=$'\t' read -r key nerd emoji unicode ascii; do
  [[ "$key" == '#'* || -z "$key" ]] && continue
  if [[ -n "$nerd" && -n "$emoji" && -n "$unicode" && -n "$ascii" ]]; then
    pass "icons.tsv row '$key' has all 4 icon columns"
  else
    fail "icons.tsv row '$key' is missing one or more icon columns"
  fi
done < "$ICONS_TSV"

rm -f "$OUT"
print_summary "test_assembly"
