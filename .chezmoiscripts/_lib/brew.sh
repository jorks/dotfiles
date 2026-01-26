# -------------------------------------------------------------------
# PURPOSE:
#   Brew helper functions for kit installation
#
# SCOPE:
#   - Sourced by kit orchestrator and install scripts
#   - Provides DRY wrapper around brew bundle
#
# BEHAVIOUR:
#   - Pure functions
#   - Assumes Homebrew is already installed
#   - Handles missing Brewfiles gracefully
# -------------------------------------------------------------------

# Apply a Brewfile idempotently
# Usage: apply_brewfile /path/to/Brewfile
apply_brewfile() {
  brewfile="$1"

  if [ ! -f "$brewfile" ]; then
    log_warn "Brewfile not found: $brewfile"
    return 1
  fi

  if [ ! -s "$brewfile" ]; then
    log_info "Brewfile is empty: $brewfile (skipping)"
    return 0
  fi

  log_info "Applying Brewfile: $brewfile"

  if brew bundle --file="$brewfile" --no-lock; then
    log_success "Brewfile applied: $brewfile"
    return 0
  else
    log_error "Brewfile failed: $brewfile"
    return 1
  fi
}
