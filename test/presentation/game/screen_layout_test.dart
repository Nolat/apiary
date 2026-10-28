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
/// [fillsWidth]: an iPhone, where the board spans the screen's width.
typedef _Device = ({
  String name,
  Size size,
  double pixelRatio,
  EdgeInsets insets,
  bool fillsWidth,
});

const _devices = <_Device>[
  (
    // Short of the minimum height until the layout is reworked for small
    // screens: the height limits the scale, as on a tablet.
    name: 'iPhone SE (3rd generation)',
    size: Size(375, 667),
    pixelRatio: 2,
    insets: EdgeInsets.zero,
    fillsWidth: false,
  ),
  (
    name: 'iPhone 13 mini',
    size: Size(375, 812),
    pixelRatio: 3,
    insets: EdgeInsets.only(top: 50, bottom: 34),
    fillsWidth: true,
  ),
  (
    name: 'iPhone 18 Pro',
    size: Size(402, 874),
    pixelRatio: 3,
    insets: EdgeInsets.only(top: 62, bottom: 34),
    fillsWidth: true,
  ),
  (
    name: 'iPhone 18 Pro Max',
    size: Size(440, 956),
    pixelRatio: 3,
    insets: EdgeInsets.only(top: 62, bottom: 34),
    fillsWidth: true,
  ),
  (
    name: 'iPhone Duo',
    size: Size(466, 678),
    pixelRatio: 3,
    insets: EdgeInsets.only(right: 84),
    fillsWidth: false,
  ),
  (
    name: 'iPad mini (A17 Pro)',
    size: Size(744, 1133),
    pixelRatio: 2,
    insets: EdgeInsets.only(top: 24, bottom: 20),
    fillsWidth: false,
  ),
  (
    name: 'iPad Pro 13-inch (M5)',
    size: Size(1032, 1376),
    pixelRatio: 2,
    insets: EdgeInsets.only(top: 24, bottom: 20),
    fillsWidth: false,
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
    layout.spacer.height,
    greaterThanOrEqualTo(ScreenLayout.minimumSpacerHeight - 1),
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
          if (device.fillsWidth) {
            expect(layout.board.left, 0, reason: 'board edge to edge');
            expect(layout.board.right, closeTo(layout.screen.right, 0.5));
          }
        },
      );
    }

    test('fits every safe area from the minimum size up', () {
      for (var width = 140.0; width <= 330; width += 7.3) {
        for (var height = 269.0; height <= 600; height += 13.7) {
          final safeArea = Rect.fromLTWH(0.4, 9.1, width, height);
          final layout = ScreenLayout.compute(
            screen: Rect.fromLTWH(0, 0, width + 1, height + 20),
            safeArea: safeArea,
          );

          _expectValid(layout, safeArea);
        }
      }
    });

    test('spans the whole width of an iPhone with its board', () {
      // iPhone 18 Pro: 140×304.4 game pixels, safe from 21.6 to 292.5.
      final layout = ScreenLayout.compute(
        screen: const Rect.fromLTWH(0, 0, 140, 304.4),
        safeArea: const Rect.fromLTRB(0, 21.59, 140, 292.54),
      );

      // The bottom is floored (292.54 → 292): the bar stays above the home
      // indicator.
      expect(layout.board, const Rect.fromLTWH(0, 292 - 40 - 180, 140, 180));
      expect(layout.hud.top, 22);
      expect(layout.bottomBar.bottom, 292);
      expect(layout.spacer.height, (292 - 40 - 180) - (22 + 14 + 35));
    });
  });
}
