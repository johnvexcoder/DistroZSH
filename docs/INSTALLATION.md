# Installation

DistroZSH installs `zsh`, the two standalone plugins, and the engine, using
your distribution's native package manager. Nothing is downloaded from the
internet except what your package manager pulls from its own repositories.

## Requirements

- A Linux distribution (see the supported list in the README).
- `bash` (for the installer) and network access to your package repositories.
- A terminal with a standard monospace font — no Nerd Fonts required.

## Quick start

```sh
git clone https://github.com/your-name/DistroZSH.git
cd DistroZSH
./install.sh
```

The installer asks whether to make `zsh` your default shell. Answer `y` if you
want that (your previous shell is recorded and restored by `uninstall.sh`).

### Options

| Option | Description |
| --- | --- |
| `./install.sh` | interactive install |
| `./install.sh --shell` | install and change the default shell, no prompt |
| `./install.sh --no-shell` | install without touching the default shell |
| `./install.sh --help` | show help |

## What gets installed

| Item | Location | Notes |
| --- | --- | --- |
| `zsh` | system package | installed only if missing |
| `zsh-autosuggestions` | system package | standalone plugin |
| `zsh-syntax-highlighting` | system package | standalone plugin |
| Engine | `~/.config/distrozsh/` | `init.zsh`, `zsh/`, `themes/`, `layouts/`, `scripts/` |
| Launcher | `~/.zshrc` | thin file, do not edit |
| Configuration | `~/.config/distrozsh/config.zsh` | created once, never overwritten |
| State | `~/.config/distrozsh/.install-state` | used by `uninstall.sh` |

An existing `~/.zshrc` is backed up to `~/.zshrc.bak.<timestamp>`.

## Per-distribution notes

### Fedora (dnf)

Plugins are in the base repositories. Nothing extra is needed.

```sh
sudo dnf install zsh zsh-autosuggestions zsh-syntax-highlighting
```

### RHEL family — Rocky, AlmaLinux, CentOS Stream (dnf)

The plugins are packaged in **EPEL**, which the installer enables
automatically. Oracle Linux uses `oraclelinux-release-epel`; the installer
handles that too. If you enable EPEL manually:

```sh
sudo dnf install epel-release          # or oraclelinux-release-epel on Oracle
sudo dnf install zsh zsh-autosuggestions zsh-syntax-highlighting
```

### Debian family — Debian, Ubuntu, Kali, Mint, Pop!_OS, etc. (apt)

The installer runs `apt-get update` first, then installs the three packages.

```sh
sudo apt update
sudo apt install zsh zsh-autosuggestions zsh-syntax-highlighting
```

### Arch family — Arch, Manjaro, EndeavourOS, etc. (pacman)

All three packages are in the `community`/extra repositories.

```sh
sudo pacman -S --noconfirm --needed zsh zsh-autosuggestions zsh-syntax-highlighting
```

### openSUSE Leap / Tumbleweed (zypper)

The plugins are **not** in the main OSS repositories. They live in the OBS
project `shells:zsh-users`. The installer adds the correct repository for your
release (Leap uses its version, Tumbleweed uses `tumbleweed`), refreshes, then
installs. To do it manually:

```sh
# Leap 15.6 as an example
sudo zypper addrepo --refresh \
  https://download.opensuse.org/repositories/shells:zsh-users/15.6/shells:zsh-users.repo
# Tumbleweed
sudo zypper addrepo --refresh \
  https://download.opensuse.org/repositories/shells:zsh-users/tumbleweed/shells:zsh-users.repo
sudo zypper refresh
sudo zypper install zsh zsh-autosuggestions zsh-syntax-highlighting
```

## After installation

- Open a new terminal or run `exec zsh`.
- Press `Ctrl+P` to toggle between the two-line and one-line layouts.
- Edit `~/.config/distrozsh/config.zsh` to change theme, layout and behaviour.

## Uninstallation

```sh
./uninstall.sh
```

Restores your previous `~/.zshrc`, restores your previous default shell, saves
your `config.zsh`, and removes `~/.config/distrozsh`. It never uninstalls `zsh`
or the plugins.

## Troubleshooting

- **Theme looks wrong** → run `./scripts/distro-detect.sh` to see what was
  detected; force a theme with `DISTROZSH_THEME=<name>` in `config.zsh`.
- **No colors** → ensure your terminal reports a color-capable `$TERM`
  (e.g. `xterm-256color` or `alacritty`).
- **Plugins not loading** → verify the packages are installed
  (`rpm -q zsh-autosuggestions`, `dpkg -s zsh-autosuggestions`,
  `pacman -Q zsh-autosuggestions`). The engine scans all known plugin paths
  at startup.
- **Prompt glyphs look wrong** → you are probably missing the `┌ ─ └ ◉` glyphs,
  which ship with every standard monospace font (DejaVu, Noto Sans Mono,
  JetBrains Mono, Fira Code).
