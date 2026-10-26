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

  /// The board of a first game: a single Common generator on
  /// [startingGeneratorPosition].
  factory Board.initial() => Board(
    items: {
      startingGeneratorPosition: const BoardItem.generator(
        family: Family.common,
      ),
    },
  );

  const Board._();

  static const columns = 7;
  static const rows = 9;

  /// Where the starting generator is. Provisional, until the layout of all the
  /// starting objects (hive, incubator) is settled — see `docs/DESIGN.md`.
  static const startingGeneratorPosition = BoardPosition(column: 3, row: 4);

  /// Whether [position] lies on the grid.
  bool contains(BoardPosition position) =>
      position.column >= 0 &&
      position.column < columns &&
      position.row >= 0 &&
      position.row < rows;

  /// The item on [position], or `null` when the cell is empty.
  BoardItem? itemAt(BoardPosition position) => items[position];
}
