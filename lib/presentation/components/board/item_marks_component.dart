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
  final _held = <BoardPosition, double>{};

  /// The cells wearing a badge.
  Set<BoardPosition> get marked => _rects.keys.toSet();

  set marked(Set<BoardPosition> cells) {
    _rects = {for (final cell in cells) cell: _rectOf(cell)};
  }

  /// Keeps the badge of [cell] from being drawn, for [seconds] or until
  /// [release]: while an item moves or lands there, the badge would show
  /// before it.
  void hold(BoardPosition cell, {double seconds = double.infinity}) =>
      _held[cell] = seconds;

  void release(BoardPosition cell) => _held.remove(cell);

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
  void update(double dt) {
    if (_held.isNotEmpty) {
      _held
        ..updateAll((_, left) => left - dt)
        ..removeWhere((_, left) => left <= 0);
    }
  }

  @override
  void render(Canvas canvas) {
    final sprite = _sprite;
    if (sprite == null) {
      return;
    }
    for (final MapEntry(key: cell, value: rect) in _rects.entries) {
      if (!_held.containsKey(cell)) {
        sprite.renderRect(canvas, rect, overridePaint: _paint);
      }
    }
  }
}
