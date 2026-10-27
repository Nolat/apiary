// 📦 Package imports:
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:apiary/domain/board/board.dart';
import 'package:apiary/domain/board/board_item.dart';
import 'package:apiary/domain/board/board_position.dart';
import 'package:apiary/domain/board/board_repository.dart';
import 'package:apiary/domain/resources/resource_branch.dart';
import 'package:apiary/presentation/components/board/board_component.dart';
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

  group('Dropping a resource on an identical one', () {
    const from = BoardPosition(column: 1, row: 1);
    const onto = BoardPosition(column: 2, row: 1);
    const comb = BoardItem.resource(branch: ResourceBranch.comb);
    const pollen = BoardItem.resource(branch: ResourceBranch.pollen);

    ApiaryGame gameWith(Map<BoardPosition, BoardItem> items) => ApiaryGame(
      boardRepository: _MemoryRepository(Board(items: items)),
    );

    Future<void> drag(ApiaryGame game, BoardComponent board) async {
      CellDrag(game, board)
        ..start(from)
        ..moveTo(onto.column, onto.row)
        ..end();
      game
        ..update(0)
        ..update(1)
        ..update(0);
      await game.ready();
    }

    ItemInfoComponent infoOf(ApiaryGame game) =>
        game.world.descendants().whereType<ItemInfoComponent>().single;

    testWithGame<ApiaryGame>(
      'makes honey on the target cell, selected, and saves it',
      () => gameWith({from: comb, onto: comb}),
      (game) async {
        final board = await boardOf(game);

        await drag(game, board);

        const honey = BoardItem.resource(branch: ResourceBranch.comb, tier: 2);
        expect(board.board.itemAt(onto), honey);
        expect(board.board.itemAt(from), isNull);
        expect(board.selection.value, onto);
        expect(board.children.whereType<ResourceComponent>(), hasLength(1));
        expect(
          (game.boardRepository! as _MemoryRepository).saved?.itemAt(onto),
          honey,
        );
        expect(infoOf(game).titleText, 'Miel · Palier 2');
        expect(
          infoOf(game).tipText,
          'Niveau maximal : cette ressource ne fusionne plus',
        );
      },
    );

    testWithGame<ApiaryGame>(
      'swaps two pollens, which are already at the last tier',
      () => gameWith({from: pollen, onto: pollen}),
      (game) async {
        final board = await boardOf(game);
        final before = board.board;

        await drag(game, board);

        expect(board.board, before);
        expect(board.children.whereType<ResourceComponent>(), hasLength(2));
      },
    );
  });
}
