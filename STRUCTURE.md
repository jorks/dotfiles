# Repository Structure

This repo is organised around capability, not chronology. The structure is designed to be safe to re-run, scale without refactors, and remain understandable months later.

This document describes patterns and intent, not an exhaustive file listing. When adding files, follow the rules below rather than updating this document line-by-line.

## High-level layout

```text
dotfiles/
├── install.sh            # single entrypoint
├── .chezmoi.toml         # data prompts for templates
│
├── home/                 # chezmoi source (maps to $HOME)
│   ├── dot_zshrc
│   ├── dot_gitconfig.tmpl
│   ├── private_dot_ssh/
│   └── .config/
│       ├── shell/
│       ├── terminal/
│       ├── vim/
│       └── motd
│
├── bootstrap/            # minimal machine baseline
│   ├── macos/
│   │   ├── bootstrap_macos.sh
│   │   └── brew/Brewfile
│   └── linux/
│       └── bootstrap_linux.sh
│
├── kits/                 # opt-in capability bundles
│   ├── devtools.sh
│   ├── security.sh
│   ├── productivity.sh
│   ├── macadmin.sh
│   ├── macos_prefs.sh
│   └── brew/
│       ├── Brewfile.devtools
│       ├── Brewfile.security
│       ├── Brewfile.productivity
│       └── Brewfile.macadmin
│
└── scripts/lib/          # sourced helpers only
    ├── brew.sh
    ├── checks.sh
    └── logging.sh
```

## `home/` - user configuration

The only directory managed by chezmoi. Everything here maps into `$HOME` when applied.

Files are edited directly in the repo; chezmoi renders templates and applies. Human-edited config lives under `.config/` when possible. Legacy dotfiles stay as dotfiles when tools expect them there.

No install logic, no scripts that mutate the system. If it's config you edit by hand and want versioned, it belongs here. See [home/CHEZMOI.md](home/CHEZMOI.md) for workflow details.

## `bootstrap/` - minimal machine baseline

Bootstrap provides the smallest viable surface to make a machine capable. Safe to re-run, works on short-lived or shared machines, stays intentionally boring.

One minimal Brewfile per platform. No personal tools, no identity, no app configuration, no OS tweaks. If it feels optional, it doesn't belong here - put it in a kit instead.

## `kits/` - optional capability bundles

Opt-in, rerunnable bundles that add tools for a purpose. Each kit is independent. Kits may prompt or be opinionated. They usually map 1:1 to a Brewfile. No cross-kit orchestration.

Examples: dev tools, security tooling, productivity apps, macOS admin utilities, system preferences. If you might not want it on every machine, it belongs in a kit.

## Brewfiles

Brewfiles are declarative and define what gets installed. Scripts decide when. No inline `brew install` commands in shell scripts. No conditionals in Brewfiles - use separate files instead.

## `scripts/lib/` - sourced helpers

Shared helper functions meant to be sourced by other scripts. These are not executable entrypoints. Use `source scripts/lib/brew.sh` from executable scripts in `bootstrap/` or `kits/`.

## Adding new things

When adding something new, ask: is this baseline, optional tooling, or user config? Is it safe to re-run? Would I regret this on a temporary machine?

New tool group → new kit. New app config → `home/.config/<app>/`. New package → Brewfile, not inline script logic.

Avoid growing bootstrap scope, mixing install logic with dotfiles, or writing stateful scripts that can't be re-run safely.
