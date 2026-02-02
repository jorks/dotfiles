# -------------------------------------------------------------------
# PURPOSE:
#   Logging helpers for chezmoi run_* scripts with clear dotfiles
#   prefixing, optional colour for interactive use, and file logging.
#
# SCOPE:
#   - Sourced by scripts in .chezmoiscripts/
#   - No execution logic
#
# BEHAVIOUR:
#   - Pure functions
#   - Safe to source multiple times
#   - Logs to both console (with color) and file (plain text)
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Log file setup (always enabled, XDG-compliant location)
# -------------------------------------------------------------------
LOG_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/chezmoi"
LOG_FILE="$LOG_DIR/apply.log"

# Ensure log file exists (defensive - prevents errors if sourced standalone)
if [ ! -d "$LOG_DIR" ]; then
  mkdir -p "$LOG_DIR" 2>/dev/null
fi
if [ ! -f "$LOG_FILE" ]; then
  touch "$LOG_FILE" 2>/dev/null
fi

# Helper: write plain text with timestamp to file
_log_to_file() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') $*" >> "$LOG_FILE"
}

# -------------------------------------------------------------------
# Detect interactivity / colour support
# -------------------------------------------------------------------
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  COLOR_RESET="\033[0m"
  COLOR_DIM="\033[2m"
  COLOR_INFO="\033[36m"     # cyan
  COLOR_SUCCESS="\033[32m"  # green
  COLOR_WARN="\033[33m"     # yellow
  COLOR_ERROR="\033[31m"    # red
else
  COLOR_RESET=""
  COLOR_DIM=""
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
  _log_to_file "[INFO ] $*"
}

log_success() {
  printf "%b\n" "${LOG_PREFIX} ${COLOR_SUCCESS}✓${COLOR_RESET} $*"
  _log_to_file "[OK   ] $*"
}

log_warn() {
  printf "%b\n" "${LOG_PREFIX} ${COLOR_WARN}!${COLOR_RESET} $*" >&2
  _log_to_file "[WARN ] $*"
}

log_error() {
  printf "%b\n" "${LOG_PREFIX} ${COLOR_ERROR}✗${COLOR_RESET} $*" >&2
  _log_to_file "[ERROR] $*"
}

log_fatal() {
  printf "%b\n" "${LOG_PREFIX} ${COLOR_ERROR}✗${COLOR_RESET} $*" >&2
  _log_to_file "[FATAL] $*"
  exit "${2:-1}"
}

# -------------------------------------------------------------------
# Script lifecycle helpers
# -------------------------------------------------------------------
log_divider() {
  log_info "════════════════════════════════════════════════════════════"
}

log_script_start() {
  log_divider
  log_info "Script: $1"
}

log_script_end() {
  log_info "Finished: $1"
}

log_script_skip() {
  log_info "Skipping: $1 ($2)"
}
