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
    const comb = BoardItem.resource(branch: ResourceBranch.comb);
    const from = BoardPosition(column: 1, row: 1);
    const onto = BoardPosition(column: 2, row: 1);
    Board boardOf(BoardItem a, BoardItem b) => Board(items: {from: a, onto: b});

    test('turns two combs into honey, on the target cell', () {
      final result = boardOf(comb, comb).drop(from, onto)!;

      expect(result, isA<ItemsMerged>());
      expect(
        result.board.itemAt(onto),
        const BoardItem.resource(branch: ResourceBranch.comb, tier: 2),
      );
      expect(result.board.itemAt(from), isNull);
      expect(result.board.items, hasLength(1));
    });

    test('costs exactly two resources for one', () {
      final board = Board(
        items: {from: comb, onto: comb, Board.startingHivePosition: comb},
      );

      expect(board.mergeResources(from, onto)!.items, hasLength(2));
    });

    test('does not merge honey, pollen, or resources that differ', () {
      const honey = BoardItem.resource(branch: ResourceBranch.comb, tier: 2);
      const pollen = BoardItem.resource(branch: ResourceBranch.pollen);

      expect(boardOf(honey, honey).mergeResources(from, onto), isNull);
      expect(boardOf(pollen, pollen).mergeResources(from, onto), isNull);
      expect(boardOf(comb, pollen).mergeResources(from, onto), isNull);
      expect(boardOf(comb, honey).mergeResources(from, onto), isNull);
    });

    test('swaps what does not merge, leaving the board as it was', () {
      const honey = BoardItem.resource(branch: ResourceBranch.comb, tier: 2);
      final result = boardOf(honey, honey).drop(from, onto)!;

      expect(result, isA<ItemsSwapped>());
      expect(result.board, boardOf(honey, honey));
    });

    test('does not merge a resource with itself or with another item', () {
      expect(boardOf(comb, comb).mergeResources(from, from), isNull);
      expect(
        boardOf(
          comb,
          const BoardItem.larva(family: Family.common),
        ).mergeResources(from, onto),
        isNull,
      );
    });
  });

  group('A resource', () {
    const resource = BoardItem.resource(branch: ResourceBranch.comb);
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
