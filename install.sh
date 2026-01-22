#!/usr/bin/env bash
set -euo pipefail

# -------------------------------------------------------------------
# Dotfiles installer
# Author: James Corcoran | jorks.net
#
# Purpose:
#   Fetch the dotfiles repo and run the appropriate bootstrap script.
#
# This script is intentionally small and transparent.
# All real logic lives in the bootstrap scripts.
# -------------------------------------------------------------------

DEFAULT_TARGET="$HOME/.dotfiles"
DEFAULT_BRANCH="main"

# -------------------------------------------------------------------
# Banner
# -------------------------------------------------------------------
cat <<'EOF'
   ___       __  ____ __
  / _ \___  / /_/ _(_) /__ ___
 / // / _ \/ __/ _/ / / -_|_-<
/____/\___/\__/_//_/_/\__/___/

Dotfiles bootstrap
Author: James Corcoran | jorks.net
--------------------------------------------------
EOF

# -------------------------------------------------------------------
# Helpers
# -------------------------------------------------------------------
info()  { echo "→ $*"; }
fatal() { echo "✗ $*" >&2; exit 1; }

require_executable() {
  local file="$1"

  [[ -f "$file" ]] \
    || fatal "Bootstrap script not found: $file"

  [[ -x "$file" ]] \
    || fatal "Bootstrap script not executable: $file (run: chmod +x \"$file\")"
}

# -------------------------------------------------------------------
# Preflight
# -------------------------------------------------------------------
info "Running preflight checks"

command -v git >/dev/null 2>&1 || fatal "git is required but not installed"

OS="$(uname -s)"
case "$OS" in
  Darwin|Linux) ;;
  *)
    fatal "Unsupported OS: $OS"
    ;;
esac

# -------------------------------------------------------------------
# Prompt for repo
# -------------------------------------------------------------------
info "Enter the full Git repository URL (HTTPS or SSH)"
info "Examples:"
info "  https://github.com/jorks/dotfiles.git"
info "  git@github.com:jorks/dotfiles.git"
echo

read -r -p "Dotfiles git repo URL: " REPO_URL
[[ -n "$REPO_URL" ]] || fatal "Repo URL is required"

read -r -p "Target directory [$DEFAULT_TARGET]: " TARGET_DIR
TARGET_DIR="${TARGET_DIR:-$DEFAULT_TARGET}"

read -r -p "Branch [$DEFAULT_BRANCH]: " BRANCH
BRANCH="${BRANCH:-$DEFAULT_BRANCH}"

echo

# -------------------------------------------------------------------
# Clone or reuse
# -------------------------------------------------------------------
if [[ -d "$TARGET_DIR/.git" ]]; then
  info "Using existing repo at $TARGET_DIR"
else
  info "Cloning repo into $TARGET_DIR"
  git clone --branch "$BRANCH" "$REPO_URL" "$TARGET_DIR"
fi

cd "$TARGET_DIR"

# -------------------------------------------------------------------
# Select bootstrap
# -------------------------------------------------------------------
case "$OS" in
  Darwin)
    BOOTSTRAP="bootstrap/macos/bootstrap_macos.sh"
    ;;
  Linux)
    BOOTSTRAP="bootstrap/linux/bootstrap_linux.sh"
    ;;
esac

require_executable "$BOOTSTRAP"

# -------------------------------------------------------------------
# Run bootstrap
# -------------------------------------------------------------------
echo
info "Starting bootstrap"
echo

exec "$BOOTSTRAP"
