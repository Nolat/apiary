---
name: new-sprite
description: Add a pixel-art sprite or sprite sheet to Apiary — validate the x1/x2 PNGs, place and declare them, load them once through Flame's image cache, wrap them in a component and cover it with a golden. Use when the user provides a new image asset (bee, larva, hive, resource, tile, HUD element).
argument-hint: <name> <path to x1 png> [path to x2 png]
---

Add this pixel-art asset to Apiary: $ARGUMENTS

Art direction (`docs/DESIGN.md`, "Direction artistique"): pixel art, reference resolution 240×480, assets also supplied at ×2 (480×960), pixel-perfect rendering — integer scaling only, no blurry interpolation. A board cell is **30×30 px** at x1.

## 1. Validate the files

```bash
python3 "${CLAUDE_SKILL_DIR}/check_sprite.py" <x1.png> [<x2.png>] [--size 30x30]
```

Pass `--size` when the expected size is known (30x30 for anything that sits in a board cell; for a sprite sheet, the full sheet size). Any `ERROR` blocks the import: report it to the user rather than "fixing" the art yourself (resampling or re-thresholding alpha changes the artist's pixels). Mention the `INFO` lines too.

For a **sprite sheet**, also ask (or read from the file name) the frame size and frame count, and check the sheet size is an exact multiple of the frame size.

## 2. Place and declare

- x1: `assets/images/<notion>/<name>.png`; x2: `assets/images/<notion>/2.0x/<name>.png` (Flutter's resolution-variant layout). `<notion>` follows the design vocabulary (`bees/`, `larvae/`, `hives/`, `resources/`, `board/`, `hud/`), `<name>` in `snake_case`.
- Declare the folder in `pubspec.yaml` under `flutter: assets:` (`- assets/images/<notion>/`) if it isn't already; the `2.0x/` variant is picked up automatically.
- Flame's image cache does **not** pick resolution variants by itself, and the integer-scaling strategy is still open (`CLAUDE.md`, "Rendering"; `docs/STACK.md`). Until it is decided, load the x1 file and tell the user that the x2 file is stored but not used yet.

## 3. Load and display

- Load once through Flame's cache — `game.images.load('<notion>/<name>.png')` (prefix `assets/images/`), preloaded in `ApiaryGame.onLoad()` or the scene's `onLoad()` — then `Sprite(game.images.fromCache(...))`. Never load per component instance.
- Sprite sheet: `SpriteSheet(image: …, srcSize: Vector2(frameW, frameH))` and `SpriteAnimation` with a named step time constant.
- The component lives in `lib/presentation/components/<notion>/`, sized and positioned in whole reference-resolution pixels (named constants, e.g. the 30 px cell). Keep the paint's `filterQuality` at `FilterQuality.none`, and create any `Paint` once, never in `render()`.
- The component only displays: what it represents comes from domain state.

## 4. Golden

Add or extend a golden (`testGameGolden`, see `docs/TESTING.md`) showing the sprite in context — e.g. on the board — at x1, one pixel per game pixel. Generate it on macOS with `fvm flutter test --update-goldens --tags golden <file>`, open the PNG, and check the sprite's pixels are crisp (no blending at the edges).

## 5. Check

```bash
fvm flutter analyze
fvm flutter test test/presentation/
```

Report in French: the checks' output, where the files went, how the sprite is loaded, the golden added, and whether the x2 asset is in use. Don't commit.
