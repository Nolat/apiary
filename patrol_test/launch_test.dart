// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

// 🌎 Project imports:
import 'package:apiary/core/auth/auth_service.dart';
import 'package:apiary/core/di/injection.dart';
import 'package:apiary/presentation/scenes/board_scene.dart';
import 'common.dart';

void main() {
  patrolTest(
    'cold start signs in anonymously and opens the board',
    ($) async {
      final game = await launchApiary($);

      expect(getIt<AuthService>().currentUserId, isNotNull);
      expect(game.router.currentRoute.name, BoardScene.routeName);
    },
  );
}
