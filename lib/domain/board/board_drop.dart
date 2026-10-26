// 📦 Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

// 🌎 Project imports:
import 'package:apiary/domain/board/board.dart';

part 'board_drop.freezed.dart';

/// The outcome of dropping an item on another cell; [board] is the board
/// once it is done.
@freezed
sealed class BoardDrop with _$BoardDrop {
  /// The item moved to an empty cell.
  const factory BoardDrop.moved({required Board board}) = ItemMoved;

  /// The item and the one it was dropped on traded places.
  const factory BoardDrop.swapped({required Board board}) = ItemsSwapped;

  /// The item and the one it was dropped on merged into a new one, on the
  /// cell they were dropped on.
  const factory BoardDrop.merged({required Board board}) = ItemsMerged;
}
