// 🎯 Dart imports:
import 'dart:ui';

// 🌎 Project imports:
import 'package:apiary/domain/bees/family.dart';

/// How a [Family] looks on the board: its sprites and its outline.
///
/// The outline is shared by every item of a family (queens, larvae and bees),
/// which tells the family at a glance (see "Univers visuel" in
/// `docs/DESIGN.md`). The outline sprites are white and tinted with
/// [borderColor], so a new family needs a color here, not a new outline
/// sprite. This lives in `presentation/`: the domain knows nothing of looks.
extension FamilySprites on Family {
  /// The family's bee, which the queen of the family also wears.
  String get beeImage => switch (this) {
    Family.common => 'bees/common.png',
  };

  /// The family's larva.
  String get larvaImage => switch (this) {
    Family.common => 'larvae/common.png',
  };

  /// The outline sprite hugging a bee's silhouette, queen included: a queen
  /// differs from a bee by her crown, not by her outline.
  String get beeBorderImage => 'bees/border_bee.png';

  /// The outline sprite hugging a larva's silhouette.
  String get larvaBorderImage => 'larvae/border_larva.png';

  /// The color of the family's outline. Provisional, like the families'
  /// palette in `docs/DESIGN.md`.
  Color get borderColor => switch (this) {
    Family.common => const Color(0xFFFBDA80),
  };

  /// A paint drawing an outline sprite in [borderColor], nearest-neighbor so
  /// pixels stay sharp at fractional scales. The tint multiplies the white of
  /// the sprite. Create it once per component, never per frame.
  Paint get borderPaint => Paint()
    ..filterQuality = FilterQuality.none
    ..colorFilter = ColorFilter.mode(borderColor, BlendMode.modulate);
}
