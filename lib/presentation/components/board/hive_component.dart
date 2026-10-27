// 🎯 Dart imports:
import 'dart:ui';

// 📦 Package imports:
import 'package:flame/components.dart';

// 🌎 Project imports:
import 'package:apiary/presentation/game/screen_layout.dart';

/// A hive, drawn under the white outline of the objects that belong to no
/// family (see "Univers visuel" in `docs/DESIGN.md`). Provisional sprite,
/// empty only: a hive holding a bee will need its own look. Its parent
/// places it on its cell; the board handles taps.
class HiveComponent extends PositionComponent with HasGameReference {
  HiveComponent({super.position})
    : super(size: Vector2.all(ScreenLayout.itemSize));

  static const borderImage = 'hives/border_hive.png';
  static const spriteImage = 'hives/hive.png';

  @override
  Future<void> onLoad() async {
    final [border, sprite] = await game.images.loadAll([
      borderImage,
      spriteImage,
    ]);
    // Nearest-neighbor, so pixels stay sharp at fractional scales. The
    // outline goes first: it never covers the hive.
    final paint = Paint()..filterQuality = FilterQuality.none;
    for (final image in [border, sprite]) {
      await add(
        SpriteComponent(sprite: Sprite(image), paint: paint, size: size),
      );
    }
  }
}
