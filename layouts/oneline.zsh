# =============================================================================
# DistroZSH - layouts/oneline.zsh (classic one-line)
# =============================================================================
#
# Single-line layout keeping the ◉ identity:
#
#   user◉distribution:~/Projects$
#
# =============================================================================

_distrozsh_prompt() {
    PROMPT="%B%F{${DISTROZSH_THEME_USER_COLOR}}%n%f%F{${DISTROZSH_THEME_SEPARATOR_COLOR}}◉%F{${DISTROZSH_THEME_DISTRO_COLOR}}${DISTROZSH_DISTRO_LABEL}%f%F{${DISTROZSH_THEME_PATH_COLOR}}:%B%~%b%f %B%(#.%F{${DISTROZSH_THEME_ROOT_PROMPT_COLOR}}#.%F{${DISTROZSH_THEME_PROMPT_COLOR}}\$)%b%f "
    RPROMPT=""
}
