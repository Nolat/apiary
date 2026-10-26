// 🎯 Dart imports:
import 'dart:ui';

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart' show immutable;

/// Where each band of the game screen goes, in game pixels, Flambé-style:
/// fixed-size bands pinned to the top and bottom of the safe area, and a
/// [spacer] absorbing the height that varies from one device to another.
///
/// ```text
/// ┌─ safe area ─────────────┐  decor ([screen]) extends under the system UI
/// │ hud           12 fixed  │  ← pinned to the top
/// │ orders        32 fixed  │
/// │ spacer       ≥ 6 flex   │  ← 9 (iPhone SE) to ~50 (iPhone Pro Max)
/// │ board    140×180 fixed  │  ← 7×9 cells of 20, centered
/// │ bottomBar     16 fixed  │  ← pinned to the bottom
/// └─────────────────────────┘
/// ```
///
/// The board is as wide as the minimum safe area, so on every iPhone — where
/// the screen is exactly that wide — it fills the width, edge to edge; on
/// tablets and foldables, where the height limits the scale, it is as large
/// as the height allows, centered. The other bands span the safe area's width
/// (140 on iPhones, up to ~190 on iPads, where panels widen through
/// 9-slices). Edges are whole pixels. Pure: a scene recomputes it from
/// `ApiaryGame.layout` in `onGameResize`. Band heights other than the
/// board's are placeholders until the HUD and orders are designed.
@immutable
class ScreenLayout {
  const ScreenLayout._({
    required this.screen,
    required this.hud,
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
    // area by less than half a game pixel at most, but a 140-wide safe area
    // always holds the 140-wide board.
    final left = safeArea.left.roundToDouble();
    final top = safeArea.top.roundToDouble();
    final right = safeArea.right.roundToDouble();
    final bottom = safeArea.bottom.roundToDouble();

    final hud = Rect.fromLTRB(left, top, right, top + hudHeight);
    final orders = Rect.fromLTRB(
      left,
      hud.bottom,
      right,
      hud.bottom + ordersHeight,
    );
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
    return ScreenLayout._(
      screen: screen,
      hud: hud,
      orders: orders,
      spacer: Rect.fromLTRB(left, orders.bottom, right, board.top),
      board: board,
      bottomBar: bottomBar,
    );
  }

  static const hudHeight = 12.0;
  static const ordersHeight = 32.0;
  static const bottomBarHeight = 16.0;

  static const boardColumns = 7;
  static const boardRows = 9;

  /// A cell's size, and its sprites' (×1 assets only).
  static const cellSize = 20.0;
  static const boardSize = Size(boardColumns * cellSize, boardRows * cellSize);

  /// Height of the fixed bands, stacked.
  static const double fixedHeight =
      hudHeight + ordersHeight + boardRows * cellSize + bottomBarHeight;

  static const minimumSpacerHeight = 6.0;

  /// The smallest safe area the layout fits: the board's width, and the
  /// fixed bands' height plus the minimum spacer — 246, which the iPhone SE,
  /// the tightest screen, just meets (249.0).
  static const minimumSafeSize = Size(
    boardColumns * cellSize,
    fixedHeight + minimumSpacerHeight,
  );

  /// The whole screen, for the decor.
  final Rect screen;

  /// Resources: day, energy, Apidex, shop.
  final Rect hud;

  /// The day's customers and their orders.
  final Rect orders;

  /// Room between the orders and the board, at least [minimumSpacerHeight].
  final Rect spacer;

  /// The 7×9 grid.
  final Rect board;

  /// Selected item, delete button.
  final Rect bottomBar;

  /// Every band but the screen, top to bottom.
  List<Rect> get bands => [hud, orders, spacer, board, bottomBar];

  @override
  bool operator ==(Object other) =>
      other is ScreenLayout &&
      other.screen == screen &&
      other.hud == hud &&
      other.orders == orders &&
      other.spacer == spacer &&
      other.board == board &&
      other.bottomBar == bottomBar;

  @override
  int get hashCode =>
      Object.hash(screen, hud, orders, spacer, board, bottomBar);

  @override
  String toString() =>
      'ScreenLayout(screen: $screen, hud: $hud, orders: $orders, '
      'spacer: $spacer, board: $board, bottomBar: $bottomBar)';
}
