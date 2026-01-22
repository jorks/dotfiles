#!/usr/bin/env bash
set -euo pipefail

# -------------------------------------------------------------------
# Linux bootstrap (Ubuntu)
#
# Purpose:
#   Establish a safe, generic Linux baseline.
#
# Installs:
#   - Core system packages
#   - Core CLI tools
#   - zsh (sets default shell)
#   - Oh My Zsh (dependency only)
#   - chezmoi (optional apply)
#
# Non-goals:
#   - Security hardening
#   - SSH / firewall config
#   - System tuning
#   - Personal tooling
#
# Safe to re-run.
# -------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

DRY_RUN=false
APPLY_CHEZMOI=true

# -------------------------------------------------------------------
# Load helpers
# -------------------------------------------------------------------
source "$REPO_ROOT/scripts/lib/logging.sh"
source "$REPO_ROOT/scripts/lib/checks.sh"

# -------------------------------------------------------------------
# Flags
# -------------------------------------------------------------------
usage() {
  cat <<EOF
Usage: bootstrap_linux.sh [options]

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

require_linux
require_interactive
require_sudo
require_network

if [[ "$(id -u)" -eq 0 ]]; then
  log_fatal "Do not run this script as root"
fi

if ! grep -qi ubuntu /etc/os-release; then
  log_fatal "This script currently supports Ubuntu only"
fi

log_success "Preflight checks passed"

# -------------------------------------------------------------------
# Base system packages
# -------------------------------------------------------------------
log_section "Base system"

if [[ "$DRY_RUN" == "true" ]]; then
  log_info "[dry-run] apt-get update"
else
  sudo apt-get update -y
fi

log_info "Installing base system packages"

BASE_PACKAGES=(
  ca-certificates
  curl
  wget
  gnupg
  lsb-release
)

if [[ "$DRY_RUN" == "true" ]]; then
  log_info "[dry-run] apt-get install ${BASE_PACKAGES[*]}"
else
  sudo apt-get install -y "${BASE_PACKAGES[@]}"
fi

log_success "Base system ready"

# -------------------------------------------------------------------
# Core CLI tools
# -------------------------------------------------------------------
log_section "Core CLI tools"

CLI_PACKAGES=(
  git
  git-delta
  zsh
  fzf
  nano
  neovim
  ripgrep
  jq
  tldr
  htop
  btop
  ncdu
  duf
  bat
  eza
  lsof
  tree
  fd-find
)

if [[ "$DRY_RUN" == "true" ]]; then
  log_info "[dry-run] apt-get install ${CLI_PACKAGES[*]}"
else
  sudo apt-get install -y "${CLI_PACKAGES[@]}"
fi

log_success "CLI tools installed"

# -------------------------------------------------------------------
# Default shell
# -------------------------------------------------------------------
log_section "Shell"

ZSH_PATH="$(command -v zsh)"

if [[ "$SHELL" != "$ZSH_PATH" ]]; then
  log_info "Setting zsh as default shell (takes effect on next login)"
  if [[ "$DRY_RUN" != "true" ]]; then
    chsh -s "$ZSH_PATH"
  fi
else
  log_success "zsh already the default shell"
fi

# -------------------------------------------------------------------
# Oh My Zsh (dependency only)
# -------------------------------------------------------------------
log_section "Oh My Zsh"

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
  log_info "Installing chezmoi"
  if [[ "$DRY_RUN" == "true" ]]; then
    log_info "[dry-run] Install chezmoi"
  else
    sh -c "$(curl -fsLS https://chezmoi.io/get)" -- -b "$HOME/.local/bin"
  fi
fi

export PATH="$HOME/.local/bin:$PATH"

if [[ "$APPLY_CHEZMOI" == "true" ]]; then
  echo
  read -r -p "Apply dotfiles with chezmoi now? (y/N): " CONFIRM
  if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
    if [[ "$DRY_RUN" == "true" ]]; then
      log_info "[dry-run] chezmoi init --source $REPO_ROOT/home"
      log_info "[dry-run] chezmoi apply"
    else
      chezmoi init --source "$REPO_ROOT/home"
      chezmoi apply
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
log_success "Linux bootstrap finished"

cat <<EOF

Next steps:
- Log out and back in to start using zsh
- Optionally run kits (devtools, security, etc.)

This script can be safely re-run at any time.
EOF
