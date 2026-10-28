// � Dart imports:

// 🎯 Dart imports:
import 'dart:math';

/// How many resources a bee makes in a hive before it is spent (see "Règles
/// de la ruche" in `docs/DESIGN.md` and "Durée de vie des abeilles" in
/// `docs/CONTENT.md`): the single table of lifespans.
abstract final class BeeLifespan {
  /// The lifespan of a level-1 bee.
  static const baseLevelLifespan = 10;

  /// How much longer each level lives than the one below it.
  static const growthPerLevel = 1.5;

  /// How many resources a bee of [level] makes once placed in a hive: 10, 15,
  /// 23, 34… The ±20 % of luck of `docs/CONTENT.md` is not applied yet: this
  /// is the average.
  static int of(int level) =>
      (baseLevelLifespan * pow(growthPerLevel, level - 1)).round();
}
