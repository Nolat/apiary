// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import '../../helpers/game_golden.dart';

void main() {
  group('BoardScene', () {
    testGameGolden(
      'renders the empty board',
      goldenFile: 'goldens/board_scene_empty.png',
    );
  });
}
