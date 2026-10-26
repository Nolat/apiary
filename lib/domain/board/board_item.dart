// 📦 Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

// 🌎 Project imports:
import 'package:apiary/domain/bees/family.dart';

part 'board_item.freezed.dart';

/// What can sit in a cell of the board. Larvae, bees, resources and hives join
/// the union as their stories land.
@freezed
sealed class BoardItem with _$BoardItem {
  /// A queen, level 1: creates the larvae of its [family].
  const factory BoardItem.queen({required Family family}) = Queen;
}

extension BoardItemLevel on BoardItem {
  /// The item's level, or `null` for an item that has none.
  int? get level => switch (this) {
    Queen() => 1,
  };
}
