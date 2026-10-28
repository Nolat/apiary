// 🎯 Dart imports:
import 'dart:ui';

// 📦 Package imports:
import 'package:flame/components.dart';

// 🌎 Project imports:
import 'package:apiary/domain/board/board_position.dart';
import 'package:apiary/presentation/components/pixel_paint.dart';
import 'package:apiary/presentation/game/screen_layout.dart';

/// The check badges the board wears: one on the top-right corner of each cell
/// whose resource an order counts (see `OrderProgress`). It only draws the
/// [marked] cells it is given, on the board's coordinates.
class ItemMarksComponent extends Component with HasGameReference {
  static const image = 'board/order_mark.png';

  /// The badge sprite's side.
  static const double markSize = 7;

  Sprite? _sprite;
  final Paint _paint = pixelPaint();
  var _rects = <BoardPosition, Rect>{};
  BoardPosition? _hidden;

  /// The cells wearing a badge.
  Set<BoardPosition> get marked => _rects.keys.toSet();

  set marked(Set<BoardPosition> cells) {
    _rects = {for (final cell in cells) cell: _rectOf(cell)};
  }

  /// A cell whose badge is not drawn for now, the one of an item the finger
  /// holds: the badge would stay behind on the cell it left.
  // ignore: avoid_setters_without_getters
  set hidden(BoardPosition? cell) => _hidden = cell;

  static Rect _rectOf(BoardPosition cell) => Rect.fromLTWH(
    (cell.column + 1) * ScreenLayout.cellSize - markSize,
    cell.row * ScreenLayout.cellSize,
    markSize,
    markSize,
  );

  @override
  Future<void> onLoad() async {
    _sprite = Sprite(await game.images.load(image));
  }

  @override
  void render(Canvas canvas) {
    final sprite = _sprite;
    if (sprite == null) {
      return;
    }
    for (final MapEntry(key: cell, value: rect) in _rects.entries) {
      if (cell != _hidden) {
        sprite.renderRect(canvas, rect, overridePaint: _paint);
      }
    }
  }
}
