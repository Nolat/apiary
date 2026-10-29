// 📦 Package imports:
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:apiary/domain/bees/family.dart';
import 'package:apiary/domain/board/board.dart';
import 'package:apiary/domain/board/board_item.dart';
import 'package:apiary/domain/board/board_position.dart';
import 'package:apiary/domain/board/board_repository.dart';
import 'package:apiary/presentation/game/apiary_game.dart';
import '../../helpers/board_tap.dart';
import '../../helpers/game_text.dart';

class _MemoryRepository implements BoardRepository {
  _MemoryRepository([this.saved]);

  Board? saved;
  int saves = 0;

  @override
  Future<Board?> load() async => saved;

  @override
  Future<void> save(Board board) async {
    saved = board;
    saves++;
  }
}

class _BrokenRepository extends _MemoryRepository {
  @override
  Future<Board?> load() => Future.error(StateError('database locked'));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadGameText);

  group('BoardScene persistence', () {
    testWithGame<ApiaryGame>(
      'starts on the starting board when nothing was saved',
      () => ApiaryGame(boardRepository: _MemoryRepository()),
      (game) async {
        final board = await boardOf(game);

        expect(board.board, Board.initial());
      },
    );

    testWithGame<ApiaryGame>(
      'starts on the starting board when loading fails',
      () => ApiaryGame(boardRepository: _BrokenRepository()),
      (game) async {
        final board = await boardOf(game);

        expect(board.board, Board.initial());
      },
    );

    final saved = Board(
      items: {
        const BoardPosition(column: 1, row: 2): const BoardItem.queen(
          family: Family.honeybee,
        ),
        const BoardPosition(column: 5, row: 7): const BoardItem.bee(
          family: Family.honeybee,
          level: 2,
        ),
      },
    );

    testWithGame<ApiaryGame>(
      'restores the saved board',
      () => ApiaryGame(boardRepository: _MemoryRepository(saved)),
      (game) async {
        final board = await boardOf(game);

        expect(board.board, saved);
      },
    );

    testWithGame<ApiaryGame>(
      'saves right after an action',
      () => ApiaryGame(boardRepository: _MemoryRepository(saved)),
      (game) async {
        final board = await boardOf(game);
        final repository = game.boardRepository! as _MemoryRepository;
        const queen = BoardPosition(column: 1, row: 2);

        tapCell(game, board, queen);
        tapCell(game, board, queen);
        await game.ready();

        expect(repository.saves, 1);
        expect(repository.saved, board.board);
        expect(repository.saved!.items, hasLength(3));
      },
    );
  });
}
