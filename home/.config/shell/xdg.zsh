# ~/.config/shell/xdg.zsh
#
# PURPOSE
# -------
# Define XDG Base Directory locations for tools that support them.
#
# WHAT IS XDG?
# ------------
# The XDG Base Directory Specification is a freedesktop.org standard
# that defines where user-specific configuration, cache, data, and
# state files should live.
#
# Instead of every tool dumping dotfiles directly into $HOME
# (~/.toolrc, ~/.tool-cache, ~/.tool-history, etc), XDG provides
# a consistent, predictable layout:
#
#   Config  → ~/.config
#   Cache   → ~/.cache
#   Data    → ~/.local/share
#   State   → ~/.local/state
#
# WHY SET THIS?
# -------------
# - Keeps $HOME clean and readable over time
# - Reduces dotfile sprawl
# - Many modern tools already respect XDG automatically
# - Tools that *don’t* support XDG are unaffected
#
# This is intentionally non-invasive:
# - No files are moved
# - No behaviour is forced
# - Only tools that opt-in will use these paths
#
# Think of this as setting sensible defaults for the future.

# -------------------------------------------------------------------
# XDG Base Directories
# -------------------------------------------------------------------

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
