# Fonts Kit

Optional typography collection for design and development.

## Includes

### Design Fonts (Sans-Serif)
- **Inter** - Variable font, modern UI/web standard (GitHub, Vercel)
- **Poppins** - Geometric sans, trending 2024-26
- **Roboto** - Google's default, everywhere
- **Montserrat** - Free Gotham alternative
- **DM Sans** - Minimal, clean UI
- **Space Grotesk** - Modern geometric

### Design Fonts (Serif)
- **Merriweather** - Readable body text
- **Playfair Display** - Elegant headers

### Bonus Coding Fonts
- **Fira Code** - Ligature support
- **Cascadia Code** - Microsoft's ligature font
- **Source Code Pro** - Adobe monospace

## Setup

Enabled via `.chezmoi.toml`:
```toml
[data.kits]
  fonts = true
```

Applied automatically by `30-apply-kits.sh` orchestrator.

## Notes

- Essential coding fonts (JetBrains Mono, Inconsolata) are installed separately
- All fonts installed system-wide to `/Library/Fonts`
- Available immediately in all applications
- Track favorite fonts over time by updating this Brewfile
