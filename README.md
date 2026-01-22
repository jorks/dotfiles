# dotfiles

This is a minimal, opinionated dotfiles setup designed for fast, repeatable environment bootstrapping. It's built for macOS primarily, with lean Linux support for server environments.

The goal is simple: get from a fresh machine to a productive shell in under five minutes, without waiting for every GUI app you might eventually want. Bootstrap installs the essentials. Optional kits layer on tooling when you need it.

I use this across fresh installs, temporary machines, and remote servers. It's designed to be forked, adapted, and made your own.

## Quick start

On a fresh macOS or Linux machine:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/jorks/dotfiles/main/install.sh)
```

This will:

- Install Homebrew (macOS) or ensure core utilities are present (Linux)
- Install and configure chezmoi
- Apply your dotfiles from `home/`
- Leave you with a working shell

*(What's chezmoi? [It's a dotfile manager](https://www.chezmoi.io/). Think of it as a templating engine for your home directory.)*

That's it. No apps, no bloat - just the foundation.

If you want dev tools, productivity apps, or security utilities, run the optional kits afterward:

```bash
./kits/devtools.sh
./kits/productivity.sh
./kits/security.sh
```

See `kits/README.md` for what each kit includes.

## Why this exists

Most dotfiles repos are either too personal (full of hardcoded usernames and opaque scripts) or too generic (a pile of config files with no install story). This repo sits in between.

I wanted something I could run on:

- A new MacBook straight out of the box
- A temporary EC2 instance
- A colleague's machine to pair on
- My own setup, six months later, when I've forgotten how it works

The bootstrap is intentionally boring. It installs chezmoi, applies your dotfiles, and gets out of the way. Everything else is opt-in. (Well, almost everything, I've bundled in a few apps I can't work without: Chrome, 1Password, Sublime Text, and Raycast. You do you.)

## Design principles

### Bootstrap does the minimum

`install.sh` and the platform-specific bootstrap scripts (`bootstrap/macos/`, `bootstrap/linux/`) install only what's required for a working shell and chezmoi. On macOS, that's Homebrew and a small set of formulae. On Linux, even less - usually just chezmoi itself.

This means the initial install is fast and predictable. You're not waiting for Docker or Node.js or a dozen other things you might not need right now.

### Kits are optional and composable

Once the bootstrap is done, you can run "kits" to install groups of related tools:

- `devtools.sh` – compilers, language runtimes, Docker, etc.
- `productivity.sh` – browsers, communication apps, utilities
- `security.sh` – VPNs, password managers, security tools
- `macadmin.sh` – IT/sysadmin tooling for Mac management

Kits are just shell scripts that call Homebrew (or other installers) in a structured way. They're safe to run multiple times. You can edit them, skip them, or write your own.

### Linux support is intentionally minimal

This repo targets server Linux, not desktop Linux. The Linux bootstrap skips GUI apps and focuses on shell utilities, chezmoi, and SSH config. If you're running a desktop Linux environment, you'll want to fork this and expand the bootstrap to match your needs.

### Chezmoi is an apply engine, not an edit workflow

The `home/` directory is the chezmoi source directory. When you run the install, chezmoi applies those files to your home directory. That's it.

I don't use `chezmoi edit`. I edit files in `home/` directly, then run `chezmoi apply` to sync changes. This keeps the workflow simple and version-control-friendly.

Templates (`.tmpl` files) let you handle differences across machines: usernames, email addresses, SSH hosts - without hardcoding anything. See `home/CHEZMOI.md` for how this works.

### No secrets, no personal data

This repo contains no usernames, email addresses, API keys, or personal information. Anything machine-specific is templated and sourced from chezmoi's encrypted data or interactive prompts.

That makes it safe to publish, easy to share, and trivial to fork.

## Forking this

You should fork this.

This repo is a starting point, not a prescription. Your shell preferences, editor config, and tool choices are different from mine. Fork it, rip out what you don't need, and adapt it to your workflow.

A few things to check when you fork:

- Update the install URL in this README
- Edit `home/` to reflect your preferred shell config
- Customise the kits in `kits/` to match your toolchain
- Adjust bootstrap scripts if you have different baseline requirements

The structure is intentionally simple. Everything is a shell script or a config file. No build system, no framework, no magic.

## Documentation

- [**STRUCTURE.md**](STRUCTURE.md) – How this repo is organised and where things live
- [**home/README.md**](home/README.md) – What's in the dotfiles directory and how to modify it
- [**home/CHEZMOI.md**](home/CHEZMOI.md) – How chezmoi is used, templates, and data sourcing
- [**kits/README.md**](kits/README.md) – What each kit installs and how to run them

## License

MIT. See [LICENSE.md](LICENSE.md).
