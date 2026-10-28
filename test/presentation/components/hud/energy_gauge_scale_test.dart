// 🎯 Dart imports:
import 'dart:typed_data';

// 🐦 Flutter imports:
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// 📦 Package imports:
import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:apiary/domain/energy/energy.dart';
import 'package:apiary/presentation/game/apiary_game.dart';
import 'package:apiary/presentation/game/energy_notifier.dart';
import 'package:apiary/presentation/game/screen_layout.dart';

import '../../../helpers/energy_container.dart';
import '../../../helpers/fake_trusted_clock.dart';
import '../../../helpers/game_text.dart';

/// The goldens render at ×1, where every pixel of every sprite is the same.
/// On a phone the scale is fractional (an iPhone 18 Pro is 1206 physical
/// pixels for 140 game pixels, 8.6 each): this renders the HUD at that scale,
/// where a 9-slice that is squashed (a panel shorter than the sprite parts
/// `drawImageNine` draws whole) or an edge that is blended shows at once.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadGameText);

  const width = 1206;
  const gamePixel = width / 140;

  testWidgets('the energy panel draws every game pixel at the same size', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(width * 1.0, 2622)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final start = DateTime.utc(2026, 10, 27, 8);
    final now = start.add(const Duration(seconds: 25));
    final game = ApiaryGame(
      container: energyContainer(
        clock: FakeTrustedClock(time: now)..serverTime = now,
        saved: Energy(value: 42, countedFrom: start),
      ),
    );
    final key = GlobalKey();

    late ByteData pixels;
    late int imageWidth;
    await tester.runAsync(() async {
      await loadGameText();
      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: GameWidget(game: game),
        ),
      );
      await tester.pump();
      await game.ready();
      game.update(EnergyNotifier.refreshInterval);
      await game.ready();
      await tester.pump();
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage();
      imageWidth = image.width;
      pixels = (await image.toByteData())!;
    });

    int colorAt(int x, int y) => pixels.getUint32((y * imageWidth + x) * 4);

    // The heights, in physical pixels, of the runs of one color down the
    // column of game pixel [gameX], from the top of the screen to [gameY].
    List<int> runsDown(double gameX, double gameY) {
      final x = (gameX * gamePixel).round();
      final runs = <int>[];
      int? previous;
      for (var y = 0; y < gameY * gamePixel; y++) {
        final color = colorAt(x, y);
        if (color == previous) {
          runs.last++;
        } else {
          runs.add(1);
          previous = color;
        }
      }
      return runs;
    }

    // A column through the panel, clear of the bolt, the badge and the text:
    // its three rings (white, shadow, light) are one game pixel each.
    // The panel starts under the screen's top padding: skip the backdrop.
    final rings = runsDown(
      14,
      ScreenLayout.verticalPadding + 3,
    ).skip(1).take(3);

    expect(
      rings,
      everyElement(inInclusiveRange(gamePixel.floor(), gamePixel.ceil())),
      reason: 'A game pixel is 8 or 9 physical pixels, the ring rows too',
    );
  });
}
