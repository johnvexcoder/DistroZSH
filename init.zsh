# =============================================================================
# DistroZSH - init.zsh (engine bootstrap)
# =============================================================================
#
# DistroZSH: a lightweight, framework-free, cross-distribution ZSH experience
# inspired by native Linux distributions.
#
# This file is sourced from the ~/.zshrc launcher and bootstraps the engine.
# The engine is intentionally modular: every file under $DISTROZSH_HOME/zsh/
# covers one concern and is loaded in dependency order. Themes and layouts
# are loaded dynamically, so new distributions, themes and layouts can be
# added without touching this file.
#
# =============================================================================

: "${DISTROZSH_HOME:=$HOME/.config/distrozsh}"
typeset -g DISTROZSH_VERSION="2.0.0"

# ---------------------------------------------------------------------------
# Module loader
# ---------------------------------------------------------------------------
# Sources a module from $DISTROZSH_HOME/zsh/ if it exists and is readable.
# Silent by design: a missing optional module must never break the shell.
# ---------------------------------------------------------------------------
_distrozsh_source_module() {
    local module="$1"
    local file="$DISTROZSH_HOME/zsh/$module"
    if [[ -r "$file" ]]; then
        source "$file"
    fi
}

_distrozsh_source_module 10-config.zsh      # defaults + user configuration
_distrozsh_source_module 11-detect.zsh      # distribution detection
_distrozsh_source_module 12-theme.zsh       # theme resolution + loading
_distrozsh_source_module 13-layout.zsh      # layout loading
_distrozsh_source_module 14-prompt.zsh      # prompt runtime (precmd, title)
_distrozsh_source_module 20-options.zsh     # shell options
_distrozsh_source_module 21-history.zsh     # history
_distrozsh_source_module 22-completion.zsh  # completion
_distrozsh_source_module 23-keybindings.zsh # key bindings
_distrozsh_source_module 24-aliases.zsh     # aliases + color support
_distrozsh_source_module 25-plugins.zsh     # standalone distribution plugins

unset -f _distrozsh_source_module
