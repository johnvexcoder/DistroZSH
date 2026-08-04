# =============================================================================
# DistroZSH - layouts/compact.zsh (compact)
# =============================================================================
#
# Compact classic single line with hostname:
#
#   user@host:~/Projects$
#
# =============================================================================

_distrozsh_prompt() {
    PROMPT="%B%F{${DISTROZSH_THEME_USER_COLOR}}%n%F{${DISTROZSH_THEME_DISTRO_COLOR}}@%m%f%F{${DISTROZSH_THEME_PATH_COLOR}}:%B%~%b%f %B%(#.%F{${DISTROZSH_THEME_ROOT_PROMPT_COLOR}}#.%F{${DISTROZSH_THEME_PROMPT_COLOR}}\$)%b%f "
    RPROMPT=""
}
