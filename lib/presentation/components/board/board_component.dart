// 🎯 Dart imports:
import 'dart:ui';

// 📦 Package imports:
import 'package:flame/components.dart';

// 🌎 Project imports:
import 'package:apiary/presentation/game/screen_layout.dart';

/// The 7×9 grid of [ScreenLayout.cellSize] cells, all empty for now: a
/// checkerboard of light and dark cell sprites, so each cell stands apart
/// from its neighbours. Its parent places it on [ScreenLayout.board].
///
/// The cell sprites are placeholders until the visual universe is set (see
/// `docs/DESIGN.md`, "Direction artistique"). Only the ×1 files are loaded:
/// picking the ×2 ones from the viewport's scale is still open (see
/// `docs/STACK.md`).
class BoardComponent extends PositionComponent with HasGameReference {
  BoardComponent()
    : super(
        size: Vector2(
          ScreenLayout.boardSize.width,
          ScreenLayout.boardSize.height,
        ),
      );

  static const lightCellImage = 'board/cell_light.png';
  static const darkCellImage = 'board/cell_dark.png';

  @override
  Future<void> onLoad() async {
    final [lightCell, darkCell] = await game.images.loadAll([
      lightCellImage,
      darkCellImage,
    ]);
    final lightSprite = Sprite(lightCell);
    final darkSprite = Sprite(darkCell);
    // One paint for every cell: nearest-neighbor, so pixels stay sharp at
    // fractional scales.
    final paint = Paint()..filterQuality = FilterQuality.none;
    for (var row = 0; row < ScreenLayout.boardRows; row++) {
      for (var column = 0; column < ScreenLayout.boardColumns; column++) {
        await add(
          SpriteComponent(
            sprite: (row + column).isEven ? lightSprite : darkSprite,
            paint: paint,
            position: Vector2(
              column * ScreenLayout.cellSize,
              row * ScreenLayout.cellSize,
            ),
            size: Vector2.all(ScreenLayout.cellSize),
          ),
        );
      }
    }
  }
}
