// 📦 Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

// 🌎 Project imports:
import 'package:apiary/domain/bees/family.dart';
import 'package:apiary/domain/board/board_item.dart';
import 'package:apiary/domain/board/board_position.dart';

part 'board.freezed.dart';

/// The 7×9 grid and what sits on it; every cell that is not a key of [items]
/// is empty.
@freezed
abstract class Board with _$Board {
  const factory Board({
    @Default({}) Map<BoardPosition, BoardItem> items,
  }) = _Board;

  /// The board of a first game: a single Common queen on
  /// [startingQueenPosition].
  factory Board.initial() => Board(
    items: {
      startingQueenPosition: const BoardItem.queen(
        family: Family.common,
      ),
    },
  );

  const Board._();

  static const columns = 7;
  static const rows = 9;

  /// Where the starting queen is. Provisional, until the layout of all the
  /// starting objects (hive, incubator) is settled — see `docs/DESIGN.md`.
  static const startingQueenPosition = BoardPosition(column: 3, row: 4);

  /// Whether [position] lies on the grid.
  bool contains(BoardPosition position) =>
      position.column >= 0 &&
      position.column < columns &&
      position.row >= 0 &&
      position.row < rows;

  /// The item on [position], or `null` when the cell is empty.
  BoardItem? itemAt(BoardPosition position) => items[position];

  /// The selected cell once the player taps [tapped], [current] being the
  /// selected cell so far (`null` when nothing is selected): tapping an item
  /// selects it, tapping an empty cell leaves the selection as it was.
  BoardPosition? selectionAfterTap(
    BoardPosition? current,
    BoardPosition tapped,
  ) => itemAt(tapped) == null ? current : tapped;
}
