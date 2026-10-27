// 🎯 Dart imports:
import 'dart:math';

// 📦 Package imports:
import 'package:glados/glados.dart';

// 🌎 Project imports:
import 'package:apiary/domain/bees/family.dart';
import 'package:apiary/domain/board/board.dart';
import 'package:apiary/domain/board/board_drop.dart';
import 'package:apiary/domain/board/board_item.dart';
import 'package:apiary/domain/board/board_position.dart';
import 'package:apiary/domain/board/larva_spawn.dart';

extension AnyBoardPosition on Any {
  Generator<BoardPosition> get boardPosition => combine2(
    intInRange(0, Board.columns),
    intInRange(0, Board.rows),
    (column, row) => BoardPosition(column: column, row: row),
  );
}

void main() {
  _removeTests();
  _hiveTests();
  group('Board.initial', () {
    test('holds a Common queen and an empty hive', () {
      final board = Board.initial();

      expect(board.items, hasLength(2));
      expect(board.items.values, [
        const BoardItem.queen(family: Family.common),
        const BoardItem.hive(),
      ]);
    });

    test('puts the hive on its own starting cell', () {
      expect(Board.initial().contains(Board.startingHivePosition), isTrue);
      expect(
        Board.startingHivePosition,
        isNot(Board.startingQueenPosition),
      );
      expect(
        Board.initial().itemAt(Board.startingHivePosition),
        const BoardItem.hive(),
      );
    });

    test('puts the queen on the same starting cell every time', () {
      expect(Board.initial(), Board.initial());
      expect(
        Board.initial().itemAt(Board.startingQueenPosition),
        const BoardItem.queen(family: Family.common),
      );
    });

    test('puts the queen on the board', () {
      expect(Board.initial().contains(Board.startingQueenPosition), isTrue);
    });

    Glados(any.boardPosition).test('leaves every other cell empty', (position) {
      final board = Board.initial();

      expect(
        board.itemAt(position) == null,
        position != Board.startingQueenPosition &&
            position != Board.startingHivePosition,
      );
    });
  });

  group('Board.contains', () {
    test('rejects cells beyond the grid', () {
      for (final (column, row) in [(-1, 0), (0, -1), (7, 0), (0, 9)]) {
        expect(
          const Board().contains(BoardPosition(column: column, row: row)),
          isFalse,
        );
      }
    });

    Glados(any.boardPosition).test('accepts every cell of the grid', (p) {
      expect(const Board().contains(p), isTrue);
    });
  });

  group('Board.selectionAfterTap', () {
    final board = Board.initial();
    const queen = Board.startingQueenPosition;
    const empty = BoardPosition(column: 0, row: 0);

    test('selects the tapped item', () {
      expect(board.selectionAfterTap(null, queen), queen);
    });

    test('keeps the selection when the tapped item is already selected', () {
      expect(board.selectionAfterTap(queen, queen), queen);
    });

    test('keeps the selection when an empty cell is tapped', () {
      expect(board.selectionAfterTap(queen, empty), queen);
      expect(board.selectionAfterTap(null, empty), isNull);
    });

    Glados2(any.boardPosition, any.boardPosition).test(
      'only ever selects a cell holding an item',
      (current, tapped) {
        final selection = board.selectionAfterTap(current, tapped);

        expect(selection, anyOf(current, tapped));
        if (selection != current) {
          expect(board.itemAt(selection!), isNotNull);
        }
      },
    );
  });

  group('BoardItem.level', () {
    test('is the level of a bee', () {
      expect(const BoardItem.bee(family: Family.common).level, 1);
      expect(const BoardItem.bee(family: Family.common, level: 3).level, 3);
    });

    test('is 1 for a queen', () {
      expect(const BoardItem.queen(family: Family.common).level, 1);
    });

    test('is absent for a larva', () {
      expect(const BoardItem.larva(family: Family.common).level, isNull);
    });
  });

  group('Board.nearestFreeCell', () {
    const origin = BoardPosition(column: 3, row: 4);
    const larva = BoardItem.larva(family: Family.common);

    // The board with a larva on each of [cells], plus the starting queen.
    Board filled(Iterable<BoardPosition> cells) => Board(
      items: {
        Board.startingQueenPosition: const BoardItem.queen(
          family: Family.common,
        ),
        for (final cell in cells) cell: larva,
      },
    );

    Iterable<BoardPosition> allCells() => [
      for (var row = 0; row < Board.rows; row++)
        for (var column = 0; column < Board.columns; column++)
          BoardPosition(column: column, row: row),
    ];

    int ring(BoardPosition a, BoardPosition b) =>
        max((a.column - b.column).abs(), (a.row - b.row).abs());

    test('starts with the cell above the origin', () {
      expect(
        Board.initial().nearestFreeCell(origin),
        const BoardPosition(column: 3, row: 3),
      );
    });

    test('goes clockwise around the origin: top, right, bottom, then left', () {
      var board = Board.initial();
      final cells = <BoardPosition>[];
      for (var i = 0; i < 8; i++) {
        final cell = board.nearestFreeCell(origin)!;
        cells.add(cell);
        board = filled([...board.items.keys, cell]);
      }

      expect(
        cells.map((cell) => (cell.column - 3, cell.row - 4)),
        [(0, -1), (1, -1), (1, 0), (1, 1), (0, 1), (-1, 1), (-1, 0), (-1, -1)],
      );
    });

    test('moves on to the next cell of the ring once one is taken', () {
      final board = filled([const BoardPosition(column: 3, row: 3)]);

      expect(
        board.nearestFreeCell(origin),
        const BoardPosition(column: 4, row: 3),
      );
    });

    test('moves on to the next ring once the 8 cells around are taken', () {
      final board = filled(
        allCells().where((cell) => ring(cell, origin) == 1),
      );

      expect(
        board.nearestFreeCell(origin),
        const BoardPosition(column: 3, row: 2),
      );
    });

    test('is found far from the origin, in a corner', () {
      final board = filled(
        allCells().where(
          (cell) => cell != const BoardPosition(column: 6, row: 8),
        ),
      );

      expect(
        board.nearestFreeCell(origin),
        const BoardPosition(column: 6, row: 8),
      );
    });

    test('is absent when the board is full', () {
      expect(filled(allCells()).nearestFreeCell(origin), isNull);
    });

    Glados2(any.boardPosition, any.boardPosition).test(
      'is an empty cell of the board, no farther than any other',
      (origin, taken) {
        final board = filled([taken, origin]);

        final nearest = board.nearestFreeCell(origin)!;

        expect(board.contains(nearest), isTrue);
        expect(board.itemAt(nearest), isNull);
        for (final cell in allCells().where((c) => board.itemAt(c) == null)) {
          expect(ring(nearest, origin), lessThanOrEqualTo(ring(cell, origin)));
        }
      },
    );
  });

  group('Board.spawnLarva', () {
    const queen = Board.startingQueenPosition;

    test('puts a larva of the queen family on the nearest free cell', () {
      final result = Board.initial().spawnLarva(queen);

      expect(
        result,
        LarvaSpawn.created(
          board: Board(
            items: {
              ...Board.initial().items,
              const BoardPosition(column: 3, row: 3): const BoardItem.larva(
                family: Family.common,
              ),
            },
          ),
          position: const BoardPosition(column: 3, row: 3),
        ),
      );
    });

    test('gives the same answer on the same board every time', () {
      expect(
        Board.initial().spawnLarva(queen),
        Board.initial().spawnLarva(queen),
      );
    });

    test('creates exactly one larva per tap and keeps the queen', () {
      var board = Board.initial();
      for (var taps = 1; taps <= 20; taps++) {
        final result = board.spawnLarva(queen) as LarvaCreated;
        board = result.board;

        expect(board.items, hasLength(2 + taps));
        expect(
          board.itemAt(queen),
          const BoardItem.queen(family: Family.common),
        );
        expect(board.itemAt(result.position), isA<Larva>());
      }
    });

    test('creates nothing on a full board, until the last free cell', () {
      var board = Board.initial();
      for (var free = Board.columns * Board.rows - 2; free > 0; free--) {
        board = (board.spawnLarva(queen) as LarvaCreated).board;
      }

      expect(board.items, hasLength(Board.columns * Board.rows));
      expect(board.spawnLarva(queen), const LarvaSpawn.boardFull());
    });
  });

  group('Board.mergeLarvae', () {
    const larva = BoardItem.larva(family: Family.common);
    const from = BoardPosition(column: 1, row: 1);
    const onto = BoardPosition(column: 2, row: 1);
    final board = Board.initial().copyWith(
      items: {
        ...Board.initial().items,
        from: larva,
        onto: larva,
      },
    );

    test('replaces two identical larvae by a bee on the target cell', () {
      final merged = board.mergeLarvae(from, onto)!;

      expect(merged.itemAt(from), isNull);
      expect(merged.itemAt(onto), const BoardItem.bee(family: Family.common));
      expect(merged.items, hasLength(board.items.length - 1));
      expect(
        merged.itemAt(Board.startingQueenPosition),
        board.itemAt(Board.startingQueenPosition),
      );
    });

    test('leaves the original board untouched', () {
      board.mergeLarvae(from, onto);

      expect(board.itemAt(from), larva);
      expect(board.itemAt(onto), larva);
    });

    test('does not merge a larva with itself', () {
      expect(board.mergeLarvae(from, from), isNull);
    });

    test('does not merge onto an empty cell, a queen or a bee', () {
      final withBee = board.copyWith(
        items: {
          ...board.items,
          const BoardPosition(column: 5, row: 5): const BoardItem.bee(
            family: Family.common,
          ),
        },
      );

      for (final target in [
        const BoardPosition(column: 0, row: 0),
        const BoardPosition(column: 9, row: 9),
        Board.startingQueenPosition,
        const BoardPosition(column: 5, row: 5),
      ]) {
        expect(withBee.mergeLarvae(from, target), isNull);
      }
    });

    test('does not merge something that is not a larva', () {
      expect(board.mergeLarvae(Board.startingQueenPosition, onto), isNull);
      expect(
        board.mergeLarvae(const BoardPosition(column: 0, row: 0), onto),
        isNull,
      );
    });
  });

  group('Board.mergeBees', () {
    const from = BoardPosition(column: 1, row: 1);
    const onto = BoardPosition(column: 2, row: 1);
    Board boardWith(BoardItem a, BoardItem b) => Board.initial().copyWith(
      items: {...Board.initial().items, from: a, onto: b},
    );
    BoardItem bee(int level) =>
        BoardItem.bee(family: Family.common, level: level);

    test(
      'replaces two bees of level N by one of level N + 1 on the target',
      () {
        for (var level = 1; level < Family.common.maxLevel; level++) {
          final board = boardWith(bee(level), bee(level));

          final merged = board.mergeBees(from, onto)!;

          expect(merged.itemAt(from), isNull);
          expect(merged.itemAt(onto), bee(level + 1));
          expect(merged.items, hasLength(board.items.length - 1));
          expect(
            merged.itemAt(Board.startingQueenPosition),
            board.itemAt(Board.startingQueenPosition),
          );
        }
      },
    );

    test('does not merge bees of the last level', () {
      final last = bee(Family.common.maxLevel);

      expect(boardWith(last, last).mergeBees(from, onto), isNull);
    });

    test('does not merge bees of different levels, itself or off board', () {
      final board = boardWith(bee(1), bee(2));

      expect(board.mergeBees(from, onto), isNull);
      expect(boardWith(bee(1), bee(1)).mergeBees(from, from), isNull);
      expect(
        boardWith(bee(1), bee(1)).mergeBees(
          from,
          const BoardPosition(column: 9, row: 9),
        ),
        isNull,
      );
    });

    test('does not merge something that is not a bee', () {
      const larva = BoardItem.larva(family: Family.common);

      expect(boardWith(larva, bee(1)).mergeBees(from, onto), isNull);
      expect(boardWith(bee(1), larva).mergeBees(from, onto), isNull);
      expect(
        boardWith(
          bee(1),
          bee(1),
        ).mergeBees(from, const BoardPosition(column: 0, row: 0)),
        isNull,
      );
    });
  });

  group('Board.move', () {
    const larva = BoardItem.larva(family: Family.common);
    const from = BoardPosition(column: 1, row: 1);
    const empty = BoardPosition(column: 5, row: 6);
    final board = Board.initial().copyWith(
      items: {...Board.initial().items, from: larva},
    );

    test('moves an item to an empty cell and frees its origin', () {
      final moved = board.move(from, empty)!;

      expect(moved.itemAt(from), isNull);
      expect(moved.itemAt(empty), larva);
      expect(moved.items, hasLength(board.items.length));
    });

    test('moves the queen too', () {
      const queen = Board.startingQueenPosition;
      final moved = board.move(queen, empty)!;

      expect(moved.itemAt(queen), isNull);
      expect(moved.itemAt(empty), board.itemAt(queen));
    });

    test('leaves the original board untouched', () {
      board.move(from, empty);

      expect(board.itemAt(from), larva);
      expect(board.itemAt(empty), isNull);
    });

    test('does nothing on its own cell, an occupied or off-board cell', () {
      for (final target in [
        from,
        Board.startingQueenPosition,
        const BoardPosition(column: -1, row: 0),
        const BoardPosition(column: 0, row: Board.rows),
      ]) {
        expect(board.move(from, target), isNull);
      }
    });

    test('does nothing when there is no item to move', () {
      expect(board.move(empty, const BoardPosition(column: 0, row: 0)), isNull);
    });

    Glados2(any.boardPosition, any.boardPosition).test(
      'keeps the number of items and fills only the target',
      (a, b) {
        final moved = board.move(a, b);
        if (moved != null) {
          expect(moved.items, hasLength(board.items.length));
          expect(moved.itemAt(b), board.itemAt(a));
          expect(moved.itemAt(a), isNull);
        }
      },
    );
  });

  group('Board.interacts', () {
    const larva = BoardItem.larva(family: Family.common);
    const bee = BoardItem.bee(family: Family.common);
    const queen = Board.startingQueenPosition;
    const larvaCell = BoardPosition(column: 1, row: 1);
    const otherLarvaCell = BoardPosition(column: 0, row: 8);
    const beeCell = BoardPosition(column: 5, row: 6);
    const otherBeeCell = BoardPosition(column: 6, row: 6);
    final board = Board.initial().copyWith(
      items: {
        ...Board.initial().items,
        larvaCell: larva,
        otherLarvaCell: larva,
        beeCell: bee,
        otherBeeCell: bee,
      },
    );

    test('holds between identical larvae', () {
      expect(board.interacts(larvaCell, otherLarvaCell), isTrue);
    });

    test('holds between identical bees below the last level', () {
      expect(board.interacts(beeCell, otherBeeCell), isTrue);
    });

    test('does not hold between bees of the last level or of two levels', () {
      const last = BoardItem.bee(family: Family.common, level: 5);
      final withLast = board.copyWith(
        items: {...board.items, beeCell: last, otherBeeCell: last},
      );
      final mixed = board.copyWith(
        items: {...board.items, otherBeeCell: last},
      );

      expect(withLast.interacts(beeCell, otherBeeCell), isFalse);
      expect(mixed.interacts(beeCell, otherBeeCell), isFalse);
    });

    test('does not hold between other pairs, queens included', () {
      expect(board.interacts(larvaCell, beeCell), isFalse);
      expect(board.interacts(larvaCell, queen), isFalse);
      expect(board.interacts(queen, beeCell), isFalse);
    });

    test('does not hold when a cell is empty', () {
      const empty = BoardPosition(column: 6, row: 0);

      expect(board.interacts(larvaCell, empty), isFalse);
      expect(board.interacts(empty, larvaCell), isFalse);
    });
  });

  group('Board.swap', () {
    const larva = BoardItem.larva(family: Family.common);
    const bee = BoardItem.bee(family: Family.common);
    const queen = Board.startingQueenPosition;
    const larvaCell = BoardPosition(column: 1, row: 1);
    const beeCell = BoardPosition(column: 5, row: 6);
    const otherLarvaCell = BoardPosition(column: 0, row: 8);
    final board = Board.initial().copyWith(
      items: {
        ...Board.initial().items,
        larvaCell: larva,
        beeCell: bee,
        otherLarvaCell: larva,
      },
    );

    test('exchanges a larva and a bee, in both directions', () {
      final swapped = board.swap(larvaCell, beeCell)!;
      final back = board.swap(beeCell, larvaCell)!;

      expect(swapped.itemAt(larvaCell), bee);
      expect(swapped.itemAt(beeCell), larva);
      expect(back, swapped);
    });

    test('exchanges a larva or a bee with the queen, and moves her', () {
      final withLarva = board.swap(larvaCell, queen)!;
      final withBee = board.swap(queen, beeCell)!;

      expect(withLarva.itemAt(queen), larva);
      expect(withLarva.itemAt(larvaCell), board.itemAt(queen));
      expect(withBee.itemAt(beeCell), board.itemAt(queen));
      expect(withBee.itemAt(queen), bee);
    });

    test('exchanges two bees of the last level, which cannot merge', () {
      const otherBeeCell = BoardPosition(column: 6, row: 6);
      final last = BoardItem.bee(
        family: Family.common,
        level: Family.common.maxLevel,
      );
      final twoBees = board.copyWith(
        items: {...board.items, beeCell: last, otherBeeCell: last},
      );

      expect(twoBees.swap(beeCell, otherBeeCell), isNotNull);
    });

    test('creates and removes nothing', () {
      final swapped = board.swap(larvaCell, beeCell)!;

      expect(swapped.items.keys, board.items.keys);
      expect(
        swapped.items.values,
        unorderedEquals(board.items.values),
      );
    });

    test('leaves the original board untouched', () {
      board.swap(larvaCell, beeCell);

      expect(board.itemAt(larvaCell), larva);
      expect(board.itemAt(beeCell), bee);
    });

    test('does nothing with an identical item, an empty or off-board cell', () {
      for (final target in [
        larvaCell,
        otherLarvaCell,
        const BoardPosition(column: 6, row: 0),
        const BoardPosition(column: -1, row: 0),
        const BoardPosition(column: 0, row: Board.rows),
      ]) {
        expect(board.swap(larvaCell, target), isNull);
      }
    });

    test('exchanges two queens, identical or not', () {
      const otherQueenCell = BoardPosition(column: 2, row: 7);
      final twoQueens = board.copyWith(
        items: {
          ...board.items,
          otherQueenCell: const BoardItem.queen(family: Family.common),
        },
      );

      final swapped = twoQueens.swap(queen, otherQueenCell)!;

      expect(swapped.items, twoQueens.items);
      expect(swapped.items, hasLength(twoQueens.items.length));
    });

    test('does nothing when there is no item to swap', () {
      expect(
        board.swap(const BoardPosition(column: 6, row: 0), beeCell),
        isNull,
      );
    });

    Glados2(any.boardPosition, any.boardPosition).test(
      'keeps the occupied cells and the items, only exchanging two',
      (a, b) {
        final swapped = board.swap(a, b);
        if (swapped != null) {
          expect(swapped.items.keys, board.items.keys);
          expect(swapped.itemAt(a), board.itemAt(b));
          expect(swapped.itemAt(b), board.itemAt(a));
        }
      },
    );
  });

  group('Board.drop', () {
    const larva = BoardItem.larva(family: Family.common);
    const bee = BoardItem.bee(family: Family.common);
    const a = BoardPosition(column: 1, row: 1);
    const b = BoardPosition(column: 2, row: 1);
    const empty = BoardPosition(column: 5, row: 6);
    const queen = Board.startingQueenPosition;

    Board boardWith(BoardItem x, BoardItem y) => Board.initial().copyWith(
      items: {...Board.initial().items, a: x, b: y},
    );

    test('moves onto an empty cell', () {
      final drop = boardWith(larva, bee).drop(a, empty);

      expect(drop, isA<ItemMoved>());
      expect(drop!.board.itemAt(empty), larva);
    });

    test('merges identical larvae and bees', () {
      expect(boardWith(larva, larva).drop(a, b), isA<ItemsMerged>());
      expect(boardWith(bee, bee).drop(a, b), isA<ItemsMerged>());
    });

    test('swaps different items, and bees of the last level', () {
      expect(boardWith(larva, bee).drop(a, b), isA<ItemsSwapped>());
      expect(boardWith(larva, bee).drop(a, queen), isA<ItemsSwapped>());
      final last = BoardItem.bee(
        family: Family.common,
        level: Family.common.maxLevel,
      );
      expect(boardWith(last, last).drop(a, b), isA<ItemsSwapped>());
    });

    test('does nothing from an empty cell, onto itself or off the grid', () {
      final board = boardWith(larva, bee);

      expect(board.drop(empty, a), isNull);
      expect(board.drop(a, a), isNull);
      expect(board.drop(a, const BoardPosition(column: -1, row: 0)), isNull);
      expect(board.drop(a, const BoardPosition(column: 7, row: 0)), isNull);
    });
  });
}

