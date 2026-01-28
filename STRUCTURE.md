# Customizing This Repo

This is a chezmoi-first dotfiles setup. Everything runs through chezmoi's lifecycle. There's no parallel framework to learn.

Fork this, rip out what you don't need, and adapt it to your workflow. This document explains the architecture, where things live, and how to extend them.

## Repository layout

```text
dotfiles/
├── .chezmoiroot                 # source directory pointer (value: "home")
├── README.md                    # user-facing overview
├── STRUCTURE.md                 # this file - architecture & customization
├── LICENSE.md
│
├── docs/                        # centralized documentation
│   ├── dotfiles.md              # daily workflow, naming conventions
│   ├── scripts.md               # script lifecycle, numbering scheme
│   ├── kits.md                  # kit system overview, creating kits
│   ├── kits-devtools.md         # devtools kit package reference
│   └── kits-fonts.md            # fonts kit package reference
│
└── home/                        # chezmoi source root (maps to $HOME)
    ├── .chezmoi.toml.tmpl       # user prompts (name, email, enabled kits)
    ├── .chezmoiignore           # files excluded from apply
    │
    ├── _lib/                    # source-only script libraries (never applied)
    │   ├── log.sh               # logging helpers with color support
    │   ├── brew.sh              # Brewfile application functions
    │   └── checks.sh            # platform/existence predicates
    │
    ├── .chezmoiscripts/         # lifecycle automation
    │   ├── 00-base/             # platform bootstrap (Homebrew, XCode CLT)
    │   ├── 10-packages/         # base CLI tools
    │   ├── 20-shell/            # shell setup
    │   ├── 30-kits/             # kit orchestration
    │   ├── 40-os-defaults/      # macOS preferences
    │   └── 90-debug/            # diagnostics
    │
    ├── dot_zshrc
    ├── dot_gitconfig.tmpl
    ├── private_dot_ssh/
    │   └── config.tmpl
    └── dot_config/
        ├── shell/
        ├── terminal/
        ├── vim/
        └── kits/                # capability Brewfiles
            └── devtools/
                ├── Brewfile
                └── setup.sh     # optional post-install script
```

## How it's organized

### `.chezmoiroot` – source directory pointer

This file contains a single word: `home`. It tells chezmoi that the `home/` directory is the source root. All dotfiles in `home/` map to `$HOME` when you run `chezmoi apply`.

This is why all chezmoi special files (`.chezmoi.toml.tmpl`, `.chezmoiignore.tmpl`, `.chezmoiscripts/`) must live inside `home/`, not at the project root. Chezmoi looks for these files relative to the source root.

### `home/` – dotfiles and user config

Everything here maps into `$HOME` when you run `chezmoi apply`. Dotfiles at the top level, structured config in `dot_config/` when tools support XDG.

Templates (`.tmpl` suffix) are rendered with data from `.chezmoi.toml` before being applied. This keeps personal values out of version control.

The `kits/` subdirectory is where capability Brewfiles live. They're applied to `~/.config/kits/` and consumed by `.chezmoiscripts/30-kits/` during apply. Optional `setup.sh` scripts handle post-install configuration that can't be expressed in a Brewfile.

### `home/_lib/` – source-only script libraries

Shared shell functions used by scripts in `.chezmoiscripts/`. These files are **never applied to `$HOME`** — they exist only in the chezmoi source directory (`~/.local/share/chezmoi/home/_lib/`).

Scripts source these libraries during execution using `{{ .chezmoi.sourceDir }}/_lib/log.sh`, making them available at script runtime without polluting your home directory.

**Available libraries:**
- `log.sh` – Logging with color output and file logging to `~/.local/state/chezmoi/apply.log`
- `brew.sh` – Homebrew PATH setup and Brewfile application
- `checks.sh` – Platform and tool existence predicates

**Why not in `.chezmoiscripts/_lib/`?** Chezmoi executes everything in `.chezmoiscripts/` as scripts. Non-executable files (like sourced libraries) cause "not a script" errors. Libraries must live outside `.chezmoiscripts/` as source-only infrastructure.

The `_lib/` directory is explicitly listed in `.chezmoiignore` to prevent application to target.

### `home/.chezmoiscripts/` – lifecycle automation

Scripts run automatically during `chezmoi apply`, numbered for execution order. Prefixes determine behavior:

- `run_once_` – runs once per machine
- `run_onchange_` – reruns when script content or dependencies change

**Directory structure:**

- `00-base/` – Platform bootstrap (Homebrew, XCode CLT, XDG directories)
- `10-packages/` – Base CLI tools
- `20-shell/` – Shell-specific setup
- `30-kits/` – Kit orchestration
- `40-os-defaults/` – macOS system preferences
- `90-debug/` – Diagnostic scripts

See [docs/scripts.md](docs/scripts.md) for detailed script documentation and how to add new scripts.

### `docs/` – centralized documentation

Documentation moved out of implementation directories to keep the source tree clean. Each file documents a specific subsystem:

- [docs/dotfiles.md](docs/dotfiles.md) – Daily workflow, naming conventions, common tasks
- [docs/scripts.md](docs/scripts.md) – Script lifecycle, numbering scheme, directory purposes
- [docs/kits.md](docs/kits.md) – Kit system overview, available kits, creating new kits
- [docs/kits-devtools.md](docs/kits-devtools.md) – Devtools kit package list
- [docs/kits-fonts.md](docs/kits-fonts.md) – Fonts kit package list

