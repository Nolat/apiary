// 🌎 Project imports:
import 'package:apiary/domain/bees/family.dart';
import 'package:apiary/domain/board/board_item.dart';
import 'package:apiary/domain/resources/resource_branch.dart';

/// Which resources each species makes: the single table the hive reads (see
/// "Abeilles par famille" in `docs/CONTENT.md`).
abstract final class ResourceCatalogue {
  /// The resources [bee]'s species makes, in a stable order. [bee]'s level
  /// must be one of its family's.
  // The switch is exhaustive: a new family cannot be forgotten.
  static List<Resource> madeBy(Bee bee) => switch (bee.family) {
    Family.honeybee => _honeybee[bee.level - 1],
  };

  static const _waxDrop = Resource(branch: ResourceBranch.wax);
  static const _rawWax = Resource(branch: ResourceBranch.wax, tier: 2);
  static const _refinedWax = Resource(branch: ResourceBranch.wax, tier: 3);
  static const _nectar = Resource(branch: ResourceBranch.honey);
  static const _lightHoney = Resource(branch: ResourceBranch.honey, tier: 2);
  static const _amberHoney = Resource(branch: ResourceBranch.honey, tier: 3);
  static const _goldenHoney = Resource(branch: ResourceBranch.honey, tier: 4);

  // The candle is only made by merging. Level 4 is the only one making golden
  // honey.
  static const List<List<Resource>> _honeybee = [
    [_waxDrop, _nectar],
    [_rawWax, _waxDrop, _lightHoney, _nectar],
    [_refinedWax, _rawWax, _amberHoney, _lightHoney],
    [_refinedWax, _goldenHoney, _amberHoney],
  ];
}
