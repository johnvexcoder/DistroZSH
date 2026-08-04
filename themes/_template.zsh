# =============================================================================
# DistroZSH - themes/_template.zsh (theme authoring template)
# =============================================================================
#
# A theme controls colors ONLY. The prompt engine reads these seven variables
# and nothing else. Structure is controlled by the layout engine, never by a
# theme.
#
# To create a custom theme:
#   1. Copy this file to  ~/.config/distrozsh/themes/mine.zsh
#   2. Set DISTROZSH_THEME=mine  in  ~/.config/distrozsh/config.zsh
#
# Color values are ZSH prompt color names (white, cyan, red, ...) or any
# #RRGGBB truecolor value supported by your terminal (e.g. #3C6EB4).
#
# =============================================================================

typeset -g DISTROZSH_THEME_NAME="template"    # name of this theme (informational)

# Regular-user username color (root uses DISTROZSH_THEME_ROOT_COLOR)
typeset -g DISTROZSH_THEME_USER_COLOR="white"

# Root-user username color
typeset -g DISTROZSH_THEME_ROOT_COLOR="red"

# The ◉ separator symbol
typeset -g DISTROZSH_THEME_SEPARATOR_COLOR="white"

# The distribution name
typeset -g DISTROZSH_THEME_DISTRO_COLOR="white"

# The current directory
typeset -g DISTROZSH_THEME_PATH_COLOR="cyan"

# The normal prompt symbol ($)
typeset -g DISTROZSH_THEME_PROMPT_COLOR="white"

# The root prompt symbol (#)
typeset -g DISTROZSH_THEME_ROOT_PROMPT_COLOR="red"
