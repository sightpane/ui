#!/usr/bin/env python3
# sightpane — error tracking, product analytics and session replay you host yourself.
# Copyright (C) 2026 Can Us
#
# SPDX-License-Identifier: AGPL-3.0-or-later

"""Draws the favicon and the PWA icons from the same geometry the widget uses.

The mark lives in `lib/shared/brand.dart` as a CustomPainter, which the browser
tab and the app launcher cannot reach — they need PNG files. Rather than commit
five images nobody can regenerate, this redraws them from the numbers in the
identity study, so a change to the mark is a change to one grid here and one
painter there.

    python3 tool/gen_icons.py

Everything is in units of a 64-unit grid, exactly as in brand.dart:

    frame    rounded rect 4,4 → 60,60, radius 14, stroke 4
    mullion  vertical at x=40, horizontal at y=38 stopping at the mullion
    pane     40,6 → 58,58, clipped to the inner opening (6,6 → 58,58, radius 12)
"""

from pathlib import Path

from PIL import Image, ImageDraw

# Straight from lib/app/theme/tokens.dart, except PAPER: the tokens have no
# light ground because the product never renders one, but an icon needs a frame
# colour that holds against the amber pane.
INK = (0x0E, 0x0D, 0x0B, 255)  # Tokens.bg
AMBER = (0xF8, 0xA8, 0x18, 255)  # Tokens.brand
PAPER = (0xF4, 0xF1, 0xEC, 255)

GRID = 64
# Supersampling factor. The mark is all long straight strokes, so drawing big
# and shrinking with LANCZOS is what keeps the 4-unit stroke from crawling.
SS = 8

WEB = Path(__file__).resolve().parent.parent / "web"


def draw_mark(size: int, frame: tuple, simplified: bool) -> Image.Image:
    """The mark alone, transparent behind it, at [size] pixels square."""
    n = size * SS
    k = n / GRID
    img = Image.new("RGBA", (n, n), (0, 0, 0, 0))

    # The lit pane, masked to the inner opening so it cannot spill over the
    # frame's rounded corner.
    pane = Image.new("RGBA", (n, n), (0, 0, 0, 0))
    ImageDraw.Draw(pane).rectangle([40 * k, 6 * k, 58 * k, 58 * k], fill=AMBER)
    mask = Image.new("L", (n, n), 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        [6 * k, 6 * k, 58 * k, 58 * k], radius=12 * k, fill=255
    )
    img.paste(pane, (0, 0), mask)

    d = ImageDraw.Draw(img)
    # An SVG stroke straddles its path; Pillow draws inward from the box. The
    # box is therefore the outer edge — 4,4 minus half a stroke — and the radius
    # grows by the same half.
    w = round(4 * k)
    d.rounded_rectangle(
        [2 * k, 2 * k, 62 * k, 62 * k], radius=16 * k, outline=frame, width=w
    )
    d.line([(40 * k, 4 * k), (40 * k, 60 * k)], fill=frame, width=w)
    if not simplified:
        d.line([(4 * k, 38 * k), (40 * k, 38 * k)], fill=frame, width=w)

    return img.resize((size, size), Image.LANCZOS)


def icon(size: int, *, mark_ratio: float, corner_ratio: float) -> Image.Image:
    """The mark on an ink ground, centred.

    [corner_ratio] of 0 is a full-bleed square, which is what a maskable icon
    has to be: the launcher crops it to whatever shape the platform wants, and
    a rounded PNG would be rounded twice.
    """
    n = size * SS
    img = Image.new("RGBA", (n, n), (0, 0, 0, 0))
    if corner_ratio > 0:
        ImageDraw.Draw(img).rounded_rectangle(
            [0, 0, n - 1, n - 1], radius=corner_ratio * n, fill=INK
        )
    else:
        ImageDraw.Draw(img).rectangle([0, 0, n - 1, n - 1], fill=INK)
    img = img.resize((size, size), Image.LANCZOS)

    m = round(size * mark_ratio)
    # Small icons take the simplified mark for the same reason the widget does:
    # the horizontal mullion collides with the corner radius once the stroke is
    # down to a pixel.
    mark = draw_mark(m, PAPER, simplified=m < 40)
    img.alpha_composite(mark, ((size - m) // 2, (size - m) // 2))
    return img


def main() -> None:
    (WEB / "icons").mkdir(parents=True, exist_ok=True)

    # The tab. 32 px rather than 16 so it still has something to show on a
    # high-density display, on the ink ground so the frame reads against a
    # light and a dark tab strip alike.
    icon(32, mark_ratio=0.72, corner_ratio=0.22).save(WEB / "favicon.png")

    # Installed-app icons. 0.615 and radius 24/104 are the proportions of the
    # app icon in the identity study.
    for size in (192, 512):
        icon(size, mark_ratio=0.615, corner_ratio=24 / 104).save(
            WEB / "icons" / f"Icon-{size}.png"
        )

    # Maskable: full bleed, and the mark small enough to survive the platform
    # cropping it to a circle. A centred square of side s has its corners at
    # s·√2/2 from the middle, and the safe zone is a circle of radius 0.4, so
    # anything past 0.566 can lose a corner.
    for size in (192, 512):
        icon(size, mark_ratio=0.55, corner_ratio=0).save(
            WEB / "icons" / f"Icon-maskable-{size}.png"
        )

    for p in sorted(WEB.rglob("*.png")):
        print(f"{p.relative_to(WEB.parent)}  {Image.open(p).size[0]}px")


if __name__ == "__main__":
    main()
