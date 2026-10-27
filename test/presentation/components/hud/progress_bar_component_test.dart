// 📦 Package imports:
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:apiary/presentation/components/hud/progress_bar_component.dart';
import 'package:apiary/presentation/game/apiary_game.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProgressBarComponent', () {
    late ProgressBarComponent bar;

    Future<ApiaryGame> load(ApiaryGame game) async {
      bar = ProgressBarComponent(width: 80);
      await game.world.add(bar);
      await game.ready();
      return game;
    }

    testWithGame<ApiaryGame>('starts empty', ApiaryGame.new, (game) async {
      await load(game);

      expect(bar.fillWidth, 0);
    });

    testWithGame<ApiaryGame>(
      'fills the inside of its frame, in whole pixels',
      ApiaryGame.new,
      (game) async {
        await load(game);

        bar.value = 1;
        expect(bar.fillWidth, 76);

        bar.value = 0.5;
        expect(bar.fillWidth, 38);

        bar.value = 0.333;
        expect(bar.fillWidth, 25);
      },
    );

    testWithGame<ApiaryGame>('keeps its value within 0 and 1', ApiaryGame.new, (
      game,
    ) async {
      await load(game);

      bar.value = 2;
      expect(bar.value, 1);

      bar.value = -1;
      expect(bar.value, 0);
    });
  });
}
