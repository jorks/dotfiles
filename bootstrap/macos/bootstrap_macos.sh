#!/usr/bin/env bash
set -euo pipefail

# -------------------------------------------------------------------
# macOS bootstrap
#
# Purpose:
#   Establish a safe, generic baseline on macOS.
#
# Installs:
#   - Xcode Command Line Tools
#   - Homebrew
#   - Minimal Brewfile (essentials)
#   - Oh My Zsh (minimal)
#   - Chezmoi (optional apply)
#
# Non-goals:
#   - Personal tools (e.g. password managers)
#   - App configuration
#   - macOS defaults
# -------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

BREWFILE="$REPO_ROOT/bootstrap/macos/brew/Brewfile"

DRY_RUN=false
APPLY_CHEZMOI=true

# -------------------------------------------------------------------
# Load helpers
# -------------------------------------------------------------------
source "$REPO_ROOT/scripts/lib/logging.sh"
source "$REPO_ROOT/scripts/lib/checks.sh"
source "$REPO_ROOT/scripts/lib/brew.sh"

# -------------------------------------------------------------------
# Flags
# -------------------------------------------------------------------
usage() {
  cat <<EOF
Usage: bootstrap_macos.sh [options]

Options:
  --dry-run        Show what would be done without making changes
  --no-chezmoi     Install chezmoi but do not apply dotfiles
  -h, --help       Show this help message
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --no-chezmoi)
      APPLY_CHEZMOI=false
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      log_fatal "Unknown option: $1"
      ;;
  esac
done

# -------------------------------------------------------------------
# Preflight
# -------------------------------------------------------------------
log_section "Preflight"

require_macos
require_interactive
require_sudo
require_network

log_success "Preflight checks passed"

# -------------------------------------------------------------------
# XDG base directories
# -------------------------------------------------------------------
log_section "XDG base directories"

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

if [[ "$DRY_RUN" == "true" ]]; then
  log_info "[dry-run] mkdir -p $XDG_CONFIG_HOME $XDG_CACHE_HOME $XDG_DATA_HOME $XDG_STATE_HOME"
else
  mkdir -p \
    "$XDG_CONFIG_HOME" \
    "$XDG_CACHE_HOME" \
    "$XDG_DATA_HOME" \
    "$XDG_STATE_HOME"
fi

log_success "XDG directories ensured"

# -------------------------------------------------------------------
# Xcode Command Line Tools
# -------------------------------------------------------------------
log_section "Xcode Command Line Tools"

if xcode-select -p >/dev/null 2>&1; then
  log_success "Xcode Command Line Tools already installed"
else
  log_info "Installing Xcode Command Line Tools"
  log_info "A system dialog will appear. Click 'Install' to continue."

  if [[ "$DRY_RUN" == "true" ]]; then
    log_info "[dry-run] xcode-select --install"
  else
    xcode-select --install

    log_info "Waiting for Command Line Tools to finish installing..."
    until xcode-select -p >/dev/null 2>&1; do
      sleep 5
    done
  fi

  log_success "Xcode Command Line Tools installed"
fi

# -------------------------------------------------------------------
# Homebrew + essentials
# -------------------------------------------------------------------
log_section "Homebrew"

ensure_homebrew
brew_bundle "$BREWFILE"

# -------------------------------------------------------------------
# Oh My Zsh (minimal)
# -------------------------------------------------------------------
log_section "Shell"

if [[ -d "$HOME/.oh-my-zsh" ]]; then
  log_success "Oh My Zsh already installed"
else
  log_info "Installing Oh My Zsh (minimal)"

  if [[ "$DRY_RUN" == "true" ]]; then
    log_info "[dry-run] Install Oh My Zsh"
  else
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
      sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi

  log_success "Oh My Zsh installed"
fi

# Install optional zsh plugins
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# zsh-autosuggestions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions \
    "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

# zsh-syntax-highlighting
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting \
    "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# -------------------------------------------------------------------
# Chezmoi
# -------------------------------------------------------------------
log_section "Chezmoi"

if command -v chezmoi >/dev/null 2>&1; then
  log_success "Chezmoi already installed"
else
  log_info "Installing Chezmoi"
  if [[ "$DRY_RUN" == "true" ]]; then
    log_info "[dry-run] brew install chezmoi"
  else
    brew install chezmoi
  fi
  log_success "Chezmoi installed"
fi

if [[ "$APPLY_CHEZMOI" == "true" ]]; then
  echo
  read -r -p "Apply dotfiles with chezmoi now? (y/N): " CONFIRM
  if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
    if [[ "$DRY_RUN" == "true" ]]; then
      log_info "[dry-run] chezmoi -S \"$REPO_ROOT\" init --apply"
    else
      chezmoi -S "$REPO_ROOT" init --apply
    fi
    log_success "Chezmoi applied"
  else
    log_warn "Chezmoi apply skipped"
  fi
else
  log_warn "Chezmoi apply disabled via flag"
fi

# -------------------------------------------------------------------
# Done
# -------------------------------------------------------------------
log_section "Complete"
log_success "macOS bootstrap finished"

cat <<EOF

Next steps (optional):
  - kits/devtools.sh
  - kits/security.sh
  - kits/productivity.sh
  - kits/macadmin.sh

This machine now has a safe, generic baseline.
EOF
