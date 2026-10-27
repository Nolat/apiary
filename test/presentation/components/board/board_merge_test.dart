// 🐦 Flutter imports:
import 'package:flutter/services.dart';

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

// Lets every bounce, slide and melt run to its end.
void settle(ApiaryGame game) => game
  ..update(0)
  ..update(1)
  ..update(0);

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
        settle(game);
        await game.ready();

        expect(board.board.itemAt(first), isNull);
        expect(
          board.board.itemAt(second),
          const BoardItem.bee(family: Family.common),
        );
        expect(board.board.items, hasLength(3));
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
        expect(board.board.items, hasLength(4));
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
        expect(board.board.items, hasLength(3));
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

        expect(board.board.items, hasLength(2));
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
      settle(game);
      await game.ready();
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

        // The item that was not dragged slides to its new cell and bounces.
        game.update(BoardComponent.slideDuration / 2);
        expect(
          board.children.whereType<BeeComponent>().single.position,
          isNot(BoardComponent.itemPosition(first)),
        );
        game
          ..update(BoardComponent.slideDuration)
          ..update(0);
        await game.ready();

        expect(board.board.itemAt(first), bee);
        expect(board.board.itemAt(second), larva);
        expect(board.board.items, hasLength(4));
        expect(board.selection.value, second);
        expect(
          board.children.whereType<LarvaComponent>().single.position,
          BoardComponent.itemPosition(second),
        );
        expect(
          board.children.whereType<BeeComponent>().single.position.distanceTo(
            BoardComponent.itemPosition(first),
          ),
          lessThan(1e-3),
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

        expect(board.board.items, hasLength(5));
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
        // Past the hop of the newly selected queen too.
        game.update(BoardComponent.bounceDuration * 2);
        await game.ready();

        expect(
          board.children.whereType<QueenComponent>().single.position,
          BoardComponent.itemPosition(first),
        );
      },
    );
  });

  group('BeeComponent', () {
    test('refuses a level beyond the last one of its family', () {
      expect(
        () => BeeComponent(
          family: Family.common,
          level: Family.common.maxLevel + 1,
        ),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => BeeComponent(family: Family.common, level: 0),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('Dragging a bee', () {
    const from = BoardPosition(column: 1, row: 1);
    const onto = BoardPosition(column: 2, row: 1);

    // Replaces the scene's board by one holding two bees of [level].
    Future<BoardComponent> twoBees(ApiaryGame game, int level) async {
      final scene = await boardOf(game);
      final bee = BoardItem.bee(family: Family.common, level: level);
      final board = BoardComponent(
        board: Board(items: {from: bee, onto: bee}),
        energy: game.energy,
      )..position.setFrom(scene.position);
      scene.removeFromParent();
      await game.world.add(board);
      await game.ready();
      return board;
    }

    testWithGame<ApiaryGame>(
      'merges onto an identical bee into the next level',
      ApiaryGame.new,
      (game) async {
        final board = await twoBees(game, 1);

        CellDrag(game, board)
          ..start(from)
          ..moveTo(onto.column, onto.row)
          ..end();
        settle(game);
        await game.ready();

        expect(board.board.itemAt(from), isNull);
        expect(
          board.board.itemAt(onto),
          const BoardItem.bee(family: Family.common, level: 2),
        );
        expect(board.board.items, hasLength(1));
        expect(board.children.whereType<BeeComponent>(), hasLength(1));
        expect(board.children.whereType<BeeComponent>().single.level, 2);
        expect(board.selection.value, onto);
      },
    );

    testWithGame<ApiaryGame>(
      'goes back to its cell when both bees have the last level',
      ApiaryGame.new,
      (game) async {
        final board = await twoBees(game, Family.common.maxLevel);
        final before = board.board;

        CellDrag(game, board)
          ..start(from)
          ..moveTo(onto.column, onto.row)
          ..end();
        await game.ready();

        // Same items either way: the bees trade places.
        expect(board.board.items, before.items);
        expect(board.children.whereType<BeeComponent>(), hasLength(2));
      },
    );
  });

  group('A gesture that goes wrong', () {
    const queen = Board.startingQueenPosition;
    const first = BoardPosition(column: 3, row: 3);
    const second = BoardPosition(column: 4, row: 3);

    Future<BoardComponent> twoLarvae(ApiaryGame game) async {
      final board = await boardOf(game);
      for (var i = 0; i < 3; i++) {
        tapCell(game, board, queen);
      }
      await game.ready();
      return board;
    }

    testWithGame<ApiaryGame>(
      'puts the item back when cancelled over an identical one',
      ApiaryGame.new,
      (game) async {
        final board = await twoLarvae(game);
        final before = board.board;

        CellDrag(game, board)
          ..start(first)
          ..moveTo(second.column, second.row)
          ..cancel();
        await game.ready();

        expect(board.board, before);
        expect(
          board.children.whereType<LarvaComponent>().map((c) => c.position),
          containsAll([
            BoardComponent.itemPosition(first),
            BoardComponent.itemPosition(second),
          ]),
        );
      },
    );

    testWithGame<ApiaryGame>(
      'ignores a second finger while an item is dragged',
      ApiaryGame.new,
      (game) async {
        final board = await twoLarvae(game);

        final held = CellDrag(game, board)..start(first);
        CellDrag(game, board, pointerId: 2)
          ..start(second)
          ..moveTo(5, 5)
          ..end();
        held
          ..moveTo(second.column, second.row)
          ..end();
        await game.ready();

        expect(board.board.itemAt(first), isNull);
        expect(
          board.board.itemAt(second),
          const BoardItem.bee(family: Family.common),
        );
      },
    );

    testWithGame<ApiaryGame>(
      'stops a shaking queen when she is grabbed',
      ApiaryGame.new,
      (game) async {
        final board = await boardOf(game);
        board.board = board.board.copyWith(
          items: {
            for (var c = 0; c < Board.columns; c++)
              for (var r = 0; r < Board.rows; r++)
                BoardPosition(column: c, row: r):
                    board.board.itemAt(BoardPosition(column: c, row: r)) ??
                    const BoardItem.larva(family: Family.common),
          },
        );
        tapCell(game, board, queen);
        tapCell(game, board, queen);
        game.update(BoardComponent.shakeStep);

        CellDrag(game, board).start(queen);
        settle(game);
        await game.ready();

        // Held up, but centered on her cell: the swing is gone.
        final held = board.children.whereType<QueenComponent>().single;
        expect(held.scale.x, closeTo(BoardComponent.liftScale, 1e-6));
        expect(
          held.position + held.size * (held.scale.x / 2),
          BoardComponent.itemPosition(queen) + held.size / 2,
        );
      },
    );
  });

  group('Haptic feedback', () {
    const queen = Board.startingQueenPosition;
    final impacts = <Object?>[];

    setUp(() {
      impacts.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            if (call.method == 'HapticFeedback.vibrate') {
              impacts.add(call.arguments);
            }
            return null;
          });
    });

    testWithGame<ApiaryGame>(
      'is light when the queen makes a larva, medium on a merge',
      ApiaryGame.new,
      (game) async {
        final board = await boardOf(game);
        for (var i = 0; i < 3; i++) {
          tapCell(game, board, queen);
        }
        await game.ready();
        // The first tap only selects her; the next two make a larva each.
        expect(impacts, [
          'HapticFeedbackType.lightImpact',
          'HapticFeedbackType.lightImpact',
        ]);

        impacts.clear();
        CellDrag(game, board)
          ..start(const BoardPosition(column: 3, row: 3))
          ..moveTo(4, 3)
          ..end();
        // The result is felt once the held item has landed.
        expect(impacts, isEmpty);
        settle(game);
        await game.ready();
        expect(impacts, ['HapticFeedbackType.mediumImpact']);
      },
    );
  });

  group('Bounce', () {
    const queen = Board.startingQueenPosition;
    const larvaCell = BoardPosition(column: 3, row: 3);

    SpriteComponent frameOf(BoardComponent board) => board.children
        .whereType<SpriteComponent>()
        .firstWhere((c) => c.priority == 1);

    testWithGame<ApiaryGame>(
      'scales the item up and back when it gets selected',
      ApiaryGame.new,
      (game) async {
        final board = await boardOf(game);
        final component = board.children.whereType<QueenComponent>().single;

        tapCell(game, board, queen);
        game
          ..update(0)
          ..update(BoardComponent.bounceDuration / 2);
        expect(component.scale.x, greaterThan(1));
        // Around its center: it stays centered on its cell.
        expect(
          component.position + component.size * (component.scale.x / 2),
          BoardComponent.itemPosition(queen) + component.size / 2,
        );
        settle(game);

        expect(component.scale, Vector2.all(1));
        expect(component.position, BoardComponent.itemPosition(queen));
      },
    );

    testWithGame<ApiaryGame>(
      'jumps the selection frame to the new cell and bounces it there',
      ApiaryGame.new,
      (game) async {
        final board = await boardOf(game);
        tapCell(game, board, queen);
        tapCell(game, board, queen);
        await game.ready();
        settle(game);
        final frame = frameOf(board);

        tapCell(game, board, larvaCell);
        game
          ..update(0)
          ..update(BoardComponent.bounceDuration / 2);

        expect(frame.scale.x, greaterThan(1));
        expect(
          frame.position + frame.size * (frame.scale.x / 2),
          Vector2(60, 60) + frame.size / 2,
        );
        settle(game);
        expect(frame.scale, Vector2.all(1));
        expect(frame.position, Vector2(60, 60));
      },
    );

    testWithGame<ApiaryGame>(
      'bounces the queen each time she makes a larva',
      ApiaryGame.new,
      (game) async {
        final board = await boardOf(game);
        final component = board.children.whereType<QueenComponent>().single;
        tapCell(game, board, queen);
        await game.ready();
        settle(game);

        tapCell(game, board, queen);
        await game.ready();
        game
          ..update(0)
          ..update(BoardComponent.bounceDuration / 2);

        expect(component.scale.x, greaterThan(1));
      },
    );

    testWithGame<ApiaryGame>(
      'lifts the held item, and lands it on the one it merges with',
      ApiaryGame.new,
      (game) async {
        final board = await boardOf(game);
        for (var i = 0; i < 3; i++) {
          tapCell(game, board, queen);
        }
        await game.ready();
        settle(game);
        const second = BoardPosition(column: 4, row: 3);

        CellDrag(game, board).start(larvaCell);
        game.update(BoardComponent.liftDuration);
        final held = board.children.whereType<LarvaComponent>().firstWhere(
          (c) => c.priority == BoardComponent.draggedPriority,
        );
        expect(held.scale.x, closeTo(BoardComponent.liftScale, 1e-6));

        CellDrag(game, board)
          ..start(larvaCell)
          ..moveTo(second.column, second.row)
          ..end();
        await game.ready();
        // Landing: it comes down to its size while the other one waits.
        game.update(BoardComponent.landDuration / 2);
        expect(held.scale.x, lessThan(BoardComponent.liftScale));
        expect(held.scale.x, greaterThan(1));
        expect(board.children.whereType<BeeComponent>(), isEmpty);

        game.update(BoardComponent.landDuration);
        await game.ready();
        game.update(0);
        expect(held.isMounted, isFalse);
        // The result starts smaller than itself and pops in.
        final bee = board.children.whereType<BeeComponent>().single;
        expect(bee.scale.x, lessThan(1));
        settle(game);
        expect(bee.scale, Vector2.all(1));
        expect(
          bee.position.distanceTo(BoardComponent.itemPosition(second)),
          lessThan(1e-3),
        );
      },
    );
  });
}
