// 📦 Package imports:
import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

// 🌎 Project imports:
import 'package:apiary/bootstrap.dart';
import 'package:apiary/presentation/game/apiary_game.dart';

/// Starts the real app exactly like `main()` (Sentry, Firebase, anonymous
/// sign-in...) and waits for the game to be on screen.
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
  return game;
}

/// The running [ApiaryGame]. Flame scenes are painted on a canvas, invisible
/// to widget finders: E2E tests drive and inspect the game through it
/// (`game.router`, components) instead.
ApiaryGame gameOf(PatrolIntegrationTester $) => $.tester
    .state<GameWidgetState<ApiaryGame>>(find.byType(GameWidget<ApiaryGame>))
    .currentGame;
