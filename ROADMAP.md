# Roadmap

DistroZSH v2 ships as a complete, production-ready cross-distribution ZSH
experience. The roadmap below describes where it goes next without ever
abandoning the core philosophy: **framework-free, native ZSH, distribution-first.**

Legend: ✅ done · 🚧 in progress · 🔜 planned · 💭 considering

## v2.0 — Cross-distribution foundation ✅

- [x] Modular engine (`zsh/` modules, one concern per file).
- [x] Automatic distribution detection from `/etc/os-release`.
- [x] Theme engine separated from the prompt engine.
- [x] Four prompt layouts (kali, oneline, minimal, compact).
- [x] Themes for all officially supported distributions.
- [x] Multi-package-manager installer (dnf / apt / pacman / zypper).
- [x] EPEL + openSUSE OBS repository handling.
- [x] Fully reversible uninstaller.
- [x] Screenshot pipeline and preview tooling.
- [x] GitHub-ready docs, workflows and templates.

## v2.1 — Polish and coverage 🔜

- [ ] Additional community distribution themes.
- [ ] `--theme` and `--layout` command-line flags for the installer.
- [ ] A `distrozsh` helper command (theme/layout switch, preview, diagnostics).
- [ ] Installer dry-run mode (`--dry-run`).
- [ ] Automatic detection of the `rpm-ostree` path for atomic distros.
- [ ] Pre-built container test matrix for every package manager.

## v2.2 — Extensibility 🔜

- [ ] Theme "derives from" support (inherit another theme and override colors).
- [ ] Layout registry with validation on load.
- [ ] Optional per-host overrides (`~/.config/distrozsh/host.zsh`).
- [ ] Better documentation: per-distribution guides and troubleshooting.

## v3.0 — Community 🔜

- [ ] Official installer for additional package managers
      (apk, xbps, emerge/portage).
- [ ] First-class container/OCI images for CI use.
- [ ] Community theme gallery and theme contest.
- [ ] Translations of the documentation.

## Out of scope (will never happen)

- Oh My Zsh / Prezto / Antigen / Zinit / Zplug / Powerlevel10k compatibility.
- External prompt engines (Starship and friends).
- Nerd Font glyphs or Powerline segments.
- Flashy widgets: battery, clocks, CPU/RAM graphs, cloud indicators.
- Network-dependent runtime behaviour.

## Contribution ideas

Pick anything marked 🔜 or 💭 — see [CONTRIBUTING.md](CONTRIBUTING.md) for how
to get started. Ideas are welcome as feature requests; large changes should be
discussed in an issue first.
