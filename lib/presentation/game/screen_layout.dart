// 🎯 Dart imports:
import 'dart:ui';

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart' show immutable;

// 🌎 Project imports:
import 'package:apiary/domain/board/board.dart';

/// Where each band of the game screen goes, in game pixels, Flambé-style:
/// fixed-size bands pinned to the top and bottom of the safe area, and the
/// height left over, which varies from one device to another, shared between
/// the room above the orders and the [spacer] under them.
///
/// ```text
/// ┌─ safe area ─────────────┐  decor ([screen]) extends under the system UI
/// │ padding        4 fixed  │
/// │ hud           14 fixed  │  ← pinned to the top
/// │ ordersGap    ≥ 4 flex   │  ← half of the room left over
/// │ orders        35 fixed  │
/// │ spacer       ≥ 4 flex   │  ← the other half; 8 in all from 285 up
/// │ board    140×180 fixed  │  ← 7×9 cells of 20, centered
/// │ bottomBar     40 fixed  │  ← pinned to the bottom (panel 38, padded 2)
/// │ padding        4 fixed  │
/// └─────────────────────────┘
/// ```
///
/// The scale is set by the height: a phone's safe area is 285 game pixels
/// tall, which fits the fixed bands and [minimumSpacerHeight] of room, and its
/// width follows from its shape (143 on an iPhone 18 Pro, 156 on an iPhone
/// SE), the 140-pixel board centered with a margin of wood on each side. On
/// tablets and foldables the screen is wider still. The other bands span the
/// safe area's width (up to ~215 on iPads, where panels widen through
/// 9-slices). Edges are whole pixels. Pure: a scene recomputes it from
/// `ApiaryGame.layout` in `onGameResize`. Band heights other than the board's
/// are placeholders until the HUD and orders are designed.
@immutable
class ScreenLayout {
  const ScreenLayout._({
    required this.screen,
    required this.hud,
    required this.ordersGap,
    required this.orders,
    required this.spacer,
    required this.board,
    required this.bottomBar,
  });

  /// Lays the bands out on [screen] (the whole screen), within [safeArea],
  /// which must be at least [minimumSafeSize].
  factory ScreenLayout.compute({
    required Rect screen,
    required Rect safeArea,
  }) {
    // Whole pixels, rounded to the nearest: the bands overflow the safe
    // area by less than half a game pixel at most, but a safe area at least
    // [minimumSafeSize] wide always holds the 140-wide board.
    final left = safeArea.left.roundToDouble();
    // Always kept off the edges, on top of the insets: an iPhone SE has none,
    // and the corners of other screens are rounded.
    final top = safeArea.top.roundToDouble() + verticalPadding;
    final right = safeArea.right.roundToDouble();
    // Floored, so the bottom bar never dips under the home indicator.
    final bottom = safeArea.bottom.floorToDouble() - verticalPadding;

    final hud = Rect.fromLTRB(left, top, right, top + hudHeight);
    final bottomBar = Rect.fromLTRB(
      left,
      bottom - bottomBarHeight,
      right,
      bottom,
    );
    final board = Rect.fromLTWH(
      left + ((right - left - boardSize.width) / 2).floorToDouble(),
      bottomBar.top - boardSize.height,
      boardSize.width,
      boardSize.height,
    );
    // The room left between the HUD and the board, minus the orders, is shared
    // in two: the orders sit in the middle of it.
    final room = board.top - hud.bottom - ordersHeight;
    final orders = Rect.fromLTWH(
      left,
      hud.bottom + (room / 2).floorToDouble(),
      right - left,
      ordersHeight,
    );
    return ScreenLayout._(
      screen: screen,
      hud: hud,
      ordersGap: Rect.fromLTRB(left, hud.bottom, right, orders.top),
      orders: orders,
      spacer: Rect.fromLTRB(left, orders.bottom, right, board.top),
      board: board,
      bottomBar: bottomBar,
    );
  }

  /// The room kept at the top and at the bottom of the safe area, so that the
  /// bands never touch the edge of a screen without insets.
  static const verticalPadding = 4.0;

  /// The HUD is as tall as the energy gauge's panel; the countdown pill
  /// under it hangs over the orders band.
  static const hudHeight = 14.0;
  static const ordersHeight = 35.0;

  /// How far from the safe area's left edge the HUD's content starts, which
  /// keeps it off the rounded screen corners.
  static const hudPadding = 2.0;

  /// The bottom bar holds the panels, [bottomBarPanelHeight] tall, with
  /// [bottomBarPadding] of room above them, which keeps them off the board,
  /// and on each side, which keeps them clear of the rounded screen corners.
  static const bottomBarPadding = 2.0;
  static const bottomBarPanelHeight = 38.0;
  static const double bottomBarHeight = bottomBarPadding + bottomBarPanelHeight;

  /// A cell's size, and its sprites' (×1 assets only).
  static const cellSize = 20.0;

  /// An item's sprites are 16×16, centered in a cell.
  static const itemMargin = 2.0;
  static const double itemSize = cellSize - 2 * itemMargin;
  static const boardSize = Size(
    Board.columns * cellSize,
    Board.rows * cellSize,
  );

  /// Height of the fixed bands, stacked.
  static const double fixedHeight =
      2 * verticalPadding +
      hudHeight +
      ordersHeight +
      Board.rows * cellSize +
      bottomBarHeight;

  /// The room left over, above and under the orders together.
  static const minimumSpacerHeight = 8.0;

  /// The smallest safe area the layout fits: as wide as the board, and as
  /// tall as the fixed bands plus the minimum room, 285. The viewport scales
  /// the game so that a phone's safe area is just this tall, hence a little
  /// wider than the board.
  static const minimumSafeSize = Size(
    Board.columns * cellSize,
    fixedHeight + minimumSpacerHeight,
  );

  /// The whole screen, for the decor.
  final Rect screen;

  /// Resources: day, energy, Apidex, shop.
  final Rect hud;

  /// Room between the HUD and the orders, which the energy gauge's "+" and
  /// countdown pill overhang.
  final Rect ordersGap;

  /// The day's customers and their orders.
  final Rect orders;

  /// Room between the orders and the board; with [ordersGap], at least
  /// [minimumSpacerHeight].
  final Rect spacer;

  /// The 7×9 grid.
  final Rect board;

  /// Selected item, delete button.
  final Rect bottomBar;

  /// Every band but the screen, top to bottom.
  List<Rect> get bands => [hud, ordersGap, orders, spacer, board, bottomBar];

  @override
  bool operator ==(Object other) =>
      other is ScreenLayout &&
      other.screen == screen &&
      other.hud == hud &&
      other.ordersGap == ordersGap &&
      other.orders == orders &&
      other.spacer == spacer &&
      other.board == board &&
      other.bottomBar == bottomBar;

  @override
  int get hashCode =>
      Object.hash(screen, hud, ordersGap, orders, spacer, board, bottomBar);

  @override
  String toString() =>
      'ScreenLayout(screen: $screen, hud: $hud, ordersGap: $ordersGap, '
      'orders: $orders, spacer: $spacer, board: $board, bottomBar: $bottomBar)';
}
