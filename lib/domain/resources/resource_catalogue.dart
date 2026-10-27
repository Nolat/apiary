// 🌎 Project imports:
import 'package:apiary/domain/bees/family.dart';
import 'package:apiary/domain/board/board_item.dart';
import 'package:apiary/domain/resources/resource_branch.dart';

/// Which resources each species makes: the single table the hive reads (see
/// "Règles de la ruche" in `docs/DESIGN.md`: every species makes one or two
/// branches).
abstract final class ResourceCatalogue {
  /// The one or two branches of resources [bee]'s species makes, in a stable
  /// order.
  // Provisional: every species of the Common family makes both branches, until
  // the species are designed (see "Chantiers à part"). The switch is
  // exhaustive: a new family cannot be forgotten.
  static List<ResourceBranch> branchesMadeBy(Bee bee) => switch (bee.family) {
    Family.common => const [ResourceBranch.comb, ResourceBranch.pollen],
  };
}
