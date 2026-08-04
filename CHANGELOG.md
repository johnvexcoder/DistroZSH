# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-08-04

DistroZSH v2 is a complete generalization of the Fedora-only v1 project
("fedora-zsh") into a cross-distribution ZSH experience.

### Added

- Cross-distribution engine with automatic detection from `/etc/os-release`
  (`ID`, `ID_LIKE`, `NAME`, `PRETTY_NAME`).
- Modular engine architecture under `zsh/` (config, detect, theme, layout,
  prompt, options, history, completion, keybindings, aliases, plugins).
- Per-distribution color themes for all officially supported distributions:
  Fedora, Ubuntu, Linux Mint, Debian, Kali Linux, Arch Linux, Manjaro,
  EndeavourOS, openSUSE, Pop!_OS, elementary OS, Zorin OS, Rocky Linux,
  AlmaLinux, plus community themes and a neutral `generic` fallback.
- Four prompt layouts: `kali` (default), `oneline`, `minimal`, `compact`.
- User configuration via `~/.config/distrozsh/config.zsh` (never overwritten
  on reinstall).
- Theme engine separated from the prompt engine; custom themes can be added
  by dropping a file into `~/.config/distrozsh/themes/`.
- Multi-package-manager installer: `dnf`, `apt`, `pacman`, `zypper`.
- Automatic EPEL repository enablement for RHEL-family distributions.
- Automatic OBS `shells:zsh-users` repository setup for openSUSE.
- Fully reversible uninstaller that restores the previous `~/.zshrc`, the
  previous default shell, and preserves the user `config.zsh`.
- `scripts/distro-detect.sh` standalone detection helper.
- `scripts/preview.sh` prompt preview renderer and `scripts/make-screenshots.sh`
  screenshot pipeline (`scripts/ansi_to_png.py`).
- GitHub-ready project files: README, LICENSE, CONTRIBUTING, CODE_OF_CONDUCT,
  SECURITY, ROADMAP, docs/, screenshots/, .github/ workflows and templates.

### Changed

- Project renamed from "fedora-zsh" to "DistroZSH".
- Tagline: "A lightweight, framework-free, cross-distribution ZSH experience
  inspired by native Linux distributions."
- `~/.zshrc` is now a thin launcher; all logic moved into the engine.
- Prompt identity separator changed to **◉** (never Kali's `㉿`).
- Install state moved to `~/.config/distrozsh/.install-state`.

### Removed

- Fedora-only hardcoded package handling (now distribution-aware).
- Dependency on the v1 single `.zshrc` monolith.

### Fixed

- Plugin loading now scans all distribution-specific install paths
  (`/usr/share/`, `/usr/share/zsh/plugins/`, `/usr/share/zsh/site-contrib/`).
- Truecolor theme rendering in the screenshot pipeline.

## [1.0.0] - 2026-08-01

Version 1: "fedora-zsh" — Kali-style ZSH for Fedora (retired, superseded by
DistroZSH v2).
