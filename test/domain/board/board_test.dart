// 📦 Package imports:
import 'package:glados/glados.dart';

// 🌎 Project imports:
import 'package:apiary/domain/bees/family.dart';
import 'package:apiary/domain/board/board.dart';
import 'package:apiary/domain/board/board_item.dart';
import 'package:apiary/domain/board/board_position.dart';

extension AnyBoardPosition on Any {
  Generator<BoardPosition> get boardPosition => combine2(
    intInRange(0, Board.columns),
    intInRange(0, Board.rows),
    (column, row) => BoardPosition(column: column, row: row),
  );
}

void main() {
  group('Board.initial', () {
    test('holds a single Common queen', () {
      final board = Board.initial();

      expect(board.items, hasLength(1));
      expect(board.items.values, [
        const BoardItem.queen(family: Family.common),
      ]);
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
        position != Board.startingQueenPosition,
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
    test('is 1 for a queen', () {
      expect(const BoardItem.queen(family: Family.common).level, 1);
    });
  });
}
