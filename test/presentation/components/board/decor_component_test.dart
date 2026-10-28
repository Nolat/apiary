// 📦 Package imports:
import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:apiary/presentation/components/board/decor_component.dart';
import 'package:apiary/presentation/game/apiary_game.dart';

void main() {
  // The decor's tile loads from the asset bundle, which needs the binding.
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DecorComponent', () {
    for (final (name, screenSize) in [
      ('the minimum screen', Vector2(140, 269)),
      ('a tablet', Vector2(1024, 1366)),
    ]) {
      testWithGame<ApiaryGame>(
        'aligns its tiles on the board cells on $name',
        ApiaryGame.new,
        (game) async {
          await game.ready();
          game.onGameResize(screenSize);

          final decor = game.world
              .descendants()
              .whereType<DecorComponent>()
              .single;
          final board = game.layout.board;
          final offset = decor.tileOffset;
          // A tile starts on the board's corner, in the decor's coordinates.
          expect((board.left - decor.position.x - offset.dx) % 20, 0);
          expect((board.top - decor.position.y - offset.dy) % 20, 0);
          expect(offset.dx, inInclusiveRange(0, 31));
          expect(offset.dy, inInclusiveRange(0, 31));
        },
      );
    }
  });
}
