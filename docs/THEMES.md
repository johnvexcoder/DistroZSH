# Themes

A theme defines colors **only**. Structure comes from the active layout, never
from a theme. Every theme sets exactly seven variables; nothing else.

## The seven colors

| Variable | What it colors |
| --- | --- |
| `DISTROZSH_THEME_USER_COLOR` | the username (regular user) |
| `DISTROZSH_THEME_ROOT_COLOR` | the username (root) |
| `DISTROZSH_THEME_SEPARATOR_COLOR` | the **◉** separator |
| `DISTROZSH_THEME_DISTRO_COLOR` | the distribution name |
| `DISTROZSH_THEME_PATH_COLOR` | the current directory |
| `DISTROZSH_THEME_PROMPT_COLOR` | the normal prompt symbol (`$`) |
| `DISTROZSH_THEME_ROOT_PROMPT_COLOR` | the root prompt symbol (`#`) |

Color values are ZSH prompt color names (`white`, `cyan`, `red`, ...) or any
`#RRGGBB` truecolor value (`#3C6EB4`).

## Choosing a theme

In `~/.config/distrozsh/config.zsh`:

```zsh
DISTROZSH_THEME=auto      # default: detect from the running distribution
DISTROZSH_THEME=arch      # force any built-in theme
```

## Built-in themes

| Theme | Distribution | Accent |
| --- | --- | --- |
| `fedora` | Fedora | Fedora Blue `#3C6EB4` |
| `ubuntu` | Ubuntu | Ubuntu Orange `#E95420` |
| `mint` | Linux Mint | Mint Green `#8AB440` |
| `debian` | Debian | Debian Red `#D70A53` |
| `kali` | Kali Linux | Kali Green `#16C60C` |
| `arch` | Arch Linux | Arch Blue `#1793D1` |
| `manjaro` | Manjaro | Manjaro Green `#35BF5C` |
| `endeavour` | EndeavourOS | EndeavourOS Purple `#7F2FFF` |
| `opensuse` | openSUSE | openSUSE Green `#73BA25` |
| `pop` | Pop!_OS | Pop!_OS Teal `#48B9C7` |
| `elementary` | elementary OS | elementary Blue `#3689E6` |
| `zorin` | Zorin OS | Zorin Blue `#15A6F0` |
| `rocky` | Rocky Linux | Rocky Green `#10B981` |
| `almalinux` | AlmaLinux | AlmaLinux Blue `#266DA6` |
| `centos` | CentOS Stream | CentOS Blue `#2A6BB2` |
| `oracle` | Oracle Linux | Oracle Red `#F80000` |
| `artix` | Artix Linux | Artix Teal `#2AA198` |
| `parrot` | Parrot OS | Parrot Green `#8BC53F` |
| `neon` | KDE neon | KDE Blue `#3DAEE9` |
| `peppermint` | Peppermint OS | Peppermint Green `#47B345` |
| `generic` | any / unknown | Neutral White |

Community distributions without a dedicated theme inherit the closest parent
theme automatically (e.g. Garuda Linux and CachyOS → `arch`, Nobara and
Ultramarine → `fedora`).

## Creating a custom theme

```sh
cp themes/_template.zsh ~/.config/distrozsh/themes/mine.zsh
```

Edit the seven colors, then:

```sh
echo 'DISTROZSH_THEME=mine' >> ~/.config/distrozsh/config.zsh
exec zsh
```

Your custom theme is preserved across reinstalls because the installer only
copies the bundled defaults and never deletes files in `~/.config/distrozsh/`.

## Previewing themes

```sh
./scripts/preview.sh fedora kali       # one theme + layout
./scripts/preview.sh --list            # list everything available
./scripts/make-screenshots.sh          # regenerate the whole PNG matrix
```
