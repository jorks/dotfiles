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
