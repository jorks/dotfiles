# Kits

Kits are opt-in capability bundles — groups of related tools you might not want on every machine. Dev laptop gets Docker and editors, personal machine skips it. Work machine gets IT tools, homelab doesn't.

## How kits work

Each kit uses `Brewfile.formula` and/or `Brewfile.casks` (packages) and optional `setup.sh.tmpl` (for config that can't be declarative). They live in `home/dot_config/kits/<name>/` and are discovered automatically by the kit orchestrator.

### Enabling kits

On first `chezmoi apply`, you're prompted which kits to enable:

```bash
Enable devtools kit? (Editors, containers, terminals) [y/N]: 
Enable productivity kit? (Browsers, communication, tasks) [y/N]: 
...
```

Your choices are stored in `~/.config/chezmoi/chezmoi.toml` and never committed. Enable different kits on different machines.

### How they're applied

The `30-apply-kits.sh` orchestrator:
1. Loops through enabled kits in your config
2. Applies each kit's Brewfile.formula (strict) and Brewfile.casks (best-effort) via `brew bundle` / one-by-one cask install
3. Runs optional `setup.sh` if it exists (rendered from `setup.sh.tmpl`)

This happens automatically during `chezmoi apply`. Change a kit's Brewfiles, rerun apply, packages install.

## Example kits

- **devtools** – Editors, terminals, containers, API tools. For machines where you write code.
- **productivity** – Browsers, communication apps, task managers. Personal and work laptops.
- **utilities** – Menu bar apps, window management, Quick Look extensions.
- **php-dev / python-dev** – Language-specific tooling and IDEs.

Browse `home/dot_config/kits/` to see all available kits and their Brewfile.formula / Brewfile.casks.

## Creating a new kit

**Kit names:** Use hyphens only (e.g. `php-dev`, `python-dev`). Never underscores. The directory name under `dot_config/kits/` and the config key in `[data.kits]` must match exactly.

1. **Create the directory and Brewfiles:**
   ```bash
   mkdir -p home/dot_config/kits/my-kit
   touch home/dot_config/kits/my-kit/Brewfile.formula   # formulae (strict)
   touch home/dot_config/kits/my-kit/Brewfile.casks    # casks (best-effort), optional
   ```
   Use one or both. Formulae go in `Brewfile.formula`, casks in `Brewfile.casks`. Kits can have only formulae, only casks, or both.

2. **Add packages** (see `.cursor/rules.md` for format standards). Put `brew` and `mas` in Brewfile.formula; put `cask` in Brewfile.casks:
   ```ruby
   # Brewfile.formula
   brew "package-name"                    # Brief description

   # Brewfile.casks
   cask "app-name"                        # Brief description
   ```

3. **Add a prompt to `.chezmoi.toml.tmpl`:**
   ```
   {{- $kits_mykit := promptBoolOnce . "kits.my-kit" "Enable my-kit?" false -}}
   
   # In the [data.kits] section (use quoted key if name has hyphen):
   [data.kits]
     "my-kit" = {{ $kits_mykit }}
   ```

4. **Optional: Add post-install config** (use `.tmpl` for chezmoi templating):
   ```bash
   touch home/dot_config/kits/my-kit/setup.sh.tmpl
   ```

The orchestrator discovers it automatically. No code changes needed.

## Kit guidelines

**Keep kits focused.** A kit should represent a capability (dev tools, security stack) not a random collection of packages.

**Use Brewfile.formula and Brewfile.casks for packages.** Only use `setup.sh.tmpl` for configuration that can't be expressed declaratively (system settings, manual install documentation, etc.).

**Follow the format standards.** See `.cursor/rules.md` for Brewfile and setup.sh.tmpl templates.