## Templates and data

User-specific values (name, email, preferences) are defined in `home/.chezmoi.toml.tmpl`. On first apply, chezmoi prompts once. Answers live in `~/.config/chezmoi/chezmoi.toml` locally and never touch version control.

Templates reference these values: `{{ .git_name }}`, `{{ .kits.devtools }}`. No defaults for identity, sensible defaults for preferences.

### Workflow options

**Option 1: chezmoi edit workflow**  
Use `chezmoi edit <file>` to edit in chezmoi's source directory (typically `~/.local/share/chezmoi`). Commit and push from there. Chezmoi manages the apply automatically.

**Option 2: Direct git workflow** (my preference)  
Edit `home/` directly in your IDE, commit via git, then run `chezmoi apply` to sync changes. This repo is designed for this pattern - the source is version-controlled, not hidden.

Both work. Choose what fits your muscle memory.

## Platform differences

Handled via in-script OS checks. macOS-only scripts check the OS at runtime and exit early if not appropriate. Linux equivalents exist where needed.

Separate files for separate platforms. No branching logic within scripts - early exit on OS mismatch.

## Brewfiles

All package installation goes through Brewfiles. No inline `brew install` in scripts. Scripts apply Brewfiles, they don't make installation decisions.

**Exception:** Base CLI packages (`10-packages/`) use inline installation loops for auto-install on first apply. This is intentional - these foundational tools need to install immediately without manual Brewfile management. Kits use proper Brewfiles.

No conditionals inside Brewfiles - use separate files instead.

## Kits system

Your work laptop doesn't need the same tools as your home desktop. Kits let you install groups of related tools only where they make sense.

Each kit is a Brewfile (packages to install) and optional `setup.sh` (post-install config that can't be declarative). They live in `home/dot_config/kits/<name>/` and are applied to `~/.config/kits/` by chezmoi.

### How kits work

1. **Enable during first run** – `home/.chezmoi.toml.tmpl` prompts which kits you want
2. **Kits are applied** – The `30-apply-kits.sh` orchestrator loops through enabled kits in your config
3. **Brewfiles install packages** – Each kit's Brewfile gets applied via `brew bundle`
4. **Optional setup runs** – If a `setup.sh` exists, it runs for kit-specific configuration

### Available kits

- **devtools** – Docker, compilers, language runtimes. For machines where you write code.
- **productivity** – Browsers, communication apps, utilities. Personal laptops, not servers.
- **security** – VPNs, password managers. Work machines, not your homelab.
- **macadmin** – IT/sysadmin tooling for Mac management. Only if you're that kind of sysadmin.
- **fonts** – Design fonts and bonus coding fonts. Typography nerds only.

See [docs/kits.md](docs/kits.md) for details on individual kits and how to create new ones.

## Design principles

A few architectural rules that make this system work:

**Don't fight the framework.** Chezmoi has opinions about structure and lifecycle. Work with them, not around them. Custom orchestration outside chezmoi is a maintenance nightmare.

**Keep scripts focused.** One script, one job. If it's doing three things, split it into three scripts. Execution order is controlled by numbering and prefixes.

**Brewfiles are data, not logic.** No inline `brew install` in scripts (except base packages for auto-install). Scripts apply Brewfiles. Separation of concerns.

**Platform differences are explicit.** Separate files for macOS and Linux. No complex branching. Let chezmoi decide what to apply via conditionals and `.chezmoiignore`.

**Templates for values, dotfiles for config.** If it changes per machine (name, email), template it. If it's preference (shell aliases, editor settings), dotfile it.

## Troubleshooting

**Something looks wrong?**  
Run `chezmoi doctor` to check your setup.

**Want to see what ran?**  
Check the log file at `~/.local/state/chezmoi/apply.log`. All script output is logged with timestamps.

**Script failed?**  
Chezmoi scripts are idempotent — safe to rerun. Fix the issue and `chezmoi apply` again.

**Want to see what changed?**  
Run `chezmoi diff` before applying to preview changes.

**Need to reset?**  
Your answers are in `~/.config/chezmoi/chezmoi.toml`. Delete it to start fresh on next apply.

**Package won't install?**  
Check the Brewfile syntax. Run `brew bundle --file=<path>` manually to see the error.

**Script won't trigger?**  
`run_once_` scripts track via hash. Delete `~/.local/share/chezmoi/.chezmoiscripts/.run-once-*` to force a rerun. `run_onchange_` scripts rerun when content changes — check the hash comment at the top.

## Adding new things

**New dotfile** → Drop it in `home/` with the appropriate prefix (`dot_`, `private_`, `create_`, `.tmpl`).

**New kit** → Create `home/dot_config/kits/<name>/Brewfile`, add prompt to `home/.chezmoi.toml.tmpl`. The orchestrator handles the rest. Add optional `setup.sh` for post-install config.

**New platform setup** → Add `run_once_` script to `home/.chezmoiscripts/00-base/` with platform guard.

**New base package** → Edit the package list in `home/.chezmoiscripts/10-packages/` scripts (inline installation for immediate auto-install).

Everything fits into one of a few categories. If it doesn't, rethink what you're adding.
