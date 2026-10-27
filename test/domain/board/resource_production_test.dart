// 📦 Package imports:
import 'package:glados/glados.dart';

// 🌎 Project imports:
import 'package:apiary/domain/bees/family.dart';
import 'package:apiary/domain/board/board.dart';
import 'package:apiary/domain/board/board_item.dart';
import 'package:apiary/domain/board/board_position.dart';
import 'package:apiary/domain/board/resource_production.dart';
import 'package:apiary/domain/resources/resource_catalogue.dart';
import 'package:apiary/domain/resources/resource_type.dart';

void main() {
  const hive = Board.startingHivePosition;

  Board boardWith(Bee bee) => Board.initial().copyWith(
    items: {
      ...Board.initial().items,
      hive: BoardItem.hive(bee: bee),
    },
  );

  Board fullBoardWith(Bee bee) => Board(
    items: {
      for (var column = 0; column < Board.columns; column++)
        for (var row = 0; row < Board.rows; row++)
          BoardPosition(column: column, row: row): const BoardItem.larva(
            family: Family.common,
          ),
      hive: BoardItem.hive(bee: bee),
    },
  );

  group('Board.produceResource', () {
    Glados2(any.intInRange(1, 6), any.intInRange(0, 1 << 20)).test(
      'makes one tier-1 resource of a type the species makes, next to the '
      'hive, and keeps the bee',
      (level, seed) {
        final bee = Bee(family: Family.common, level: level);
        final board = boardWith(bee);

        final result =
            board.produceResource(hive, Random(seed)) as ResourceCreated;

        final made = result.board.itemAt(result.position)! as Resource;
        expect(ResourceCatalogue.typesMadeBy(bee), contains(made.type));
        expect(made.tier, 1);
        expect(result.position, board.nearestFreeCell(hive));
        expect(result.board.itemAt(hive), BoardItem.hive(bee: bee));
        expect(result.board.items, hasLength(board.items.length + 1));
      },
    );

    test('draws both types of a two-type species', () {
      const bee = Bee(family: Family.common);
      final random = Random(1);
      final types = {
        for (var tap = 0; tap < 50; tap++)
          ((boardWith(bee).produceResource(hive, random) as ResourceCreated)
                      .board
                      .itemAt(const BoardPosition(column: 3, row: 6))!
                  as Resource)
              .type,
      };

      expect(types, {ResourceType.comb, ResourceType.pollen});
    });

    test('is deterministic for a given seed', () {
      final board = boardWith(const Bee(family: Family.common));

      expect(
        board.produceResource(hive, Random(7)),
        board.produceResource(hive, Random(7)),
      );
    });

    test('makes nothing on a full board', () {
      expect(
        fullBoardWith(
          const Bee(family: Family.common),
        ).produceResource(hive, Random(0)),
        const ResourceProduction.boardFull(),
      );
    });
  });

  group('A resource', () {
    const resource = BoardItem.resource(type: ResourceType.comb);
    const from = BoardPosition(column: 1, row: 1);
    const onto = BoardPosition(column: 2, row: 1);
    final board = Board.initial().copyWith(
      items: {...Board.initial().items, from: resource},
    );

    test('can be removed', () {
      expect(board.remove(from)!.itemAt(from), isNull);
    });

    test('moves to an empty cell and swaps with another item', () {
      expect(board.move(from, onto)!.itemAt(onto), resource);
      expect(
        board.swap(from, Board.startingQueenPosition)!.itemAt(from),
        const BoardItem.queen(family: Family.common),
      );
    });

    test('does not go into a hive', () {
      expect(board.placeInHive(from, hive), isNull);
    });
  });
}
