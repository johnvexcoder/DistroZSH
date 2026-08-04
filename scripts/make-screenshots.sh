#!/usr/bin/env bash
#
# make-screenshots.sh - regenerate the PNG screenshots from the preview matrix
#
#   ./make-screenshots.sh          regenerate .ansi previews and .png screenshots
#   ./make-screenshots.sh --plain  also write plain-text copies
#
# Requires: zsh, python3 with Pillow, and a monospace TTF font. The preview
# matrix (.ansi) is always regenerated; PNGs are produced for every theme x
# layout so the README can embed a fresh matrix after theme changes.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
FONT="${DISTROZSH_PREVIEW_FONT:-/usr/share/fonts/google-noto-vf/NotoSansMono[wght].ttf}"

PLAIN=""
if [[ "${1:-}" == "--plain" ]]; then
    PLAIN="--plain"
fi

echo "==> Rendering preview matrix"
"$SCRIPT_DIR/preview.sh" --all $PLAIN

echo "==> Converting ANSI previews to PNG"
mkdir -p "$REPO_DIR/screenshots"
for ansi in "$REPO_DIR"/screenshots/*.ansi; do
    png="${ansi%.ansi}.png"
    python3 "$SCRIPT_DIR/ansi_to_png.py" --font "$FONT" "$ansi" "$png"
done

echo "==> Done: $(find "$REPO_DIR/screenshots" -name '*.png' | wc -l) PNG screenshots"
