// 📦 Package imports:
import 'package:glados/glados.dart';

// 🌎 Project imports:
import 'package:apiary/domain/bees/bee_lifespan.dart';
import 'package:apiary/domain/bees/family.dart';
import 'package:apiary/domain/board/bee_release.dart';
import 'package:apiary/domain/board/board.dart';
import 'package:apiary/domain/board/board_item.dart';
import 'package:apiary/domain/board/board_position.dart';
import 'package:apiary/domain/board/resource_production.dart';
import '../../helpers/hive_boards.dart';

void main() {
  const hive = Board.startingHivePosition;

  group('Board.releaseBee', () {
    const bee = Bee(family: Family.honeybee, level: 3);

    test('puts a bee that made nothing on the nearest free cell', () {
      final board = boardWithBeeInHive(bee);

      final result = board.releaseBee(hive)! as BeeReleased;

      expect(result.position, board.nearestFreeCell(hive));
      expect(result.board.itemAt(result.position), bee);
      expect(result.board.itemAt(hive), const BoardItem.hive());
      expect(result.board.items, hasLength(board.items.length + 1));
    });

    test('lets the hive take a bee again, with its whole lifespan', () {
      final result = boardWithBeeInHive(bee).releaseBee(hive)! as BeeReleased;

      final again = result.board.drop(result.position, hive)!.board;

      expect(again.itemAt(hive), const BoardItem.hive(bee: bee));
      expect((again.itemAt(hive)! as Hive).lifeLeft, BeeLifespan.of(3));
    });

    test('keeps the bee once it has made a resource', () {
      final worn = (boardWithBeeInHive(
        bee,
      ).produceResource(hive, Random(0)) as ResourceCreated).board;

      expect(worn.releaseBee(hive), isNull);
    });

    test('does nothing for an empty hive or a cell that is no hive', () {
      expect(Board.initial().releaseBee(hive), isNull);
      expect(
        Board.initial().releaseBee(Board.startingQueenPosition),
        isNull,
      );
      expect(
        Board.initial().releaseBee(const BoardPosition(column: 0, row: 0)),
        isNull,
      );
    });

    test('keeps the bee in its hive on a full board', () {
      final full = fullBoardWithBeeInHive(bee);

      expect(full.releaseBee(hive), const BeeRelease.boardFull());
      expect(full.itemAt(hive), const BoardItem.hive(bee: bee));
    });
  });
}
