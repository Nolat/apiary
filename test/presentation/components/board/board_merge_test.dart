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
    SpriteComponent selectionFrame(BoardComponent board) => board.children
        .whereType<SpriteComponent>()
        .firstWhere((c) => c.priority == 1);

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
        expect(selectionFrame(board).opacity, 0);
        expect(
          component.position,
          BoardComponent.itemPosition(first) - Vector2(60, 60),
        );
        drag.end();
        expect(selectionFrame(board).opacity, 1);
      },
    );

    testWithGame<ApiaryGame>(
      'goes back to its cell when dropped on itself or off the board',
      ApiaryGame.new,
      (game) async {
        final board = await twoLarvae(game);
        final before = board.board;

        for (final (column, row) in [
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
      'moves to an empty cell, freeing its origin and keeping the count',
      ApiaryGame.new,
      (game) async {
        final board = await twoLarvae(game);
        const target = BoardPosition(column: 0, row: 0);

        CellDrag(game, board)
          ..start(first)
          ..moveTo(target.column, target.row)
          ..end();
        await game.ready();

        expect(board.board.itemAt(first), isNull);
        expect(board.board.itemAt(target), larva);
        expect(board.board.items, hasLength(3));
        expect(board.selection.value, target);
        expect(
          board.children.whereType<LarvaComponent>().map((c) => c.position),
          containsAll([
            BoardComponent.itemPosition(target),
            BoardComponent.itemPosition(second),
          ]),
        );
      },
    );

    testWithGame<ApiaryGame>(
      'can be merged after having been moved',
      ApiaryGame.new,
      (game) async {
        final board = await twoLarvae(game);
        const target = BoardPosition(column: 0, row: 0);

        CellDrag(game, board)
          ..start(first)
          ..moveTo(target.column, target.row)
          ..end();
        CellDrag(game, board)
          ..start(target)
          ..moveTo(second.column, second.row)
          ..end();
        await game.ready();

        expect(
          board.board.itemAt(second),
          const BoardItem.bee(family: Family.common),
        );
        expect(board.board.items, hasLength(2));
      },
    );
  });

  group('Dragging the queen', () {
    const queen = Board.startingQueenPosition;
    const target = BoardPosition(column: 1, row: 1);
    const larva = BoardItem.larva(family: Family.common);

    testWithGame<ApiaryGame>(
      'moves her, selects her and creates no larva',
      ApiaryGame.new,
      (game) async {
        final board = await boardOf(game);
        tapCell(game, board, queen);

        CellDrag(game, board)
          ..start(queen)
          ..moveTo(target.column, target.row)
          ..end();
        await game.ready();

        expect(board.board.items, hasLength(1));
        expect(
          board.board.itemAt(target),
          const BoardItem.queen(family: Family.common),
        );
        expect(board.selection.value, target);
        expect(
          board.children.whereType<QueenComponent>().single.position,
          BoardComponent.itemPosition(target),
        );
      },
    );

    testWithGame<ApiaryGame>(
      'does not create a larva when a tap on the selected queen becomes a drag',
      ApiaryGame.new,
      (game) async {
        final board = await boardOf(game);
        tapCell(game, board, queen);
        // Finger down on the already selected queen, then a drag takes over
        // without the tap recognizer ever reporting a cancel.
        pressCell(game, board, queen);
        CellDrag(game, board)
          ..start(queen)
          ..moveTo(target.column, target.row)
          ..end();
        releaseCell(game, board, queen);
        await game.ready();

        expect(board.board.items.values.where((i) => i == larva), isEmpty);
      },
    );

    testWithGame<ApiaryGame>(
      'makes the new larvae appear around her new cell',
      ApiaryGame.new,
      (game) async {
        final board = await boardOf(game);
        CellDrag(game, board)
          ..start(queen)
          ..moveTo(target.column, target.row)
          ..end();
        await game.ready();

        tapCell(game, board, target);
        await game.ready();

        expect(
          board.board.itemAt(const BoardPosition(column: 1, row: 0)),
          larva,
        );
      },
    );
  });

  group('Dragging onto a different item', () {
    const queen = Board.startingQueenPosition;
    const first = BoardPosition(column: 3, row: 3);
    const second = BoardPosition(column: 4, row: 3);
    const larva = BoardItem.larva(family: Family.common);
    const bee = BoardItem.bee(family: Family.common);

    // The board of the merge test, with one bee left on `second` and one
    // larva on `first`.
    Future<BoardComponent> larvaAndBee(ApiaryGame game) async {
      final board = await boardOf(game);
      for (var i = 0; i < 3; i++) {
        tapCell(game, board, queen);
      }
      await game.ready();
      // Merges the larvae on `first` and `second`, then makes another larva.
      CellDrag(game, board)
        ..start(first)
        ..moveTo(second.column, second.row)
        ..end();
      // The first tap selects the queen again, the second creates the larva.
      tapCell(game, board, queen);
      tapCell(game, board, queen);
      await game.ready();
      expect(board.board.itemAt(second), bee);
      expect(board.board.itemAt(first), larva);
      return board;
    }

    testWithGame<ApiaryGame>(
      'exchanges the two items and selects the dragged one',
      ApiaryGame.new,
      (game) async {
        final board = await larvaAndBee(game);

        CellDrag(game, board)
          ..start(first)
          ..moveTo(second.column, second.row)
          ..end();
        await game.ready();

        expect(board.board.itemAt(first), bee);
        expect(board.board.itemAt(second), larva);
        expect(board.board.items, hasLength(3));
        expect(board.selection.value, second);
        expect(
          board.children.whereType<LarvaComponent>().single.position,
          BoardComponent.itemPosition(second),
        );
        expect(
          board.children.whereType<BeeComponent>().single.position,
          BoardComponent.itemPosition(first),
        );
      },
    );

    testWithGame<ApiaryGame>(
      'exchanges with the queen, whose larvae then appear around her new cell',
      ApiaryGame.new,
      (game) async {
        final board = await larvaAndBee(game);

        CellDrag(game, board)
          ..start(queen)
          ..moveTo(first.column, first.row)
          ..end();
        await game.ready();

        expect(
          board.board.itemAt(first),
          const BoardItem.queen(family: Family.common),
        );
        expect(board.board.itemAt(queen), larva);
        expect(
          board.children.whereType<QueenComponent>().single.position,
          BoardComponent.itemPosition(first),
        );

        tapCell(game, board, first);
        await game.ready();

        expect(board.board.items, hasLength(4));
        expect(
          board.board.itemAt(const BoardPosition(column: 3, row: 2)),
          larva,
        );
      },
    );

    testWithGame<ApiaryGame>(
      'can be dragged again after the exchange',
      ApiaryGame.new,
      (game) async {
        final board = await larvaAndBee(game);
        const free = BoardPosition(column: 0, row: 0);

        CellDrag(game, board)
          ..start(first)
          ..moveTo(second.column, second.row)
          ..end();
        CellDrag(game, board)
          ..start(first)
          ..moveTo(free.column, free.row)
          ..end();
        await game.ready();

        expect(board.board.itemAt(free), bee);
        expect(board.board.itemAt(first), isNull);
        expect(board.board.itemAt(second), larva);
      },
    );

    testWithGame<ApiaryGame>(
      'ends a shake of the queen on her new cell',
      ApiaryGame.new,
      (game) async {
        final board = await larvaAndBee(game);
        // Fills the board so that the next tap on the queen shakes her.
        board.board = board.board.copyWith(
          items: {
            for (var c = 0; c < Board.columns; c++)
              for (var r = 0; r < Board.rows; r++)
                BoardPosition(column: c, row: r):
                    board.board.itemAt(BoardPosition(column: c, row: r)) ??
                    larva,
          },
        );
        tapCell(game, board, queen);
        await game.ready();

        CellDrag(game, board)
          ..start(first)
          ..moveTo(queen.column, queen.row)
          ..end();
        game.update(BoardComponent.shakeStep);
        await game.ready();

        expect(
          board.children.whereType<QueenComponent>().single.position,
          BoardComponent.itemPosition(first),
        );
      },
    );
  });
}
