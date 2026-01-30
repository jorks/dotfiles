# upgrades.zsh
#
# PURPOSE
# -------
# Prefer improved, modern CLI tools over traditional Unix defaults
# when they are available.
#
# Design rules:
# - Interactive use only
# - Conditional on tool existence
# - Same mental model as the original command
# - Easy to disable as a group

# -------------------------------------------------------------------
# Search / help
# -------------------------------------------------------------------

# Prefer ripgrep over grep (fast, recursive, sane defaults)
if command -v rg >/dev/null 2>&1; then
  alias grep='rg'
else
  # Fallback: colourised grep
  alias grep='grep --color=auto'
fi

# Prefer tldr over man for quick recall
if command -v tldr >/dev/null 2>&1; then
  alias help='tldr'
fi

# -------------------------------------------------------------------
# System monitoring / "top-style" tools
# -------------------------------------------------------------------

# Prefer htop over top
if command -v htop >/dev/null 2>&1; then
  alias top='htop'
fi

# Prefer btop if installed (modern, very readable)
if command -v btop >/dev/null 2>&1; then
  alias top='btop'
fi

# -------------------------------------------------------------------
# Disk usage / storage diagnostics
# -------------------------------------------------------------------

# Prefer ncdu for disk usage exploration
if command -v ncdu >/dev/null 2>&1; then
  alias du='ncdu'
fi

# Safer, more readable df
if command -v duf >/dev/null 2>&1; then
  alias df='duf'
fi

# -------------------------------------------------------------------
# File viewing
# -------------------------------------------------------------------

# Prefer bat over cat (syntax highlighting, paging)
if command -v bat >/dev/null 2>&1; then
  alias cat='bat'
elif command -v batcat >/dev/null 2>&1; then
  # Debian/Ubuntu naming
  alias cat='batcat'
fi

# -------------------------------------------------------------------
# Directory listing
# -------------------------------------------------------------------

# Prefer modern ls replacements (optional)
if command -v eza >/dev/null 2>&1; then
  alias ls='eza'
  alias ll='eza -lah --git'
elif command -v lsd >/dev/null 2>&1; then
  alias ls='lsd'
  alias ll='lsd -lah'
else
  alias ll='ls -FGlAhp'
fi

# -------------------------------------------------------------------
# Networking diagnostics
# -------------------------------------------------------------------

# Better ping output
if command -v prettyping >/dev/null 2>&1; then
  alias pping='prettyping --nolegend'
fi

# -------------------------------------------------------------------
# JSON / data inspection
# -------------------------------------------------------------------

# Pretty-print JSON via jq (fallback-safe)
if command -v jq >/dev/null 2>&1; then
  alias json='jq .'
fi

# -------------------------------------------------------------------
# Git UX improvements (lightweight)
# -------------------------------------------------------------------

# Better diff pager if installed
if command -v delta >/dev/null 2>&1; then
  alias diff='delta'
fi
