// 🎯 Dart imports:
import 'dart:typed_data';
import 'dart:ui';

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart' show visibleForTesting;

// 📦 Package imports:
import 'package:flame/components.dart';

/// The board scene's backdrop: a repeating tile covering the whole area it
/// is given (the whole screen, under the system UI and on the sides of the
/// board on tablets and foldables). The tile grid is aligned on the board's
/// cells, so the decor lines up with the grid wherever it shows.
///
/// The tile is a placeholder, ×1 only, like the cells (see
/// `BoardComponent`).
class DecorComponent extends PositionComponent with HasGameReference {
  static const tileImage = 'board/decor.png';

  late final Image _tile;
  final _paint = Paint();
  Offset _boardOrigin = Offset.zero;

  /// Where the tile grid starts within the component, in game pixels: the
  /// board's corner, brought back within the first tile.
  @visibleForTesting
  Offset get tileOffset => Offset(
    _boardOrigin.dx % _tile.width,
    _boardOrigin.dy % _tile.height,
  );

  @override
  Future<void> onLoad() async {
    _tile = await game.images.load(tileImage);
    _updateShader();
  }

  /// Covers [area], with the tiles aligned on [board], both in the parent's
  /// coordinates.
  void cover(Rect area, {required Rect board}) {
    position.setValues(area.left, area.top);
    size.setValues(area.width, area.height);
    _boardOrigin = board.topLeft - area.topLeft;
    if (isLoaded) {
      _updateShader();
    }
  }

  // Rebuilt on resize only, never per frame. Nearest-neighbor sampling keeps
  // the tile's pixels sharp; the rectangle's edges, which Impeller softens,
  // lie off-screen.
  void _updateShader() {
    final offset = tileOffset;
    _paint.shader = ImageShader(
      _tile,
      TileMode.repeated,
      TileMode.repeated,
      // Column-major translation matrix.
      Float64List.fromList([
        1, 0, 0, 0, //
        0, 1, 0, 0, //
        0, 0, 1, 0, //
        offset.dx, offset.dy, 0, 1,
      ]),
      filterQuality: FilterQuality.none,
    );
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), _paint);
  }
}
