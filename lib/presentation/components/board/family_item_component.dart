// 📦 Package imports:
import 'package:flame/components.dart';

// 🌎 Project imports:
import 'package:apiary/domain/bees/family.dart';
import 'package:apiary/presentation/components/board/family_sprites.dart';
import 'package:apiary/presentation/components/pixel_paint.dart';
import 'package:apiary/presentation/game/screen_layout.dart';

/// An item of the board drawn in the colors of its [family]: the family's
/// outline (a separate sprite hugging the item's silhouette, see "Univers
/// visuel" in `docs/DESIGN.md`) under the item's own sprite, and optionally
/// sprites on top of it. Its parent places it on its cell; the board handles
/// taps.
abstract class FamilyItemComponent extends PositionComponent
    with HasGameReference {
  FamilyItemComponent({required this.family, super.position})
    : super(size: Vector2.all(ScreenLayout.itemSize));

  final Family family;

  /// The outline sprite hugging the item's silhouette.
  String get borderImage;

  /// The item's own sprite.
  String get spriteImage;

  /// Sprites drawn over [spriteImage], bottom to top.
  List<String> get overlayImages => const [];

  @override
  Future<void> onLoad() async {
    final [border, ...sprites] = await game.images.loadAll([
      borderImage,
      spriteImage,
      ...overlayImages,
    ]);
    // Nearest-neighbor, so pixels stay sharp at fractional scales.
    final paint = pixelPaint();
    // Bottom to top: the outline never covers the item.
    for (final (image, layerPaint) in [
      (border, family.borderPaint),
      for (final sprite in sprites) (sprite, paint),
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
