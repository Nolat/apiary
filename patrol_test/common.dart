// 🐦 Flutter imports:
import 'package:flutter/widgets.dart';

// 📦 Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flame/game.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

// 🌎 Project imports:
import 'package:apiary/app.dart';
import 'package:apiary/bootstrap.dart';
import 'package:apiary/core/di/injection.dart';
import 'package:apiary/domain/board/board_repository.dart';
import 'package:apiary/presentation/game/apiary_game.dart';
import 'package:apiary/presentation/scenes/board_scene.dart';

/// Starts the real app exactly like `main()` (Sentry, Firebase, anonymous
/// sign-in...) and waits for the splash screen to give way to the board.
///
/// Call once per test: `bootstrap()` initializes process-wide singletons
/// (Firebase, get_it). Android runs each test in a fresh process (test
/// orchestrator); iOS doesn't, so keep one test per file there for now.
Future<ApiaryGame> launchApiary(PatrolIntegrationTester $) async {
  await bootstrap();
  // Never `pumpAndSettle`: the Flame game loop schedules frames forever.
  await $(GameWidget<ApiaryGame>).waitUntilExists();
  final game = gameOf($);
  await game.ready();
  // The launch runs behind the splash screen, which leaves once it is over.
  for (var i = 0; game.router.currentRoute.name != BoardScene.routeName; i++) {
    expect(i, lessThan(300), reason: 'The splash screen never gave way');
    await $.tester.pump(const Duration(milliseconds: 100));
  }
  return game;
}

/// The running [ApiaryGame]. Flame scenes are painted on a canvas, invisible
/// to widget finders: E2E tests drive and inspect the game through it
/// (`game.router`, components) instead.
ApiaryGame gameOf(PatrolIntegrationTester $) => $.tester
    .state<GameWidgetState<ApiaryGame>>(find.byType(GameWidget<ApiaryGame>))
    .currentGame;

/// Closes the game and opens the app again on the same database, as when the
/// player leaves the app and comes back: services stay up (a process cannot
/// be restarted from inside a test), the game starts over and reloads its
/// saved board.
Future<ApiaryGame> relaunchApiary(PatrolIntegrationTester $) async {
  await $.tester.pumpWidget(const SizedBox.shrink());
  await $.tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const [Locale('fr'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('fr'),
      child: ProviderScope(
        child: ApiaryApp(boardRepository: getIt<BoardRepository>()),
      ),
    ),
  );
  await $(GameWidget<ApiaryGame>).waitUntilExists();
  final game = gameOf($);
  await game.ready();
  return game;
}
