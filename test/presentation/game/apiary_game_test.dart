// 📦 Package imports:
import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:apiary/presentation/game/apiary_game.dart';
import 'package:apiary/presentation/scenes/board_scene.dart';

void main() {
  group('ApiaryGame', () {
    testWithGame<ApiaryGame>(
      'opens on the board scene',
      ApiaryGame.new,
      (game) async {
        // Route children mount on later ticks: wait for the tree to settle.
        await game.ready();

        expect(game.router.currentRoute.name, BoardScene.routeName);
        expect(game.world.descendants().whereType<BoardScene>(), hasLength(1));
      },
    );

    testWithGame<ApiaryGame>(
      'renders at the pixel-art reference resolution',
      ApiaryGame.new,
      (game) async {
        expect(game.camera.viewport.virtualSize, ApiaryGame.referenceResolution);
        expect(game.camera.viewfinder.anchor, Anchor.topLeft);
      },
    );
  });
}
