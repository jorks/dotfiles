# `.cursor/rules.md` Cursor Rules – Dotfiles Repository

These rules define **hard constraints** for working in this repository.
They are enforceable expectations, not suggestions.

If a change violates these rules, it is incorrect.

This repository also contains an `AI_CONTEXT.md`.
Read it before making structural or architectural changes.

---

## Core Principles

- Chezmoi is the **only orchestration framework**
- Prefer chezmoi-native features over custom logic
- Everything must be **safe to re-run**
- Optimise for clarity and durability over cleverness
- macOS-first, Linux second

Do not introduce parallel systems or custom managers.

---

## Source Root & Structure (Authoritative)

- `home/` is the **chezmoi source root**
- Files under `home/` map directly to `$HOME`
- Chezmoi special files (`.chezmoi*`) MUST live in `home/`
- Except `.chezmoiroot` which MUST live in the project root

Canonical structure:

```

home/
├── .chezmoi.toml.tmpl
├── .chezmoiscripts/
├── _lib/
├── dot**
└── dot_config/

```

Do not invent new top-level structures without updating documentation.

---

## Script Lifecycle Rules

All executable logic MUST live in:

```
home/.chezmoiscripts/
```

Rules:

- Scripts execute in **lexicographic order**
- Scripts MUST be executable
- Templated scripts MUST use `.sh.tmpl`

Prefix semantics:

- `run_once_`  
  - Runs once per machine  
  - Editing the script does NOT rerun it  
- `run_onchange_`  
  - Reruns when content or declared dependencies change  
- No prefix  
  - Runs on every apply (rare, usually incorrect)

Use `run_onchange_` for scripts that should react to configuration updates.

---

## Script Libraries (`_lib/`)

- Shared functions MUST live in `home/_lib/`
- `_lib/` is source-only and MUST NOT be applied to `$HOME`
- `_lib/` MUST be excluded via `.chezmoiignore`

Never:
- Place libraries inside `.chezmoiscripts/`
- Place libraries at repo root
- Apply `_lib/` to `$HOME`

Scripts may source libraries using:

```sh
# shellcheck source=../../_lib/log.sh
. "{{ .chezmoi.sourceDir }}/_lib/filename.sh"
```

---

## Kit Brewfile Standards

All kit Brewfiles MUST follow this structure.

### Header

Every Brewfile MUST begin with a descriptive header:

```ruby
# <Kit Name> Kit
#
# <One-line description of the kit's purpose>
# <Optional: Use case or who should enable this kit>
```

### Section Organization

Packages MUST be grouped by category with section comments:

```ruby
# ===================================================================
# <Category Name>
# ===================================================================
```

### Package Format

All package declarations MUST use aligned inline comments (column 40):

```ruby
brew "package-name"                    # Brief description
cask "app-name"                        # Brief description
mas "App Name", id: 123456789          # Brief description
```

### Ordering

Within each section, packages MUST be listed in **alphabetical order** by package name.

### Mac App Store Apps

When a kit includes Mac App Store apps:

1. Include `brew "mas"` at the top of the Brewfile (in a Dependencies section)
2. Use the `mas` directive with app name and ID
3. App IDs can be found via `mas search <name>` or App Store URLs

### Complete Example

```ruby
# Productivity Kit
#
# Browsers, communication, task management, and writing tools.
# Use case: Personal and work laptops.

# ===================================================================
# Dependencies
# ===================================================================

brew "mas"                             # Mac App Store CLI

# ===================================================================
# Browsers
# ===================================================================

cask "firefox"                         # Mozilla browser
cask "google-chrome"                   # Google browser
cask "microsoft-edge"                  # Microsoft browser

# ===================================================================
# Communication
# ===================================================================

cask "slack"                           # Team messaging
cask "zoom"                            # Video conferencing

# ===================================================================
# Mac App Store
# ===================================================================

mas "Amphetamine", id: 937984704       # Prevent sleep
mas "Things 3", id: 904280696          # Task manager
```

---

## Kit setup.sh.tmpl Standards

Optional `setup.sh.tmpl` scripts MUST follow the standard script header format,
source shared libraries, and include documentation for apps not available via Homebrew.

