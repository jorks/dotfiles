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

This assumes your dotfiles repo is named `dotfiles`.

This installs chezmoi, clones your repo, and prompts for what you want installed. Five minutes from bare metal to a working shell with your config, your tools, your preferences.

First run prompts for identity (name, email) and which capability kits to enable (dev tools, productivity apps, security utilities, etc.). Answers are stored locally, never committed. The repo stays generic.

After that, everything runs through `chezmoi apply`. Edit dotfiles, apply, done.

## What you get

- **Platform bootstrap** – Homebrew, XCode CLT, base CLI tools installed automatically
- **Capability kits** – Opt-in bundles for dev tools, productivity apps, security utilities
- **Dotfile management** – Shell configs, git settings, SSH keys, all templated per-machine
- **Lifecycle automation** – Package lists in Brewfiles, managed by chezmoi
- **Cross-platform** – macOS first-class, Linux supported for servers

## Why you should fork this

The structure is deliberately constrained. Dotfiles in `home/`, scripts in `home/.chezmoiscripts/`, packages in Brewfiles. Fork it, rip out my zsh setup, drop in your fish config, adjust the kits. The structure stays, your preferences slot in.

See [STRUCTURE.md](STRUCTURE.md) for architecture details and customization guide.

## Documentation

- [**STRUCTURE.md**](STRUCTURE.md) – Architecture, customization, and design principles
- [**docs/dotfiles.md**](docs/dotfiles.md) – Working with dotfiles day-to-day
- [**docs/scripts.md**](docs/scripts.md) – Lifecycle scripts and bootstrap logic
- [**docs/kits.md**](docs/kits.md) – Managing capability kits

## License

MIT. See [LICENSE.md](LICENSE.md). Use it, fork it, make it yours.
