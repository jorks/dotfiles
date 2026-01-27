# `.chezmoiscripts/`

Scripts in this directory run automatically during `chezmoi apply`. They're numbered for execution order. Chezmoi decides when to run them based on filename prefixes:

- `run_once_` – runs once per machine, tracked by content hash
- `run_onchange_` – reruns when the script or its dependencies change

This is where bootstrap, package installation, and system configuration happen. No manual script running. Everything is part of the apply lifecycle.

## Numbering scheme

Scripts are grouped into numbered directories to control execution order:

- `00-base/` – Platform bootstrap (Homebrew, XCode CLT, etc.)
- `10-packages/` – Base CLI tools
- `20-shell/` – Shell-specific setup
- `30-kits/` – Optional capability bundles
- `40-os-defaults/` – macOS system preferences
- `90-debug/` – Debug and diagnostic helpers

Lower numbers run first. Within a directory, scripts run alphabetically. This is why scripts have numeric prefixes like `00-preflight.sh`, `05-homebrew.sh` - it guarantees execution order even when the filesystem decides to be creative.

## `00-base/` – Platform bootstrap

One-time setup scripts that prepare a fresh machine. These run once and rarely need to change unless you're adding a new baseline dependency.

**`00-preflight.sh`** – Checks if we're on a supported OS. Exits early if not. Saves time and confusion.

**`01-macos-hostname.sh`** – Prompts for and sets macOS hostname if not already configured. This runs early because other scripts might reference it.

**`02-xdg-dirs.sh`** – Creates standard XDG directories (`~/.config`, `~/.local/bin`, etc.). Required before anything tries to write config there.

**`03-macos-xcode-clt.sh`** – Installs Xcode Command Line Tools on macOS. Git, compilers, headers - all the things Homebrew needs to function.

**`04-macos-rosetta.sh`** – Installs Rosetta 2 on Apple Silicon Macs. Some packages still need it. Runs once, stays out of the way.

**`05-macos-homebrew.sh`** – Installs Homebrew if not present. This is the foundation for everything else on macOS.

**`06-linux-apt-update.sh`** – Runs `apt update` on Debian/Ubuntu systems. Boring but necessary before installing packages.

**`07-linux-base-packages.sh`** – Installs essential packages on Linux via apt. Things like `curl`, `git`, `build-essential`.

These scripts are conservative and minimal. If it's not required for chezmoi or basic shell functionality, it doesn't belong here.

## `10-packages/` – Base CLI tools

Installs essential CLI packages via Homebrew (macOS) or apt (Linux). Things like `git`, `curl`, `jq`, `fzf`, `ripgrep` - tools you need regardless of your specialty.

Uses `run_onchange_` so the script reruns when the package list changes. Add a package to the list, rerun `chezmoi apply`, it gets installed. No manual intervention.

Platform-specific variants exist (`*-macos.sh`, `*-linux.sh`) because package managers differ. The logic is the same, the package names occasionally aren't.

**Note:** These use inline package installation loops rather than Brewfiles for immediate auto-install on first apply. See [STRUCTURE.md](../STRUCTURE.md#brewfiles) for rationale. Kits use proper Brewfiles.

## `20-shell/` – Shell setup

Installs oh-my-zsh and sets the default shell to zsh. This is opinionated - if you prefer fish, powerlevel10k, or something else, this is where you'd adapt it.

Most shell config lives in `home/dot_zshrc` and `home/dot_config/shell/` as dotfiles. This directory exists for setup that requires side effects: git clones, changing login shells, installing plugin managers. If you can do it with a dotfile, do it with a dotfile.

## `30-kits/` – Capability bundles

Orchestrates optional "kits" - groups of related tools you might not want on every machine. Dev tools, productivity apps, security utilities, macOS admin tooling.

**`30-apply-kits.sh`** – The kit orchestrator. Loops through enabled kits in `.chezmoi.toml`, applies their Brewfiles from `~/.config/kits/`, runs optional `setup.sh` scripts for post-install configuration.

Kits are defined in `home/dot_config/kits/<name>/`. Each kit is just a Brewfile (packages to install) and an optional `setup.sh` (config that can't be expressed declaratively). The orchestrator discovers and applies them automatically based on user config.

This keeps capability-based installation flexible without custom logic per kit. Brewfiles are data. The orchestrator is generic.

## `40-os-defaults/` – macOS system preferences

Sets macOS system defaults. Keyboard repeat rates, Dock behavior, Finder preferences, the usual suspects.

Uses `run_once_` because these settings rarely change and don't need to be reapplied constantly. Safe to rerun if needed.

macOS-only. Scripts check the OS at runtime and exit early if not on macOS.

## `90-debug/` – Diagnostics

Debug and diagnostic scripts that don't run automatically. Helpful when something breaks or you're troubleshooting a fresh machine.

These aren't part of the normal apply lifecycle. They're here for convenience when you need them.

## `_lib/` – Shared functions

Pure functions sourced by scripts in other directories. Not executable on their own.

**`log.sh`** – Logging wrappers with color and prefixes. `log_info`, `log_warn`, `log_error`, `log_success`.

**`brew.sh`** – Brewfile application logic. `apply_brewfile()` handles missing files, empty files, and errors gracefully.

**`checks.sh`** – Common checks like "is this macOS?", "is Homebrew installed?", etc.

Keeps script logic DRY. Scripts source what they need at the top: `. "{{ .chezmoi.sourceDir }}/_lib/log.sh"`.

## Writing new scripts

Keep them focused. One script, one job. If a script is doing three unrelated things, split it into three scripts.

Use the right prefix:
- `run_once_` for setup that happens once per machine
- `run_onchange_` for things that should reapply when config changes

Number them appropriately. If it depends on Homebrew, it goes after `05-macos-homebrew.sh`. If it installs packages, it probably belongs in `10-packages/` or a kit.

### OS-specific scripts

Template them (`.tmpl` suffix) if they need user data or platform conditionals. For OS-specific scripts, use this pattern:

```bash
#!/usr/bin/env sh
set -eu

# -------------------------------------------------------------------
# ... header comments ...
# -------------------------------------------------------------------

# shellcheck source=../../_lib/log.sh
. "{{ .chezmoi.sourceDir }}/_lib/log.sh"

{{- if ne .chezmoi.os "darwin" }}
log_info "Skipping: not running on macOS"
exit 0
{{- end }}

# ... rest of script ...
```

**Important:** The shebang (`#!/usr/bin/env sh`) MUST be on line 1. Template conditionals that appear before it will cause "exec format error". Always source libraries before OS checks so you can use log functions in skip messages.

**Note:** `.chezmoiignore` does NOT prevent script execution. Scripts in `.chezmoiscripts/` are always executed during `chezmoi apply`. OS filtering happens via the in-script checks shown above.

Source shared functions from `_lib/` rather than duplicating logic. Log what you're doing so users understand what's happening during apply.

## Notes on maintenance

This structure isn't sacred. Scripts will change over time as needs evolve. The numbering scheme might expand. New directories might appear. That's fine.

What matters: scripts stay focused, execution order is clear, and the lifecycle is handled by chezmoi. If you're tempted to write a custom orchestrator or bypass `chezmoi apply`, you're probably solving the wrong problem.
