# Devtools Kit

Optional development tools and runtimes.

## Includes

- **Containers**: Docker, docker-compose
- **Languages**: Node.js, Python, Go
- **Build tools**: cmake, pkg-config
- **Dev utilities**: GitHub CLI, httpie

## Setup

Enabled via `.chezmoi.toml`:
```toml
[data.kits]
  devtools = true
```

Applied automatically by `30-apply-kits.sh` orchestrator.

## Customization

- **Brewfile**: Package definitions
- **setup.sh**: Optional custom configuration (currently none needed)
