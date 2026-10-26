// 🎯 Dart imports:
import 'dart:ui';

// 📦 Package imports:
import 'package:flame/components.dart';

// 🌎 Project imports:
import 'package:apiary/domain/bees/family.dart';
import 'package:apiary/presentation/components/board/family_sprites.dart';
import 'package:apiary/presentation/game/screen_layout.dart';

/// A bee, drawn as the bee of her family: the family's outline (a separate
/// sprite hugging the bee's silhouette, see "Univers visuel" in
/// `docs/DESIGN.md`) under the bee. Its parent places it on its cell; the
/// board handles taps.
class BeeComponent extends PositionComponent with HasGameReference {
  BeeComponent({required this.family, super.position})
    : super(size: Vector2.all(ScreenLayout.itemSize));

  final Family family;

  @override
  Future<void> onLoad() async {
    final [border, bee] = await game.images.loadAll([
      family.beeBorderImage,
      family.beeImage,
    ]);
    // Nearest-neighbor, so pixels stay sharp at fractional scales.
    final paint = Paint()..filterQuality = FilterQuality.none;
    // Bottom to top: the outline never covers the bee.
    for (final (image, layerPaint) in [
      (border, family.borderPaint),
      (bee, paint),
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
