// 🌎 Project imports:
import 'package:apiary/domain/bees/family.dart';
import 'package:apiary/domain/board/board_item.dart';
import 'package:apiary/domain/resources/resource_type.dart';

/// Which resources each species makes: the single table the hive reads (see
/// "Règles de la ruche" in `docs/DESIGN.md`: every species makes one or two
/// types).
abstract final class ResourceCatalogue {
  /// The one or two types of resource [bee]'s species makes, in a stable
  /// order.
  // Provisional: every species of the Common family makes both types, until
  // the species are designed (see "Chantiers à part"). The switch is
  // exhaustive: a new family cannot be forgotten.
  static List<ResourceType> typesMadeBy(Bee bee) => switch (bee.family) {
    Family.common => const [ResourceType.comb, ResourceType.pollen],
  };
}
