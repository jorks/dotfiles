# `home/`

This is the chezmoi source directory. Everything here maps into `$HOME` when applied - it's your home directory, versioned and templatable.

Files are edited directly in the repo. Git is the primary interface; chezmoi renders and applies. This is intentional.

## What belongs here

Shell configs (`.zshrc`, `.gitconfig`), XDG directories, editor preferences, SSH templates. If it's user-facing config you'd edit by hand and want synced across machines, it belongs here.

## What doesn't

Bootstrap scripts, Brewfiles, install logic, system setup. Those live elsewhere. This directory is intentionally scoped to user-level config that's safe to apply repeatedly.

See [CHEZMOI.md](CHEZMOI.md) for workflow and templating.
