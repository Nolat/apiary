// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:apiary/presentation/game/layout_debug_overlay.dart';

import '../../helpers/game_golden.dart';

void main() {
  group('LayoutDebugOverlay', () {
    testGameGolden(
      'draws the outline, checkerboard and scale over the board',
      goldenFile: 'goldens/layout_debug_overlay.png',
      arrange: (game, tester) async =>
          game.camera.viewfinder.add(LayoutDebugOverlay()),
    );
  });
}
