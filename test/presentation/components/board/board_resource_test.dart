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
import 'package:apiary/domain/resources/resource_branch.dart';
import 'package:apiary/domain/resources/resource_catalogue.dart';
import 'package:apiary/presentation/components/board/hive_component.dart';
import 'package:apiary/presentation/components/board/item_info_component.dart';
import 'package:apiary/presentation/components/board/resource_component.dart';
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

  group('Tapping an occupied hive', () {
    const hive = Board.startingHivePosition;
    // The nearest free cell of the starting board: above the hive.
    const firstResource = BoardPosition(column: 3, row: 6);
    const occupied = BoardItem.hive(bee: Bee(family: Family.common));

    ApiaryGame gameWith(Board board, {int seed = 0}) => ApiaryGame(
      boardRepository: _MemoryRepository(board),
      random: Random(seed),
    );

    final starting = Board.initial().copyWith(
      items: {...Board.initial().items, hive: occupied},
    );

    testWithGame<ApiaryGame>(
      'only selects it the first time, then makes a resource when selected',
      () => gameWith(starting),
      (game) async {
        final board = await boardOf(game);

        tapCell(game, board, hive);
        await game.ready();
        expect(board.board, starting);
        expect(board.children.whereType<ResourceComponent>(), isEmpty);

        tapCell(game, board, hive);
        await game.ready();

        final made = board.board.itemAt(firstResource);
        expect(made, isA<Resource>());
        expect((made! as Resource).tier, 1);
        expect(
          board.board.itemAt(hive),
          const BoardItem.hive(
            bee: Bee(family: Family.common),
            remainingLife: BeeLifespan.provisional - 1,
          ),
        );
        expect(board.children.whereType<ResourceComponent>(), hasLength(1));
        expect(board.selection.value, hive);
      },
    );

    for (final seed in [0, 1, 2, 3]) {
      testWithGame<ApiaryGame>(
        'draws its branch from the seed ($seed)',
        () => gameWith(starting, seed: seed),
        (game) async {
          final board = await boardOf(game);

          tapCell(game, board, hive);
          tapCell(game, board, hive);
          await game.ready();

          final branches = ResourceCatalogue.branchesMadeBy(
            const Bee(family: Family.common),
          );
          expect(
            board.board.itemAt(firstResource),
            BoardItem.resource(
              branch: branches[Random(seed).nextInt(branches.length)],
            ),
          );
        },
      );
    }

    testWithGame<ApiaryGame>(
      'does nothing for an empty hive, even selected',
      () => gameWith(Board.initial()),
      (game) async {
        final board = await boardOf(game);

        tapCell(game, board, hive);
        tapCell(game, board, hive);
        await game.ready();

        expect(board.board, Board.initial());
      },
    );

    testWithGame<ApiaryGame>(
      'makes nothing on a full board and keeps the bee',
      () => gameWith(
        Board(
          items: {
            for (var column = 0; column < Board.columns; column++)
              for (var row = 0; row < Board.rows; row++)
                BoardPosition(column: column, row: row): const BoardItem.larva(
                  family: Family.common,
                ),
            hive: occupied,
          },
        ),
      ),
      (game) async {
        final board = await boardOf(game);
        final before = board.board;

        tapCell(game, board, hive);
        tapCell(game, board, hive);
        await game.ready();

        expect(board.board, before);
        expect(
          board.fullBanner.isShown,
          isTrue,
        );
      },
    );

    testWithGame<ApiaryGame>(
      'shows a resource in the info panel once selected',
      () => gameWith(starting),
      (game) async {
        final board = await boardOf(game);
        tapCell(game, board, hive);
        tapCell(game, board, hive);
        await game.ready();

        tapCell(game, board, firstResource);
        await game.ready();

        final info = game.world
            .descendants()
            .whereType<ItemInfoComponent>()
            .single;
        final made = board.board.itemAt(firstResource)! as Resource;
        expect(
          info.titleText,
          made.branch == ResourceBranch.comb
              ? 'Rayon · Palier 1'
              : 'Pollen · Palier 1',
        );
        // Only the comb has a tier above its first: pollen is already at its
        // branch's last tier.
        expect(
          info.tipText,
          made.branch == ResourceBranch.comb
              ? 'FUSIONNEZ pour atteindre le niveau suivant.'
              : 'Niveau maximal : cette ressource ne fusionne plus',
        );
      },
    );

    testWithGame<ApiaryGame>(
      'makes a resource that can be removed and brought back',
      () => gameWith(starting),
      (game) async {
        final board = await boardOf(game);
        tapCell(game, board, hive);
        tapCell(game, board, hive);
        await game.ready();
        final made = board.board.itemAt(firstResource);

        tapCell(game, board, firstResource);
        board.removeSelected();
        expect(board.board.itemAt(firstResource), isNull);

        await board.undoRemoval();
        await game.ready();
        expect(board.board.itemAt(firstResource), made);
      },
    );

    testWithGame<ApiaryGame>(
      'empties the hive once the bee has made all its resources',
      () => gameWith(starting),
      (game) async {
        final board = await boardOf(game);
        final info = game.world
            .descendants()
            .whereType<ItemInfoComponent>()
            .single;

        tapCell(game, board, hive);
        for (var made = 0; made < BeeLifespan.provisional; made++) {
          tapCell(game, board, hive);
          await game.ready();
        }

        expect(board.board.itemAt(hive), const BoardItem.hive());
        expect(board.children.whereType<HiveComponent>().single.bee, isNull);
        expect(
          board.children.whereType<ResourceComponent>(),
          hasLength(BeeLifespan.provisional),
        );
        expect(info.titleText, 'Ruche vide');
        // An empty hive no longer makes anything.
        tapCell(game, board, hive);
        await game.ready();
        expect(
          board.children.whereType<ResourceComponent>(),
          hasLength(BeeLifespan.provisional),
        );
      },
    );
  });
}
