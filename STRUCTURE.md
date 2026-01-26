# Customizing This Repo

This is a chezmoi-first dotfiles setup. Everything runs through chezmoi's lifecycle. There's no parallel framework to learn.

Fork this, rip out what you don't need, and adapt it to your workflow. This document explains where things live and how to extend them.

## Repository layout

```text
dotfiles/
├── .chezmoi.toml.tmpl           # user prompts (name, email, enabled kits)
├── .chezmoiignore.tmpl          # files excluded from apply
├── .chezmoiroot                 # source directory pointer
│
├── home/                        # chezmoi source (maps to $HOME)
│   ├── dot_zshrc
│   ├── dot_gitconfig.tmpl
│   ├── private_dot_ssh/
│   │   └── config.tmpl
│   └── dot_config/
│       ├── shell/
│       ├── terminal/
│       ├── vim/
│       └── kits/                # capability Brewfiles
│           └── devtools/
│               ├── Brewfile
│               └── setup.sh     # optional post-install script
│
└── .chezmoiscripts/             # lifecycle automation
    ├── 00-base/                 # platform bootstrap (Homebrew, XCode CLT)
    ├── 10-packages/             # base CLI tools
    ├── 20-shell/                # shell setup
    ├── 30-kits/                 # kit orchestration
    ├── 40-os-defaults/          # macOS preferences
    └── _lib/                    # shared functions
```

## How it's organized

### `home/` – dotfiles and user config

Everything here maps into `$HOME` when you run `chezmoi apply`. Dotfiles at the top level, structured config in `dot_config/` when tools support XDG.

Templates (`.tmpl` suffix) are rendered with data from `.chezmoi.toml` before being applied. This keeps personal values out of version control.

The `kits/` subdirectory is where capability Brewfiles live. They're applied to `~/.config/kits/` and consumed by `.chezmoiscripts/30-kits/` during apply. Optional `setup.sh` scripts handle post-install configuration that can't be expressed in a Brewfile.

### `.chezmoiscripts/` – lifecycle automation

Scripts run automatically during `chezmoi apply`, numbered for execution order. Prefixes determine behavior:

- `run_once_` – runs once per machine
- `run_onchange_` – reruns when script content or dependencies change

**`00-base/`** – One-time platform setup. Homebrew, XCode CLT, XDG directories. Minimal and boring.

**`10-packages/`** – Base CLI tools via Homebrew or apt. Things like `git`, `curl`, `jq`, `fzf`.

**`20-shell/`** – Shell-specific setup. Minimal, mostly handled via dotfiles instead.

**`30-kits/`** – Orchestrates optional capability bundles. Loops through enabled kits in `.chezmoi.toml`, applies their Brewfiles, runs optional `setup.sh` scripts.

**`40-os-defaults/`** – macOS system preferences. Runs once, safe to rerun.

**`_lib/`** – Shared functions sourced by other scripts. Logging, Brewfile helpers, error handling.

## Templates and data

User-specific values (name, email, preferences) are defined in `.chezmoi.toml.tmpl`. On first apply, chezmoi prompts once. Answers live in `~/.config/chezmoi/chezmoi.toml` locally and never touch version control.

Templates reference these values: `{{ .git_name }}`, `{{ .kits.devtools }}`. No defaults for identity, sensible defaults for preferences.

## Platform differences

Handled via chezmoi conditionals and `.chezmoiignore`. macOS-only scripts use platform guards (`{{- if eq .chezmoi.os "darwin" }}`). Linux equivalents exist where needed.

Separate files for separate platforms. No branching logic. Let chezmoi decide what applies.

## Brewfiles

All package installation goes through Brewfiles. No inline `brew install` in scripts. Scripts apply Brewfiles, they don't make installation decisions.

**Exception:** Base CLI packages (`10-packages/`) use inline installation loops for auto-install on first apply. This is intentional - these foundational tools need to install immediately without manual Brewfile management. Kits use proper Brewfiles.

No conditionals inside Brewfiles - use separate files instead.

## Adding new things

**New dotfile** → Drop it in `home/` with the appropriate prefix (`dot_`, `private_`, `.tmpl`).

**New kit** → Create `home/dot_config/kits/<name>/Brewfile`, add prompt to `.chezmoi.toml.tmpl`. The orchestrator handles the rest. Add optional `setup.sh` for post-install config.

**New platform setup** → Add `run_once_` script to `.chezmoiscripts/00-base/` with platform guard.

**New base package** → Edit the Brewfile content in `.chezmoiscripts/10-packages/`.

Everything fits into one of a few categories. If it doesn't, rethink what you're adding.
