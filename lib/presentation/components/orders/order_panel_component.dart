// 🎯 Dart imports:
import 'dart:ui';

// 📦 Package imports:
import 'package:flame/components.dart';

// 🌎 Project imports:
import 'package:apiary/presentation/components/pixel_paint.dart';

/// A 9-slice panel from an image, whose edges are `ring` px wide: the corners
/// keep their size, the edges and the middle are stretched over [size]. Drawn
/// as nine stretched parts with nearest-neighbor, rather than as a
/// `PixelPanelComponent`: the 9-slice behind the first card of the orders
/// strip never showed over the decor (goldens), where these do.
class OrderPanelComponent extends PositionComponent {
  OrderPanelComponent(
    Image image, {
    required Vector2 size,
    required int ring,
    super.position,
  }) : _parts = _partsOf(image, size, ring),
       super(size: size);

  final List<(Sprite, Rect)> _parts;
  final Paint _paint = pixelPaint();

  static List<(Sprite, Rect)> _partsOf(Image image, Vector2 size, int ring) {
    final edge = ring.toDouble();
    // Per column and row: where it starts and how long it is, in the sprite
    // and on the panel.
    final spriteX = [0.0, edge, image.width - edge];
    final spriteY = [0.0, edge, image.height - edge];
    final spriteWidth = [edge, image.width - 2 * edge, edge];
    final spriteHeight = [edge, image.height - 2 * edge, edge];
    final panelX = [0.0, edge, size.x - edge];
    final panelY = [0.0, edge, size.y - edge];
    final panelWidth = [edge, size.x - 2 * edge, edge];
    final panelHeight = [edge, size.y - 2 * edge, edge];
    return [
      for (var row = 0; row < 3; row++)
        for (var column = 0; column < 3; column++)
          (
            Sprite(
              image,
              srcPosition: Vector2(spriteX[column], spriteY[row]),
              srcSize: Vector2(spriteWidth[column], spriteHeight[row]),
            ),
            Rect.fromLTWH(
              panelX[column],
              panelY[row],
              panelWidth[column],
              panelHeight[row],
            ),
          ),
    ];
  }

  @override
  void render(Canvas canvas) {
    for (final (sprite, rect) in _parts) {
      sprite.renderRect(canvas, rect, overridePaint: _paint);
    }
  }
}
