// 🐦 Flutter imports:
import 'package:flutter/widgets.dart';

// 📦 Package imports:
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:apiary/presentation/game/apiary_game.dart';
import 'package:apiary/presentation/game/game_viewport.dart';

void main() {
  group('GameViewport', () {
    GameViewport viewportFor(FlameGame game) =>
        game.camera.viewport as GameViewport;

    FlameGame Function() gameWith({
      required double devicePixelRatio,
      EdgeInsets safePadding = EdgeInsets.zero,
    }) =>
        () => FlameGame(
          camera: CameraComponent(
            viewport: GameViewport(
              minimumSize: ApiaryGame.minimumSize,
              devicePixelRatio: () => devicePixelRatio,
              safePadding: () => safePadding,
            ),
          ),
        );

    // iPhone 16/18 Pro: 402×874 logical, DPR 3, so 1206×2622 physical; the
    // safe area (minus Dynamic Island and home indicator) is 1206×2334.
    final iPhonePro = gameWith(
      devicePixelRatio: 3,
      safePadding: const EdgeInsets.only(top: 62, bottom: 34),
    );
    final iPhoneProSize = Vector2(402, 874);

    testWithGame<FlameGame>(
      'maps one game pixel to one pixel at the minimum size',
      gameWith(devicePixelRatio: 1),
      (game) async {
        game.onGameResize(Vector2(140, 285));
        final viewport = viewportFor(game);

        expect(viewport.pixelScale, 1);
        expect(viewport.visibleArea, const Rect.fromLTWH(0, 0, 140, 285));
        expect(viewport.safeArea, const Rect.fromLTWH(0, 0, 140, 285));
      },
    );

    testWithGame<FlameGame>(
      'is exactly 285 game pixels tall in the safe area of an iPhone, its '
      'width following',
      iPhonePro,
      (game) async {
        game.onGameResize(iPhoneProSize);
        final viewport = viewportFor(game);

        // min(1206 / 140, 2334 / 285): the height limits, ×8.19.
        const scale = 2334 / 285;
        expect(viewport.pixelScale, closeTo(scale, 1e-6));
        expect(viewport.scale.x, closeTo(scale / 3, 1e-6));
        expect(viewport.safeArea.height, closeTo(285, 1e-4));
        expect(viewport.visibleArea.width, closeTo(1206 / scale, 1e-4));
        expect(viewport.visibleArea.height, closeTo(2622 / scale, 1e-4));
        expect(viewport.safeArea.top, closeTo(186 / scale, 1e-4));
        expect(viewport.safeArea.bottom, closeTo(2520 / scale, 1e-4));
        // A little wider than the board.
        expect(viewport.visibleArea.width, greaterThan(140));
        expect(viewport.visibleArea.width, lessThan(150));
      },
    );

    testWithGame<FlameGame>(
      'is wider on the iPhone SE, whose screen is shorter for its width',
      // iPhone SE: 375×667 logical, DPR 2, 16:9.
      gameWith(devicePixelRatio: 2),
      (game) async {
        game.onGameResize(Vector2(375, 667));
        final viewport = viewportFor(game);

        // min(750 / 140, 1334 / 285): the height limits, ×4.68.
        const scale = 1334 / 285;
        expect(viewport.pixelScale, closeTo(scale, 1e-6));
        expect(viewport.safeArea.height, closeTo(285, 1e-4));
        expect(viewport.visibleArea.width, closeTo(750 / scale, 1e-4));
        expect(viewport.visibleArea.width, closeTo(160.2, 0.1));
      },
    );

    testWithGame<FlameGame>(
      'widens instead on a tablet, where the height limits',
      // iPad Pro 13": 1032×1376 logical, DPR 2, status bar and home
      // indicator insets.
      gameWith(
        devicePixelRatio: 2,
        safePadding: const EdgeInsets.only(top: 24, bottom: 20),
      ),
      (game) async {
        game.onGameResize(Vector2(1032, 1376));
        final viewport = viewportFor(game);

        // min(2064 / 140, 2664 / 285) = 9.35: 221 game pixels wide.
        const scale = 2664 / 285;
        expect(viewport.pixelScale, closeTo(scale, 1e-6));
        expect(viewport.safeArea.height, closeTo(285, 1e-4));
        expect(viewport.visibleArea.width, closeTo(2064 / scale, 1e-4));
      },
    );

    testWithGame<FlameGame>(
      'keeps the minimum width clear of a camera hole on the side',
      // iPhone Duo-like: 1398×2340 physical, camera hole on the right side.
      gameWith(
        devicePixelRatio: 3,
        safePadding: const EdgeInsets.only(right: 84),
      ),
      (game) async {
        game.onGameResize(Vector2(466, 780));
        final viewport = viewportFor(game);

        // min(1146 / 140, 2340 / 285): the width limits, just.
        const scale = 1146 / 140;
        expect(viewport.pixelScale, closeTo(scale, 1e-6));
        expect(viewport.safeArea.left, 0);
        expect(viewport.safeArea.width, closeTo(140, 1e-4));
        expect(viewport.safeArea.height, greaterThanOrEqualTo(285));
      },
    );

    testWithGame<FlameGame>(
      'converts between screen and game coordinates',
      iPhonePro,
      (game) async {
        game.onGameResize(iPhoneProSize);
        final worldPoint = Vector2(30, 270);

        final screenPoint = game.camera.localToGlobal(worldPoint);

        // 30 × 8.19 / 3 and 270 × 8.19 / 3 logical pixels.
        const scale = 2334 / 285;
        expect(screenPoint.x, closeTo(30 * scale / 3, 1e-3));
        expect(screenPoint.y, closeTo(270 * scale / 3, 1e-3));
        final back = game.camera.globalToLocal(screenPoint);
        expect(back.x, closeTo(worldPoint.x, 1e-3));
        expect(back.y, closeTo(worldPoint.y, 1e-3));
      },
    );
  });
}
