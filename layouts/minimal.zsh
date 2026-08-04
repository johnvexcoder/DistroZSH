# =============================================================================
# DistroZSH - layouts/minimal.zsh (minimal)
# =============================================================================
#
# Bare minimum: the current directory and the prompt symbol.
#
#   ~/Projects$
#
# =============================================================================

_distrozsh_prompt() {
    PROMPT="%B%F{${DISTROZSH_THEME_PATH_COLOR}}%~%b%f %B%(#.%F{${DISTROZSH_THEME_ROOT_PROMPT_COLOR}}#.%F{${DISTROZSH_THEME_PROMPT_COLOR}}\$)%b%f "
    RPROMPT=""
}
