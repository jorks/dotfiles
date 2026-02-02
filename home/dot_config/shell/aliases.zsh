# aliases.zsh
#
# PURPOSE
# -------
# Interactive shell aliases and small helper functions.
# Sourced from ~/.zshrc.
#
# Principles:
# - Prefer safety over cleverness
# - Avoid aliases that break scripts or muscle memory
# - macOS-first, Linux-safe

# -------------------------------------------------------------------
# Safer defaults (interactive use)
# -------------------------------------------------------------------

# Ask before overwriting or deleting
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -i'

# Create parent dirs as needed, be verbose
alias mkdir='mkdir -pv'

# -------------------------------------------------------------------
# Directory navigation
# -------------------------------------------------------------------

# Always list contents after cd (interactive convenience)
if [[ -o interactive ]]; then
  cd() {
    builtin cd "$@" || return
    command ls -FGlAhp 2>/dev/null
  }
fi

# Fast directory jumps
alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'
alias back='cd -'

# -------------------------------------------------------------------
# PATH inspection
# -------------------------------------------------------------------

# Print PATH entries one per line (safe, readable)
alias path='echo "$PATH" | tr ":" "\n"'

# -------------------------------------------------------------------
# File permissions
# -------------------------------------------------------------------

# Make file executable
alias ax='chmod +x'

# -------------------------------------------------------------------
# macOS-specific helpers
# -------------------------------------------------------------------

if [[ "$(uname)" == "Darwin" ]]; then
  # Move files to macOS Trash instead of rm
  trash() {
    command mv "$@" ~/.Trash
  }

  # Quick Look any file
  ql() {
    qlmanage -p "$@" >/dev/null 2>&1
  }

  # Open man pages in a separate window (optional)
  man() {
    open "x-man-page://$*"
  }

  # Pipe output to a desktop file (handy for debugging)
  alias DT='tee ~/Desktop/terminalOut.txt'

fi

# -------------------------------------------------------------------
# Process inspection
# -------------------------------------------------------------------

# Processes owned by current user
mine() {
  ps "$@" -u "$USER" -o pid,%cpu,%mem,start,time,command
}

alias memHogs='ps wwaxm -o pid,stat,vsize,rss,time,command | head -10'
alias cpuHogs='ps wwaxr -o pid,stat,%cpu,time,command | head -10'

