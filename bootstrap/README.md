# Bootstrap

Bootstrap establishes a minimal, usable baseline. The goal is to make a fresh machine capable without making it yours. This is intentionally boring.

## What gets installed

**macOS:** Xcode Command Line Tools, Homebrew, Oh My Zsh, chezmoi, and a core set of CLI tools that mirror the Linux package list (git, ripgrep, fzf, jq, bat, eza, fd, delta, neovim, btop, etc.). A handful of must-have GUI apps (Chrome, 1Password, Sublime, Raycast) and some macOS-specific utilities (watch, shellcheck, 1password-cli).

**Linux:** System essentials (ca-certificates, curl, wget, gnupg), the same core CLI tooling as macOS, zsh with Oh My Zsh, and chezmoi. Assumes Ubuntu. No desktop environment, no GUI apps.

Both converge on the same CLI experience. The intent is to jump between a macOS laptop and a Linux server without muscle memory drift.

## What doesn't get installed

Personal tools. Development environments. Security tooling. System configuration. macOS defaults. Anything you'd skip on a temporary machine or shared system.

If you're wondering whether something belongs in bootstrap, it doesn't. Put it in a kit.

## Safe to re-run

Bootstrap scripts are safe to re-run. They're designed for fresh installs, temporary VMs, and short-lived machines you don't fully control.

See `kits/` for everything else.
