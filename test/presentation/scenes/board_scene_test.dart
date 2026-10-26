// 📦 Package imports:
import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:apiary/presentation/components/board/board_component.dart';
import 'package:apiary/presentation/components/board/decor_component.dart';
import 'package:apiary/presentation/game/apiary_game.dart';

import '../../helpers/game_golden.dart';

void main() {
  group('BoardScene', () {
    testGameGolden(
      'renders the empty board',
      goldenFile: 'goldens/board_scene_empty.png',
    );

    testWithGame<ApiaryGame>(
      'covers the whole screen with its decor',
      ApiaryGame.new,
      (game) async {
        await game.ready();
        // Wider than 140×246: the screen is more than 140 game pixels wide.
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
      ('the minimum screen', Vector2(140, 246)),
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
