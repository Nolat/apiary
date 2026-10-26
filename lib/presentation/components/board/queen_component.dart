// 🎯 Dart imports:
import 'dart:ui';

// 📦 Package imports:
import 'package:flame/components.dart';

// 🌎 Project imports:
import 'package:apiary/domain/bees/family.dart';
import 'package:apiary/presentation/components/board/family_sprites.dart';
import 'package:apiary/presentation/game/screen_layout.dart';

/// A queen, drawn as the queen of her family: the family's bee, the
/// family's outline (a separate sprite hugging the bee's silhouette, see
/// "Univers visuel" in `docs/DESIGN.md`) and a crown, which is what sets her
/// apart from a bee. Its parent places it on its cell;
/// the board handles taps.
class QueenComponent extends PositionComponent with HasGameReference {
  QueenComponent({required this.family, super.position})
    : super(size: Vector2.all(ScreenLayout.itemSize));

  final Family family;

  static const crownImage = 'queens/crown_queen.png';

  @override
  Future<void> onLoad() async {
    final [border, bee, crown] = await game.images.loadAll([
      family.beeBorderImage,
      family.beeImage,
      crownImage,
    ]);
    // Nearest-neighbor, so pixels stay sharp at fractional scales.
    final paint = Paint()..filterQuality = FilterQuality.none;
    // Bottom to top: the outline never covers the bee, the crown sits on top.
    for (final (image, layerPaint) in [
      (border, family.borderPaint),
      (bee, paint),
      (crown, paint),
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
