# `home/`

This is the chezmoi source directory. Everything here maps into `$HOME` when you apply. Edit files here, run `chezmoi apply`, done.

This guide covers the day-to-day workflow for managing your dotfiles.

## Naming conventions

Chezmoi uses prefixes to control how files are applied:

- `dot_zshrc` → `~/.zshrc`
- `private_dot_ssh/` → `~/.ssh/` (mode 0600/0700)
- `dot_gitconfig.tmpl` → `~/.gitconfig` (rendered with user data first)
- `dot_config/` → `~/.config/`
- `create_filename` → creates file only if it doesn't exist (won't overwrite)

Templates (`.tmpl` suffix) are rendered before apply. Reference user data with `{{ .git_name }}` or `{{ .kits.devtools }}`. Values come from `.chezmoi.toml` prompts.

## Quick start

Edit a file in this directory, then apply:

```bash
chezmoi apply
```

Preview changes first with `chezmoi diff`. That's it.

Templates get rendered with your personal data (name, email, preferences). Everything else is copied as-is. The repo stays generic, your machine gets your config.

## Daily workflow

This repo is designed for the **direct git workflow**:

1. **Edit** – Modify files in `home/` directly in your IDE
2. **Preview** – Run `chezmoi diff` to see what will change
3. **Apply** – Run `chezmoi apply` to sync changes to `$HOME`
4. **Commit** – Use git to commit and push your changes

Alternatively, use `chezmoi edit <file>` to work in chezmoi's managed source directory. Both approaches work — choose what fits your muscle memory.

## Common tasks

### Adding a new dotfile

Drop it in `home/` with the appropriate prefix:

```bash
# Static file
touch home/dot_vimrc

# Templated file (uses data from .chezmoi.toml)
touch home/dot_gitconfig.tmpl
```

Then `chezmoi apply` to sync.

### Making a file private

Rename with `private_` prefix:

```bash
mv home/dot_ssh home/private_dot_ssh
```

Chezmoi will set permissions to 0600 (files) or 0700 (directories).

### Templating a value

Edit the `.tmpl` file and reference data from `.chezmoi.toml`:

```bash
# In home/dot_gitconfig.tmpl
[user]
  name = {{ .git_name }}
  email = {{ .git_email }}
```

### Adding a shell alias

Edit `home/dot_config/shell/aliases.zsh` (or create a new file and source it from `dot_zshrc`).

### Platform-specific config

Use chezmoi conditionals in `.tmpl` files:

```bash
{{- if eq .chezmoi.os "darwin" }}
# macOS only
{{- end }}

{{- if eq .chezmoi.os "linux" }}
# Linux only
{{- end }}
```

Or use `.chezmoiignore` to exclude entire files/directories from being copied to `$HOME` on certain platforms. Note that `.chezmoiignore` only affects files copied to your home directory - it does NOT prevent scripts in `.chezmoiscripts/` from running. Scripts handle OS filtering internally.

## What belongs here

Shell configs, editor preferences, SSH templates, XDG directories. User-level config you'd edit by hand and want versioned.

## What doesn't

Install scripts, Brewfiles, system setup. Those live in `.chezmoiscripts/` or outside chezmoi entirely.
