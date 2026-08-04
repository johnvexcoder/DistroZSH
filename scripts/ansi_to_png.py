#!/usr/bin/env python3
"""
ansi_to_png.py - render an ANSI-colored text file to a PNG screenshot.

Used by scripts/make-screenshots.sh to turn the .ansi previews produced by
scripts/preview.sh into PNG screenshots for the README.

Usage:
    ansi_to_png.py input.ansi output.png [--font PATH] [--size N] [--pad N]
"""

import argparse
import re
import sys

from PIL import Image, ImageDraw, ImageFont

# Standard xterm-ish palette for the 8/16 basic colors (indexes 0..15).
BASIC_COLORS = [
    (0x1D, 0x1F, 0x21),  # 0  black
    (0xCC, 0x33, 0x33),  # 1  red
    (0x66, 0xCC, 0x66),  # 2  green
    (0xF2, 0xBB, 0x66),  # 3  yellow
    (0x66, 0x99, 0xCC),  # 4  blue
    (0xCC, 0x99, 0xCC),  # 5  magenta
    (0x66, 0xCC, 0xCC),  # 6  cyan
    (0xDD, 0xDD, 0xDD),  # 7  white
    (0x66, 0x66, 0x66),  # 8  bright black
    (0xF0, 0x77, 0x77),  # 9  bright red
    (0x99, 0xE5, 0x99),  # 10 bright green
    (0xF7, 0xCC, 0x88),  # 11 bright yellow
    (0x88, 0xBB, 0xEE),  # 12 bright blue
    (0xDD, 0xAA, 0xDD),  # 13 bright magenta
    (0x88, 0xDD, 0xDD),  # 14 bright cyan
    (0xFD, 0xFD, 0xFD),  # 15 bright white
]


def xterm_256(n):
    """Map an xterm 256-color index to RGB."""
    if n < 16:
        return BASIC_COLORS[n]
    if n < 232:
        n -= 16
        level = [0, 95, 135, 175, 215, 255]
        r = level[n // 36]
        g = level[(n // 6) % 6]
        b = level[n % 6]
        return (r, g, b)
    v = 8 + (n - 232) * 10
    return (v, v, v)


def strip_colors(text):
    """Return text with ANSI escapes removed."""
    return re.sub(r"\x1b\[[0-9;]*[a-zA-Z]", "", text)


def cell_size(font, cell):
    """Measure the pixel box of a reference cell for the given font."""
    d = ImageDraw.Draw(Image.new("RGB", (1, 1)))
    bbox = d.textbbox((0, 0), cell, font=font)
    return (bbox[2] - bbox[0], bbox[3] - bbox[1])


def render(input_path, output_path, font_path, size, pad, background):
    font = ImageFont.truetype(font_path, size)
    cell_w, cell_h = cell_size(font, "M")
    ascent, descent = font.getmetrics()

    with open(input_path, "r", encoding="utf-8") as fh:
        raw = fh.read()

    lines = raw.splitlines()
    if not lines:
        sys.exit("empty input")

    # Parse the text into (char, fg, bold) cells.
    cells = []
    tokens = re.split(r"(\x1b\[[0-9;]*[a-zA-Z])", raw)
    fg = (0xE6, 0xE6, 0xE6)
    bold = False
    for token in tokens:
        if not token:
            continue
        m = re.match(r"\x1b\[([0-9;]*)m", token)
        if m:
            params = m.group(1)
            if not params:
                fg = (0xE6, 0xE6, 0xE6)
                bold = False
                continue
            codes = params.split(";")
            i = 0
            while i < len(codes):
                code = codes[i]
                if code in ("", "0"):
                    fg = (0xE6, 0xE6, 0xE6)
                    bold = False
                elif code == "1":
                    bold = True
                elif code == "39":
                    fg = (0xE6, 0xE6, 0xE6)
                elif code in ("30", "31", "32", "33", "34", "35", "36", "37"):
                    fg = BASIC_COLORS[int(code) - 30]
                elif code in ("90", "91", "92", "93", "94", "95", "96", "97"):
                    fg = BASIC_COLORS[int(code) - 90 + 8]
                elif code == "38" and i + 1 < len(codes):
                    if codes[i + 1] == "5" and i + 2 < len(codes):
                        fg = xterm_256(int(codes[i + 2]))
                        i += 2
                    elif codes[i + 1] == "2" and i + 4 < len(codes):
                        fg = tuple(max(0, min(255, int(p))) for p in codes[i + 2 : i + 5])
                        i += 4
                i += 1
            continue
        for ch in token:
            cells.append((ch, fg, bold))

    # Lay the cells out into rows.
    rows = []
    row = []
    for ch, fg, bold in cells:
        if ch == "\r":
            continue
        if ch == "\n":
            rows.append(row)
            row = []
            continue
        row.append((ch, fg, bold))
    rows.append(row)
    while rows and not rows[-1]:
        rows.pop()

    ncols = max(len(r) for r in rows)
    nrows = len(rows)
    line_h = ascent + descent
    img = Image.new("RGB", (ncols * cell_w + pad * 2, nrows * line_h + pad * 2), background)
    draw = ImageDraw.Draw(img)

    for y, row in enumerate(rows):
        baseline = pad + y * line_h + ascent
        for x, (ch, fg, bold) in enumerate(row):
            draw.text((pad + x * cell_w, baseline), ch, font=font, fill=fg)
            if bold:
                draw.text((pad + x * cell_w + 1, baseline), ch, font=font, fill=fg)

    img.save(output_path)
    print(f"  {output_path}")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("input")
    parser.add_argument("output")
    parser.add_argument("--font", default="/usr/share/fonts/google-noto-vf/NotoSansMono[wght].ttf")
    parser.add_argument("--size", type=int, default=20)
    parser.add_argument("--pad", type=int, default=14)
    parser.add_argument("--background", default="#14171C")
    args = parser.parse_args()

    def to_rgb(hex_color):
        hex_color = hex_color.lstrip("#")
        return tuple(int(hex_color[i : i + 2], 16) for i in (0, 2, 4))

    render(args.input, args.output, args.font, args.size, args.pad, to_rgb(args.background))


if __name__ == "__main__":
    main()
