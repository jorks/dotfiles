#!/usr/bin/env bash

# -------------------------------------------------------------------
# Logging helpers
#
# Goals:
# - Make it obvious when *this script* is doing something
# - Stay readable next to noisy tools like brew
# - Use colour only when interactive
# - Be safe in non-TTY / CI environments
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Detect interactivity / colour support
# -------------------------------------------------------------------
if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
  COLOR_RESET="\033[0m"
  COLOR_DIM="\033[2m"
  COLOR_BOLD="\033[1m"

  COLOR_INFO="\033[36m"     # cyan
  COLOR_SUCCESS="\033[32m"  # green
  COLOR_WARN="\033[33m"     # yellow
  COLOR_ERROR="\033[31m"    # red
else
  COLOR_RESET=""
  COLOR_DIM=""
  COLOR_BOLD=""
  COLOR_INFO=""
  COLOR_SUCCESS=""
  COLOR_WARN=""
  COLOR_ERROR=""
fi

# -------------------------------------------------------------------
# Prefix (makes it clear this is *your* script)
# -------------------------------------------------------------------
LOG_PREFIX="${COLOR_DIM}[dotfiles]${COLOR_RESET}"

# -------------------------------------------------------------------
# Logging functions
# -------------------------------------------------------------------
log_info() {
  echo -e "${LOG_PREFIX} ${COLOR_INFO}→${COLOR_RESET} $*"
}

log_success() {
  echo -e "${LOG_PREFIX} ${COLOR_SUCCESS}✓${COLOR_RESET} $*"
}

log_warn() {
  echo -e "${LOG_PREFIX} ${COLOR_WARN}!${COLOR_RESET} $*" >&2
}

log_error() {
  echo -e "${LOG_PREFIX} ${COLOR_ERROR}✗${COLOR_RESET} $*" >&2
}

log_fatal() {
  log_error "$*"
  exit 1
}

# -------------------------------------------------------------------
# Section helper (for visual separation)
# -------------------------------------------------------------------
log_section() {
  echo
  echo -e "${LOG_PREFIX} ${COLOR_BOLD}$*${COLOR_RESET}"
}

# -------------------------------------------------------------------
# Command runner (optional but recommended)
# -------------------------------------------------------------------
run_cmd() {
  if [[ "${DRY_RUN:-false}" == "true" ]]; then
    echo -e "${LOG_PREFIX} ${COLOR_DIM}[dry-run]${COLOR_RESET} $*"
  else
    "$@"
  fi
}
