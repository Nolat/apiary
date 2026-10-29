// 📦 Package imports:
import 'package:glados/glados.dart';

// 🌎 Project imports:
import 'package:apiary/domain/bees/bee_lifespan.dart';
import 'package:apiary/domain/bees/family.dart';
import 'package:apiary/domain/board/board.dart';
import 'package:apiary/domain/board/board_item.dart';
import 'package:apiary/domain/board/board_position.dart';
import 'package:apiary/domain/board/resource_production.dart';
import 'package:apiary/domain/resources/resource_catalogue.dart';
import '../../helpers/hive_boards.dart';

void main() {
  const hive = Board.startingHivePosition;

  group('Board.produceResource', () {
    Glados2(
      any.intInRange(1, Family.honeybee.maxLevel + 1),
      any.intInRange(0, 1 << 20),
    ).test(
      'makes one resource the species makes, next to the hive, and uses one '
      'life of the bee',
      (level, seed) {
        final bee = Bee(family: Family.honeybee, level: level);
        final board = boardWithBeeInHive(bee);

        final result =
            board.produceResource(hive, Random(seed)) as ResourceCreated;

        expect(
          ResourceCatalogue.madeBy(bee),
          contains(result.board.itemAt(result.position)),
        );
        expect(result.position, board.nearestFreeCell(hive));
        expect(
          result.board.itemAt(hive),
          BoardItem.hive(bee: bee, remainingLife: BeeLifespan.of(level) - 1),
        );
        expect(result.board.items, hasLength(board.items.length + 1));
      },
    );

    Glados(any.intInRange(2, 6)).test(
      'takes exactly one life from the bee, which stays in its hive',
      (life) {
        const bee = Bee(family: Family.honeybee);
        final board = Board.initial().copyWith(
          items: {
            ...Board.initial().items,
            hive: BoardItem.hive(bee: bee, remainingLife: life),
          },
        );

        final result =
            board.produceResource(hive, Random(0)) as ResourceCreated;

        expect(
          result.board.itemAt(hive),
          BoardItem.hive(bee: bee, remainingLife: life - 1),
        );
      },
    );

    test('spends the bee with its last life: the hive is empty again', () {
      final board = Board.initial().copyWith(
        items: {
          ...Board.initial().items,
          hive: const BoardItem.hive(
            bee: Bee(family: Family.honeybee),
            remainingLife: 1,
          ),
        },
      );

      final result = board.produceResource(hive, Random(0)) as ResourceCreated;

      expect(result.board.itemAt(hive), const BoardItem.hive());
      expect(result.board.itemAt(result.position), isA<Resource>());
    });

    test('empties a hive after exactly its lifespan of productions', () {
      final random = Random(0);
      for (var level = 1; level <= Family.honeybee.maxLevel; level++) {
        final bee = Bee(family: Family.honeybee, level: level);
        var board = boardWithBeeInHive(bee);
        var made = 0;
        while (board.itemAt(hive) is Hive &&
            (board.itemAt(hive)! as Hive).bee != null) {
          board =
              (board.produceResource(hive, random) as ResourceCreated).board;
          made++;
        }

        expect(made, BeeLifespan.of(level));
        expect(board.itemAt(hive), const BoardItem.hive());
      }
    });

    test('takes a new bee, with its whole lifespan, once spent', () {
      const spent = Bee(family: Family.honeybee);
      const next = Bee(family: Family.honeybee, level: 3);
      final board = Board.initial().copyWith(
        items: {
          ...Board.initial().items,
          hive: const BoardItem.hive(bee: spent, remainingLife: 1),
          const BoardPosition(column: 0, row: 0): next,
        },
      );

      final emptied =
          (board.produceResource(hive, Random(0)) as ResourceCreated).board;
      final refilled = emptied.drop(
        const BoardPosition(column: 0, row: 0),
        hive,
      )!;

      expect(refilled.board.itemAt(hive), const BoardItem.hive(bee: next));
    });

    test('keeps the life of a bee when the board is full', () {
      const bee = Bee(family: Family.honeybee);
      final full = fullBoardWithBeeInHive(bee);

      expect(
        full.produceResource(hive, Random(0)),
        const ResourceProduction.boardFull(),
      );
      expect(full.itemAt(hive), const BoardItem.hive(bee: bee));
    });

    test('draws every resource the species makes', () {
      final random = Random(1);
      for (var level = 1; level <= Family.honeybee.maxLevel; level++) {
        final bee = Bee(family: Family.honeybee, level: level);
        final made = {
          for (var tap = 0; tap < 200; tap++)
            (boardWithBeeInHive(bee).produceResource(hive, random)
                    as ResourceCreated)
                .board
                .itemAt(const BoardPosition(column: 3, row: 6)),
        };

        expect(made, ResourceCatalogue.madeBy(bee).toSet());
      }
    });

    test('is deterministic for a given seed', () {
      final board = boardWithBeeInHive(const Bee(family: Family.honeybee));

      expect(
        board.produceResource(hive, Random(7)),
        board.produceResource(hive, Random(7)),
      );
    });

    test('makes nothing on a full board', () {
      expect(
        fullBoardWithBeeInHive(
          const Bee(family: Family.honeybee),
        ).produceResource(hive, Random(0)),
        const ResourceProduction.boardFull(),
      );
    });
  });
}
