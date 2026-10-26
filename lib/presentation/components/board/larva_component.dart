// 🎯 Dart imports:
import 'dart:ui';

// 📦 Package imports:
import 'package:flame/components.dart';

// 🌎 Project imports:
import 'package:apiary/domain/bees/family.dart';
import 'package:apiary/presentation/components/board/family_sprites.dart';
import 'package:apiary/presentation/game/screen_layout.dart';

/// A larva, drawn as the larva of her family: the family's outline (a
/// separate sprite hugging the larva's silhouette, see "Univers visuel" in
/// `docs/DESIGN.md`) under the larva. Its parent places it on its cell; the board
/// handles taps.
class LarvaComponent extends PositionComponent with HasGameReference {
  LarvaComponent({required this.family, super.position})
    : super(size: Vector2.all(ScreenLayout.itemSize));

  final Family family;

  @override
  Future<void> onLoad() async {
    final [border, larva] = await game.images.loadAll([
      family.larvaBorderImage,
      family.larvaImage,
    ]);
    // Nearest-neighbor, so pixels stay sharp at fractional scales.
    final paint = Paint()..filterQuality = FilterQuality.none;
    // Bottom to top: the outline never covers the larva.
    for (final (image, layerPaint) in [
      (border, family.borderPaint),
      (larva, paint),
    ]) {
      await add(
        SpriteComponent(
          sprite: Sprite(image),
          paint: layerPaint,
          size: size,
        ),
      );
    }
  }
}
