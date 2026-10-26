// 📦 Package imports:
import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:apiary/domain/bees/family.dart';
import 'package:apiary/domain/board/board.dart';
import 'package:apiary/domain/board/board_item.dart';
import 'package:apiary/domain/board/board_position.dart';
import 'package:apiary/presentation/components/board/bee_component.dart';
import 'package:apiary/presentation/components/board/board_component.dart';
import 'package:apiary/presentation/components/board/larva_component.dart';
import 'package:apiary/presentation/components/board/queen_component.dart';
import 'package:apiary/presentation/game/apiary_game.dart';

import '../../../helpers/board_tap.dart';
import '../../../helpers/game_text.dart';

void main() {
  // The sprites load from the asset bundle, which needs the binding.
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadGameText);

  group('Dragging a larva', () {
    const queen = Board.startingQueenPosition;
    const first = BoardPosition(column: 3, row: 3);
    const second = BoardPosition(column: 4, row: 3);
    const larva = BoardItem.larva(family: Family.common);

    // Taps the queen twice, so the board holds her and two larvae.
    Future<BoardComponent> twoLarvae(ApiaryGame game) async {
      final board = await boardOf(game);
      tapCell(game, board, queen);
      tapCell(game, board, queen);
      tapCell(game, board, queen);
      await game.ready();
      expect(board.board.items.values.where((i) => i == larva), hasLength(2));
      return board;
    }

    testWithGame<ApiaryGame>(
      'merges onto an identical larva into a selected bee',
      ApiaryGame.new,
      (game) async {
        final board = await twoLarvae(game);

        CellDrag(game, board)
          ..start(first)
          ..moveTo(second.column, second.row)
          ..end();
        await game.ready();

        expect(board.board.itemAt(first), isNull);
        expect(
          board.board.itemAt(second),
          const BoardItem.bee(family: Family.common),
        );
        expect(board.board.items, hasLength(2));
        expect(board.children.whereType<LarvaComponent>(), isEmpty);
        expect(board.children.whereType<BeeComponent>(), hasLength(1));
        expect(board.selection.value, second);
      },
    );

    testWithGame<ApiaryGame>(
      'follows the finger and selects the larva while dragged',
      ApiaryGame.new,
      (game) async {
        final board = await twoLarvae(game);
        final component = board.children.whereType<LarvaComponent>().firstWhere(
          (c) => c.position == BoardComponent.itemPosition(first),
        );

        final drag = CellDrag(game, board)
          ..start(first)
          ..moveTo(0, 0);

        expect(board.selection.value, first);
        expect(
          component.position,
          BoardComponent.itemPosition(first) - Vector2(60, 60),
        );
        drag.end();
      },
    );

    testWithGame<ApiaryGame>(
      'goes back to its cell when dropped anywhere but on a twin',
      ApiaryGame.new,
      (game) async {
        final board = await twoLarvae(game);
        final before = board.board;

        // Empty cell, queen, own cell, off the board.
        for (final (column, row) in [
          (0, 0),
          (queen.column, queen.row),
          (first.column, first.row),
          (-3, 20),
        ]) {
          CellDrag(game, board)
            ..start(first)
            ..moveTo(column, row)
            ..end();
          await game.ready();

          expect(board.board, before);
          final larvae = board.children.whereType<LarvaComponent>().toList();
          expect(larvae, hasLength(2));
          expect(
            larvae.map((c) => c.position),
            containsAll([
              BoardComponent.itemPosition(first),
              BoardComponent.itemPosition(second),
            ]),
          );
        }
      },
    );

    testWithGame<ApiaryGame>(
      'is not possible for the queen',
      ApiaryGame.new,
      (game) async {
        final board = await twoLarvae(game);
        final before = board.board;

        CellDrag(game, board)
          ..start(queen)
          ..moveTo(0, 0)
          ..end();
        await game.ready();

        expect(board.board, before);
        expect(
          board.children.whereType<QueenComponent>().single.position,
          BoardComponent.itemPosition(queen),
        );
      },
    );
  });
}
