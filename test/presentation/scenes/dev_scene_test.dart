// 🎯 Dart imports:
import 'dart:async';

// 🐦 Flutter imports:
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show KeyEventResult;

// 📦 Package imports:
import 'package:flame/events.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:apiary/core/dev/dev_tools.dart';
import 'package:apiary/domain/board/board.dart';
import 'package:apiary/presentation/components/dev/dev_button_component.dart';
import 'package:apiary/presentation/game/apiary_game.dart';
import 'package:apiary/presentation/scenes/board_scene.dart';
import 'package:apiary/presentation/scenes/dev_scene.dart';

import '../../helpers/board_tap.dart';
import '../../helpers/game_text.dart';

KeyDownEvent _keyDown(LogicalKeyboardKey key) => KeyDownEvent(
  physicalKey: PhysicalKeyboardKey.keyD,
  logicalKey: key,
  timeStamp: Duration.zero,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadGameText);

  late int resets;
  late StreamController<void> shakes;
  var resetDatabase = () async {};

  ApiaryGame newGame() => ApiaryGame(
    devTools: DevTools(
      resetDatabase: () async {
        resets++;
        await resetDatabase();
      },
      shakes: shakes.stream,
    ),
  );

  setUp(() {
    resets = 0;
    resetDatabase = () async {};
    shakes = StreamController<void>.broadcast(sync: true);
  });

  tearDown(() => shakes.close());

  String route(ApiaryGame game) => game.router.currentRoute.name!;

  group('DevScene', () {
    testWithGame<ApiaryGame>(
      'opens and closes when the phone is shaken',
      newGame,
      (game) async {
        await game.ready();

        shakes.add(null);
        await game.ready();
        expect(route(game), DevScene.routeName);

        shakes.add(null);
        await game.ready();
        expect(route(game), BoardScene.routeName);
      },
    );

    testWithGame<ApiaryGame>(
      'opens with Cmd+Shift+D',
      newGame,
      (game) async {
        await game.ready();

        final handled = game.onKeyEvent(_keyDown(LogicalKeyboardKey.keyD), {
          LogicalKeyboardKey.metaLeft,
          LogicalKeyboardKey.shiftLeft,
          LogicalKeyboardKey.keyD,
        });
        await game.ready();

        expect(handled, KeyEventResult.handled);
        expect(route(game), DevScene.routeName);
      },
    );

    testWithGame<ApiaryGame>(
      'ignores D without Cmd and Shift',
      newGame,
      (game) async {
        await game.ready();

        game
          ..onKeyEvent(_keyDown(LogicalKeyboardKey.keyD), {
            LogicalKeyboardKey.keyD,
          })
          ..onKeyEvent(_keyDown(LogicalKeyboardKey.keyD), {
            LogicalKeyboardKey.metaLeft,
            LogicalKeyboardKey.keyD,
          });
        await game.ready();

        expect(route(game), BoardScene.routeName);
      },
    );

    testWithGame<ApiaryGame>(
      'does not exist without dev tools',
      ApiaryGame.new,
      (game) async {
        await game.ready();

        game.toggleDevScreen();
        await game.ready();

        expect(route(game), BoardScene.routeName);
      },
    );

    testWithGame<ApiaryGame>(
      'Close goes back to the board',
      newGame,
      (game) async {
        await game.ready();
        game.toggleDevScreen();
        await game.ready();
        final dev = game.world.descendants().whereType<DevScene>().single;

        await dev.buttons.last.onPressed();
        await game.ready();

        expect(route(game), BoardScene.routeName);
      },
    );

    testWithGame<ApiaryGame>(
      'Reset database erases the data and restarts on the starting board',
      newGame,
      (game) async {
        final played = await boardOf(game);
        tapCell(game, played, Board.startingQueenPosition);
        tapCell(game, played, Board.startingQueenPosition);
        await game.ready();
        expect(played.board, isNot(Board.initial()));
        game.toggleDevScreen();
        await game.ready();
        final dev = game.world.descendants().whereType<DevScene>().single;
        expect(dev.buttons.first.label, 'Reset database');

        await dev.buttons.first.onPressed();
        final fresh = await boardOf(game);

        expect(resets, 1);
        expect(fresh, isNot(same(played)));
        expect(fresh.board, Board.initial());
        expect(route(game), BoardScene.routeName);
      },
    );

    testWithGame<ApiaryGame>(
      'keeps the dev screen and says so when the reset fails',
      newGame,
      (game) async {
        resetDatabase = () => Future.error(StateError('database locked'));
        await game.ready();
        game.toggleDevScreen();
        await game.ready();
        final dev = game.world.descendants().whereType<DevScene>().single;

        await dev.buttons.first.onPressed();

        expect(route(game), DevScene.routeName);
        expect(dev.statusText, contains('failed'));
      },
    );

    group('button', () {
      Future<(DevButtonComponent, Offset, MultiTapDispatcher)> openedButton(
        ApiaryGame game,
      ) async {
        await game.ready();
        game.toggleDevScreen();
        await game.ready();
        final button = game.world
            .descendants()
            .whereType<DevButtonComponent>()
            .first;
        final center = game.camera.localToGlobal(button.absoluteCenter);
        return (
          button,
          Offset(center.x, center.y),
          game.findByKey(const MultiTapDispatcherKey())! as MultiTapDispatcher,
        );
      }

      testWithGame<ApiaryGame>(
        'looks pressed while a finger is down and runs on release',
        newGame,
        (game) async {
          final (button, at, dispatcher) = await openedButton(game);

          dispatcher.onTapDown(
            createTapDownEvents(game: game, globalPosition: at),
          );
          expect(button.isPressed, isTrue);
          expect(resets, 0);

          dispatcher.onTapUp(
            createTapUpEvents(game: game, globalPosition: at),
          );
          await game.ready();

          expect(button.isPressed, isFalse);
          expect(resets, 1);
        },
      );

      testWithGame<ApiaryGame>(
        'does nothing while disabled',
        newGame,
        (game) async {
          final (button, at, dispatcher) = await openedButton(game);

          button.enabled = false;
          dispatcher
            ..onTapDown(createTapDownEvents(game: game, globalPosition: at))
            ..onTapUp(createTapUpEvents(game: game, globalPosition: at));
          await game.ready();

          expect(button.isPressed, isFalse);
          expect(resets, 0);
        },
      );
    });
  });
}
