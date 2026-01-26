# dotfiles

A production-ready dotfiles setup built entirely on chezmoi. Fast, rerunnable, forkable.

**Here's the idea:** Your computer should feel like *yours* within minutes of unboxing. No manual setup. No "I'll configure that later." No copying commands from a three-year-old Gist you can't quite remember writing.

This repo does platform bootstrap, package management, dotfile templating, and lifecycle automation through one framework: [chezmoi](https://www.chezmoi.io/). No custom orchestration. No parallel systems. Just a really well-considered implementation of what chezmoi already does.

It's opinionated about *how* things are organized, but generic about *what* gets installed. Fork it, rip out my shell config, drop in yours, and you're done. That's the whole point.

> **Real talk:** I spent way too long building custom dotfile frameworks before I actually read the chezmoi docs. Turns out 90% of what I needed was already there. This repo is what I wish I'd started with - chezmoi used properly, with just enough structure to stay sane six months later.

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

This is built entirely around [chezmoi](https://www.chezmoi.io/). No parallel framework, no custom orchestration. Chezmoi handles dotfiles, templates, and lifecycle scripts. Everything else is just data.

**Platform bootstrap** – Fresh Mac? This installs Homebrew, XCode CLT, and base CLI tools automatically. Linux server? Gets the apt equivalents. You answer a few prompts on first run, then never think about it again.

**Capability kits** – Dev laptop gets Docker and language runtimes. Personal machine skips them. Work laptop gets VPN tools. Home desktop doesn't. One repo, different machines, zero manual setup.

**Dotfile management** – Your shell config, git settings, SSH keys, editor preferences. All templated so "Josh's MacBook Pro" and "josh-dev-server" get the right values without you editing files per-machine.

**Lifecycle automation** – Package lists live in Brewfiles. Change a Brewfile, run `chezmoi apply`, packages install. Everything's in version control, so you know exactly what's installed and where it came from.

**Cross-platform** – macOS first-class, Linux supported for servers. Platform-specific logic is isolated and explicit. No giant if/else pyramids.

## Why you should fork this

The structure is deliberately constrained. Dotfiles go in `home/`. Lifecycle scripts go in `.chezmoiscripts/`. Packages go in Brewfiles. If it doesn't fit one of those categories, rethink what you're adding.

This isn't my config anymore - it's a template. Your shell preferences, editor choices, and tool stack will differ. Fork it, rip out my zsh setup, drop in your fish config, adjust the kits, and you're done. The structure stays, your preferences slot in.

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

**Two workflow options:**
- **Option 1:** `chezmoi edit <file>` to edit in chezmoi's source, then commit and push from the source directory
- **Option 2:** Edit `home/` directly in your IDE, commit via git, then `chezmoi apply` to sync changes

Both work. Choose what fits your muscle memory.

See [home/README.md](home/README.md) for naming conventions and workflow.

## Kits: opt-in capability bundles

Your work laptop doesn't need the same tools as your home desktop. Kits let you install groups of related tools only where they make sense.

Each kit is just a Brewfile (list of packages) and optional `setup.sh` (for config that can't be declarative). Enable the ones you want during first run. The orchestrator applies them automatically.

**Available kits:**
- **devtools** – Docker, compilers, language runtimes. For machines where you write code.
- **productivity** – Browsers, communication apps, utilities. Personal laptops, not servers.
- **security** – VPNs, password managers. Work machines, not your homelab.
- **macadmin** – IT/sysadmin tooling for Mac management. Only if you're that kind of sysadmin.
- **fonts** – Design fonts and bonus coding fonts. Typography nerds only.

Adding a new kit? Create the Brewfile, add a prompt to `.chezmoi.toml.tmpl`, done. The orchestrator discovers it automatically.

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

## Troubleshooting

**Something looks wrong?** Run `chezmoi doctor` to check your setup.

**Script failed?** Chezmoi scripts are idempotent — safe to rerun. Fix the issue and `chezmoi apply` again.

**Want to see what changed?** Run `chezmoi diff` before applying to preview changes.

**Need to reset?** Your answers are in `~/.config/chezmoi/chezmoi.toml`. Delete it to start fresh on next apply.

## Documentation

- [**STRUCTURE.md**](STRUCTURE.md) – Repository layout and customization guide
- [**home/README.md**](home/README.md) – Dotfile naming conventions and workflow
- [**.chezmoiscripts/README.md**](.chezmoiscripts/README.md) – Lifecycle scripts explained

## License

MIT. See [LICENSE.md](LICENSE.md). Use it, fork it, make it yours.
