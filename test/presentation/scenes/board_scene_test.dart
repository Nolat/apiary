// 📦 Package imports:
import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:apiary/domain/board/board.dart';
import 'package:apiary/domain/board/board_position.dart';
import 'package:apiary/presentation/components/board/board_component.dart';
import 'package:apiary/presentation/components/board/board_full_banner_component.dart';
import 'package:apiary/presentation/components/board/decor_component.dart';
import 'package:apiary/presentation/game/apiary_game.dart';

import '../../helpers/board_tap.dart';
import '../../helpers/game_golden.dart';

void main() {
  group('BoardScene', () {
    testGameGolden(
      'renders the starting board',
      goldenFile: 'goldens/board_scene_start.png',
    );

    testGameGolden(
      'renders the board with the queen selected',
      goldenFile: 'goldens/board_scene_selected.png',
      arrange: (game, tester) async {
        final board = game.world
            .descendants()
            .whereType<BoardComponent>()
            .single;
        board.selection.value = Board.startingQueenPosition;
        // Past the bounce of the newly selected queen.
        game
          ..update(0)
          ..update(1)
          ..update(0);
      },
    );

    testGameGolden(
      'renders the full-board banner over a full board',
      goldenFile: 'goldens/board_scene_full.png',
      arrange: (game, tester) async {
        final board = await boardOf(game);
        const queen = Board.startingQueenPosition;
        tapCell(game, board, queen);
        while (board.board.items.length < Board.columns * Board.rows) {
          tapCell(game, board, queen);
        }
        // One more tap: the banner pops in, then holds.
        tapCell(game, board, queen);
        await game.ready();
        game
          ..update(0)
          ..update(BoardFullBannerComponent.popDuration + 0.5)
          ..update(0);
      },
    );

    testGameGolden(
      'renders the bee born from two merged larvae, selected',
      goldenFile: 'goldens/board_scene_bee.png',
      arrange: (game, tester) async {
        final board = await boardOf(game);
        for (var i = 0; i < 3; i++) {
          tapCell(game, board, Board.startingQueenPosition);
        }
        await game.ready();
        CellDrag(game, board)
          ..start(const BoardPosition(column: 3, row: 3))
          ..moveTo(4, 3)
          ..end();
        await game.ready();
        // Past the landing of the held larva, then the pop of the bee.
        game
          ..update(0)
          ..update(1)
          ..update(0);
        await game.ready();
        game
          ..update(0)
          ..update(1)
          ..update(0);
      },
    );

    testWithGame<ApiaryGame>(
      'covers the whole screen with its decor',
      ApiaryGame.new,
      (game) async {
        await game.ready();
        // Wider than 140×248: the screen is more than 140 game pixels wide.
        game.onGameResize(Vector2(600, 800));

        final decor = game.world
            .descendants()
            .whereType<DecorComponent>()
            .single;
        final visibleArea = game.visibleArea;
        expect(visibleArea.width, greaterThan(140));
        expect(decor.position.x, closeTo(visibleArea.left, 1e-4));
        expect(decor.position.y, closeTo(visibleArea.top, 1e-4));
        expect(decor.size.x, closeTo(visibleArea.width, 1e-4));
        expect(decor.size.y, closeTo(visibleArea.height, 1e-4));
      },
    );

    for (final (name, screenSize) in [
      ('the minimum screen', Vector2(140, 248)),
      ('a tall phone', Vector2(393, 852)),
      ('a tablet', Vector2(1024, 1366)),
    ]) {
      testWithGame<ApiaryGame>(
        'puts the board in its band on $name',
        ApiaryGame.new,
        (game) async {
          await game.ready();
          game.onGameResize(screenSize);

          final board = game.world
              .descendants()
              .whereType<BoardComponent>()
              .single;
          final band = game.layout.board;
          expect(board.position, Vector2(band.left, band.top));
          expect(board.size, Vector2(band.width, band.height));
          expect(band.bottom, game.layout.bottomBar.top);
        },
      );
    }
  });
}
