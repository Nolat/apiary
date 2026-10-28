"""Checks screenshots of the app built with APIARY_LAYOUT_DEBUG=true.

Measures the LayoutDebugOverlay test card (lib/presentation/game/
layout_debug_overlay.dart) on each screenshot, for a scale s (physical
pixels per game pixel, usually fractional), and checks that:
- the board is 140s x 180s physical pixels;
- the board is centered, with a few game pixels of margin each side on an
  iPhone (the scale fits the height); on the screens given with
  --centered=shot.png (tablets, foldables) off center is only a warning, the
  safe area may require it (a camera hole on one side);
- scanned top to bottom, the band outlines come in order — hud, orders,
  board, bottom bar — with none overlapping;
- every game pixel inside the checkerboard (an image, drawn like a sprite) is
  floor(s) or ceil(s) physical pixels (nearest-neighbor scaling, no blur);
  the checkerboard's outer edges may be soft, as the GPU anti-aliases them.

Screens that iOS downsamples (iPhone mini, "Plus" models: the app renders at
@3x, then iOS shrinks the image to the panel) blur the checkerboard: give
them with --downsampled=shot.png, their checkerboard checks become warnings.

    python3 check_layout.py shot.png...          # check, exit 1 on failure
    python3 check_layout.py --ready shot.png [previous.png]
        # exit 0 once the board scene shows (not the splash screen, which the
        # card is drawn over too) and, given previous.png, nothing moved since
"""

import math
import sys

from PIL import Image, ImageChops

BOARD = (140, 180)  # game pixels, see ScreenLayout
CHECKERBOARD_OFFSET = 8  # game pixels from the board's corner
CHECKERBOARD_SIZE = 16
HONEY = (0xF2, 0xC1, 0x4E)  # AppColors.honey: board outline
ACCENT = (0xE5, 0x9A, 0x1F)  # AppColors.accent: other bands, checkerboard
TOLERANCE = 12
WOOD = (0x24, 0x14, 0x0D)  # the board scene's backdrop (the splash is darker)
WOOD_TOLERANCE = 3
WOOD_SHARE = 0.05  # of the screen, at least, once the board scene is up


def close(pixel, color):
    return all(abs(a - b) <= TOLERANCE for a, b in zip(pixel, color))


def mask(image, color):
    """Black and white image: white where the pixel is close to color."""
    bands = [
        band.point(lambda v, c=c: 255 if abs(v - c) <= TOLERANCE else 0)
        for band, c in zip(image.split(), color)
    ]
    return ImageChops.multiply(ImageChops.multiply(bands[0], bands[1]), bands[2])


def runs(pixels, color):
    """Lengths of the alternating runs of color / not color."""
    lengths, current, inside = [], 0, close(pixels[0], color)
    for pixel in pixels:
        if close(pixel, color) == inside:
            current += 1
        else:
            lengths.append(current)
            current, inside = 1, not inside
    lengths.append(current)
    return lengths


def classify(pixel):
    return "H" if close(pixel, HONEY) else "A" if close(pixel, ACCENT) else None


def lines(pixels):
    """Colors of the outline lines crossed, in order, as "H" or "A"."""
    found, previous = [], None
    for pixel in pixels:
        current = classify(pixel)
        if current and current != previous:
            found.append(current)
        previous = current
    return found


def outline_box(image):
    """Bounding box of the board's outline: the honey lines that run across
    most of the screen, which leaves out the honey of other sprites (the
    energy bolt, the coins), or the blends of them that a downsampled screen
    has."""
    honey = mask(image, HONEY)
    width, height = image.size
    columns = honey.resize((width, 1), Image.BOX).tobytes()
    rows = honey.resize((1, height), Image.BOX).tobytes()
    # The outline's sides are the board's height, its top and bottom the
    # board's width: at least 40 % of the screen's in all cases.
    xs = [x for x, v in enumerate(columns) if v >= 0.4 * 255]
    ys = [y for y, v in enumerate(rows) if v >= 0.4 * 255]
    if not xs or not ys:
        return None
    return xs[0], ys[0], xs[-1] + 1, ys[-1] + 1


def ready(path, previous=None):
    """Whether the board scene is up in the screenshot, and still."""
    image = Image.open(path).convert("RGB")
    if outline_box(image) is None:
        return False
    # The test card is drawn over the splash screen too: tell them apart by
    # the wooden backdrop, which only the board scene has.
    bands = [
        band.point(lambda v, c=c: 255 if abs(v - c) <= WOOD_TOLERANCE else 0)
        for band, c in zip(image.split(), WOOD)
    ]
    wood = ImageChops.multiply(ImageChops.multiply(bands[0], bands[1]), bands[2])
    share = wood.histogram()[255] / (image.width * image.height)
    if share < WOOD_SHARE:
        return False
    if previous is None:
        return True
    try:
        before = Image.open(previous).convert("RGB")
    except FileNotFoundError:
        return False
    return before.size == image.size and not ImageChops.difference(
        image, before
    ).getbbox()


