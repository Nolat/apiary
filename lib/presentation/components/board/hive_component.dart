// 🎯 Dart imports:
import 'dart:ui';

// 📦 Package imports:
import 'package:flame/components.dart';

// 🌎 Project imports:
import 'package:apiary/domain/board/board_item.dart';
import 'package:apiary/presentation/components/board/family_sprites.dart';
import 'package:apiary/presentation/game/screen_layout.dart';

/// A hive (provisional sprites), whose outline is white while it is empty, like
/// the objects that belong to no family (see "Univers visuel" in
/// `docs/DESIGN.md`). A hive holding a [bee] has its own sprite and takes its
/// family's outline color, which tell it from an empty one; which bee it holds
/// shows in the item info. Its parent places it on its cell; the board handles
/// taps.
class HiveComponent extends PositionComponent with HasGameReference {
  HiveComponent({this.bee, super.position})
    : super(size: Vector2.all(ScreenLayout.itemSize));

  /// The bee the hive holds, `null` while it is empty.
  final Bee? bee;

  static const borderImage = 'hives/border_hive.png';
  static const spriteImage = 'hives/hive.png';
  static const fullSpriteImage = 'hives/hive_full.png';

  @override
  Future<void> onLoad() async {
    final [border, sprite] = await game.images.loadAll([
      borderImage,
      if (bee == null) spriteImage else fullSpriteImage,
    ]);
    // Nearest-neighbor, so pixels stay sharp at fractional scales. The
    // outline goes first: it never covers the hive.
    final paint = Paint()..filterQuality = FilterQuality.none;
    // The hive's outline takes the family's color once a bee lives in it.
    final outlinePaint = bee?.family.borderPaint ?? paint;
    for (final (image, layerPaint) in [
      (border, outlinePaint),
      (sprite, paint),
    ]) {
      await add(
        SpriteComponent(sprite: Sprite(image), paint: layerPaint, size: size),
      );
    }
  }
}
