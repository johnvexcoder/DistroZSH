# =============================================================================
# DistroZSH - 12-theme.zsh (theme resolution + loading)
# =============================================================================
#
# The theme engine is deliberately separated from the prompt engine.
#
#   Themes  control colors only   (username, separator, distro, path, symbol)
#   Layouts control structure only (kali, oneline, minimal, compact)
#
# A theme is a plain file under $DISTROZSH_HOME/themes/ that only sets the
# seven color variables documented in themes/_template.zsh. Nothing else.
#
# Users choose a theme with DISTROZSH_THEME in their config.zsh:
#
#   DISTROZSH_THEME=auto     # detect from the running distribution (default)
#   DISTROZSH_THEME=arch     # force any registered theme
#   DISTROZSH_THEME=custom   # drop your own themes/custom.zsh
#
# =============================================================================

# ---------------------------------------------------------------------------
# Resolve the active theme
# ---------------------------------------------------------------------------
DISTROZSH_THEME="${DISTROZSH_THEME:-auto}"

if [[ "$DISTROZSH_THEME" == "auto" ]]; then
    DISTROZSH_THEME="$DISTROZSH_DETECTED_THEME"
fi

# ---------------------------------------------------------------------------
# Load the theme (fall back to the neutral generic theme on failure)
# ---------------------------------------------------------------------------
if [[ -r "$DISTROZSH_HOME/themes/$DISTROZSH_THEME.zsh" ]]; then
    source "$DISTROZSH_HOME/themes/$DISTROZSH_THEME.zsh"
else
    DISTROZSH_THEME="generic"
    source "$DISTROZSH_HOME/themes/generic.zsh"
fi

# Safety net: every theme must define all seven colors. Missing variables are
# filled from the generic theme so a half-written theme can never break the
# prompt.
local _distrozsh_color_var
for _distrozsh_color_var in DISTROZSH_THEME_USER_COLOR DISTROZSH_THEME_ROOT_COLOR \
                            DISTROZSH_THEME_SEPARATOR_COLOR DISTROZSH_THEME_DISTRO_COLOR \
                            DISTROZSH_THEME_PATH_COLOR DISTROZSH_THEME_PROMPT_COLOR \
                            DISTROZSH_THEME_ROOT_PROMPT_COLOR; do
    if [[ -z "${(P)_distrozsh_color_var:-}" ]]; then
        case "$_distrozsh_color_var" in
            DISTROZSH_THEME_USER_COLOR)      DISTROZSH_THEME_USER_COLOR="white" ;;
            DISTROZSH_THEME_ROOT_COLOR)      DISTROZSH_THEME_ROOT_COLOR="red" ;;
            DISTROZSH_THEME_SEPARATOR_COLOR) DISTROZSH_THEME_SEPARATOR_COLOR="white" ;;
            DISTROZSH_THEME_DISTRO_COLOR)    DISTROZSH_THEME_DISTRO_COLOR="white" ;;
            DISTROZSH_THEME_PATH_COLOR)      DISTROZSH_THEME_PATH_COLOR="cyan" ;;
            DISTROZSH_THEME_PROMPT_COLOR)    DISTROZSH_THEME_PROMPT_COLOR="white" ;;
            DISTROZSH_THEME_ROOT_PROMPT_COLOR) DISTROZSH_THEME_ROOT_PROMPT_COLOR="red" ;;
        esac
    fi
done
unset _distrozsh_color_var
