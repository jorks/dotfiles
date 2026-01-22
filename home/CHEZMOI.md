# Chezmoi Usage

This repo uses chezmoi in **source-directory mode**. That means `home/` is the canonical source, and chezmoi is just the render-and-apply engine. You edit files here in the repo, not via `chezmoi edit`. Git stays in charge.

## Workflow

Bootstrap scripts handle the initial setup. If running manually:

```bash
chezmoi init --source ./home
chezmoi apply
```

After that, the loop is simple: edit files in `home/`, then apply.

```bash
chezmoi apply
```

Preview before applying with `chezmoi diff`. Re-apply everything with `--verbose` if you want confirmation of what changed.

## Templates and data

User-specific values (name, email, etc.) are handled via chezmoi's data model. Prompts are defined in `.chezmoi.toml` at the repo root. On first apply, you're prompted once. Answers live in `~/.config/chezmoi/chezmoi.toml` locally and never touch version control.

Templates (`*.tmpl`) reference those values directly:

```ini
name = {{ .git_name }}
email = {{ .git_email }}
```

Identity values have no defaults. Preferences may. Templates fail loudly if required data is missing - this is intentional.

To add a new value, define it in `.chezmoi.toml`, then reference it from a template. Do not hard-code personal data in the repo.

## Constraints

The `home/` directory is the only thing chezmoi manages. No install logic, no mutating scripts, nothing that touches files outside `$HOME`. Everything here should be safe to apply repeatedly.

Platform-specific variants exist where necessary (`dot_gitconfig.darwin`, etc.), but platform logic is kept minimal. Files excluded from apply are listed in `.chezmoiignore` - mostly docs and reference material.

Structured config lives in `.config/` when tools support it. Legacy dotfiles stay where tools expect them.
