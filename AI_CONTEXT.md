# `AI_CONTEXT.md` AI Context – Dotfiles Repository

This document explains **intent, architecture, and constraints**
for AI assistants working in this repository.

It is explanatory, not enforceable.
When in conflict, `.cursor/rules.md` takes precedence.

---

## Purpose & Philosophy

This repository is a production-grade dotfiles setup built entirely on **chezmoi**.

It exists to make a new machine feel “done” within minutes:
- repeatable
- rerunnable
- forkable
- boring in the best possible way

This is **not** a collection of scripts with chezmoi added later.
Chezmoi *is* the framework.

The value of this repo is in **structure and lifecycle discipline**, not custom tooling.

---

## What This Repo Is Not

- Not a custom dotfile manager
- Not a shell framework
- Not locked to specific tools
- Not designed for manual setup

If something can be done using chezmoi features, that is preferred.

---

## Architecture Overview

### Source Root Model

The repo uses a `.chezmoiroot` file so that:

```

home/

```

is the chezmoi **source root**.

This means:
- All applied files live under `home/`
- All chezmoi special files must live under `home/`
- The repo root is for visibility and documentation only

This separation is intentional and non-negotiable.

---

## File Categories

There are three distinct categories of files:

1. **Applied dotfiles**  
   - `home/dot_*` → `$HOME/.*`

2. **Lifecycle scripts**  
   - `home/.chezmoiscripts/`  
   - Executed during `chezmoi apply`

3. **Source-only libraries**  
   - `home/_lib/`  
   - Shared helpers, never applied

Each category has different behaviour and constraints.

---

## Script Execution Model

Scripts run via chezmoi’s lifecycle, not manual orchestration.

Key points:
- Execution order is lexicographic
- Directories provide coarse grouping
- Prefixes control lifecycle semantics

Important distinction:

- `run_once_` is **write-once**
- `run_onchange_` is **reactive**

A common mistake is using `run_once_` for scripts that should update.
This repo explicitly avoids that.

---

## Kit System Design

Kits are **opt-in capability bundles**, not feature flags.

Structure:

```

home/dot_config/kits/<kit-name>/
├── Brewfile.formula   # formulae + mas (strict), optional
├── Brewfile.casks    # casks (best-effort), optional
└── setup.sh (optional)

```

Characteristics:
- Declarative first (Brewfile.formula / Brewfile.casks)
- Imperative only when necessary (`setup.sh`)
- Auto-discovered by the orchestrator
- Enabled via prompts stored in local chezmoi config

Kits are designed to be:
- easy to add
- easy to remove
- easy to fork

---

## Template Data Flow

Personalisation follows a strict flow:

1. Prompts defined in `.chezmoi.toml.tmpl`
2. Values persisted in `~/.config/chezmoi/chezmoi.toml`
3. Templates consume values via `.data` keys

This avoids:
- environment variable drift
- ad-hoc prompting
- machine-specific commits

---

## Platform Awareness

Platform differences are handled via:
- chezmoi variables
- template conditionals
- minimal branching in scripts

The goal is **one repo**, not per-OS forks.

---

## Common Footguns (Historical Scars)

Avoid these mistakes:

- Putting libraries inside `.chezmoiscripts/`
- Using `run_once_` for evolving logic
- Hardcoding identity data
- Building custom orchestrators
- Adding manual post-install steps
- Writing non-idempotent scripts

Most of these existed in earlier iterations of this repo.

They were removed on purpose.

---

## Documentation Strategy

- `README.md` – user-facing overview
- `STRUCTURE.md` – architecture and customisation
- `docs/` – subsystem details
- `.cursor/rules.md` – enforceable constraints
- `AI_CONTEXT.md` – this document

Documentation lives with intent, not convenience.

---

## Evolution & Design History

This repo began as a custom shell framework.
Over time it became clear that chezmoi already solved the problem space.

Key learnings:
- Stop reinventing orchestration
- Prefer declarative configuration
- Let chezmoi own lifecycle and state
- Keep complexity low and visible

The current design reflects those lessons.

---

## Non-Goals & Future Ideas

Possible future additions (not implemented):
- Secret management integration

Guiding rule:
If chezmoi already supports it, use that.
Only extend when there is no simpler option.

---

## How to Think Before Changing Things

Before modifying this repo, ask:

1. Does chezmoi already support this?
2. Is this rerunnable?
3. Is this structure consistent with existing patterns?
4. Does this need documentation?

If unsure, choose the simpler approach.
