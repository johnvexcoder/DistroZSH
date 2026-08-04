# =============================================================================
# DistroZSH - 10-config.zsh (defaults + user configuration)
# =============================================================================
#
# Everything the user is allowed to customize lives in one place:
#
#   $DISTROZSH_HOME/config.zsh   (i.e. ~/.config/distrozsh/config.zsh)
#
# Defaults are declared below with the :|:=| operators so they only apply when
# the variable has not been set yet (e.g. from the environment or from a
# previous invocation). The user configuration file is sourced afterwards and
# therefore always wins.
#
# =============================================================================

# ---------------------------------------------------------------------------
# Defaults
# ---------------------------------------------------------------------------
: "${DISTROZSH_THEME:=auto}"                 # auto | <theme name> (see themes/)
: "${DISTROZSH_LAYOUT:=kali}"                # kali | oneline | minimal | compact
: "${DISTROZSH_NEWLINE_BEFORE_PROMPT:=no}"   # print a blank line before the prompt
: "${DISTROZSH_SET_TITLE:=yes}"              # set the terminal window title
: "${DISTROZSH_HISTFILE:=$HOME/.zsh_history}" # history database location

# ---------------------------------------------------------------------------
# Debian-style chroot detection (no-op unless /etc/debian_chroot exists)
# ---------------------------------------------------------------------------
# Used by the prompt to show the current chroot, mirroring the behaviour of
# the stock Debian/Kali zshrc.
# ---------------------------------------------------------------------------
if [[ -z "${debian_chroot:-}" ]] && [[ -r /etc/debian_chroot ]]; then
    debian_chroot="$(< /etc/debian_chroot)"
fi

# ---------------------------------------------------------------------------
# User configuration (sourced last so it can override everything above)
# ---------------------------------------------------------------------------
if [[ -r "$DISTROZSH_HOME/config.zsh" ]]; then
    source "$DISTROZSH_HOME/config.zsh"
fi
