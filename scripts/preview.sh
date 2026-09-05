#!/usr/bin/env zsh
#
# preview.sh - render a DistroZSH prompt (screenshots + theme checks)
#
# Runs directly from the repository without installation. Every theme is
# rendered in every layout so maintainers can inspect the whole matrix.
#
# Usage:
#   ./preview.sh [theme] [layout]      render one prompt (default: auto, kali)
#   ./preview.sh --list                list available themes and layouts
#   ./preview.sh --all [--plain]       render every theme x layout into screenshots/
#
# Output is ANSI-colored text (truecolor for #RRGGBB accents). The --all mode
# writes one file per combination so it can be embedded or converted to PNG.
#
setopt promptsubst

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DISTROZSH_HOME="${DISTROZSH_HOME:-$REPO_DIR}"

# ---------------------------------------------------------------------------
# Inventory
# ---------------------------------------------------------------------------
typeset -a THEMES LAYOUTS
THEMES=()
for f in "$DISTROZSH_HOME"/themes/*.zsh; do
    name="${f:t:r}"
    [[ "$name" == "_template" ]] && continue
    THEMES+=("$name")
done
LAYOUTS=()
for f in "$DISTROZSH_HOME"/layouts/*.zsh; do
    LAYOUTS+=("${f:t:r}")
done

render() { # theme layout [outfile]
    local theme="$1" layout="$2" out="${3:-}"
    DISTROZSH_THEME="$theme"
    DISTROZSH_DISTRO_LABEL="$theme"
    source "$DISTROZSH_HOME/themes/$theme.zsh"
    source "$DISTROZSH_HOME/layouts/$layout.zsh"
    _distrozsh_prompt
    if [[ -n "$out" ]]; then
        print -P -- "$PROMPT" > "$out"
    else
        print -P -- "$PROMPT"
    fi
}

case "${1:-}" in
    --list)
        printf 'Themes:  %s\n' "${(j:, :)THEMES}"
        printf 'Layouts: %s\n' "${(j:, :)LAYOUTS}"
        ;;
    --all)
        plain="no"
        [[ "${2:-}" == "--plain" ]] && plain="yes"
        OUT_DIR="${DISTROZSH_PREVIEW_OUT_DIR:-$REPO_DIR/screenshots}"
        mkdir -p "$OUT_DIR"
        local theme layout out
        for theme in "${THEMES[@]}"; do
            for layout in "${LAYOUTS[@]}"; do
                out="$OUT_DIR/${theme}-${layout}.ansi"
                render "$theme" "$layout" "$out"
                if [[ "$plain" == "yes" ]]; then
                    local plain_file="$OUT_DIR/${theme}-${layout}.txt"
                    # shellcheck disable=SC2002
                    cat "$out" | sed -E $'s/\x1B\\[[0-9;]*[a-zA-Z]//g' > "$plain_file"
                fi
                print "  $out"
            done
        done
        ;;
    *)
        theme="${1:-auto}"
        layout="${2:-kali}"
        if [[ "$theme" == "auto" ]]; then
            theme="$("$REPO_DIR/scripts/distro-detect.sh" --theme)"
        fi
        if [[ -z "${THEMES[(r)$theme]}" ]]; then
            print -- "unknown theme: $theme" >&2
            exit 1
        fi
        if [[ -z "${LAYOUTS[(r)$layout]}" ]]; then
            print -- "unknown layout: $layout" >&2
            exit 1
        fi
        render "$theme" "$layout"
        ;;
esac
