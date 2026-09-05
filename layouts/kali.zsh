# =============================================================================
# DistroZSH - layouts/kali.zsh (classic Kali-style, default)
# =============================================================================
#
# Two-line boxed layout, the DistroZSH identity:
#
#   ┌──(user◉distribution)-[~/Projects]
#   └─$
#
# Colors are read from the active theme. Structure never changes per theme.
#
# =============================================================================

_distrozsh_prompt() {
    local -r sep="$DISTROZSH_THEME_SEPARATOR_COLOR"
    PROMPT="%F{$sep}┌──(%B%F{${DISTROZSH_THEME_USER_COLOR}}%n%f%F{$sep}◉%F{${DISTROZSH_THEME_DISTRO_COLOR}}${DISTROZSH_DISTRO_LABEL}%b%f%F{$sep})-[%B%F{${DISTROZSH_THEME_PATH_COLOR}}%~%b%f%F{$sep}]"$'\n'"└─%B%(#.%F{${DISTROZSH_THEME_ROOT_PROMPT_COLOR}}#.%F{${DISTROZSH_THEME_PROMPT_COLOR}}\$)%b%f "
    RPROMPT=""
}
