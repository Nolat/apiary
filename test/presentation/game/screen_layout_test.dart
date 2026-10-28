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
import 'package:apiary/presentation/game/screen_layout.dart';

/// A device of `tool/screenshots/ios.sh`: logical size, pixel ratio and safe
/// insets (estimated, the status bar being hidden).
/// [isPhone]: an iPhone, whose height the game scale fits to the pixel.
typedef _Device = ({
  String name,
  Size size,
  double pixelRatio,
  EdgeInsets insets,
  bool isPhone,
});

const _devices = <_Device>[
  (
    name: 'iPhone SE (3rd generation)',
    size: Size(375, 667),
    pixelRatio: 2,
    insets: EdgeInsets.zero,
    isPhone: true,
  ),
  (
    name: 'iPhone 13 mini',
    size: Size(375, 812),
    pixelRatio: 3,
    insets: EdgeInsets.only(top: 50, bottom: 34),
    isPhone: true,
  ),
  (
    name: 'iPhone 18 Pro',
    size: Size(402, 874),
    pixelRatio: 3,
    insets: EdgeInsets.only(top: 62, bottom: 34),
    isPhone: true,
  ),
  (
    name: 'iPhone 18 Pro Max',
    size: Size(440, 956),
    pixelRatio: 3,
    insets: EdgeInsets.only(top: 62, bottom: 34),
    isPhone: true,
  ),
  (
    name: 'iPhone Duo',
    size: Size(466, 678),
    pixelRatio: 3,
    insets: EdgeInsets.only(right: 84),
    isPhone: false,
  ),
  (
    name: 'iPad mini (A17 Pro)',
    size: Size(744, 1133),
    pixelRatio: 2,
    insets: EdgeInsets.only(top: 24, bottom: 20),
    isPhone: false,
  ),
  (
    name: 'iPad Pro 13-inch (M5)',
    size: Size(1032, 1376),
    pixelRatio: 2,
    insets: EdgeInsets.only(top: 24, bottom: 20),
    isPhone: false,
  ),
];

/// The bands are whole-pixel, inside the safe area (give or take half a
/// pixel of rounding), stacked top to bottom
/// without gap or overlap, with a fixed-size board centered horizontally.
void _expectValid(ScreenLayout layout, Rect safeArea) {
  for (final band in layout.bands) {
    for (final edge in [band.left, band.top, band.right, band.bottom]) {
      expect(edge, edge.roundToDouble(), reason: '$band has whole edges');
    }
    expect(band.left, greaterThanOrEqualTo(safeArea.left - 0.5));
    expect(band.top, greaterThanOrEqualTo(safeArea.top - 0.5));
    expect(band.right, lessThanOrEqualTo(safeArea.right + 0.5));
    // Never under the system UI at the bottom (home indicator).
    expect(band.bottom, lessThanOrEqualTo(safeArea.bottom));
  }
  final bands = layout.bands;
  for (var i = 1; i < bands.length; i++) {
    expect(bands[i].top, bands[i - 1].bottom, reason: 'bands are stacked');
  }
  // Rounding the safe area may take up to a pixel.
  expect(
    layout.ordersGap.height + layout.spacer.height,
    greaterThanOrEqualTo(ScreenLayout.minimumSpacerHeight - 1),
  );
  // The orders sit in the middle of the room left over.
  expect(
    (layout.ordersGap.height - layout.spacer.height).abs(),
    lessThanOrEqualTo(1),
  );
  expect(layout.board.size, ScreenLayout.boardSize);
  final leftMargin = layout.board.left - layout.hud.left;
  final rightMargin = layout.hud.right - layout.board.right;
  expect((leftMargin - rightMargin).abs(), lessThanOrEqualTo(1));
}

void main() {
  group('ScreenLayout', () {
    for (final device in _devices) {
      testWithGame<FlameGame>(
        'lays out every band in the safe area of an ${device.name}',
        () => FlameGame(
          camera: CameraComponent(
            viewport: GameViewport(
              minimumSize: ApiaryGame.minimumSize,
              devicePixelRatio: () => device.pixelRatio,
              safePadding: () => device.insets,
            ),
          ),
        ),
        (game) async {
          game.onGameResize(Vector2(device.size.width, device.size.height));
          final viewport = game.camera.viewport as GameViewport;

          final layout = ScreenLayout.compute(
            screen: viewport.visibleArea,
            safeArea: viewport.safeArea,
          );

          _expectValid(layout, viewport.safeArea);
          if (device.isPhone) {
            // The room left over is just the minimum, give or take rounding.
            expect(
              layout.ordersGap.height + layout.spacer.height,
              lessThanOrEqualTo(ScreenLayout.minimumSpacerHeight + 2),
            );
          }
        },
      );
    }

    test('fits every safe area from the minimum size up', () {
      for (var width = 140.0; width <= 330; width += 7.3) {
        for (var height = 285.0; height <= 600; height += 13.7) {
          final safeArea = Rect.fromLTWH(0.4, 9.1, width, height);
          final layout = ScreenLayout.compute(
            screen: Rect.fromLTWH(0, 0, width + 1, height + 20),
            safeArea: safeArea,
          );

          _expectValid(layout, safeArea);
        }
      }
    });

    test('fits an iPhone, the board centered and the orders mid-room', () {
      // iPhone 18 Pro: 147.3×320.2 game pixels, safe from 22.71 to 307.7.
      final layout = ScreenLayout.compute(
        screen: const Rect.fromLTWH(0, 0, 147.26, 320.17),
        safeArea: const Rect.fromLTRB(0, 22.71, 147.26, 307.7),
      );

      // The right edge is rounded (147.26 → 147), the bottom floored
      // (307.7 → 307): the bar stays above the home indicator. Both ends
      // keep 4 px of padding.
      expect(layout.board, const Rect.fromLTWH(3, 303 - 40 - 180, 140, 180));
      expect(layout.hud.left, 0);
      expect(layout.hud.right, 147);
      expect(layout.hud.top, 27);
      expect(layout.bottomBar.bottom, 303);
      expect(layout.ordersGap, const Rect.fromLTRB(0, 41, 147, 44));
      expect(layout.orders, const Rect.fromLTRB(0, 44, 147, 79));
      expect(layout.spacer, const Rect.fromLTRB(0, 79, 147, 83));
    });

    test('keeps a padding at the top and the bottom of the safe area', () {
      final layout = ScreenLayout.compute(
        screen: const Rect.fromLTWH(0, 0, 160, 300),
        safeArea: const Rect.fromLTRB(0, 0, 160, 300),
      );

      expect(layout.hud.top, ScreenLayout.verticalPadding);
      expect(layout.bottomBar.bottom, 300 - ScreenLayout.verticalPadding);
    });

    test('shares what is left over above and under the orders', () {
      // 30 px left over: 15 on each side of the orders.
      final layout = ScreenLayout.compute(
        screen: const Rect.fromLTWH(0, 0, 140, 320),
        safeArea: const Rect.fromLTRB(0, 0, 140, 307),
      );

      expect(layout.ordersGap.height, 15);
      expect(layout.spacer.height, 15);
    });
  });
}
