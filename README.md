# dotfiles

A production-ready dotfiles setup built entirely on chezmoi. Fast, rerunnable, forkable.

This repo handles platform bootstrap, package management, dotfile templating, and lifecycle automation through a single framework. No custom orchestration. No parallel systems. Just chezmoi doing what it's designed to do.

It's opinionated about structure but generic about content. Fork it, swap in your preferences, and you're done. That's the design.

> **Lessons learned:**  Turns out I should have just read the chezmoi docs earlier. 90% of what I needed was already there. Don't reinvent what's built-in.

## Quick start

On a fresh macOS or Linux machine:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply <your-github-username>
```

Replace `<your-github-username>` with your GitHub username. This assumes your dotfiles repo is named `dotfiles`.

This installs chezmoi, clones your repo, and prompts for what you want installed. Five minutes from bare metal to a working shell with your config, your tools, your preferences.

First run prompts for identity (name, email) and which capability kits to enable (dev tools, productivity apps, security utilities, etc.). Answers are stored locally, never committed. The repo stays generic.

After that, everything runs through `chezmoi apply`. Edit dotfiles, apply, done.

## What you get

This is built entirely around chezmoi. No parallel framework, no custom orchestration. Chezmoi handles dotfiles, templates, and lifecycle scripts. Everything else is just data.

**Platform bootstrap** – Homebrew, XCode CLT, base CLI tools. Minimal and boring.

**Capability kits** – Opt-in bundles for dev tools, productivity apps, security utilities, macOS admin tooling. Enable what you need, skip the rest.

**Dotfile management** – Shell configs, git settings, SSH templates, editor preferences. All templated for machine-specific values (your name, your email, your hostname).

**Lifecycle automation** – Scripts run automatically during `chezmoi apply`. Platform setup happens once. Package lists reapply when changed. No manual intervention.

**Cross-platform** – macOS first-class, Linux supported for servers. Platform-specific logic is isolated and explicit.

## Why this exists (and why you should fork it)

Most dotfiles repos are either too personal to reuse or too generic to be useful. This sits in the middle: opinionated enough to be a foundation, generic enough to fork without major surgery.

I wanted something I could run on a new MacBook, a temporary EC2 instance, or a colleague's machine to pair-program. Something I could come back to six months later and understand immediately.

The structure is deliberately constrained. Dotfiles go in `home/`. Lifecycle scripts go in `.chezmoiscripts/`. Packages go in Brewfiles. If it doesn't fit one of those categories, rethink what you're adding.

This isn't my config anymore - it's a template. Your shell preferences, editor choices, and tool stack will differ. Fork it and make it yours. That's the intended workflow.

## How it's organized

```text
dotfiles/
├── home/                  # chezmoi source (maps to $HOME)
│   ├── dot_zshrc
│   ├── dot_gitconfig.tmpl
│   └── dot_config/
│       ├── shell/
│       └── kits/          # capability Brewfiles
│
└── .chezmoiscripts/       # lifecycle automation
    ├── 00-base/           # platform bootstrap
    ├── 10-packages/       # base CLI tools
    ├── 30-kits/           # kit orchestration
    └── _lib/              # shared functions
```

Dotfiles and config live in `home/`. Scripts that run during apply live in `.chezmoiscripts/`. Packages are declared in Brewfiles, not inline in scripts.

See [STRUCTURE.md](STRUCTURE.md) for expanded details.

## Templates and machine-specific config

User-specific values (name, email, preferences) are prompted for on first run. Answers are stored locally in `~/.config/chezmoi/chezmoi.toml` and never touch version control.

Templates reference these values: `{{ .git_name }}`, `{{ .kits.devtools }}`. The repo stays generic. Your machine gets your config.

Edit files in `home/`, run `chezmoi apply`, changes sync. No `chezmoi edit` workflow. Git is the primary interface.

See [home/README.md](home/README.md) for naming conventions and workflow.

## Kits: opt-in capability bundles

Kits are groups of related tools you might not want on every machine. Each kit is a Brewfile in `home/dot_config/kits/<name>/` and an optional `setup.sh` for post-install config.

Available kits:
- **devtools** – Docker, compilers, language runtimes, dev tools
- **productivity** – Browsers, communication apps, utilities
- **security** – VPNs, password managers, security tools
- **macadmin** – IT/sysadmin tooling for Mac management
- **fonts** – Design fonts and bonus coding fonts

Enable kits via prompts on first run. Add new kits by creating a Brewfile and adding a prompt to `.chezmoi.toml.tmpl`. The orchestrator handles the rest.

## Forking

Please fork this. Seriously.

This repo is a starting point. Your preferences will differ. When you fork:

- Fork this repo and rename it to `dotfiles` (or adjust the chezmoi init command)
- Edit `home/` to match your shell and editor preferences
- Customize kits to match your toolchain
- Add or remove platform-specific setup as needed

The structure is intentionally simple. Shell scripts, config files, Brewfiles. No build system, no framework magic. If you can read bash and understand chezmoi prefixes, you can modify this.

## Design notes

A few things I learned the hard way:

**Don't fight the framework.** Chezmoi has opinions about structure and lifecycle. Work with them, not around them. Custom orchestration outside chezmoi is a maintenance nightmare.

**Keep scripts focused.** One script, one job. If it's doing three things, split it into three scripts. Execution order is controlled by numbering and prefixes.

**Brewfiles are data, not logic.** No inline `brew install` in scripts. Scripts apply Brewfiles. Separation of concerns.

**Platform differences are explicit.** Separate files for macOS and Linux. No complex branching. Let chezmoi decide what to apply via conditionals and `.chezmoiignore`.

**Templates for values, dotfiles for config.** If it changes per machine (name, email), template it. If it's preference (shell aliases, editor settings), dotfile it.

## Documentation

- [**STRUCTURE.md**](STRUCTURE.md) – Repository layout and customization guide
- [**home/README.md**](home/README.md) – Dotfile naming conventions and workflow
- [**.chezmoiscripts/README.md**](.chezmoiscripts/README.md) – Lifecycle scripts explained

## License

MIT. See [LICENSE.md](LICENSE.md). Use it, fork it, make it yours.
