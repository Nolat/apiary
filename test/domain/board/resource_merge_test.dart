// 📦 Package imports:
import 'package:glados/glados.dart';

// 🌎 Project imports:
import 'package:apiary/domain/bees/family.dart';
import 'package:apiary/domain/board/board.dart';
import 'package:apiary/domain/board/board_drop.dart';
import 'package:apiary/domain/board/board_item.dart';
import 'package:apiary/domain/board/board_position.dart';
import 'package:apiary/domain/resources/resource_branch.dart';

void main() {
  const hive = Board.startingHivePosition;

  group('Board.mergeResources', () {
    const waxDrop = BoardItem.resource(branch: ResourceBranch.wax);
    const from = BoardPosition(column: 1, row: 1);
    const onto = BoardPosition(column: 2, row: 1);
    Board boardOf(BoardItem a, BoardItem b) => Board(items: {from: a, onto: b});

    test('turns two wax drops into raw wax, on the target cell', () {
      final result = boardOf(waxDrop, waxDrop).drop(from, onto)!;

      expect(result, isA<ItemsMerged>());
      expect(
        result.board.itemAt(onto),
        const BoardItem.resource(branch: ResourceBranch.wax, tier: 2),
      );
      expect(result.board.itemAt(from), isNull);
      expect(result.board.items, hasLength(1));
    });

    for (final branch in ResourceBranch.values) {
      test('goes up every tier of the ${branch.name} branch', () {
        for (var tier = 1; tier < branch.maxTier; tier++) {
          final item = BoardItem.resource(branch: branch, tier: tier);

          expect(
            boardOf(item, item).mergeResources(from, onto)!.itemAt(onto),
            BoardItem.resource(branch: branch, tier: tier + 1),
          );
        }
      });
    }

    test('costs exactly two resources for one', () {
      final board = Board(
        items: {
          from: waxDrop,
          onto: waxDrop,
          Board.startingHivePosition: waxDrop,
        },
      );

      expect(board.mergeResources(from, onto)!.items, hasLength(2));
    });

    test('does not merge the last tier, or resources that differ', () {
      for (final branch in ResourceBranch.values) {
        final last = BoardItem.resource(branch: branch, tier: branch.maxTier);
        expect(boardOf(last, last).mergeResources(from, onto), isNull);
      }
      const nectar = BoardItem.resource(branch: ResourceBranch.honey);
      const rawWax = BoardItem.resource(branch: ResourceBranch.wax, tier: 2);

      expect(boardOf(waxDrop, nectar).mergeResources(from, onto), isNull);
      expect(boardOf(waxDrop, rawWax).mergeResources(from, onto), isNull);
    });

    test('swaps what does not merge, leaving the board as it was', () {
      const candle = BoardItem.resource(branch: ResourceBranch.wax, tier: 4);
      final result = boardOf(candle, candle).drop(from, onto)!;

      expect(result, isA<ItemsSwapped>());
      expect(result.board, boardOf(candle, candle));
    });

    test('does not merge a resource with itself or with another item', () {
      expect(boardOf(waxDrop, waxDrop).mergeResources(from, from), isNull);
      expect(
        boardOf(
          waxDrop,
          const BoardItem.larva(family: Family.honeybee),
        ).mergeResources(from, onto),
        isNull,
      );
    });
  });

  group('A resource', () {
    const resource = BoardItem.resource(branch: ResourceBranch.wax);
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
        const BoardItem.queen(family: Family.honeybee),
      );
    });

    test('does not go into a hive', () {
      expect(board.placeInHive(from, hive), isNull);
    });
  });
}
