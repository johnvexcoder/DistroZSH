# =============================================================================
# DistroZSH - 14-prompt.zsh (prompt runtime)
# =============================================================================
#
# Renders the prompt once at load time (no subprocesses, no per-keyword
# overhead) and keeps the terminal title, the optional blank line before the
# prompt, and the layout toggle (Ctrl+P) in sync.
#
# =============================================================================

# ---------------------------------------------------------------------------
# Terminal title
# ---------------------------------------------------------------------------
# Only set a title in terminals that understand the OSC-0 escape sequence.
# The title itself is interpolated at load time; %-escapes such as %n, %m and
# %~ are expanded by print -P on every precmd.
# ---------------------------------------------------------------------------
if [[ "$DISTROZSH_SET_TITLE" == "yes" ]]; then
    case "$TERM" in
        xterm*|rxvt*|Eterm|aterm|kterm|gnome*|alacritty|ptyxis*|konsole*)
            local _distrozsh_chroot_title=""
            if [[ -n "$debian_chroot" ]]; then
                _distrozsh_chroot_title="($debian_chroot)"
            fi
            TERM_TITLE=$'\e]0;'"${_distrozsh_chroot_title}%n@%m: %~"$'\a'
            unset _distrozsh_chroot_title
            ;;
        *)
            TERM_TITLE=""
            ;;
    esac
else
    TERM_TITLE=""
fi

# ---------------------------------------------------------------------------
# precmd: keep the terminal title fresh and print an optional blank line
# ---------------------------------------------------------------------------
precmd() {
    if [[ -n "$TERM_TITLE" ]]; then
        print -Pnr -- "$TERM_TITLE"
    fi

    if [[ "$DISTROZSH_NEWLINE_BEFORE_PROMPT" == "yes" ]]; then
        if [[ -z "$_DISTROZSH_NEW_LINE_BEFORE_PROMPT" ]]; then
            _DISTROZSH_NEW_LINE_BEFORE_PROMPT=1
        else
            print ""
        fi
    fi
}

# ---------------------------------------------------------------------------
# Initial prompt render
# ---------------------------------------------------------------------------
_distrozsh_prompt

# ---------------------------------------------------------------------------
# Layout toggle (Ctrl+P): switch between the active layout and oneline
# ---------------------------------------------------------------------------
_toggle_oneline_prompt() {
    if [[ "$DISTROZSH_LAYOUT" == "oneline" ]]; then
        DISTROZSH_LAYOUT="${_DISTROZSH_PREV_LAYOUT:-kali}"
        source "$DISTROZSH_HOME/layouts/$DISTROZSH_LAYOUT.zsh"
    else
        _DISTROZSH_PREV_LAYOUT="$DISTROZSH_LAYOUT"
        DISTROZSH_LAYOUT="oneline"
        source "$DISTROZSH_HOME/layouts/oneline.zsh"
    fi
    _distrozsh_prompt
    zle reset-prompt
}

zle -N _toggle_oneline_prompt
bindkey '^P' _toggle_oneline_prompt
