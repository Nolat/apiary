// 🎯 Dart imports:
import 'dart:math';

// 📦 Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

// 🌎 Project imports:
import 'package:apiary/domain/bees/family.dart';
import 'package:apiary/domain/board/board_item.dart';
import 'package:apiary/domain/board/board_position.dart';
import 'package:apiary/domain/board/larva_spawn.dart';

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

  /// The empty cell closest to [origin], or `null` when the board is full.
  ///
  /// Closeness is the ring: the 8 cells around [origin] first, then the ring
  /// around those, and so on. Within a ring, cells are tried clockwise from
  /// the one above [origin]: the top going right, then the right side going
  /// down, the bottom going left and the left side going up. The answer never
  /// varies for a given board. The tie-break is provisional, see
  /// `docs/DESIGN.md` ("Plateau persistant et encombrement").
  BoardPosition? nearestFreeCell(BoardPosition origin) {
    for (var ring = 1; ring < max(columns, rows); ring++) {
      for (final (columnOffset, rowOffset) in _clockwiseRing(ring)) {
        final cell = BoardPosition(
          column: origin.column + columnOffset,
          row: origin.row + rowOffset,
        );
        if (contains(cell) && itemAt(cell) == null) {
          return cell;
        }
      }
    }
    return null;
  }

  // The 8 * [ring] offsets at Chebyshev distance [ring], clockwise (rows
  // grow downwards) from the cell straight above.
  static Iterable<(int, int)> _clockwiseRing(int ring) sync* {
    for (var column = 0; column <= ring; column++) {
      yield (column, -ring);
    }
    for (var row = 1 - ring; row <= ring; row++) {
      yield (ring, row);
    }
    for (var column = ring - 1; column >= -ring; column--) {
      yield (column, ring);
    }
    for (var row = ring - 1; row >= -ring; row--) {
      yield (-ring, row);
    }
    for (var column = 1 - ring; column < 0; column++) {
      yield (column, -ring);
    }
  }

  /// What tapping the queen on [queen] does: a larva of her family on the
  /// nearest free cell, or nothing when the board is full. [queen] must hold
  /// a queen.
  LarvaSpawn spawnLarva(BoardPosition queen) {
    final item = itemAt(queen);
    assert(item is Queen, 'No queen on $queen');
    final cell = nearestFreeCell(queen);
    if (item is! Queen || cell == null) {
      return const LarvaSpawn.boardFull();
    }
    return LarvaSpawn.created(
      board: copyWith(
        items: {
          ...items,
          cell: BoardItem.larva(family: item.family),
        },
      ),
      position: cell,
    );
  }
}
