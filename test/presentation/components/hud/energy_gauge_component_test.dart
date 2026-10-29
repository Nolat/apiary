// 🐦 Flutter imports:
import 'package:flutter/widgets.dart' show AppLifecycleState;

// 📦 Package imports:
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:apiary/domain/board/board.dart';
import 'package:apiary/domain/energy/energy.dart';
import 'package:apiary/presentation/components/hud/energy_gauge_component.dart';
import 'package:apiary/presentation/components/hud/pixel_panel_component.dart';
import 'package:apiary/presentation/game/apiary_game.dart';
import 'package:apiary/presentation/game/energy_countdown.dart';
import 'package:apiary/presentation/game/energy_notifier.dart';
import '../../../helpers/board_tap.dart';
import '../../../helpers/energy_container.dart';
import '../../../helpers/fake_trusted_clock.dart';
import '../../../helpers/game_text.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadGameText);

  final start = DateTime.utc(2026, 10, 27, 8);
  late FakeTrustedClock clock;

  Future<EnergyGaugeComponent> gaugeOf(ApiaryGame game) async {
    await game.ready();
    return game.world.descendants().whereType<EnergyGaugeComponent>().single;
  }

  group('EnergyGaugeComponent', () {
    testWithGame<ApiaryGame>(
      'shows 100 on a first game, without a countdown',
      ApiaryGame.new,
      (game) async {
        final gauge = await gaugeOf(game);

        expect(gauge.amountText, '100');
        expect(gauge.countdownText, isEmpty);
      },
    );

    testWithGame<ApiaryGame>(
      'sits in the HUD band, at its left',
      ApiaryGame.new,
      (game) async {
        final gauge = await gaugeOf(game);

        final hud = game.layout.hud;
        expect(gauge.position.x, hud.left + 2);
        expect(gauge.position.y, hud.top);
      },
    );

    testWithGame<ApiaryGame>(
      'follows the energy as the player spends it',
      ApiaryGame.new,
      (game) async {
        final gauge = await gaugeOf(game);
        final board = await boardOf(game);

        tapCell(game, board, Board.startingQueenPosition);
        tapCell(game, board, Board.startingQueenPosition);
        await game.ready();

        expect(gauge.amountText, '99');
      },
    );

    testWithGame<ApiaryGame>(
      'counts down to the next unit as mm:ss, and hides it at 100',
      () {
        clock = FakeTrustedClock(time: start);
        return ApiaryGame(
          container: energyContainer(
            clock: clock,
            saved: Energy(value: 50, countedFrom: start),
          ),
        );
      },
      (game) async {
        final gauge = await gaugeOf(game);

        game.update(EnergyNotifier.refreshInterval);
        expect(gauge.countdownText, '01:00');

        clock.advance(const Duration(seconds: 25));
        game.update(EnergyNotifier.refreshInterval);
        expect(gauge.countdownText, '00:35');

        clock.advance(const Duration(minutes: 50, seconds: 35));
        game.update(EnergyNotifier.refreshInterval);
        expect(gauge.amountText, '100');
        expect(gauge.countdownText, isEmpty);
      },
    );

    testWithGame<ApiaryGame>(
      'shows energy above 100 without a ceiling',
      () => ApiaryGame(
        container: energyContainer(saved: const Energy(value: 130)),
      ),
      (game) async {
        final gauge = await gaugeOf(game);

        expect(gauge.amountText, '130');
        expect(gauge.countdownText, isEmpty);
      },
    );

    testWithGame<ApiaryGame>(
      'pops when the board reports a missing energy',
      () =>
          ApiaryGame(container: energyContainer(saved: const Energy(value: 0))),
      (game) async {
        final gauge = await gaugeOf(game);
        final board = await boardOf(game);

        tapCell(game, board, Board.startingQueenPosition);
        tapCell(game, board, Board.startingQueenPosition);
        await game.ready();
        game.update(0.05);

        expect(
          gauge.children.whereType<PositionComponent>().any(
            (part) => part.scale.x > 1,
          ),
          isTrue,
        );
        game.update(1);
        expect(
          gauge.children.whereType<PositionComponent>().every(
            (part) => part.scale.x == 1,
          ),
          isTrue,
        );
      },
    );

    testWithGame<ApiaryGame>(
      'keeps a single pill when the countdown goes and comes back in a frame',
      ApiaryGame.new,
      (game) async {
        final gauge = await gaugeOf(game);
        final countdown = game.container.read(energyCountdownProvider.notifier)
          ..show(const Duration(seconds: 30))
          ..show(null)
          ..show(const Duration(seconds: 29));
        await game.ready();

        expect(gauge.showsCountdown, isTrue);
        expect(gauge.countdownText, '00:29');
        expect(gauge.children.whereType<PixelPanelComponent>(), hasLength(2));

        countdown.show(null);
        await game.ready();

        expect(gauge.showsCountdown, isFalse);
        expect(gauge.children.whereType<PixelPanelComponent>(), hasLength(1));
      },
    );

    testWithGame<ApiaryGame>(
      'ignores touches on the gauge, plus included',
      ApiaryGame.new,
      (game) async {
        final gauge = await gaugeOf(game);

        // Nothing handles taps: the gauge is not interactive for now.
        expect(gauge.children.whereType<TapCallbacks>(), isEmpty);
        expect(gauge, isNot(isA<TapCallbacks>()));
      },
    );
  });

  group('ApiaryGame energy', () {
    testWithGame<ApiaryGame>(
      'restarts from scratch on a full gauge',
      () =>
          ApiaryGame(container: energyContainer(saved: const Energy(value: 3))),
      (game) async {
        await game.ready();

        await game.restartFromScratch();
        await game.ready();

        expect(game.energyValue, Energy.full());
      },
    );

    testWithGame<ApiaryGame>(
      'asks the server for the time again when the app comes back',
      () {
        clock = FakeTrustedClock(time: start);
        return ApiaryGame(container: energyContainer(clock: clock));
      },
      (game) async {
        await game.ready();
        final before = clock.syncs;

        game.lifecycleStateChange(AppLifecycleState.paused);
        expect(clock.syncs, before);

        game.lifecycleStateChange(AppLifecycleState.resumed);
        expect(clock.syncs, before + 1);
      },
    );
  });
}
