# -------------------------------------------------------------------
# PURPOSE:
#   Brew helper functions for kit installation
#
# SCOPE:
#   - Sourced by kit orchestrator and install scripts
#   - Provides DRY wrapper around brew bundle
#
# BEHAVIOUR:
#   - Formulae: brew bundle (strict). Casks: one-by-one install if missing, skip if present (catalog/wish-list).
#   - Pure functions; Homebrew in PATH; missing/empty files skipped
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Ensure Homebrew is in PATH for this session
# -------------------------------------------------------------------
# Each chezmoi script runs in a new subprocess, so PATH from
# previous scripts doesn't persist. This ensures brew is available
# even immediately after Homebrew installation.
if [ -z "$(command -v brew)" ]; then
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

# Clean up stale Homebrew downloads that can block brew bundle
# This handles cases where a previous run was interrupted
cleanup_stale_downloads() {
  local cache_dir="$HOME/Library/Caches/Homebrew/downloads"
  if [ -d "$cache_dir" ]; then
    local stale_files
    stale_files=$(find "$cache_dir" -name "*.incomplete" -type f 2>/dev/null)
    if [ -n "$stale_files" ]; then
      log_info "Cleaning up stale Homebrew downloads..."
      rm -f "$cache_dir"/*.incomplete
    fi
  fi
}

# Install a single cask only if the app is not already in /Applications (best-effort skip).
# If metadata lookup or path check fails, we try install anyway; failures are ignored (|| true).
# Usage: install_cask_once <cask_name>
install_cask_once() {
  cask="$1"

  log_info "Processing cask: $cask"

  # Try to resolve the .app name from Homebrew metadata (best effort)
  app_name="$(
    brew info "$cask" --cask --json=v2 2>/dev/null \
      | jq -r '.casks[0].artifacts[]? | select(.app) | .app[0]' 2>/dev/null \
      | head -n 1
  )"

  if [ -n "$app_name" ] && [ -d "/Applications/$app_name" ]; then
    log_info "→ $app_name already exists, skipping install"
    return 0
  fi

  log_info "→ Installing cask $cask (best effort)"
  brew install --cask "$cask" || true
}

# Install casks from a Brewfile.casks (catalog: install if missing, skip if present, continue on failure)
# Usage: install_casks_from_brewfile /path/to/Brewfile.casks
install_casks_from_brewfile() {
  local brewfile="$1"
  local cask_name

  [ ! -f "$brewfile" ] && return 0
  [ ! -s "$brewfile" ] && return 0

  grep -E '^cask "' "$brewfile" | sed 's/^cask "\([^"]*\)".*/\1/' | while read -r cask_name; do
    install_cask_once "$cask_name"
  done
}

# Apply a kit's Brewfiles (Brewfile.formula strict, Brewfile.casks one-by-one best-effort)
# Usage: apply_brewfile /path/to/kit_dir
apply_brewfile() {
  kit_dir="$1"

  if [ ! -d "$kit_dir" ]; then
    log_warn "Kit directory not found: $kit_dir"
    return 1
  fi

  formula_file="$kit_dir/Brewfile.formula"
  casks_file="$kit_dir/Brewfile.casks"

  if [ ! -f "$formula_file" ] && [ ! -f "$casks_file" ]; then
    log_warn "No Brewfile.formula or Brewfile.casks in: $kit_dir"
    return 1
  fi

  log_info "Applying Brewfile(s): $kit_dir"
  cleanup_stale_downloads

  # Strict: formulae (and taps)
  if [ -f "$formula_file" ] && [ -s "$formula_file" ]; then
    log_info "Installing formulae from Brewfile.formula: $formula_file"
    if ! brew bundle install --file="$formula_file"; then
      log_error "Brewfile.formula failed: $formula_file"
      return 1
    fi
  fi

  # Casks: catalog install (one-by-one, install if missing, continue on failure)
  # Note on casks and bundle: bundle exits with non-zero code if any cask fails to install,
  # this does not play well with chezmoi and the catalog install strategy.
  if [ -f "$casks_file" ] && [ -s "$casks_file" ]; then
    log_info "Installing casks from: $casks_file"
    install_casks_from_brewfile "$casks_file"
  fi

  log_success "Brewfile(s) applied: $kit_dir"
  return 0
}
