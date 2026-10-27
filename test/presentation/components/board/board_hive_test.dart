// 📦 Package imports:
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

  group('Dropping a bee on a hive', () {
    const hive = Board.startingHivePosition;
    const cell = BoardPosition(column: 1, row: 1);
    const bee = Bee(family: Family.common, level: 3);

    ApiaryGame gameWith(Map<BoardPosition, BoardItem> items) =>
        ApiaryGame(boardRepository: _MemoryRepository(Board(items: items)));

    void drag(ApiaryGame game, BoardComponent board, BoardPosition from) {
      CellDrag(game, board)
        ..start(from)
        ..moveTo(hive.column, hive.row)
        ..end();
      game
        ..update(0)
        ..update(1)
        ..update(0);
    }

    testWithGame<ApiaryGame>(
      'fills the empty hive, frees the cell and selects the hive',
      () => gameWith({hive: const BoardItem.hive(), cell: bee}),
      (game) async {
        final board = await boardOf(game);
        drag(game, board, cell);
        await game.ready();

        expect(board.board.itemAt(cell), isNull);
        expect(board.board.itemAt(hive), const BoardItem.hive(bee: bee));
        expect(board.selection.value, hive);
        expect(board.children.whereType<BeeComponent>(), isEmpty);
        final hives = board.children.whereType<HiveComponent>().toList();
        expect(hives, hasLength(1));
        expect(hives.single.bee, bee);
        final info = game.world
            .descendants()
            .whereType<ItemInfoComponent>()
            .single;
        expect(info.titleText, 'Ruche occupée');
        expect(
          info.tipText,
          'Abrite : Abeille domestique',
        );
      },
    );

    testWithGame<ApiaryGame>(
      'swaps a second bee with the occupied hive',
      () => gameWith({
        hive: const BoardItem.hive(bee: bee),
        cell: const BoardItem.bee(family: Family.common),
      }),
      (game) async {
        final board = await boardOf(game);

        drag(game, board, cell);
        await game.ready();

        expect(
          board.board.itemAt(hive),
          const BoardItem.bee(family: Family.common),
        );
        expect(board.board.itemAt(cell), const BoardItem.hive(bee: bee));
        expect(board.children.whereType<BeeComponent>(), hasLength(1));
        expect(board.children.whereType<HiveComponent>().single.bee, bee);
      },
    );

    testWithGame<ApiaryGame>(
      'shows the held bee in a frame of the info panel',
      () => gameWith({hive: const BoardItem.hive(bee: bee)}),
      (game) async {
        final board = await boardOf(game);
        final info = game.world
            .descendants()
            .whereType<ItemInfoComponent>()
            .single;
        expect(info.hasRemovedFrame, isFalse);

        tapCell(game, board, hive);
        await game.ready();

        expect(info.hasRemovedFrame, isTrue);
        expect(info.hasRemoveButton, isFalse);
      },
    );
  });
}
