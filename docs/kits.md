# Kits

Kits are opt-in capability bundles — groups of related tools you might not want on every machine. Dev laptop gets Docker and editors, personal machine skips it. Work machine gets IT tools, homelab doesn't.

## How kits work

Each kit is a Brewfile (list of packages) and optional `setup.sh.tmpl` (for config that can't be declarative). They live in `home/dot_config/kits/<name>/` and are discovered automatically by the kit orchestrator.

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
2. Applies each kit's Brewfile via `brew bundle`
3. Runs optional `setup.sh` if it exists (rendered from `setup.sh.tmpl`)

This happens automatically during `chezmoi apply`. Change a kit's Brewfile, rerun apply, packages install.

## Example kits

- **devtools** – Editors, terminals, containers, API tools. For machines where you write code.
- **productivity** – Browsers, communication apps, task managers. Personal and work laptops.
- **utilities** – Menu bar apps, window management, Quick Look extensions.
- **php_dev / python_dev** – Language-specific tooling and IDEs.

Browse `home/dot_config/kits/` to see all available kits and their Brewfiles.

## Creating a new kit

1. **Create the directory and Brewfile:**
   ```bash
   mkdir -p home/dot_config/kits/mykit
   touch home/dot_config/kits/mykit/Brewfile
   ```

2. **Add packages to the Brewfile** (see `.cursor/rules.md` for format standards):
   ```ruby
   # My Kit
   #
   # Description of what this kit provides.

   brew "package-name"                    # Brief description
   cask "app-name"                        # Brief description
   ```

3. **Add a prompt to `.chezmoi.toml.tmpl`:**
   ```
   {{- $kits_mykit := promptBoolOnce . "kits.mykit" "Enable mykit?" false -}}
   
   # In the [data.kits] section:
   [data.kits]
     mykit = {{ $kits_mykit }}
   ```

4. **Optional: Add post-install config** (use `.tmpl` for chezmoi templating):
   ```bash
   touch home/dot_config/kits/mykit/setup.sh.tmpl
   ```

The orchestrator discovers it automatically. No code changes needed.

## Kit guidelines

**Keep kits focused.** A kit should represent a capability (dev tools, security stack) not a random collection of packages.

**Use Brewfiles for packages.** Only use `setup.sh.tmpl` for configuration that can't be expressed declaratively (system settings, manual install documentation, etc.).

**Follow the format standards.** See `.cursor/rules.md` for Brewfile and setup.sh.tmpl templates.
