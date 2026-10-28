// 🎯 Dart imports:
import 'dart:async';

// 📦 Package imports:
import 'package:flame/events.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:apiary/domain/bees/family.dart';
import 'package:apiary/domain/board/board.dart';
import 'package:apiary/domain/board/board_item.dart';
import 'package:apiary/domain/board/board_position.dart';
import 'package:apiary/domain/board/board_repository.dart';
import 'package:apiary/presentation/components/board/bee_component.dart';
import 'package:apiary/presentation/components/board/board_component.dart';
import 'package:apiary/presentation/components/board/hive_component.dart';
import 'package:apiary/presentation/components/board/item_info_component.dart';
import 'package:apiary/presentation/game/apiary_game.dart';

import '../../../helpers/board_tap.dart';
import '../../../helpers/game_text.dart';

class _MemoryRepository implements BoardRepository {
  _MemoryRepository(this.saved);

  Board? saved;

  @override
  Future<Board?> load() async => saved;

  @override
  Future<void> save(Board board) async => saved = board;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadGameText);

  group('Taking the bee out of a hive', () {
    const hive = Board.startingHivePosition;
    // The nearest free cell of the starting board: above the hive.
    const popped = BoardPosition(column: 3, row: 6);
    const bee = Bee(family: Family.honeybee, level: 2);

    ApiaryGame gameWith(Board board) =>
        ApiaryGame(boardRepository: _MemoryRepository(board));

    final starting = Board.initial().copyWith(
      items: {
        ...Board.initial().items,
        hive: const BoardItem.hive(bee: bee),
      },
    );

    ItemInfoComponent infoOf(ApiaryGame game) =>
        game.world.descendants().whereType<ItemInfoComponent>().single;

    testWithGame<ApiaryGame>(
      'offers a cross only while the hive is selected and untouched',
      () => gameWith(starting),
      (game) async {
        final board = await boardOf(game);
        final info = infoOf(game);
        expect(info.hasReleaseButton, isFalse);

        tapCell(game, board, hive);
        await game.ready();
        expect(info.hasReleaseButton, isTrue);

        // One resource later, the bee has worked: it stays.
        tapCell(game, board, hive);
        await game.ready();
        expect(info.hasReleaseButton, isFalse);
      },
    );

    testWithGame<ApiaryGame>(
      'pops the bee out on the nearest free cell and empties the hive',
      () => gameWith(starting),
      (game) async {
        final board = await boardOf(game);
        final info = infoOf(game);
        tapCell(game, board, hive);
        await game.ready();

        info.onReleasePressed!();
        await game.ready();

        expect(board.board.itemAt(popped), bee);
        expect(board.board.itemAt(hive), const BoardItem.hive());
        expect(board.children.whereType<BeeComponent>(), hasLength(1));
        expect(board.children.whereType<HiveComponent>().last.bee, isNull);
        expect(board.selection.value, hive);
        expect(info.titleText, 'Ruche vide');
        expect(info.hasReleaseButton, isFalse);
      },
    );

    testWithGame<ApiaryGame>(
      'keeps the bee in its hive on a full board',
      () => gameWith(
        Board(
          items: {
            for (var column = 0; column < Board.columns; column++)
              for (var row = 0; row < Board.rows; row++)
                BoardPosition(column: column, row: row): const BoardItem.larva(
                  family: Family.honeybee,
                ),
            hive: const BoardItem.hive(bee: bee),
          },
        ),
      ),
      (game) async {
        final board = await boardOf(game);
        final before = board.board;
        tapCell(game, board, hive);
        await game.ready();

        infoOf(game).onReleasePressed!();
        await game.ready();

        expect(board.board, before);
      },
    );

    testWithGame<ApiaryGame>(
      'saves the board once the bee is out',
      () => gameWith(starting),
      (game) async {
        final board = await boardOf(game);
        final repository = game.boardRepository! as _MemoryRepository;
        tapCell(game, board, hive);

        infoOf(game).onReleasePressed!();
        await game.ready();

        expect(repository.saved?.itemAt(popped), bee);
        expect(repository.saved?.itemAt(hive), const BoardItem.hive());
      },
    );

    testWithGame<ApiaryGame>(
      'keeps a removal undoable when the bee cannot leave',
      () => gameWith(
        Board.initial().copyWith(
          items: {
            ...Board.initial().items,
            hive: const BoardItem.hive(bee: bee, remainingLife: 2),
            const BoardPosition(column: 0, row: 0): const BoardItem.larva(
              family: Family.honeybee,
            ),
          },
        ),
      ),
      (game) async {
        final board = await boardOf(game);
        tapCell(game, board, const BoardPosition(column: 0, row: 0));
        board.removeSelected();
        expect(board.canUndo, isTrue);
        board.selection.value = hive;

        await board.releaseSelectedBee();

        expect(board.canUndo, isTrue);
      },
    );

    testWithGame<ApiaryGame>(
      'refreshes the info panel as soon as the bee is out',
      () => gameWith(starting),
      (game) async {
        final board = await boardOf(game);
        final info = infoOf(game);
        tapCell(game, board, hive);
        await game.ready();
        expect(info.hasReleaseButton, isTrue);

        unawaited(board.releaseSelectedBee());

        // Before the sprites of the new cells have loaded.
        expect(info.hasReleaseButton, isFalse);
        expect(info.titleText, 'Ruche vide');
      },
    );

    group('the cross', () {
      Future<(Offset, MultiTapDispatcher)> badgeOf(
        ApiaryGame game,
        BoardComponent board,
      ) async {
        tapCell(game, board, hive);
        await game.ready();
        final center = game.camera.localToGlobal(
          infoOf(game).releaseButton.absoluteCenter,
        );
        return (
          Offset(center.x, center.y),
          game.findByKey(const MultiTapDispatcherKey())! as MultiTapDispatcher,
        );
      }

      testWithGame<ApiaryGame>(
        'fades while a finger is down on it and releases the bee on lift',
        () => gameWith(starting),
        (game) async {
          final board = await boardOf(game);
          final (at, dispatcher) = await badgeOf(game, board);
          final button = infoOf(game).releaseButton;

          dispatcher.onTapDown(
            createTapDownEvents(game: game, globalPosition: at),
          );
          expect(button.isPressed, isTrue);
          expect(board.board.itemAt(popped), isNull);

          dispatcher.onTapUp(
            createTapUpEvents(game: game, globalPosition: at),
          );
          await game.ready();

          expect(button.isPressed, isFalse);
          expect(board.board.itemAt(popped), bee);
          expect(board.board.itemAt(hive), const BoardItem.hive());
        },
      );

      testWithGame<ApiaryGame>(
        'does nothing when the finger leaves it before lifting',
        () => gameWith(starting),
        (game) async {
          final board = await boardOf(game);
          final (at, dispatcher) = await badgeOf(game, board);

          dispatcher
            ..onTapDown(createTapDownEvents(game: game, globalPosition: at))
            ..onTapCancel(TapCancelEvent(1));
          await game.ready();

          expect(infoOf(game).releaseButton.isPressed, isFalse);
          expect(board.board, starting);
        },
      );
    });
  });
}
