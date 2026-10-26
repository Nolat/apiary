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
    test('holds a single Common generator', () {
      final board = Board.initial();

      expect(board.items, hasLength(1));
      expect(board.items.values, [
        const BoardItem.generator(family: Family.common),
      ]);
    });

    test('puts the generator on the same starting cell every time', () {
      expect(Board.initial(), Board.initial());
      expect(
        Board.initial().itemAt(Board.startingGeneratorPosition),
        const BoardItem.generator(family: Family.common),
      );
    });

    test('puts the generator on the board', () {
      expect(Board.initial().contains(Board.startingGeneratorPosition), isTrue);
    });

    Glados(any.boardPosition).test('leaves every other cell empty', (position) {
      final board = Board.initial();

      expect(
        board.itemAt(position) == null,
        position != Board.startingGeneratorPosition,
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
}
