// 🎯 Dart imports:
import 'dart:async';

// 📦 Package imports:
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:apiary/core/startup/game_services.dart';
import 'package:apiary/core/startup/startup.dart';
import 'package:apiary/core/startup/startup_step.dart';
import 'package:apiary/domain/board/board.dart';
import 'package:apiary/domain/board/board_repository.dart';
import 'package:apiary/presentation/game/apiary_game.dart';
import 'package:apiary/presentation/scenes/board_scene.dart';
import 'package:apiary/presentation/scenes/splash_scene.dart';

import '../../helpers/game_golden.dart';
import '../../helpers/game_text.dart';

class _MemoryRepository implements BoardRepository {
  _MemoryRepository();

  Board? saved;

  @override
  Future<Board?> load() async => saved;

  @override
  Future<void> save(Board board) async => saved = board;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadGameText);

  // A launch the test steps through: it waits at each step until released.
  late Completer<GameServices> services;
  late _MemoryRepository repository;
  late Startup startup;

  ApiaryGame newGame() => ApiaryGame(startup: startup);

  SplashScene splashOf(ApiaryGame game) =>
      game.world.descendants().whereType<SplashScene>().single;

  String route(ApiaryGame game) => game.router.currentRoute.name!;

  // Lets the game run for [seconds], a frame at a time.
  Future<void> run(ApiaryGame game, double seconds) async {
    for (var elapsed = 0.0; elapsed < seconds; elapsed += 0.05) {
      game.update(0.05);
      await game.ready();
    }
  }

  setUp(() {
    services = Completer();
    repository = _MemoryRepository();
    startup = Startup((step) => services.future);
  });

  group('SplashScene', () {
    testWithGame<ApiaryGame>(
      'is what the game opens on, with the first step shown',
      newGame,
      (game) async {
        await game.ready();

        expect(route(game), SplashScene.routeName);
        expect(splashOf(game).labelText, 'Connexion aux services...');
      },
    );

    testWithGame<ApiaryGame>('shows each step as it starts', newGame, (
      game,
    ) async {
      await game.ready();
      final splash = splashOf(game);

      startup.step.value = StartupStep.account;
      expect(splash.labelText, 'Connexion au compte...');

      startup.step.value = StartupStep.board;
      expect(splash.labelText, 'Chargement du plateau...');

      startup.step.value = StartupStep.ready;
      expect(splash.labelText, 'Prêt !');
    });

    testWithGame<ApiaryGame>(
      'fits every step in the narrowest screen',
      newGame,
      (
        game,
      ) async {
        await game.ready();
        final splash = splashOf(game);

        for (final step in StartupStep.values) {
          startup.step.value = step;
          expect(
            splash.labelWidth,
            lessThanOrEqualTo(ApiaryGame.minimumSize.x),
          );
        }
      },
    );

    testWithGame<ApiaryGame>(
      'fills the bar progressively, not at once',
      newGame,
      (
        game,
      ) async {
        await game.ready();
        final splash = splashOf(game);

        startup.step.value = StartupStep.board;
        game.update(0.1);

        expect(splash.shownProgress, greaterThan(0));
        expect(splash.shownProgress, lessThan(StartupStep.board.progress));

        await run(game, 2);
        expect(splash.shownProgress, StartupStep.board.progress);
      },
    );

    testWithGame<ApiaryGame>(
      'breathes: the bee swells and shrinks back',
      newGame,
      (
        game,
      ) async {
        await game.ready();
        final bee = splashOf(game).bee;
        expect(bee.scale.x, SplashScene.restScale);

        game.update(SplashScene.breathDuration);
        expect(bee.scale.x, closeTo(SplashScene.breathScale, 0.001));

        game.update(SplashScene.breathDuration);
        expect(bee.scale.x, closeTo(SplashScene.restScale, 0.001));

        game.update(SplashScene.breathDuration);
        expect(bee.scale.x, closeTo(SplashScene.breathScale, 0.001));
      },
    );

    testWithGame<ApiaryGame>('says so when the launch fails', newGame, (
      game,
    ) async {
      await game.ready();
      services.completeError(StateError('offline'));
      await Future<void>.delayed(Duration.zero);
      await game.ready();

      expect(splashOf(game).labelText, 'Démarrage impossible');
      expect(startup.failed.value, isTrue);
      await run(game, 3);
      expect(route(game), SplashScene.routeName);
    });
  });

  group('ApiaryGame launch', () {
    testWithGame<ApiaryGame>(
      'opens the saved board once the launch is over',
      newGame,
      (game) async {
        final saved = Board.initial();
        repository.saved = saved;
        await game.ready();

        services.complete(GameServices(boardRepository: repository));
        await Future<void>.delayed(Duration.zero);
        await run(game, 3);

        expect(startup.step.value, StartupStep.ready);
        expect(route(game), BoardScene.routeName);
        expect(game.world.descendants().whereType<SplashScene>(), isEmpty);
        expect(game.boardRepository, repository);
      },
    );

    testWithGame<ApiaryGame>(
      'keeps the splash screen until the bar is full',
      newGame,
      (game) async {
        await game.ready();

        services.complete(GameServices(boardRepository: repository));
        await Future<void>.delayed(Duration.zero);
        game.update(0.1);
        await game.ready();

        expect(startup.step.value, StartupStep.ready);
        expect(route(game), SplashScene.routeName);
      },
    );

    testWithGame<ApiaryGame>(
      'starts on the starting board when the saved one cannot be read',
      newGame,
      (game) async {
        await game.ready();

        services.complete(GameServices(boardRepository: _BrokenRepository()));
        await Future<void>.delayed(Duration.zero);
        await run(game, 3);

        expect(route(game), BoardScene.routeName);
      },
    );
  });

  testGameGolden(
    'renders the splash screen',
    goldenFile: 'goldens/splash_scene.png',
    newGame: () => ApiaryGame(
      startup: Startup((step) => Completer<GameServices>().future),
    ),
    arrange: (game, tester) async {
      // Mid-breath, the bar on its first step.
      game.update(0.5);
    },
  );
}

class _BrokenRepository implements BoardRepository {
  @override
  Future<Board?> load() async => throw StateError('broken');

  @override
  Future<void> save(Board board) async {}
}