void _removeTests() {
  group('Board.remove', () {
    const larva = BoardPosition(column: 0, row: 0);
    const bee = BoardPosition(column: 1, row: 0);
    const queen = Board.startingQueenPosition;
    final board = Board(
      items: {
        queen: const BoardItem.queen(family: Family.common),
        larva: const BoardItem.larva(family: Family.common),
        bee: const BoardItem.bee(family: Family.common, level: 3),
      },
    );

    test('frees the cell of a larva or a bee and keeps the rest', () {
      expect(board.remove(larva)!.items, {
        for (final e in board.items.entries)
          if (e.key != larva) e.key: e.value,
      });
      expect(board.remove(bee)!.itemAt(bee), isNull);
      expect(board.remove(bee)!.items, hasLength(2));
    });

    test('refuses a queen, a hive and an empty cell', () {
      expect(board.remove(queen), isNull);
      expect(Board.initial().remove(Board.startingHivePosition), isNull);
      expect(board.remove(const BoardPosition(column: 6, row: 8)), isNull);
    });
  });
}

void _hiveTests() {
  group('A hive', () {
    final board = Board.initial();
    const hive = Board.startingHivePosition;
    const empty = BoardPosition(column: 0, row: 0);

    test('moves to an empty cell', () {
      final moved = board.drop(hive, empty);

      expect(moved, isA<ItemMoved>());
      expect(moved!.board.itemAt(empty), const BoardItem.hive());
      expect(moved.board.itemAt(hive), isNull);
    });

    test('swaps with a different item', () {
      final swapped = board.drop(hive, Board.startingQueenPosition);

      expect(swapped, isA<ItemsSwapped>());
      expect(
        swapped!.board.itemAt(hive),
        board.itemAt(Board.startingQueenPosition),
      );
      expect(
        swapped.board.itemAt(Board.startingQueenPosition),
        const BoardItem.hive(),
      );
    });

    test('is selected by a tap, like any item', () {
      expect(board.selectionAfterTap(null, hive), hive);
    });
  });
}
