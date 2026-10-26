// 📦 Package imports:
import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:apiary/presentation/game/apiary_game.dart';
import 'package:apiary/presentation/game/game_viewport.dart';
import 'package:apiary/presentation/scenes/board_scene.dart';

void main() {
  // The board's sprites load from the asset bundle, which needs the binding.
  TestWidgetsFlutterBinding.ensureInitialized();

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
        final viewport = game.camera.viewport;
        expect(viewport, isA<GameViewport>());
        expect(
          (viewport as GameViewport).minimumSize,
          ApiaryGame.minimumSize,
        );
        expect(game.camera.viewfinder.anchor, Anchor.topLeft);
      },
    );
  });
}
