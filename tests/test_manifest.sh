#!/usr/bin/env bash
# tests/test_manifest.sh - Validate manifest.json structure after install

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

MANIFEST="$HOME/.promptly/manifest.json"

section "Manifest — file"
assert_file_exists "manifest.json exists" "$MANIFEST"
assert_json_valid  "manifest.json is valid JSON" "$MANIFEST"
for field in installed_at os_type icon_mode; do
  val=$(python3 -c "import json; d=json.load(open('$MANIFEST')); print(d.get('$field',''))" 2>/dev/null)
  if [[ -n "$val" ]]; then
    pass "field '$field' is present and non-empty (value: $val)"
  else
    fail "field '$field' is missing or empty"
  fi
done

section "Manifest — boolean fields are actual booleans"
for field in omz_was_preexisting zsh_was_preexisting p10k_was_preexisting; do
  val=$(python3 -c "
import json
d = json.load(open('$MANIFEST'))
v = d.get('$field', 'MISSING')
print(type(v).__name__)
" 2>/dev/null)
  if [[ "$val" == "bool" ]]; then
    pass "field '$field' is a boolean"
  else
    fail "field '$field' is not a boolean (type: $val)"
  fi
done

section "Manifest — icon_mode is a valid value"
icon_mode=$(python3 -c "import json; print(json.load(open('$MANIFEST')).get('icon_mode',''))" 2>/dev/null)
if [[ "$icon_mode" =~ ^(nerd|emoji|unicode|ascii)$ ]]; then
  pass "icon_mode '$icon_mode' is a valid value"
else
  fail "icon_mode '$icon_mode' is not one of: nerd, emoji, unicode, ascii"
fi

section "Manifest — os_type is a valid value"
os_type=$(python3 -c "import json; print(json.load(open('$MANIFEST')).get('os_type',''))" 2>/dev/null)
if [[ "$os_type" =~ ^(macos|linux|wsl|windows)$ ]]; then
  pass "os_type '$os_type' is a valid value"
else
  fail "os_type '$os_type' is not a recognised value"
fi

section "Manifest — plugins_installed is an array"
val=$(python3 -c "
import json
d = json.load(open('$MANIFEST'))
v = d.get('plugins_installed', 'MISSING')
print(type(v).__name__)
" 2>/dev/null)
if [[ "$val" == "list" ]]; then
  pass "plugins_installed is an array"
else
  fail "plugins_installed is not an array (type: $val)"
fi

print_summary "test_manifest"
