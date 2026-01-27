# Kits

Kits are opt-in capability bundles — groups of related tools you might not want on every machine. Dev laptop gets Docker, personal machine skips it. Work machine gets VPN tools, homelab doesn't.

## How kits work

Each kit is just a Brewfile (list of packages) and optional `setup.sh` (for config that can't be declarative). They live in this directory and are discovered automatically by the kit orchestrator.

### Enabling kits

On first `chezmoi apply`, you're prompted which kits to enable:

```bash
Enable devtools kit? (Docker, compilers, dev tools) [y/N]: 
Enable productivity kit? (Apps, utilities) [y/N]: 
...
```

Your choices are stored in `~/.config/chezmoi/chezmoi.toml` and never committed. Enable different kits on different machines.

### How they're applied

The `30-apply-kits.sh` orchestrator:
1. Loops through enabled kits in your config
2. Applies each kit's Brewfile via `brew bundle`
3. Runs optional `setup.sh` if it exists

This happens automatically during `chezmoi apply`. Change a kit's Brewfile, rerun apply, packages install.

## Available kits

### devtools
Docker, compilers, language runtimes, build tools.  
**Use case:** Machines where you write code.  
See [devtools/README.md](devtools/README.md) for package list.

### productivity
Browsers, communication apps, utilities.  
**Use case:** Personal laptops, not servers.  
Currently empty — add your preferred apps.

### security
VPNs, password managers, security tools.  
**Use case:** Work machines.  
Currently empty — add your required security stack.

### macadmin
IT/sysadmin tooling for Mac management.  
**Use case:** Only if you're that kind of sysadmin.  
Currently empty — add tools like Jamf Helper, AutoPkg, etc.

### fonts
Design fonts and bonus coding fonts.  
**Use case:** Typography nerds.  
See [fonts/README.md](fonts/README.md) for full font list.

## Creating a new kit

1. **Create the directory and Brewfile:**
   ```bash
   mkdir -p home/dot_config/kits/mykit
   touch home/dot_config/kits/mykit/Brewfile
   ```

2. **Add packages to the Brewfile:**
   ```ruby
   # home/dot_config/kits/mykit/Brewfile
   brew "package-name"
   cask "app-name"
   ```

3. **Add a prompt to `.chezmoi.toml.tmpl`:**
   ```toml
   {{- $kits_mykit := promptBoolOnce . "kits.mykit" "Enable mykit?" false -}}
   
   # In the [data.kits] section:
   [data.kits]
     mykit = {{ $kits_mykit }}
   ```

4. **Optional: Add post-install config:**
   ```bash
   touch home/dot_config/kits/mykit/setup.sh
   chmod +x home/dot_config/kits/mykit/setup.sh
   ```

The orchestrator discovers it automatically. No code changes needed.

## Kit guidelines

**Keep kits focused.** A kit should represent a capability (dev tools, security stack) not a random collection of packages.

**Use Brewfiles for packages.** Only use `setup.sh` for configuration that can't be expressed declaratively (symlinking, system settings, etc.).

**Document your kits.** Add a README.md explaining what's in the kit and why someone would enable it.

**Empty kits are OK.** Placeholder kits (productivity, security) exist so forks can add their own packages without modifying the orchestrator.
