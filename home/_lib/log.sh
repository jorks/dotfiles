# -------------------------------------------------------------------
# PURPOSE:
#   Logging helpers for chezmoi run_* scripts with clear dotfiles
#   prefixing and optional colour for interactive use.
#
# SCOPE:
#   - Sourced by scripts in .chezmoiscripts/
#   - No execution logic
#
# BEHAVIOUR:
#   - Pure functions
#   - Safe to source multiple times
#   - No global state mutation beyond local constants
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Detect interactivity / colour support
# -------------------------------------------------------------------
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
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
# Prefix (clearly identifies dotfiles output)
# -------------------------------------------------------------------
LOG_PREFIX="${COLOR_DIM}[dotfiles]${COLOR_RESET}"

# -------------------------------------------------------------------
# Logging functions
# -------------------------------------------------------------------
log_info() {
  printf "%b\n" "${LOG_PREFIX} ${COLOR_INFO}→${COLOR_RESET} $*"
}

log_success() {
  printf "%b\n" "${LOG_PREFIX} ${COLOR_SUCCESS}✓${COLOR_RESET} $*"
}

log_warn() {
  printf "%b\n" "${LOG_PREFIX} ${COLOR_WARN}!${COLOR_RESET} $*" >&2
}

log_error() {
  printf "%b\n" "${LOG_PREFIX} ${COLOR_ERROR}✗${COLOR_RESET} $*" >&2
}

# -------------------------------------------------------------------
# Section helper (visual separation only)
# -------------------------------------------------------------------
log_section() {
  printf "\n%b\n" "${LOG_PREFIX} ${COLOR_BOLD}$*${COLOR_RESET}"
}
