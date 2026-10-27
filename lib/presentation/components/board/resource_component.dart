// 🎯 Dart imports:
import 'dart:ui';

// 📦 Package imports:
import 'package:flame/components.dart';

// 🌎 Project imports:
import 'package:apiary/domain/resources/resource_type.dart';
import 'package:apiary/presentation/components/board/resource_sprites.dart';
import 'package:apiary/presentation/game/screen_layout.dart';

/// A resource, drawn as the resource of its [type] and [tier]. Its sprite
/// carries its own outline, so there is no separate outline sprite as for the
/// objects of a family (see "Univers visuel" in `docs/DESIGN.md`). Its parent
/// places it on its cell; the board handles taps.
class ResourceComponent extends PositionComponent with HasGameReference {
  ResourceComponent({required this.type, this.tier = 1, super.position})
    : super(size: Vector2.all(ScreenLayout.itemSize));

  final ResourceType type;
  final int tier;

  @override
  Future<void> onLoad() async {
    final image = await game.images.load(type.imageAt(tier));
    // Nearest-neighbor, so pixels stay sharp at fractional scales.
    final paint = Paint()..filterQuality = FilterQuality.none;
    await add(
      SpriteComponent(sprite: Sprite(image), paint: paint, size: size),
    );
  }
}
