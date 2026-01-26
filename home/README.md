# `home/`

This is the chezmoi source directory. Everything here maps into `$HOME` when you apply. Edit files here, run `chezmoi apply`, done.

## Naming conventions

Chezmoi uses prefixes to control how files are applied:

- `dot_zshrc` → `~/.zshrc`
- `private_dot_ssh/` → `~/.ssh/` (mode 0600/0700)
- `dot_gitconfig.tmpl` → `~/.gitconfig` (rendered with user data first)
- `dot_config/` → `~/.config/`

Templates (`.tmpl` suffix) are rendered before apply. Reference user data with `{{ .git_name }}` or `{{ .kits.devtools }}`. Values come from `.chezmoi.toml` prompts.

## Quick start

Edit a file in this directory, then apply:

```bash
chezmoi apply
```

Preview changes first with `chezmoi diff`. That's it.

Templates get rendered with your personal data (name, email, preferences). Everything else is copied as-is. The repo stays generic, your machine gets your config.

## What belongs here

Shell configs, editor preferences, SSH templates, XDG directories. User-level config you'd edit by hand and want versioned.

## What doesn't

Install scripts, Brewfiles, system setup. Those live in `.chezmoiscripts/` or outside chezmoi entirely.
