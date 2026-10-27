// 🎯 Dart imports:
import 'dart:ui' show FilterQuality;

// 📦 Package imports:
import 'package:flame/components.dart';
import 'package:flame/game.dart';

// 🌎 Project imports:
import 'package:apiary/presentation/components/board/decor_component.dart';

/// What does not sit on the pixel grid in the world of [game]: the components
/// whose top left corner or size (not a text's) is not a whole number of game pixels, with
/// where they are. Such a component is drawn blurred or offset from its
/// neighbours' pixels (see "Présentation Flame" in `docs/CONVENTIONS.md`).
///
/// Components mid-animation (scaled, or moving under an effect) are left out:
/// call it with the animations over. The decor is too, which covers the whole
/// screen and does not draw pixels of its own.
List<String> offPixelGrid(FlameGame game) {
  bool whole(double value) => (value - value.roundToDouble()).abs() < 1e-6;
  final problems = <String>[];
  for (final component in game.world.descendants()) {
    // Sprites and 9-slices are drawn nearest-neighbor and not anti-aliased (see `pixelPaint`).
    if (component is HasPaint &&
        (component is SpriteComponent || component is NineTileBoxComponent) &&
        (component.paint.filterQuality != FilterQuality.none ||
            component.paint.isAntiAlias)) {
      problems.add('${component.runtimeType} is smoothed or anti-aliased');
    }
    if (component is! PositionComponent ||
        component is DecorComponent ||
        component.size.isZero() ||
        component.scale.x != 1 ||
        component.scale.y != 1) {
      continue;
    }
    final corner = component.absoluteTopLeftPosition;
    // A text is measured in fractions of a pixel, but starts on a whole one.
    final sized = component is! TextComponent;
    if (!whole(corner.x) ||
        !whole(corner.y) ||
        (sized && (!whole(component.size.x) || !whole(component.size.y)))) {
      problems.add(
        '${component.runtimeType} at (${corner.x}, ${corner.y}), '
        'size ${component.size.x}×${component.size.y}',
      );
    }
  }
  return problems;
}
