#!/usr/bin/env bash

# -------------------------------------------------------------------
# Environment & safety checks
# -------------------------------------------------------------------

require_macos() {
  [[ "$(uname -s)" == "Darwin" ]] || log_fatal "This script must be run on macOS"
}

require_linux() {
  [[ "$(uname -s)" == "Linux" ]] || log_fatal "This script must be run on Linux"
}

require_command() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || log_fatal "Required command not found: $cmd"
}

require_interactive() {
  [[ -t 1 ]] || log_fatal "This script must be run interactively"
}

# -------------------------------------------------------------------
# Sudo handling
# -------------------------------------------------------------------

require_sudo() {
  log_info "Requesting sudo access"
  sudo -v || log_fatal "sudo authentication failed"

  # Keep sudo alive for the duration of the script
  if [[ "${DRY_RUN:-false}" != "true" ]]; then
    while true; do
      sudo -n true
      sleep 60
      kill -0 "$$" || exit
    done 2>/dev/null &
  fi
}

# -------------------------------------------------------------------
# Network
# -------------------------------------------------------------------

require_network() {
  log_info "Checking network connectivity"
  if ! ping -c 1 -W 2 github.com >/dev/null 2>&1; then
    log_fatal "Network unavailable"
  fi
}

# -------------------------------------------------------------------
# Files & paths
# -------------------------------------------------------------------

require_file() {
  local file="$1"
  [[ -f "$file" ]] || log_fatal "Missing required file: $file"
}

require_dir() {
  local dir="$1"
  [[ -d "$dir" ]] || log_fatal "Missing required directory: $dir"
}
