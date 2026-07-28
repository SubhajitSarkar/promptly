#!/usr/bin/env bash
# tests/run_tests.sh - Main test runner — executed inside the Docker container
# Runs: assembly (no network) → install → manifest → idempotency → uninstall

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
BOLD='\033[1m'
CYAN='\033[0;36m'
RESET='\033[0m'

TOTAL_PASS=0
TOTAL_FAIL=0

# Run a test file, capture its exit code, accumulate totals
run_suite() {
  local name="$1"
  local file="$SCRIPT_DIR/${name}.sh"

  echo ""
  echo -e "${BOLD}${CYAN}════════════════════════════════════════${RESET}"
  echo -e "${BOLD}${CYAN}  Suite: $name${RESET}"
  echo -e "${BOLD}${CYAN}════════════════════════════════════════${RESET}"

  if bash "$file"; then
    (( TOTAL_PASS++ )) || true
  else
    (( TOTAL_FAIL++ )) || true
  fi
}

# ─── Pre-install: unit tests that need no network ─────────────────────────────
run_suite test_assembly

# ─── Full install (non-interactive — picker defaults via non-TTY path) ─────────
echo ""
echo -e "${BOLD}${CYAN}════════════════════════════════════════${RESET}"
echo -e "${BOLD}${CYAN}  Running install.sh...${RESET}"
echo -e "${BOLD}${CYAN}════════════════════════════════════════${RESET}"
if bash "$REPO_DIR/install.sh"; then
  echo -e "${GREEN}  install.sh exited 0${RESET}"
else
  echo -e "${RED}  install.sh FAILED (exit $?) — post-install suites will likely fail${RESET}"
  (( TOTAL_FAIL++ )) || true
fi

# ─── Post-install assertions ──────────────────────────────────────────────────
run_suite test_install
run_suite test_manifest
run_suite test_idempotency

# ─── Uninstall ────────────────────────────────────────────────────────────────
run_suite test_uninstall

# ─── Final summary ────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}════════════════════════════════════════${RESET}"
echo -e "${BOLD}  TOTAL: ${GREEN}${TOTAL_PASS} suites passed${RESET}, ${RED}${TOTAL_FAIL} suites failed${RESET}"
echo -e "${BOLD}════════════════════════════════════════${RESET}"
echo ""

[[ $TOTAL_FAIL -eq 0 ]]
