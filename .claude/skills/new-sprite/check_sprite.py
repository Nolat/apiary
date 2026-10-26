#!/usr/bin/env python3
"""Checks a pixel-art sprite for Apiary.

Usage: check_sprite.py <png> [--size WxH]

Errors (exit 1): not a PNG, size mismatch, semi-transparent pixels. Info:
colour count.
"""

import argparse
import sys

from PIL import Image


def load(path):
    image = Image.open(path)
    if image.format != "PNG":
        sys.exit(f"ERROR {path}: {image.format} file, expected PNG")
    return image.convert("RGBA")


def pixels(image):
    # RGBA bytes, grouped per pixel (Image.getdata is deprecated in Pillow 12).
    data = image.tobytes()
    return [tuple(data[i:i + 4]) for i in range(0, len(data), 4)]


def check_alpha(path, image):
    partial = sum(1 for (_, _, _, a) in pixels(image) if 0 < a < 255)
    if partial:
        print(f"ERROR {path}: {partial} semi-transparent pixel(s); pixel art needs alpha 0 or 255 only")
    return partial == 0


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("png")
    parser.add_argument("--size", help="expected size, e.g. 16x16 for a board item")
    args = parser.parse_args()

    ok = True
    image = load(args.png)
    print(f"{args.png}: {image.width}x{image.height}, {len(set(pixels(image)))} colours")
    if args.size:
        width, height = (int(v) for v in args.size.lower().split("x"))
        if (image.width, image.height) != (width, height):
            print(f"ERROR {args.png}: expected {width}x{height}")
            ok = False
    ok &= check_alpha(args.png, image)

    print("OK" if ok else "FAILED")
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
