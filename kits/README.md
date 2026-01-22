# Kits

**WIP** - Logic not yet implemented. This describes intent.

Opt-in capability bundles for tooling that doesn't belong in bootstrap. Run manually after bootstrap. Safe to re-run, safe to skip.

Bootstrap gets you online. Kits make the machine useful for actual work.

## How they work

Each kit is a shell script (`kits/<name>.sh`) that orchestrates a Brewfile (`kits/brew/Brewfile.<name>`). Sources helpers from `scripts/lib/` for consistency. Independent unless stated otherwise.

**devtools** - Runtimes, containers, databases, version managers.  
**security** - VPN, network tools, credential utilities.  
**productivity** - Communication, notes, window managers.  
**macadmin** - MDM, diagnostics, disk management.  
**macos_prefs** - System defaults, Dock, Finder, keyboard.

## What belongs here

Optional tools. Role-specific apps. Anything you'd skip on a temporary machine. If it's opinionated or might slow down bootstrap, it's a kit.

Baseline tools belong in bootstrap. Config files belong in `home/`.

## Adding a kit

Create `kits/<name>.sh` and `kits/brew/Brewfile.<name>`. Keep it idempotent. Ask: would I want this on every machine? If no, it's a kit.