### File Naming

Kit setup scripts MUST use the `.tmpl` extension to enable chezmoi templating:

```
home/dot_config/kits/<kit-name>/setup.sh.tmpl
```

### Purpose

Use `setup.sh.tmpl` ONLY for:

- Post-install configuration that cannot be declarative
- Documenting apps that must be installed manually

### Shared Libraries

Kit scripts MUST source shared libraries from `_lib/` for logging and utilities:

```bash
# shellcheck source=../../../_lib/log.sh
. "{{ .chezmoi.sourceDir }}/_lib/log.sh"
```

This ensures consistent logging output across all scripts.

### Header Format

```bash
#!/usr/bin/env bash
set -eu

# -------------------------------------------------------------------
# PURPOSE:
# Post-install configuration for <kit-name> kit
#
# SCOPE:
# - Runs on: macOS
# - Lifecycle: runs after Brewfile is applied
#
# BEHAVIOUR:
# - Idempotent (safe to re-run)
# - Documents manual installation requirements
#
# NOTES:
# - Apps not in Homebrew are documented below for manual install
# -------------------------------------------------------------------

# shellcheck source=../../../_lib/log.sh
. "{{ .chezmoi.sourceDir }}/_lib/log.sh"
```

### Documenting Non-Brew Apps

Apps not available via Homebrew MUST be documented as commented blocks:

```bash
# -------------------------------------------------------------------
# MANUAL INSTALLS (not available via Homebrew)
# -------------------------------------------------------------------
#
# Jamf Admin
#   Download: https://www.jamf.com/resources/product-documentation/
#   Notes: Requires Jamf Pro subscription
#
# iMazing Profile Editor
#   Download: https://imazing.com/profile-editor
#   Notes: Free, no account required
#
# -------------------------------------------------------------------
```

---

## Templating & Configuration

- Use chezmoi templates (`{{ }}`), not shell substitution
- Prompted values MUST be defined in `.chezmoi.toml.tmpl`
- Use `promptStringOnce`, `promptBoolOnce`, etc.
- Persisted config lives in `~/.config/chezmoi/chezmoi.toml`
- Quote string values using `| quote`

Do not:

- Hardcode personal or machine-specific values
- Prompt ad-hoc inside scripts

---

## Platform Detection

- Use chezmoi-provided variables (`.chezmoi.os`)
- Do not implement custom OS detection frameworks
- Avoid `uname` unless templating cannot be used

---

## Script Style Requirements

All scripts MUST:

- Use bash (`#!/usr/bin/env sh`)
- Use `set -eu` unless explicitly justified
- Include a clear header describing purpose and rerun safety
- Use the standard section divider:

```
# -------------------------------------------------------------------
```

Scripts must assume partial state and be idempotent.

---

## Comment Header Standards

Consistency of file headers is mandatory.

### Script Files

All executable scripts MUST include a header comment immediately
after the shebang and shell options.

The header MUST follow this structure:

```
# -------------------------------------------------------------------
# PURPOSE:
# <One-line summary>
#
# SCOPE:
# - Runs on: <macOS | Linux | both>
# - Lifecycle: <run_once | run_onchange | always>
#
# BEHAVIOUR:
# - <Idempotency guarantees>
# - <User interaction or side effects>
#
# NOTES:
# - <Context or caveats>
# -------------------------------------------------------------------

```

Scripts without this header are considered incomplete.

---

### Dotfiles & Config Files

Non-executable configuration files SHOULD include a descriptive
header explaining intent and scope.

Preferred format:

```
# <Title>
#
# PURPOSE
# -------
# <What this file controls and why it exists>
#
# Goals:
# - <Design goal>
# - <Design goal>
```

Avoid inline commentary when a header can explain intent once.

---

## Documentation Requirements

If a change:

- alters structure
- introduces a new pattern
- changes lifecycle behaviour

Then documentation MUST be updated in the same change.

---

## Review Contract

When modifying this repository:

- Check for consistency with existing patterns
- Flag structural mismatches explicitly
- Highlight idempotency risks
- Call out missing documentation updates

Prefer boring, proven solutions.
