// 🎯 Dart imports:
import 'dart:ui';

// 📦 Package imports:
import 'package:flame/components.dart';

/// A loading bar: a frame with a hollow groove, and a fill growing from the
/// left inside it. Both are sprites, so the edges stay sharp at fractional
/// scales, and the fill grows by whole pixels.
class ProgressBarComponent extends PositionComponent with HasGameReference {
  ProgressBarComponent({required double width, super.position})
    : super(size: Vector2(width, barHeight));

  static const frameImage = 'ui/progress_bar_frame.png';
  static const fillImage = 'ui/progress_bar_fill.png';

  /// The frame sprite is 7×7: its 9-slice stretches the one-pixel-wide middle,
  /// and its groove, 2 px tall, starts [_groove] in from each side.
  static const _frameTileSize = 3;
  static const _groove = 2.0;
  static const double barHeight = 7;

  /// The fill sprite is 7×7 too, with its 3×2 pixels of color in the middle;
  /// only those are stretched along the groove.
  static const _fillSource = Rect.fromLTWH(2, 2, 3, 2);

  late final SpriteComponent _fill;
  double _value = 0;

  /// How much of the bar is filled, from 0 to 1.
  double get value => _value;
  set value(double value) {
    _value = value.clamp(0, 1);
    if (isLoaded) {
      _updateFill();
    }
  }

  /// The fill's width, in whole game pixels.
  double get fillWidth => isLoaded ? _fill.size.x : 0;

  @override
  Future<void> onLoad() async {
    final [frame, fill] = await game.images.loadAll([frameImage, fillImage]);
    _fill = SpriteComponent(
      sprite: Sprite(
        fill,
        srcPosition: Vector2(_fillSource.left, _fillSource.top),
        srcSize: Vector2(_fillSource.width, _fillSource.height),
      ),
      position: Vector2.all(_groove),
      size: Vector2(0, _fillSource.height),
      // Nearest-neighbor, so pixels stay sharp at fractional scales.
      paint: Paint()..filterQuality = FilterQuality.none,
    );
    await addAll([
      NineTileBoxComponent(
        nineTileBox: NineTileBox(
          Sprite(frame),
          tileSize: _frameTileSize,
          destTileSize: _frameTileSize,
        ),
        size: size,
      ),
      _fill,
    ]);
    _updateFill();
  }

  void _updateFill() =>
      _fill.size.x = ((size.x - 2 * _groove) * _value).floorToDouble();
}
