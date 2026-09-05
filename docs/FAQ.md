# FAQ

## General

### What is DistroZSH?

A lightweight, framework-free, cross-distribution ZSH configuration. It detects
your Linux distribution, loads its native color palette, and provides a fast,
native-feeling prompt — without Oh My Zsh, Starship, Powerlevel10k or any other
framework or external prompt engine.

### Is this another Oh My Zsh?

No. DistroZSH is the opposite: no framework, no plugin manager, no prompt
engine. Everything is native ZSH, and the only plugins loaded are the two
standalone plugins that distributions already package
(`zsh-autosuggestions`, `zsh-syntax-highlighting`).

### Which fonts do I need?

None beyond what you already have. The prompt uses `┌ ─ └ ◉ $ # [ ] ( )`, all
present in standard monospace fonts (DejaVu Sans Mono, Noto Sans Mono,
JetBrains Mono, Fira Code). No Nerd Fonts.

### Which shells are supported?

ZSH 5.9 or newer. The installer is written in bash for maximum portability.

## Detection and themes

### How does it know my distribution?

It reads `/etc/os-release` and uses the standard `ID` and `ID_LIKE` fields. The
registry maps known IDs (and their families) to a label, a theme and a package
manager. Unknown distributions fall back to the neutral `generic` theme.

### My distribution isn't listed. What happens?

You get the `generic` neutral theme, and the installer asks you to install
`zsh` and the plugins manually if the package manager is unknown. You can still
use DistroZSH fully — just pick any theme you like in `config.zsh`.

### Can I force a theme?

Yes. Set `DISTROZSH_THEME=<name>` in `~/.config/distrozsh/config.zsh`, e.g.
`DISTROZSH_THEME=kali` on Fedora.

### Can I make my own theme?

Yes. Copy `themes/_template.zsh` to `~/.config/distrozsh/themes/mine.zsh`, edit
the seven colors, and set `DISTROZSH_THEME=mine`. See `docs/THEMES.md`.

## Prompt

### What does the ◉ mean?

It is DistroZSH's identity separator, rendered as
`┌──(user◉distribution)-[~/Projects]`. It is deliberately **not** Kali's `㉿`
symbol — that belongs to Kali.

### How do I switch layouts?

Edit `DISTROZSH_LAYOUT` in `config.zsh` (options: `kali`, `oneline`,
`minimal`, `compact`), or press `Ctrl+P` to toggle the current layout with the
one-line layout.

### Why is the current directory shown in full?

DistroZSH keeps the path un-abbreviated by design so you always know exactly
where you are.

### Why no clock / battery / git / docker in the prompt?

DistroZSH deliberately ships no flashy widgets. It favors startup speed,
readability and a native Linux feel over decoration. Keep it simple — that is
the point.

## Command not found

### What happens when I mistype a command?

A built-in fallback prints the classic `zsh: command not found:` error, followed by:

- **Did you mean?** — up to five suggestions computed with Levenshtein distance and
  adjacent-transposition detection (the most common typo, e.g. `gti` → `git`).
- **A package hint** — "this command may be provided by a package that is not
  installed. Try: `sudo dnf install <cmd>`" using your distribution's package
  manager.

On distributions that ship their own handler (`/usr/lib/command-not-found`,
`pkgfile`, `pk-command-not-found`, `/etc/zsh_command_not_found`), DistroZSH uses
it automatically and stays out of the way.

### How does typo correction work?

With `DISTROZSH_COMMAND_CORRECTION=yes` (default), ZSH's `setopt correct` runs
an interactive spelling check before the command-not-found fallback. It lets
you fix common typos (like `sut` instead of `stash`) inline, and the built-in
fallback still runs when no correction applies.

### Can I disable typo correction?

Yes. In `~/.config/distrozsh/config.zsh`:

```zsh
DISTROZSH_COMMAND_CORRECTION=no   # or: off
```

### How do I disable the command-not-found handler?

Set `DISTROZSH_COMMAND_NOT_FOUND=off` in `config.zsh`. To keep only the
distribution's native handler, use `DISTROZSH_COMMAND_NOT_FOUND=distro`; to
always use DistroZSH's built-in fallback, use `builtin`. The default `auto`
prefers the distribution handler when one exists.

## Installation

### Which package managers are supported?

`dnf` (Fedora, RHEL family), `apt` (Debian family), `pacman` (Arch family),
`zypper` (openSUSE).

### My RHEL-family distro can't find the plugins

The plugins live in EPEL. The installer enables EPEL automatically; for Oracle
Linux it installs `oraclelinux-release-epel`. See `docs/INSTALLATION.md`.

### My openSUSE can't find the plugins

The plugins are not in the main OSS repos; they are in the OBS
`shells:zsh-users` project. The installer adds the correct repository
automatically. See `docs/INSTALLATION.md`.

### Will this break my existing configuration?

No. An existing `~/.zshrc` is backed up, and `uninstall.sh` restores it. Your
`config.zsh` is preserved across reinstalls and even saved on uninstall.

### Does the installer require root?

Only for installing system packages (it uses `sudo`). The engine is installed
into `~/.config/distrozsh/` with no root needed.

### How do I uninstall?

Run `./uninstall.sh`. It restores your previous `~/.zshrc` and default shell,
saves `config.zsh`, and removes the engine. It never uninstalls `zsh` or the
plugins.

## Troubleshooting

### The prompt shows no colors

Make sure `$TERM` advertises color support (e.g. `xterm-256color`). Some
terminal multiplexers override `$TERM` to a color-less value.

### The theme is wrong for my distro

Run `./scripts/distro-detect.sh` to see what was detected, then force a theme
with `DISTROZSH_THEME=<name>`.

### Suggestions/autosuggestions don't appear

Confirm the package is installed and that your history file has entries.
`zsh-autosuggestions` needs the history file to have content before it can
suggest anything.

### Startup is slower than expected

The prompt itself is built once at load time with zero subprocesses. If
startup feels slow, check for slow items elsewhere in your interactive shell
(login scripts, NFS-mounted `$HOME`, etc.) with `zsh -x` tracing.
