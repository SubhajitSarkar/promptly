#!/usr/bin/env bash
# tests/helpers.sh - Shared assert functions for all test files

PASS=0
FAIL=0

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
RESET='\033[0m'

pass() { echo -e "  ${GREEN}✔${RESET} $1"; (( PASS++ )); }
fail() { echo -e "  ${RED}✘${RESET} $1"; (( FAIL++ )); }
section() { echo -e "\n${BOLD}${YELLOW}▶ $1${RESET}"; }

assert_exit_0() {
  local label="$1"; shift
  if "$@" >/dev/null 2>&1; then
    pass "$label"
  else
    fail "$label (exit code $?)"
  fi
}

assert_file_exists() {
  local label="$1"
  local file="$2"
  [[ -f "$file" ]] && pass "$label" || fail "$label — file not found: $file"
}

assert_dir_exists() {
  local label="$1"
  local dir="$2"
  [[ -d "$dir" ]] && pass "$label" || fail "$label — dir not found: $dir"
}

assert_file_contains() {
  local label="$1"
  local file="$2"
  local pattern="$3"
  if grep -qE "$pattern" "$file" 2>/dev/null; then
    pass "$label"
  else
    fail "$label — pattern not found: $pattern"
  fi
}

assert_file_not_contains() {
  local label="$1"
  local file="$2"
  local pattern="$3"
  if ! grep -qE "$pattern" "$file" 2>/dev/null; then
    pass "$label"
  else
    fail "$label — unexpected pattern found: $pattern"
  fi
}

assert_json_valid() {
  local label="$1"
  local file="$2"
  if python3 -m json.tool "$file" >/dev/null 2>&1; then
    pass "$label"
  else
    fail "$label — invalid JSON: $file"
  fi
}

assert_json_field() {
  local label="$1"
  local file="$2"
  local field="$3"
  local expected="$4"
  local actual
  actual=$(python3 -c "import json,sys; d=json.load(open('$file')); print(d.get('$field',''))" 2>/dev/null)
  if [[ "$actual" == "$expected" ]]; then
    pass "$label"
  else
    fail "$label — expected '$expected', got '$actual'"
  fi
}

assert_equals() {
  local label="$1"
  local expected="$2"
  local actual="$3"
  if [[ "$expected" == "$actual" ]]; then
    pass "$label"
  else
    fail "$label — expected '$expected', got '$actual'"
  fi
}

print_summary() {
  local suite="$1"
  echo ""
  echo -e "${BOLD}────────────────────────────────────────${RESET}"
  echo -e "${BOLD}  $suite results: ${GREEN}${PASS} passed${RESET}, ${RED}${FAIL} failed${RESET}"
  echo -e "${BOLD}────────────────────────────────────────${RESET}"
  echo ""
  [[ $FAIL -eq 0 ]]  # exit 0 only if all passed
}
