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
        game.onGameResize(Vector2(224, 398));
        final viewport = viewportFor(game);

        expect(viewport.pixelScale, 1);
        expect(viewport.visibleArea, const Rect.fromLTWH(0, 0, 224, 398));
        expect(viewport.safeArea, const Rect.fromLTWH(0, 0, 224, 398));
      },
    );

    testWithGame<FlameGame>(
      'is exactly 224 game pixels wide on an iPhone, its height varying',
      iPhonePro,
      (game) async {
        game.onGameResize(iPhoneProSize);
        final viewport = viewportFor(game);

        // min(1206 / 224, 2334 / 398): the width limits, ×5.384.
        const scale = 1206 / 224;
        expect(viewport.pixelScale, closeTo(scale, 1e-6));
        expect(viewport.scale.x, closeTo(scale / 3, 1e-6));
        expect(viewport.visibleArea.width, closeTo(224, 1e-4));
        expect(viewport.visibleArea.height, closeTo(2622 / scale, 1e-4));
        expect(viewport.safeArea.top, closeTo(186 / scale, 1e-4));
        expect(viewport.safeArea.bottom, closeTo(2520 / scale, 1e-4));
      },
    );

    testWithGame<FlameGame>(
      'fills the width of the shortest iPhone too',
      // iPhone SE: 375×667 logical, DPR 2, 16:9.
      gameWith(devicePixelRatio: 2),
      (game) async {
        game.onGameResize(Vector2(375, 667));
        final viewport = viewportFor(game);

        // min(750 / 224, 1334 / 398): still the width, 224×398.4.
        expect(viewport.pixelScale, closeTo(750 / 224, 1e-6));
        expect(viewport.visibleArea.width, closeTo(224, 1e-4));
        expect(viewport.visibleArea.height, greaterThanOrEqualTo(398));
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

        // min(2064 / 224, 2664 / 398) = 6.693: 308 game pixels wide.
        const scale = 2664 / 398;
        expect(viewport.pixelScale, closeTo(scale, 1e-6));
        expect(viewport.safeArea.height, closeTo(398, 1e-4));
        expect(viewport.visibleArea.width, closeTo(2064 / scale, 1e-4));
      },
    );

    testWithGame<FlameGame>(
      'keeps the minimum width clear of a camera hole on the side',
      // iPhone Duo-like: 1398×2034 physical, camera hole on the right side.
      gameWith(
        devicePixelRatio: 3,
        safePadding: const EdgeInsets.only(right: 84),
      ),
      (game) async {
        game.onGameResize(Vector2(466, 678));
        final viewport = viewportFor(game);

        // min(1146 / 224, 2034 / 398): the height limits, just.
        const scale = 2034 / 398;
        expect(viewport.pixelScale, closeTo(scale, 1e-6));
        expect(viewport.safeArea.left, 0);
        expect(viewport.safeArea.width, closeTo(1146 / scale, 1e-4));
        expect(viewport.safeArea.width, greaterThanOrEqualTo(224));
      },
    );

    testWithGame<FlameGame>(
      'converts between screen and game coordinates',
      iPhonePro,
      (game) async {
        game.onGameResize(iPhoneProSize);
        final worldPoint = Vector2(30, 270);

        final screenPoint = game.camera.localToGlobal(worldPoint);

        // 30 × 5.384 / 3 and 270 × 5.384 / 3 logical pixels.
        const scale = 1206 / 224;
        expect(screenPoint.x, closeTo(30 * scale / 3, 1e-3));
        expect(screenPoint.y, closeTo(270 * scale / 3, 1e-3));
        final back = game.camera.globalToLocal(screenPoint);
        expect(back.x, closeTo(worldPoint.x, 1e-3));
        expect(back.y, closeTo(worldPoint.y, 1e-3));
      },
    );
  });
}
