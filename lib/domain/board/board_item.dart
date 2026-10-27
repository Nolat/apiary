// 📦 Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

// 🌎 Project imports:
import 'package:apiary/domain/bees/family.dart';

part 'board_item.freezed.dart';

/// What can sit in a cell of the board. Resources join the union as their
/// stories land.
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
  /// at a time (see `Board.placeInHive`); `null` while it is empty.
  const factory BoardItem.hive({Bee? bee}) = Hive;
}

extension BoardItemLevel on BoardItem {
  /// The item's level, or `null` for an item that has none.
  int? get level => switch (this) {
    Queen() => 1,
    Larva() => null,
    Bee(:final level) => level,
    Hive() => null,
  };
}

extension BoardItemRemoval on BoardItem {
  /// Whether the player can remove the item from the board: larvae and bees
  /// can, queens and hives cannot.
  bool get removable => switch (this) {
    Queen() || Hive() => false,
    Larva() || Bee() => true,
  };
}
