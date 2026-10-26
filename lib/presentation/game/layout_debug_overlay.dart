// 🎯 Dart imports:
import 'dart:ui';

// 🐦 Flutter imports:
import 'package:flutter/painting.dart' show TextStyle;

// 📦 Package imports:
import 'package:flame/components.dart';

// 🌎 Project imports:
import 'package:apiary/core/theme/app_colors.dart';
import 'package:apiary/presentation/game/apiary_game.dart';
import 'package:apiary/presentation/game/screen_layout.dart';

/// Debug-only test card for the screen layout, shown when the app is built
/// with `--dart-define=APIARY_LAYOUT_DEBUG=true` (see
/// `tool/screenshots/ios.sh`, which measures it on screenshots). Added to the
/// camera's viewfinder, so it is drawn above the world and its router:
///
/// - a 1-game-pixel outline inside each [ScreenLayout] band, 1 pixel in from
///   its edges so adjacent bands stay apart: [AppColors.honey] for the
///   board, [AppColors.accent] for the others (the spacer has none);
/// - a checkerboard of 1-game-pixel [AppColors.accent] squares centered in the
///   board's first cell, each ⌊s⌋ or ⌈s⌉ physical pixels wide for a scale s. It is a
///   16×16 image drawn like a sprite (nearest-neighbor), so it shows how
///   pixel art renders: shapes, like the outlines, get soft edges at a
///   fractional scale (Impeller always anti-aliases geometry), image pixels
///   don't;
/// - the scale and screen size, as text, in the board under the
///   checkerboard.
class LayoutDebugOverlay extends Component with HasGameReference<ApiaryGame> {
  // static const enabled = bool.fromEnvironment('APIARY_LAYOUT_DEBUG');
  static const enabled = true;

  /// Size of the checkerboard, in game pixels, and its offset from the
  /// board's corner: centered in the board's first cell.
  static const checkerboardSize = 16;
  static const double checkerboardOffset =
      (ScreenLayout.cellSize - checkerboardSize) / 2;

  final _boardPaint = Paint()..color = AppColors.honey;
  final _bandPaint = Paint()..color = AppColors.accent;
  final _imagePaint = Paint()..filterQuality = FilterQuality.none;
  final TextComponent _label = TextComponent(
    textRenderer: TextPaint(
      style: const TextStyle(color: AppColors.accent, fontSize: 8),
    ),
  );
  static final _checkerboardSource = Rect.fromLTWH(
    0,
    0,
    checkerboardSize.toDouble(),
    checkerboardSize.toDouble(),
  );
  late final Image _checkerboard;
  List<Rect> _boardOutline = const [];
  List<Rect> _bandOutlines = const [];
  Rect _checkerboardDestination = Rect.zero;

  @override
  Future<void> onLoad() async {
    _checkerboard = _drawCheckerboard();
    await add(_label);
  }

  /// The checkerboard at one image pixel per game pixel.
  static Image _drawCheckerboard() {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = AppColors.accent;
    for (var y = 0; y < checkerboardSize; y++) {
      for (var x = y.isEven ? 0 : 1; x < checkerboardSize; x += 2) {
        canvas.drawRect(
          Rect.fromLTWH(x.toDouble(), y.toDouble(), 1, 1),
          paint,
        );
      }
    }
    return recorder.endRecording().toImageSync(
      checkerboardSize,
      checkerboardSize,
    );
  }

  /// A 1-pixel outline 1 pixel inside [band].
  static List<Rect> _outline(Rect band) {
    final inner = band.deflate(1);
    return [
      Rect.fromLTWH(inner.left, inner.top, inner.width, 1),
      Rect.fromLTWH(inner.left, inner.bottom - 1, inner.width, 1),
      Rect.fromLTWH(inner.left, inner.top, 1, inner.height),
      Rect.fromLTWH(inner.right - 1, inner.top, 1, inner.height),
    ];
  }

  @override
  void onRemove() {
    _checkerboard.dispose();
    super.onRemove();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    final layout = game.layout;
    _boardOutline = _outline(layout.board);
    _bandOutlines = [
      for (final band in [layout.hud, layout.orders, layout.bottomBar])
        ..._outline(band),
    ];
    _checkerboardDestination = Rect.fromLTWH(
      layout.board.left + checkerboardOffset,
      layout.board.top + checkerboardOffset,
      checkerboardSize.toDouble(),
      checkerboardSize.toDouble(),
    );
    _label
      ..position.setValues(
        layout.board.left + checkerboardOffset,
        layout.board.top + 30,
      )
      ..text =
          '×${game.gameViewport.pixelScale.toStringAsFixed(3)} · '
          '${layout.screen.width.toStringAsFixed(1)}×'
          '${layout.screen.height.toStringAsFixed(1)}';
  }

  @override
  void render(Canvas canvas) {
    for (final rect in _bandOutlines) {
      canvas.drawRect(rect, _bandPaint);
    }
    for (final rect in _boardOutline) {
      canvas.drawRect(rect, _boardPaint);
    }
    canvas.drawImageRect(
      _checkerboard,
      _checkerboardSource,
      _checkerboardDestination,
      _imagePaint,
    );
  }
}
