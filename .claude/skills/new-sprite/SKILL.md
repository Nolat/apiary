---
name: new-sprite
description: Add a pixel-art sprite or sprite sheet to Apiary — validate the x1/x2 PNGs, place and declare them, load them once through Flame's image cache, wrap them in a component and cover it with a golden. Use when the user provides a new image asset (bee, larva, hive, resource, tile, HUD element).
argument-hint: <name> <path to x1 png> [path to x2 png]
---

Add this pixel-art asset to Apiary: $ARGUMENTS

Art direction (`docs/DESIGN.md`, "Direction artistique"; `CLAUDE.md`, "Rendering"; `docs/STACK.md`): pixel art, the screen is **140 game pixels wide** (minimum safe area 140×246, taller on most phones, wider on tablets), assets also supplied at ×2. The board is a 7×9 grid of **20×20 px** cells at x1 (**40×40** at ×2), holding **16×16 px** items at x1 (**32×32** at ×2, centered) — `ScreenLayout.cellSize` (`lib/presentation/game/screen_layout.dart`). The viewport scale is **fractional** (screen width ÷ 140 on iPhone), so pixel art is drawn **nearest-neighbor** (`FilterQuality.none`), never smoothed; and since Impeller anti-aliases drawn shapes at fractional scales, pixel art must be images (sprites), not `drawRect`/`Path` shapes.

## 1. Validate the files

```bash
python3 "${CLAUDE_SKILL_DIR}/check_sprite.py" <x1.png> [<x2.png>] [--size 32x32]
```

Pass `--size` when the expected size is known (16x16 for an item that sits in a board cell — `ScreenLayout.cellSize` (20) minus 2 px of margin per side — or 20x20 for the cell itself; for a sprite sheet, the full sheet size). Any `ERROR` blocks the import: report it to the user rather than "fixing" the art yourself (resampling or re-thresholding alpha changes the artist's pixels). Mention the `INFO` lines too.

For a **sprite sheet**, also ask (or read from the file name) the frame size and frame count, and check the sheet size is an exact multiple of the frame size.

## 2. Place and declare

- x1: `assets/images/<notion>/<name>.png`; x2: `assets/images/<notion>/2.0x/<name>.png` (Flutter's resolution-variant layout). `<notion>` follows the design vocabulary (`bees/`, `larvae/`, `hives/`, `resources/`, `board/`, `hud/`), `<name>` in `snake_case`.
- Declare the folder in `pubspec.yaml` under `flutter: assets:` (`- assets/images/<notion>/`) if it isn't already; the `2.0x/` variant is picked up automatically.
- Flame's image cache does **not** pick resolution variants by itself, and choosing ×1/×2 assets from `GameViewport.pixelScale` is still open (`CLAUDE.md`, "Rendering"; `docs/STACK.md`). Until it is decided, load the x1 file and tell the user that the x2 file is stored but not used yet.

## 3. Load and display

- Load once through Flame's cache — `game.images.load('<notion>/<name>.png')`, or `game.images.loadAll([...])` for several (prefix `assets/images/`), in `ApiaryGame.onLoad()`, the scene's or the owning component's `onLoad()` — then wrap the images in `Sprite`s shared by every instance. Never load per component instance.
- Existing example: `lib/presentation/components/board/board_component.dart` — the two cell images are loaded once with `game.images.loadAll`, wrapped in two `Sprite`s, and all 63 `SpriteComponent`s share a single `Paint` with `FilterQuality.none`, positioned in multiples of `ScreenLayout.cellSize`. Follow it.
- Sprite sheet: `SpriteSheet(image: …, srcSize: Vector2(frameW, frameH))` and `SpriteAnimation` with a named step time constant.
- The component lives in `lib/presentation/components/<notion>/`, sized and positioned in whole game pixels (named constants, e.g. `ScreenLayout.cellSize` for anything on the board — never a hard-coded 32). Set the paint's `filterQuality` to `FilterQuality.none` (nearest-neighbor, so pixels stay sharp at the fractional scale), and create any `Paint` once and share it, never in `render()`.
- The component only displays: what it represents comes from domain state.

## 4. Golden

Add or extend a golden (`testGameGolden`, see `docs/TESTING.md`) showing the sprite in context — e.g. on the board — at x1, one pixel per game pixel (`testGameGolden` renders at the 140×246 minimum, DPR 1). Generate it on macOS with `fvm flutter test --update-goldens --tags golden <file>`, open the PNG, and check the sprite's pixels are crisp (no blending at the edges).

## 5. Check

```bash
fvm flutter analyze
fvm flutter test test/presentation/
```

Report in French: the checks' output, where the files went, how the sprite is loaded, the golden added, and whether the x2 asset is in use. Don't commit.
