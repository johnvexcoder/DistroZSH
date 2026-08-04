# =============================================================================
# DistroZSH - 13-layout.zsh (layout loading)
# =============================================================================
#
# Layouts control prompt structure only; colors come from the active theme.
# A layout is a plain file under $DISTROZSH_HOME/layouts/ that defines the
# `_distrozsh_prompt` function, which builds PROMPT/RPROMPT from the seven
# theme variables.
#
# Users choose a layout with DISTROZSH_LAYOUT in their config.zsh:
#
#   DISTROZSH_LAYOUT=kali     # classic Kali-style two-line box (default)
#   DISTROZSH_LAYOUT=oneline  # classic one-line
#   DISTROZSH_LAYOUT=minimal  # path + prompt symbol only
#   DISTROZSH_LAYOUT=compact  # compact user@host:path
#
# =============================================================================

DISTROZSH_LAYOUT="${DISTROZSH_LAYOUT:-kali}"

if [[ -r "$DISTROZSH_HOME/layouts/$DISTROZSH_LAYOUT.zsh" ]]; then
    source "$DISTROZSH_HOME/layouts/$DISTROZSH_LAYOUT.zsh"
else
    DISTROZSH_LAYOUT="kali"
    source "$DISTROZSH_HOME/layouts/kali.zsh"
fi