def check(path, downsampled=False, centered=False):
    """Returns (summary, failures, warnings)."""
    image = Image.open(path).convert("RGB")
    width, height = image.size
    pixels = image.load()

    box = outline_box(image)
    if box is None:
        return "no test card", ["board outline not found"], []
    # The outline is drawn 1 game pixel inside the board.
    scale = (box[2] - box[0]) / (BOARD[0] - 2)
    inset = round(scale)
    left, top, right, bottom = box[0] - inset, box[1] - inset, box[2] + inset, box[3] + inset
    board_width, board_height = right - left, bottom - top
    failures, warnings = [], []

    if abs(board_height - BOARD[1] * scale) > 2:
        failures.append(f"board is {board_width}x{board_height}, not 140s x 180s")

    if centered:
        # The board's left edge is rounded down to a whole game pixel, and the
        # screen's right edge to the nearest: 1.5 game pixels at most.
        if abs(left - (width - right)) > 1.5 * scale + 1:
            warnings.append(
                f"board not centered: {left} px left, {width - right} px right "
                f"(fine if the safe area requires it)"
            )
    elif abs(left - (width - right)) > 1.5 * scale + 1:
        failures.append(
            f"board not centered: {left} px left, {width - right} px right"
        )

    # A column inside the board's right edge, clear of the label and the
    # checkerboard, on the left.
    x = right - round(3 * scale)
    order = lines(pixels[x, y] for y in range(height))
    expected = ["A", "A", "A", "A", "H", "H", "A", "A"]
    if order != expected:
        failures.append(
            f"band outlines out of order or overlapping: {''.join(order)}, "
            f"expected {''.join(expected)} (hud, orders, board, bottom bar)"
        )

    sizes = {math.floor(scale), math.ceil(scale)}
    # Locate the checkerboard itself, in the board's corner, rather than
    # deduce it from the outline, whose blended edges skew the scale a bit.
    corner = (left, top, left + round(28 * scale), top + round(28 * scale))
    found = mask(image.crop(corner), ACCENT).getbbox()
    if found is None:
        failures.append("checkerboard not found")
        row = column = []
    else:
        x0, y0 = corner[0] + found[0], corner[1] + found[1]
        x1, y1 = corner[0] + found[2], corner[1] + found[3]
        # Through the middle of the first row and column of squares.
        middle = math.floor(scale / 2)
        row = [pixels[x, y0 + middle] for x in range(x0, x1)]
        column = [pixels[x0 + middle, y] for y in range(y0, y1)]
    for name, line in (("row", row), ("column", column)):
        if not line:
            continue
        lengths = runs(line, ACCENT)
        # The image's outer edges may be blended: only its inner pixels must
        # be exact, the outer ones within a pixel.
        inner_ok = set(lengths[1:-1]) <= sizes
        outer_ok = all(min(sizes) - 1 <= n <= max(sizes) for n in (lengths[0], lengths[-1]))
        if len(lengths) != CHECKERBOARD_SIZE or not (inner_ok and outer_ok):
            problem = (
                f"checkerboard {name}: game pixels of {sorted(set(lengths))} "
                f"physical px, expected {sorted(sizes)}"
            )
            (warnings if downsampled else failures).append(problem)

    summary = (
        f"x{scale:.3f}, board {board_width}x{board_height} at ({left}, {top}) "
        f"on {width}x{height}: {left} px left / {width - right} px right"
    )
    if downsampled:
        summary += " (downsampled by iOS)"
    return summary, failures, warnings


def main(args):
    if args and args[0] == "--ready":
        return 0 if ready(*args[1:]) else 1

    def flagged(flag):
        return {a.split("=", 1)[1] for a in args if a.startswith(f"--{flag}=")}

    downsampled, centered = flagged("downsampled"), flagged("centered")
    status = 0
    for path in (a for a in args if not a.startswith("--")):
        summary, failures, warnings = check(
            path, path in downsampled, path in centered
        )
        mark = "✘" if failures else "⚠" if warnings else "✔"
        print(f"{mark} {path}: {summary}")
        for failure in failures:
            print(f"    ✘ {failure}")
        for warning in warnings:
            print(f"    ⚠ {warning}")
        status |= bool(failures)
    return status


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
