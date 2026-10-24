// 📦 Package imports:
import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:apiary/presentation/game/apiary_game.dart';
import 'package:apiary/presentation/scenes/board_scene.dart';

import '../../helpers/game_golden.dart';

void main() {
  group('BoardScene', () {
    testGameGolden(
      'renders the empty board',
      goldenFile: 'goldens/board_scene_empty.png',
    );

    testWithGame<ApiaryGame>(
      'paints its background over the whole screen',
      ApiaryGame.new,
      (game) async {
        await game.ready();
        // Wider than 224×398: the screen is more than 224 game pixels wide.
        game.onGameResize(Vector2(600, 800));

        final background = game.world
            .descendants()
            .whereType<BoardScene>()
            .single
            .children
            .whereType<RectangleComponent>()
            .single;
        final visibleArea = game.visibleArea;
        expect(visibleArea.width, greaterThan(224));
        expect(background.position.x, closeTo(visibleArea.left, 1e-4));
        expect(background.position.y, closeTo(visibleArea.top, 1e-4));
        expect(background.size.x, closeTo(visibleArea.width, 1e-4));
        expect(background.size.y, closeTo(visibleArea.height, 1e-4));
      },
    );
  });
}
