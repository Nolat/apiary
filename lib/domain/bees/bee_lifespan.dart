// 🌎 Project imports:
import 'package:apiary/domain/bees/family.dart';

/// How many resources a bee makes in a hive before it is spent (see "Règles
/// de la ruche" in `docs/DESIGN.md`): the single table of lifespans.
abstract final class BeeLifespan {
  /// The lifespan every species has until they are designed (see "Chantiers
  /// à part"): DESIGN.md's working hypothesis.
  static const provisional = 5;

  /// How many resources a bee of [family] makes once placed in a hive. It
  /// will take the level too once species differ.
  static int of(Family family) => switch (family) {
    Family.common => provisional,
  };
}
