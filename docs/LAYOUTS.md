# Layouts

A layout defines prompt **structure** only. Colors come from the active theme.
Layouts are independent of themes — any theme works with any layout.

## Choosing a layout

In `~/.config/distrozsh/config.zsh`:

```zsh
DISTROZSH_LAYOUT=kali     # default
DISTROZSH_LAYOUT=oneline
DISTROZSH_LAYOUT=minimal
DISTROZSH_LAYOUT=compact
```

You can also press `Ctrl+P` at any time to toggle between your active layout
and the one-line layout.

## Built-in layouts

### `kali` — classic Kali-style two-line (default)

The DistroZSH identity: a two-line box with the **◉** separator.

```
┌──(user◉distribution)-[~/Projects]
└─$
```

### `oneline` — classic one-line

The same identity on a single line.

```
user◉distribution:~/Projects$
```

### `minimal` — minimal

Bare minimum: the current directory and the prompt symbol.

```
~/Projects$
```

### `compact` — compact

Classic compact single line with hostname.

```
user@host:~/Projects$
```

## Creating a custom layout

Layouts live in `~/.config/distrozsh/layouts/` (copied from `layouts/` in the
repository). A layout file defines a single function, `_distrozsh_prompt`,
which builds `PROMPT` (and optionally `RPROMPT`) from the seven theme
variables:

```zsh
# ~/.config/distrozsh/layouts/mine.zsh
_distrozsh_prompt() {
    PROMPT="%B%F{${DISTROZSH_THEME_USER_COLOR}}%n%f "
    PROMPT+="%F{${DISTROZSH_THEME_SEPARATOR_COLOR}}◉"
    PROMPT+="%F{${DISTROZSH_THEME_DISTRO_COLOR}}${DISTROZSH_DISTRO_LABEL}%f "
    PROMPT+="%B%F{${DISTROZSH_THEME_PATH_COLOR}}%~%b%f "
    PROMPT+="%B%(#.%F{${DISTROZSH_THEME_ROOT_PROMPT_COLOR}}#.%F{${DISTROZSH_THEME_PROMPT_COLOR}}\$)%b%f "
    RPROMPT=""
}
```

Then select it:

```sh
echo 'DISTROZSH_LAYOUT=mine' >> ~/.config/distrozsh/config.zsh
exec zsh
```

The prompt is built once at load time (the strings are interpolated when the
layout function runs), so there is no per-keystroke cost — keep it that way and
avoid subprocesses inside `_distrozsh_prompt`.

## Prompt escapes available

Inside a layout you can use the usual ZSH prompt escapes:

- `%n` username, `%m` hostname
- `%~` current directory (with `~`), `%d` absolute path
- `%(#.true.false)` conditional on root
- `%B`/`%b` bold, `%F{color}`/`%f` foreground
- `${DISTROZSH_DISTRO_LABEL}` the detected distribution label
