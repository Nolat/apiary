// 📦 Package imports:
import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:apiary/presentation/game/apiary_game.dart';

import 'helpers/pump_app.dart';

void main() {
  setUpAll(setUpApiaryApp);

  testWidgets('ApiaryApp hosts the game', (tester) async {
    await tester.pumpApiaryApp();

    expect(find.byType(GameWidget<ApiaryGame>), findsOneWidget);
  });
}
