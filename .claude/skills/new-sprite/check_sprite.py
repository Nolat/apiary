#!/usr/bin/env python3
"""Checks a pixel-art sprite pair (x1 + optional x2) for Apiary.

Usage: check_sprite.py <x1.png> [<x2.png>] [--size WxH]

Errors (exit 1): not a PNG, size mismatch, semi-transparent pixels, x2 not
exactly twice the x1 size. Info: colour count, whether x2 is a plain
nearest-neighbour upscale of x1.
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
    parser.add_argument("x1")
    parser.add_argument("x2", nargs="?")
    parser.add_argument("--size", help="expected x1 size, e.g. 16x16 for a board item")
    args = parser.parse_args()

    ok = True
    x1 = load(args.x1)
    print(f"{args.x1}: {x1.width}x{x1.height}, {len(set(pixels(x1)))} colours")
    if args.size:
        width, height = (int(v) for v in args.size.lower().split("x"))
        if (x1.width, x1.height) != (width, height):
            print(f"ERROR {args.x1}: expected {width}x{height}")
            ok = False
    ok &= check_alpha(args.x1, x1)

    if args.x2:
        x2 = load(args.x2)
        print(f"{args.x2}: {x2.width}x{x2.height}, {len(set(pixels(x2)))} colours")
        if (x2.width, x2.height) != (x1.width * 2, x1.height * 2):
            print(f"ERROR {args.x2}: expected {x1.width * 2}x{x1.height * 2} (twice the x1 size)")
            ok = False
        else:
            upscale = x1.resize(x2.size, Image.NEAREST)
            same = list(pixels(upscale)) == list(pixels(x2))
            print("INFO x2 is " + ("a plain nearest-neighbour upscale of x1" if same else "redrawn (differs from a plain upscale of x1)"))
        ok &= check_alpha(args.x2, x2)

    print("OK" if ok else "FAILED")
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
