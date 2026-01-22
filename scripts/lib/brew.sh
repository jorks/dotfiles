#!/usr/bin/env bash

# -------------------------------------------------------------------
# Homebrew helpers
# -------------------------------------------------------------------

ensure_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    log_success "Homebrew already installed"
    return
  fi

  log_info "Installing Homebrew"

  if [[ "${DRY_RUN:-false}" == "true" ]]; then
    log_info "[dry-run] Would install Homebrew"
    return
  fi

  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Ensure brew is on PATH for this shell
  if [[ -x "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x "/usr/local/bin/brew" ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi

  log_success "Homebrew installed"
}

brew_bundle() {
  local brewfile="$1"

  require_command brew
  require_file "$brewfile"

  log_section "Homebrew bundle: $(basename "$brewfile")"

  if [[ "${DRY_RUN:-false}" == "true" ]]; then
    log_info "[dry-run] brew bundle --file=$brewfile"
    return
  fi

  brew bundle --file="$brewfile"
  log_success "Brewfile complete: $(basename "$brewfile")"
}
