# functions.zsh
#
# PURPOSE
# -------
# Small, reusable shell functions for interactive use.
# These are sourced from ~/.zshrc.
#
# Design rules:
# - Functions do ONE thing
# - No hidden side effects
# - Safe defaults
# - Portable across macOS and Linux

# -------------------------------------------------------------------
# Navigation helpers
# -------------------------------------------------------------------

# Create a directory and enter it
mcd() {
  if [[ -z "$1" ]]; then
    echo "Usage: mcd <directory>"
    return 1
  fi

  mkdir -p "$1" && cd "$1"
}

# Jump back N directories (e.g. up 3)
up() {
  local count=${1:-1}
  local path=""

  for ((i=0; i<count; i++)); do
    path="../$path"
  done

  cd "$path" || return
}

# -------------------------------------------------------------------
# Reload helpers
# -------------------------------------------------------------------

# Reload the current shell configuration
reload() {
  source "$HOME/.zshrc"
  echo "Shell configuration reloaded"
}

# -------------------------------------------------------------------
# Networking / diagnostics
# -------------------------------------------------------------------

# Show what is listening on a TCP port
port() {
  if [[ -z "$1" ]]; then
    echo "Usage: port <port>"
    return 1
  fi

  if command -v lsof >/dev/null 2>&1; then
    lsof -nP -iTCP:"$1" -sTCP:LISTEN
  else
    echo "lsof not installed"
    return 1
  fi
}

# -------------------------------------------------------------------
# File helpers
# -------------------------------------------------------------------

# Create a file and open it in $EDITOR
mkfile() {
  if [[ -z "$1" ]]; then
    echo "Usage: mkfile <filename>"
    return 1
  fi

  touch "$1" && "${EDITOR:-vi}" "$1"
}

# -------------------------------------------------------------------
# Archive extraction
# -------------------------------------------------------------------

# Extract most common archive formats
extract() {
  if [[ -z "$1" ]]; then
    echo "Usage: extract <archive>"
    return 1
  fi

  if [[ ! -f "$1" ]]; then
    echo "File not found: $1"
    return 1
  fi

  case "$1" in
    *.tar.bz2) tar xjf "$1" ;;
    *.tar.gz)  tar xzf "$1" ;;
    *.tar.xz)  tar xJf "$1" ;;
    *.tar)     tar xf "$1" ;;
    *.bz2)     bunzip2 "$1" ;;
    *.gz)      gunzip "$1" ;;
    *.xz)      unxz "$1" ;;
    *.zip)     unzip "$1" ;;
    *.7z)      7z x "$1" ;;
    *)         echo "Cannot extract '$1'" ;;
  esac
}

# -------------------------------------------------------------------
# Process helpers
# -------------------------------------------------------------------

# Show processes matching a pattern (grep-safe)
psg() {
  if [[ -z "$1" ]]; then
    echo "Usage: psg <pattern>"
    return 1
  fi

  ps aux | grep -i "[${1:0:1}]${1:1}"
}
