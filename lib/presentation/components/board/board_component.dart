// 🎯 Dart imports:
import 'dart:ui';

// 📦 Package imports:
import 'package:flame/components.dart';

// 🌎 Project imports:
import 'package:apiary/domain/board/board.dart';
import 'package:apiary/domain/board/board_item.dart';
import 'package:apiary/domain/board/board_position.dart';
import 'package:apiary/presentation/components/board/generator_component.dart';
import 'package:apiary/presentation/game/screen_layout.dart';

/// The 7×9 grid of [ScreenLayout.cellSize] cells: a checkerboard of light and
/// dark wooden cell sprites, so each cell stands apart from its neighbours,
/// with the items of its [board] on top. Its parent places it on
/// [ScreenLayout.board].
///
/// The look follows the visual universe in `docs/DESIGN.md` ("Univers
/// visuel").
class BoardComponent extends PositionComponent with HasGameReference {
  BoardComponent({required this.board})
    : super(
        size: Vector2(
          ScreenLayout.boardSize.width,
          ScreenLayout.boardSize.height,
        ),
      );

  /// What to draw on the grid; it is not observed yet.
  final Board board;

  static const lightCellImage = 'board/cell_light.png';
  static const darkCellImage = 'board/cell_dark.png';

  /// Where an item sits in this component for the cell [position]: centered
  /// in it, with a margin around.
  static Vector2 itemPosition(BoardPosition position) => Vector2(
    position.column * ScreenLayout.cellSize + ScreenLayout.itemMargin,
    position.row * ScreenLayout.cellSize + ScreenLayout.itemMargin,
  );

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
    for (var row = 0; row < Board.rows; row++) {
      for (var column = 0; column < Board.columns; column++) {
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
    for (final MapEntry(key: position, value: item) in board.items.entries) {
      await add(
        switch (item) {
          FamilyGenerator(:final family) => GeneratorComponent(
            family: family,
            position: itemPosition(position),
          ),
        },
      );
    }
  }
}
