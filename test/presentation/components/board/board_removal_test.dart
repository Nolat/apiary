// 📦 Package imports:
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:apiary/domain/board/board.dart';
import 'package:apiary/domain/board/board_item.dart';
import 'package:apiary/domain/board/board_position.dart';
import 'package:apiary/domain/board/board_repository.dart';
import 'package:apiary/presentation/components/board/board_component.dart';
import 'package:apiary/presentation/components/board/item_info_component.dart';
import 'package:apiary/presentation/game/apiary_game.dart';
import '../../../helpers/board_tap.dart';
import '../../../helpers/game_text.dart';

// Lets the components added and removed by an action reach their parents.
Future<void> settle(ApiaryGame game) async {
  game
    ..update(0)
    ..update(0);
  await game.ready();
  game.update(0);
}

class _MemoryRepository implements BoardRepository {
  final saved = <Board>[];

  @override
  Future<Board?> load() async => null;

  @override
  Future<void> save(Board board) async => saved.add(board);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadGameText);

  group('Removing an item', () {
    const queen = Board.startingQueenPosition;
    // The first larva of a queen lands on the cell above her.
    const larva = BoardPosition(column: 3, row: 3);
    final repository = _MemoryRepository();

    ItemInfoComponent infoOf(ApiaryGame game) =>
        game.world.descendants().whereType<ItemInfoComponent>().single;

    // The board once the queen has made a larva; nothing is selected after.
    Future<BoardComponent> withLarva(ApiaryGame game) async {
      final board = await boardOf(game);
      tapCell(game, board, queen);
      tapCell(game, board, queen);
      await game.ready();
      expect(board.board.itemAt(larva), isA<Larva>());
      return board;
    }

    testWithGame<ApiaryGame>(
      'offers removal for a larva, not a queen',
      ApiaryGame.new,
      (
        game,
      ) async {
        final board = await withLarva(game);
        final info = infoOf(game);

        tapCell(game, board, queen);
        await settle(game);
        expect(info.hasRemoveButton, isFalse);

        tapCell(game, board, larva);
        await settle(game);
        expect(info.hasRemoveButton, isTrue);
        expect(info.removeButton.caption, 'Retirer');
      },
    );

    testWithGame<ApiaryGame>(
      'removes the item and offers to undo',
      ApiaryGame.new,
      (
        game,
      ) async {
        final board = await withLarva(game);
        final info = infoOf(game);
        tapCell(game, board, larva);

        info.onRemovePressed!();
        await settle(game);

        expect(board.board.itemAt(larva), isNull);
        expect(board.selection.value, isNull);
        expect(board.canUndo, isTrue);
        expect(info.hasRemoveButton, isFalse);
        expect(info.hasUndoButton, isTrue);
        expect(info.undoButton.caption, 'Annuler');
      },
    );

    testWithGame<ApiaryGame>(
      'brings the item back, selected, on undo',
      ApiaryGame.new,
      (
        game,
      ) async {
        final board = await withLarva(game);
        final before = board.board;
        tapCell(game, board, larva);
        board.removeSelected();

        await board.undoRemoval();
        await settle(game);

        expect(board.board, before);
        expect(board.selection.value, larva);
        expect(board.canUndo, isFalse);
        expect(infoOf(game).hasUndoButton, isFalse);
      },
    );

    testWithGame<ApiaryGame>(
      'makes the removal final on another action',
      ApiaryGame.new,
      (
        game,
      ) async {
        final board = await withLarva(game);
        tapCell(game, board, larva);
        board.removeSelected();

        tapCell(game, board, queen);
        await settle(game);

        expect(board.canUndo, isFalse);
        await board.undoRemoval();
        expect(board.board.itemAt(larva), isNull);
      },
    );

    testWithGame<ApiaryGame>('does not remove a queen', ApiaryGame.new, (
      game,
    ) async {
      final board = await withLarva(game);
      tapCell(game, board, queen);

      board.removeSelected();

      expect(board.board.itemAt(queen), isNotNull);
      expect(board.canUndo, isFalse);
    });

    testWithGame<ApiaryGame>(
      'shows the removed item in a frame next to the undo button',
      ApiaryGame.new,
      (game) async {
        final board = await withLarva(game);
        final info = infoOf(game);
        tapCell(game, board, larva);
        expect(info.hasRemovedFrame, isFalse);

        board.removeSelected();
        await settle(game);

        expect(info.hasRemovedFrame, isTrue);
        expect(board.removedItem, isA<Larva>());
        expect('${info.titleText} ${info.tipText}'.trim(), 'a été retiré(e).');

        await board.undoRemoval();
        await settle(game);
        expect(info.hasRemovedFrame, isFalse);
      },
    );

    testWithGame<ApiaryGame>(
      'saves the board after a removal and after its undo',
      () => ApiaryGame(boardRepository: repository),
      (game) async {
        final board = await withLarva(game);
        final before = board.board;
        repository.saved.clear();
        tapCell(game, board, larva);

        board.removeSelected();
        expect(repository.saved.last.itemAt(larva), isNull);

        await board.undoRemoval();
        expect(repository.saved.last, before);
      },
    );
  });
}
