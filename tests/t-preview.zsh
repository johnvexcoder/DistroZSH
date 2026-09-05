#!/usr/bin/env zsh
#
# t-preview.zsh - the preview matrix must render every theme x layout and
# produce exactly one ANSI (and, with --plain, one TXT) file per combination.
#
set -u

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$REPO_DIR/tests/helpers.zsh"

themes=0
for f in "$REPO_DIR"/themes/*.zsh; do
    [[ "${f:t:r}" == "_template" ]] && continue
    themes=$((themes + 1))
done
layouts=0
for f in "$REPO_DIR"/layouts/*.zsh; do
    layouts=$((layouts + 1))
done
expect=$((themes * layouts))

OUT_DIR="$(mktemp -d "${TMPDIR:-/tmp}/dzsh-test-preview.XXXXXXXX")"
trap 'rm -rf "$OUT_DIR"' EXIT

DISTROZSH_PREVIEW_OUT_DIR="$OUT_DIR" "$REPO_DIR/scripts/preview.sh" --all --plain
rc=$?
t_eq "$rc" "0" "preview --all --plain exits 0"

ansi=$(ls "$OUT_DIR"/*.ansi 2>/dev/null | wc -l)
txt=$(ls "$OUT_DIR"/*.txt 2>/dev/null | wc -l)

t_eq "$ansi" "$expect" "one .ansi per theme x layout ($themes themes x $layouts layouts)"
t_eq "$txt" "$expect" "one .txt per theme x layout with --plain"

first_file="$(ls "$OUT_DIR"/*.ansi 2>/dev/null | head -1)"
if [[ -s "$first_file" ]]; then
    t_ok "ansi files are non-empty"
else
    t_fail "ansi files are non-empty"
fi

t_pass