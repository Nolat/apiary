// 🎯 Dart imports:
import 'dart:ui';

// 📦 Package imports:
import 'package:flame/components.dart';

// 🌎 Project imports:
import 'package:apiary/domain/bees/family.dart';
import 'package:apiary/presentation/game/screen_layout.dart';

/// A family generator, drawn as a queen of its family: the family's bee, an
/// outline (a separate sprite hugging the queen's silhouette, see "Univers
/// visuel" in `docs/DESIGN.md`) and a crown. Inert for now: tapping it does
/// nothing. Its parent places it on its cell.
class GeneratorComponent extends PositionComponent with HasGameReference {
  GeneratorComponent({required this.family, super.position})
    : super(size: Vector2.all(ScreenLayout.itemSize));

  final Family family;

  static const borderImage = 'generators/border_queen.png';
  static const crownImage = 'generators/crown_queen.png';

  /// The family's bee, under the queen's outline and crown.
  static String beeImage(Family family) => switch (family) {
    Family.common => 'bees/common.png',
  };

  @override
  Future<void> onLoad() async {
    final [border, bee, crown] = await game.images.loadAll([
      borderImage,
      beeImage(family),
      crownImage,
    ]);
    // Nearest-neighbor, so pixels stay sharp at fractional scales.
    final paint = Paint()..filterQuality = FilterQuality.none;
    // Bottom to top: the outline never covers the bee, the crown sits on top.
    for (final image in [border, bee, crown]) {
      await add(
        SpriteComponent(sprite: Sprite(image), paint: paint, size: size),
      );
    }
  }
}
