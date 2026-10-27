// 🎯 Dart imports:
import 'dart:ui';

/// The paint of every sprite: nearest-neighbor, and without anti-aliasing.
/// At a fractional scale the edge of a sprite falls between two physical
/// pixels; anti-aliased, it is blended with what is behind (a faint line, a
/// sliver of another color), and neighbours do not round the same way.
/// Without it each edge snaps to a whole physical pixel, the same way for all
/// the sprites (see "Présentation Flame" in `docs/CONVENTIONS.md`).
Paint pixelPaint() => Paint()
  ..filterQuality = FilterQuality.none
  ..isAntiAlias = false;
