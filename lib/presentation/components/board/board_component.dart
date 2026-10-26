// 🎯 Dart imports:
import 'dart:async';
import 'dart:ui';

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart' show ValueNotifier;

// 📦 Package imports:
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';

// 🌎 Project imports:
import 'package:apiary/domain/board/board.dart';
import 'package:apiary/domain/board/board_item.dart';
import 'package:apiary/domain/board/board_position.dart';
import 'package:apiary/domain/board/larva_spawn.dart';
import 'package:apiary/presentation/components/board/larva_component.dart';
import 'package:apiary/presentation/components/board/queen_component.dart';
import 'package:apiary/presentation/game/screen_layout.dart';

/// The 7×9 grid of [ScreenLayout.cellSize] cells: a checkerboard of light and
/// dark wooden cell sprites, so each cell stands apart from its neighbours,
/// with the items of its [board] on top. Its parent places it on
/// [ScreenLayout.board].
///
/// Tapping an item selects it ([selection]), marked by a frame on its cell.
/// Tapping a selected queen creates a larva next to her; when the board is
/// full, the queen shakes instead.
///
/// The look follows the visual universe in `docs/DESIGN.md` ("Univers
/// visuel").
class BoardComponent extends PositionComponent
    with HasGameReference, TapCallbacks {
  BoardComponent({required this.board})
    : super(
        size: Vector2(
          ScreenLayout.boardSize.width,
          ScreenLayout.boardSize.height,
        ),
      );

  /// What to draw on the grid. The component replaces it as the player acts;
  /// nothing else observes it yet.
  Board board;

  /// The selected cell, or `null` when nothing is selected, as at launch.
  final selection = ValueNotifier<BoardPosition?>(null);

  /// The selected item, if any.
  BoardItem? get selectedItem {
    final selected = selection.value;
    return selected == null ? null : board.itemAt(selected);
  }

  late final SpriteComponent _selectionFrame;
  final _itemComponents = <BoardPosition, PositionComponent>{};

  static const selectionImage = 'board/selection.png';
  static const lightCellImage = 'board/cell_light.png';
  static const darkCellImage = 'board/cell_dark.png';

  /// How far, in game pixels, a queen swings to each side to tell the board
  /// is full, and how long each swing takes. Whole pixels, to stay sharp.
  static const shakeDistance = 2.0;
  static const shakeStep = 0.05;

  /// Where an item sits in this component for the cell [position]: centered
  /// in it, with a margin around.
  static Vector2 itemPosition(BoardPosition position) => Vector2(
    position.column * ScreenLayout.cellSize + ScreenLayout.itemMargin,
    position.row * ScreenLayout.cellSize + ScreenLayout.itemMargin,
  );

  /// The cell under [point], given in this component's coordinates.
  static BoardPosition cellAt(Vector2 point) => BoardPosition(
    column: (point.x / ScreenLayout.cellSize).floor(),
    row: (point.y / ScreenLayout.cellSize).floor(),
  );

  @override
  Future<void> onLoad() async {
    final [lightCell, darkCell, frame] = await game.images.loadAll([
      lightCellImage,
      darkCellImage,
      selectionImage,
    ]);
    final lightSprite = Sprite(lightCell);
    final darkSprite = Sprite(darkCell);
    // One paint for every cell: nearest-neighbor, so pixels stay sharp at
    // fractional scales.
    final paint = Paint()..filterQuality = FilterQuality.none;
    for (var row = 0; row < Board.rows; row++) {
      for (var column = 0; column < Board.columns; column++) {
        await add(
          SpriteComponent(
            sprite: (row + column).isEven ? lightSprite : darkSprite,
            paint: paint,
            position: Vector2(
              column * ScreenLayout.cellSize,
              row * ScreenLayout.cellSize,
            ),
            size: Vector2.all(ScreenLayout.cellSize),
          ),
        );
      }
    }
    for (final MapEntry(key: position, value: item) in board.items.entries) {
      await add(_componentFor(position, item));
    }
    // Above the items, those created later too; invisible while nothing is
    // selected.
    _selectionFrame = SpriteComponent(
      priority: 1,
      sprite: Sprite(frame),
      // Its own paint: the opacity must not reach the cells.
      paint: Paint()..filterQuality = FilterQuality.none,
      size: Vector2.all(ScreenLayout.cellSize),
    )..opacity = 0;
    await add(_selectionFrame);
    selection.addListener(_updateSelectionFrame);
  }

  @override
  void onRemove() {
    selection
      ..removeListener(_updateSelectionFrame)
      ..dispose();
    super.onRemove();
  }

  @override
  void onTapDown(TapDownEvent event) {
    final tapped = cellAt(event.localPosition);
    if (!board.contains(tapped)) {
      return;
    }
    final item = board.itemAt(tapped);
    if (item is Queen && selection.value == tapped) {
      unawaited(_spawnLarva(tapped));
      return;
    }
    selection.value = board.selectionAfterTap(selection.value, tapped);
  }

  PositionComponent _componentFor(BoardPosition position, BoardItem item) {
    final component = switch (item) {
      Queen(:final family) => QueenComponent(
        family: family,
        position: itemPosition(position),
      ),
      Larva(:final family) => LarvaComponent(
        family: family,
        position: itemPosition(position),
      ),
    };
    return _itemComponents[position] = component;
  }

  Future<void> _spawnLarva(BoardPosition queen) async {
    switch (board.spawnLarva(queen)) {
      case LarvaCreated(board: final updated, :final position):
        board = updated;
        await add(_componentFor(position, board.itemAt(position)!));
      case BoardFull():
        await _shake(queen);
    }
  }

  // Back and forth around the item's cell, ending exactly where it started.
  // A shake already under way is dropped first, so taps in a row cannot make
  // the item drift.
  Future<void> _shake(BoardPosition position) async {
    final item = _itemComponents[position]!;
    for (final effect in item.children.whereType<Effect>().toList()) {
      effect.removeFromParent();
    }
    item.position.setFrom(itemPosition(position));
    Effect swing(double dx) => MoveByEffect(
      Vector2(dx, 0),
      LinearEffectController(shakeStep),
    );
    await item.add(
      SequenceEffect([
        swing(shakeDistance),
        swing(-2 * shakeDistance),
        swing(shakeDistance),
      ]),
    );
  }

  void _updateSelectionFrame() {
    final selected = selection.value;
    _selectionFrame.opacity = selected == null ? 0 : 1;
    if (selected != null) {
      _selectionFrame.position.setValues(
        selected.column * ScreenLayout.cellSize,
        selected.row * ScreenLayout.cellSize,
      );
    }
  }
}
