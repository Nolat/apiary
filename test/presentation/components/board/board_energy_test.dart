// 🎯 Dart imports:
import 'dart:math';

// 📦 Package imports:
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:apiary/domain/bees/bee_lifespan.dart';
import 'package:apiary/domain/bees/family.dart';
import 'package:apiary/domain/board/board.dart';
import 'package:apiary/domain/board/board_item.dart';
import 'package:apiary/domain/board/board_position.dart';
import 'package:apiary/domain/board/board_repository.dart';
import 'package:apiary/domain/energy/energy.dart';
import 'package:apiary/presentation/game/apiary_game.dart';

import '../../../helpers/board_tap.dart';
import '../../../helpers/energy_container.dart';
import '../../../helpers/game_text.dart';
import '../../../helpers/hive_boards.dart';

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

  const queen = Board.startingQueenPosition;
  const hive = Board.startingHivePosition;
  const bee = Bee(family: Family.honeybee);

  ApiaryGame gameWith(Board board, {Energy? saved}) => ApiaryGame(
    boardRepository: _MemoryRepository(board),
    container: energyContainer(saved: saved),
    random: Random(0),
  );

  group('Energy at a tap on a queen', () {
    testWithGame<ApiaryGame>(
      'costs one unit for the larva it makes',
      () => gameWith(Board.initial()),
      (game) async {
        final board = await boardOf(game);

        tapCell(game, board, queen);
        tapCell(game, board, queen);
        tapCell(game, board, queen);
        await game.ready();

        expect(board.board.items.length, Board.initial().items.length + 2);
        expect(game.energyValue.value, 98);
      },
    );

    testWithGame<ApiaryGame>(
      'is not spent by selecting the queen',
      () => gameWith(Board.initial()),
      (game) async {
        final board = await boardOf(game);

        tapCell(game, board, queen);
        await game.ready();

        expect(game.energyValue, Energy.full());
      },
    );

    testWithGame<ApiaryGame>(
      'makes nothing without enough energy, and says so',
      () => gameWith(
        Board.initial(),
        saved: const Energy(value: 0),
      ),
      (game) async {
        final board = await boardOf(game);
        var warnings = 0;
        board.energyMissing.addListener(() => warnings++);

        tapCell(game, board, queen);
        tapCell(game, board, queen);
        await game.ready();
        game.update(0);

        expect(board.board, Board.initial());
        expect(game.energyValue.value, 0);
        expect(board.missingEnergyBanner.isShown, isTrue);
        expect(board.fullBanner.isShown, isFalse);
        expect(warnings, 1);
      },
    );

    testWithGame<ApiaryGame>(
      'makes the last larva with the last unit, then no more',
      () => gameWith(
        Board.initial(),
        saved: const Energy(value: 1),
      ),
      (game) async {
        final board = await boardOf(game);

        tapCell(game, board, queen);
        tapCell(game, board, queen);
        tapCell(game, board, queen);
        await game.ready();

        expect(board.board.items.length, Board.initial().items.length + 1);
        expect(game.energyValue.value, 0);
      },
    );

    testWithGame<ApiaryGame>(
      'costs nothing on a full board',
      () => gameWith(
        Board(
          items: {
            for (var column = 0; column < Board.columns; column++)
              for (var row = 0; row < Board.rows; row++)
                BoardPosition(column: column, row: row): const BoardItem.larva(
                  family: Family.honeybee,
                ),
            queen: const BoardItem.queen(family: Family.honeybee),
          },
        ),
      ),
      (game) async {
        final board = await boardOf(game);

        tapCell(game, board, queen);
        tapCell(game, board, queen);
        await game.ready();

        expect(game.energyValue, Energy.full());
        expect(board.fullBanner.isShown, isTrue);
        expect(board.missingEnergyBanner.isShown, isFalse);
      },
    );
  });

  group('Energy at a tap on an occupied hive', () {
    testWithGame<ApiaryGame>(
      "costs one unit on top of the bee's lifespan",
      () => gameWith(boardWithBeeInHive(bee)),
      (game) async {
        final board = await boardOf(game);

        tapCell(game, board, hive);
        tapCell(game, board, hive);
        await game.ready();

        expect(game.energyValue.value, 99);
        expect(
          board.board.itemAt(hive),
          BoardItem.hive(
            bee: bee,
            remainingLife: BeeLifespan.of(bee.level) - 1,
          ),
        );
      },
    );

    testWithGame<ApiaryGame>(
      'makes nothing without enough energy and keeps the lifespan',
      () => gameWith(
        boardWithBeeInHive(bee),
        saved: const Energy(value: 0),
      ),
      (game) async {
        final board = await boardOf(game);
        final before = board.board;

        tapCell(game, board, hive);
        tapCell(game, board, hive);
        await game.ready();

        expect(board.board, before);
        expect(game.energyValue.value, 0);
        expect(board.missingEnergyBanner.isShown, isTrue);
      },
    );

    testWithGame<ApiaryGame>(
      'costs nothing on a full board',
      () => gameWith(fullBoardWithBeeInHive(bee)),
      (game) async {
        final board = await boardOf(game);

        tapCell(game, board, hive);
        tapCell(game, board, hive);
        await game.ready();

        expect(game.energyValue, Energy.full());
      },
    );

    testWithGame<ApiaryGame>(
      'spends one unit per resource until the bee is spent',
      () => gameWith(boardWithBeeInHive(bee)),
      (game) async {
        final board = await boardOf(game);

        tapCell(game, board, hive);
        for (var i = 0; i < BeeLifespan.of(bee.level); i++) {
          tapCell(game, board, hive);
        }
        await game.ready();

        expect(game.energyValue.value, 100 - BeeLifespan.of(bee.level));
      },
    );
  });

  group('What costs no energy', () {
    testWithGame<ApiaryGame>(
      'moving, swapping and selecting items works with an empty gauge',
      () => gameWith(
        Board.initial(),
        saved: const Energy(value: 0),
      ),
      (game) async {
        final board = await boardOf(game);
        const to = BoardPosition(column: 0, row: 0);

        tapCell(game, board, queen);
        tapCell(game, board, hive);
        CellDrag(game, board)
          ..start(queen)
          ..moveTo(to.column, to.row)
          ..end();
        await game.ready();

        expect(board.board.itemAt(to), isA<Queen>());
        expect(game.energyValue.value, 0);
      },
    );
  });
}
