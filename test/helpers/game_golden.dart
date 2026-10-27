// 🐦 Flutter imports:
import 'package:flutter/widgets.dart';

// 📦 Package imports:
import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:apiary/presentation/game/apiary_game.dart';
import 'game_text.dart';

/// Tag of every golden test, declared in `dart_test.yaml`. Goldens only match
/// on the reference platform (macOS), so CI on Linux excludes it — see
/// docs/TESTING.md.
const goldenTag = 'golden';

/// Renders a full [ApiaryGame] at its minimum size (140×248, device pixel
/// ratio 1: the tightest layout, the iPhone SE's) and compares it to
/// [goldenFile], so one golden pixel is one game pixel.
///
/// [newGame] makes the game to render, [ApiaryGame.new] by default.
///
/// [arrange] runs once the game is loaded on its initial scene: navigate
/// (`game.router.pushNamed(...)`), add components, advance time
/// (`game.update(dt)`)... before the frame is captured.
///
/// Regenerate after an intended visual change with
/// `fvm flutter test --update-goldens --tags golden`.
void testGameGolden(
  String description, {
  required String goldenFile,
  ApiaryGame Function() newGame = ApiaryGame.new,
  Future<void> Function(ApiaryGame game, WidgetTester tester)? arrange,
}) {
  testWidgets(description, tags: goldenTag, (tester) async {
    tester.view
      ..physicalSize = Size(
        ApiaryGame.minimumSize.x,
        ApiaryGame.minimumSize.y,
      )
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final game = newGame();
    const key = ValueKey('golden-game');

    // Flame loads assets and components asynchronously: real async is needed
    // for that work to complete inside the fake-async test zone.
    await tester.runAsync(() async {
      await loadGameText();
      await tester.pumpWidget(GameWidget(key: key, game: game));
      await tester.pump();
      await game.ready();
      await arrange?.call(game, tester);
      await game.ready();
      await tester.pump();
    });

    await expectLater(find.byKey(key), matchesGoldenFile(goldenFile));
  });
}
