// 📦 Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

// 🌎 Project imports:
import 'package:apiary/domain/bees/bee_lifespan.dart';
import 'package:apiary/domain/bees/family.dart';
import 'package:apiary/domain/resources/resource_branch.dart';

part 'board_item.freezed.dart';

/// What can sit in a cell of the board.
@freezed
sealed class BoardItem with _$BoardItem {
  /// A queen, level 1: creates the larvae of its [family].
  const factory BoardItem.queen({required Family family}) = Queen;

  /// A larva of the base species of its [family], created by that family's
  /// queen.
  const factory BoardItem.larva({required Family family}) = Larva;

  /// A bee of its [family]: level 1 when born from the merge of two larvae,
  /// then one level higher per merge of two identical bees, up to the
  /// family's [Family.maxLevel]. The upper bound is kept by `Board.mergeBees`;
  /// a bee rebuilt from stored data must be checked against it by whoever
  /// reads that data.
  @Assert('level >= 1', 'level must be at least 1')
  const factory BoardItem.bee({
    required Family family,
    @Default(1) int level,
  }) = Bee;

  /// A hive, which belongs to no family. It starts empty and takes one [bee]
  /// at a time (see `Board.placeInHive`); `null` while it is empty. Once the
  /// bee has made a resource, [remainingLife] is how many it has left to
  /// make, and it is spent at zero: the hive is empty again. `null` while the
  /// hive is empty or its bee has made nothing yet, its whole lifespan (see
  /// [HiveLife.lifeLeft]) being left, so that all such hives are equal.
  @Assert(
    'remainingLife == null || remainingLife >= 1',
    'remainingLife must be at least 1',
  )
  @Assert(
    'bee != null || remainingLife == null',
    'an empty hive has no remainingLife',
  )
  const factory BoardItem.hive({Bee? bee, int? remainingLife}) = Hive;

  /// A resource of a [branch], made by a hive from its bee: tier 1, then one
  /// tier higher per merge of two identical resources, up to the branch's
  /// [ResourceBranch.maxTier]. The upper bound is kept by
  /// `Board.mergeResources`; a resource rebuilt from stored data must be
  /// checked against it by whoever reads that data.
  @Assert('tier >= 1', 'tier must be at least 1')
  const factory BoardItem.resource({
    required ResourceBranch branch,
    @Default(1) int tier,
  }) = Resource;
}

extension BoardItemLevel on BoardItem {
  /// The item's level (a resource's tier), or `null` for an item that has
  /// none.
  int? get level => switch (this) {
    Queen() => 1,
    Larva() => null,
    Bee(:final level) => level,
    Hive() => null,
    Resource(:final tier) => tier,
  };
}

extension HiveLife on Hive {
  /// How many resources the bee still has to make: its whole lifespan until
  /// it makes one (see [BeeLifespan.of]); 0 for an empty hive.
  int get lifeLeft {
    final held = bee;
    return held == null ? 0 : remainingLife ?? BeeLifespan.of(held.level);
  }
}

extension HiveRelease on Hive {
  /// Whether the player can take the bee out: it is there and has made
  /// nothing yet, so its whole lifespan is left.
  bool get canReleaseBee => bee != null && remainingLife == null;
}

extension BoardItemRemoval on BoardItem {
  /// Whether the player can remove the item from the board: larvae, bees and
  /// resources can, queens and hives cannot.
  bool get removable => switch (this) {
    Queen() || Hive() => false,
    Larva() || Bee() || Resource() => true,
  };
}
