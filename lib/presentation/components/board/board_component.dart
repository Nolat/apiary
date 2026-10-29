// 🎯 Dart imports:
import 'dart:async';
import 'dart:math';

// 🐦 Flutter imports:
import 'package:flutter/animation.dart' show Curves;
import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:flutter/services.dart' show HapticFeedback;

// 📦 Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';

// 🌎 Project imports:
import 'package:apiary/domain/board/bee_release.dart';
import 'package:apiary/domain/board/board.dart';
import 'package:apiary/domain/board/board_drop.dart';
import 'package:apiary/domain/board/board_item.dart';
import 'package:apiary/domain/board/board_position.dart';
import 'package:apiary/domain/board/larva_spawn.dart';
import 'package:apiary/domain/board/resource_production.dart';
import 'package:apiary/domain/energy/energy.dart';
import 'package:apiary/presentation/components/board/bee_component.dart';
import 'package:apiary/presentation/components/board/board_banner_component.dart';
import 'package:apiary/presentation/components/board/bounce_effect.dart';
import 'package:apiary/presentation/components/board/centered_scale_effect.dart';
import 'package:apiary/presentation/components/board/hive_component.dart';
import 'package:apiary/presentation/components/board/item_marks_component.dart';
import 'package:apiary/presentation/components/board/larva_component.dart';
import 'package:apiary/presentation/components/board/queen_component.dart';
import 'package:apiary/presentation/components/board/resource_component.dart';
import 'package:apiary/presentation/components/pixel_paint.dart';
import 'package:apiary/presentation/game/energy_notifier.dart';
import 'package:apiary/presentation/game/screen_layout.dart';

/// The 7×9 grid of [ScreenLayout.cellSize] cells: a checkerboard of light and
/// dark wooden cell sprites, so each cell stands apart from its neighbours,
/// with the items of its [board] on top. Its parent places it on
/// [ScreenLayout.board].
///
/// Tapping an item selects it ([selection]), marked by a frame on its cell.
/// Lifting the finger from a selected queen creates a larva next to her; when
/// the board is full, the queen shakes instead. A drag never does: it cancels
/// the tap. Any item can be dragged: it follows the finger and is selected.
/// Dropped on a larva of the same family, a larva merges into a bee; a bee
/// dropped on an identical one (unless of the family's last level) merges into
/// the bee of the next level; a bee dropped on an empty hive goes into it; a
/// bee dropped on a hive that holds one swaps places with it; dropped on an
/// empty cell, an item moves there;
/// dropped on a different item, the two swap places; otherwise it goes back to
/// its cell.
///
/// Tapping a queen on a full board also pops up a banner on the top row (see
/// [BoardBannerComponent]) and is felt as a heavy haptic impact.
///
/// A larva born and a merge are felt as a light and a medium haptic impact.
///
/// The look follows the visual universe in `docs/DESIGN.md` ("Univers
/// visuel").
class BoardComponent extends PositionComponent
    with HasGameReference, TapCallbacks, DragCallbacks {
  BoardComponent({
    required Board board,
    required this.energy,
    this.onChanged,
    Random? random,
  }) : changes = ValueNotifier(board),
       _random = random ?? Random(),
       super(
         size: Vector2(
           ScreenLayout.boardSize.width,
           ScreenLayout.boardSize.height,
         ),
       );

  // Picks which of two resources a hive makes. Injected so tests can seed it.
  final Random _random;

  /// Where the energy a larva or a resource costs is taken from.
  final EnergyNotifier energy;

  /// What to draw on the grid. The component replaces it as the player acts;
  /// [changes] tells whoever shows something that depends on it.
  Board get board => changes.value;
  set board(Board board) => changes.value = board;

  /// The board as it is now; notifies each time an action replaces it.
  final ValueNotifier<Board> changes;

  /// Told of the new [board] each time an action changes it (a larva born, a
  /// move, a swap, a merge), as soon as it is done and not when its animation
  /// ends, so that a sudden close right after it loses nothing.
  final void Function(Board board)? onChanged;

  /// Bumped when the item of a cell changes under a selection that stays, a
  /// hive that has just made a resource or let its bee go for instance: what
  /// shows the selected item (the info panel) refreshes from it.
  final itemChanged = ValueNotifier<int>(0);

  /// Bumped each time a tap could not produce for lack of energy.
  final energyMissing = ValueNotifier<int>(0);

  /// The selected cell, or `null` when nothing is selected, as at launch.
  final selection = ValueNotifier<BoardPosition?>(null);

  /// The last removal, while it can still be undone: the board and the cell
  /// as they were before it. It lasts until the player does anything else on
  /// the board; `null` otherwise.
  final removal = ValueNotifier<({Board before, BoardPosition position})?>(
    null,
  );

  /// Whether the last removal can still be undone.
  bool get canUndo => removal.value != null;

  /// The item the last removal took, while it can still be undone.
  BoardItem? get removedItem {
    final removal = this.removal.value;
    return removal?.before.itemAt(removal.position);
  }

  /// The selected item, if any.
  BoardItem? get selectedItem {
    final selected = selection.value;
    return selected == null ? null : board.itemAt(selected);
  }

  late final SpriteComponent _selectionFrame;
  final _marks = ItemMarksComponent();
  late final BoardBannerComponent _fullBanner;
  late final BoardBannerComponent _missingEnergyBanner;

  /// The cells wearing a check badge: those whose resource an order counts.
  /// Set by whoever knows the orders; the board only draws them.
  Set<BoardPosition> get marked => _marks.marked;
  set marked(Set<BoardPosition> cells) => _marks.marked = cells;

  /// The banner of a tap that finds the board full.
  BoardBannerComponent get fullBanner => _fullBanner;

  /// The banner of a tap that finds the energy missing.
  BoardBannerComponent get missingEnergyBanner => _missingEnergyBanner;
  final _itemComponents = <BoardPosition, PositionComponent>{};

  // The queen or occupied hive the current tap started on while it was already
  // selected: it makes a larva or a resource when the tap ends, unless the tap
  // turns into a drag.
  BoardPosition? _tappedGenerator;

  // The cell of the item being dragged, and where the finger is, in this
  // component's coordinates; `null` when no item is being dragged.
  BoardPosition? _dragged;

  // The cell whose new item already pops in: it is not bounced as well.
  BoardPosition? _bouncedAlready;
  Vector2? _finger;
  int? _dragPointer;

  /// Priority of a dragged item: above the selection frame and the items.
  static const draggedPriority = 2;

  /// Priority of the full-board banner: above everything, a dragged item too.
  static const bannerPriority = 3;

  static const selectionImage = 'board/selection.png';
  static const lightCellImage = 'board/cell_light.png';
  static const darkCellImage = 'board/cell_dark.png';

  /// How far, in game pixels, a queen swings to each side to tell the board
  /// is full, and how long each swing takes. Whole pixels, to stay sharp.
  static const shakeDistance = 2.0;
  static const shakeStep = 0.05;

  /// How long the bounce of an item, when it gets selected or its queen makes
  /// a larva, and of the selection frame, takes: a quick scale up and back.
  static const bounceDuration = 0.16;

  /// How much bigger an item gets while the finger holds it, and how long it
  /// takes to be lifted.
  static const liftScale = 1.15;
  static const liftDuration = 0.08;

  /// How long the held item takes to land on the one it merges with, and
  /// the result to pop in, overshooting, once both are gone.
  static const landDuration = 0.1;
  static const popDuration = 0.22;
  static const popStartScale = 0.6;

  /// How long the selection frame takes to grow to the cell it lands on,
  /// from [frameStartScale], overshooting.
  static const frameDuration = 0.18;
  static const frameStartScale = 0.5;

  /// How long the item swapped out of its cell takes to reach its new cell,
  /// with a slight overshoot that makes it bounce.
  static const slideDuration = 0.18;

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
    final paint = pixelPaint();
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
      paint: pixelPaint(),
      size: Vector2.all(ScreenLayout.cellSize),
    )..opacity = 0;
    await add(_selectionFrame);
    // Above the items; the item a finger holds is above it.
    _marks.priority = 1;
    await add(_marks);
    // Invisible until the board is full and tapped.
    await add(
      _fullBanner = BoardBannerComponent(message: 'board.full'.tr()),
    );
    await add(
      _missingEnergyBanner = BoardBannerComponent(
        message: 'energy.missing'.tr(),
      ),
    );
    selection
      ..addListener(_updateSelectionFrame)
      ..addListener(_bounceSelected);
  }

  @override
  void onRemove() {
    selection
      ..removeListener(_updateSelectionFrame)
      ..removeListener(_bounceSelected)
      ..dispose();
    removal.dispose();
    itemChanged.dispose();
    energyMissing.dispose();
    changes.dispose();
    super.onRemove();
  }

  @override
  void onTapDown(TapDownEvent event) {
    _forgetRemoval();
    final tapped = cellAt(event.localPosition);
    if (!board.contains(tapped)) {
      return;
    }
    final item = board.itemAt(tapped);
    final generates = item is Queen || (item is Hive && item.bee != null);
    _tappedGenerator = generates && selection.value == tapped ? tapped : null;
    selection.value = board.selectionAfterTap(selection.value, tapped);
  }

  @override
  void onTapUp(TapUpEvent event) {
    final generator = _tappedGenerator;
    _tappedGenerator = null;
    if (generator == null) {
      return;
    }
    unawaited(
      board.itemAt(generator) is Queen
          ? _spawnLarva(generator)
          : _produceResource(generator),
    );
  }

  @override
  void onTapCancel(TapCancelEvent event) => _tappedGenerator = null;

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _forgetRemoval();
    // Whatever the tap recognizer reports next, this gesture is a drag.
    _tappedGenerator = null;
    // One item at a time: another finger cannot take over the drag.
    if (_dragged != null) {
      return;
    }
    final cell = cellAt(event.localPosition);
    final item = _itemComponents[cell];
    if (item == null) {
      return;
    }
    _dragged = cell;
    _marks.hold(cell);
    _dragPointer = event.pointerId;
    _finger = event.localPosition.clone();
    // A queen grabbed while shaking would carry the swing along.
    _stopEffects(item);
    item
      ..position.setFrom(itemPosition(cell))
      ..priority = draggedPriority;
    unawaited(
      _play(
        item,
        CenteredScaleEffect(
          from: 1,
          to: liftScale,
          duration: liftDuration,
          curve: Curves.easeOut,
        ),
      ),
    );
    selection.value = cell;
    // The notifier stays silent when the cell was already selected.
    _updateSelectionFrame();
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    final dragged = _dragged;
    if (dragged == null || event.pointerId != _dragPointer) {
      return;
    }
    // Follow the finger by its displacement: it keeps working past the edge
    // of the board, where the finger's own position is not delivered.
    final delta = event.localDelta;
    _finger!.add(delta);
    _itemComponents[dragged]!.position.add(delta);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (event.pointerId == _dragPointer) {
      unawaited(_drop());
    }
  }

  // A cancelled gesture is not a release: the item goes back to its cell.
  @override
  // Flame's default turns a cancel into an end, hence no call to super.
  // ignore: must_call_super
  void onDragCancel(DragCancelEvent event) {
    if (event.pointerId == _dragPointer) {
      if (_release() case (final from, final item)) {
        item.position.setFrom(itemPosition(from));
      }
    }
  }

  // Ends the drag in progress; gives the cell and the component that were held.
  (BoardPosition, PositionComponent)? _release() {
    final from = _dragged;
    _dragged = null;
    _dragPointer = null;
    _finger = null;
    if (from == null) {
      return null;
    }
    _marks.release(from);
    final item = _itemComponents[from]!..priority = 0;
    _stopEffects(item);
    // Shown again before the selection moves on, in the same frame.
    _updateSelectionFrame();
    return (from, item);
  }

  Future<void> _drop() async {
    final finger = _finger;
    final released = _release();
    if (released == null || finger == null) {
      return;
    }
    final (from, item) = released;
    final onto = cellAt(finger);
    final result = board.drop(from, onto);
    if (result == null) {
      item.position.setFrom(itemPosition(from));
      return;
    }
    board = result.board;
    onChanged?.call(board);
    switch (result) {
      case ItemMoved():
        _itemComponents
          ..remove(from)
          ..[onto] = item;
        item.position.setFrom(itemPosition(onto));
        selection.value = onto;
      case ItemsSwapped():
        final other = _itemComponents[onto]!;
        _stopEffects(other);
        _itemComponents
          ..[from] = other
          ..[onto] = item;
        // The item that was not dragged slides to the cell left free.
        _marks.hold(from, seconds: slideDuration);
        other.position.setFrom(itemPosition(onto));
        unawaited(_slide(other, itemPosition(from)));
        item.position.setFrom(itemPosition(onto));
        selection.value = onto;
      case BeeHoused():
        // The bee lands on the hive, then both give way to the hive that
        // holds it.
        await _landAndReplace(from, onto, item);
      case ItemsMerged():
        // The held item lands on the other one, which is still there; only
        // then do both give way to the result.
        await _landAndReplace(from, onto, item);
    }
  }

  /// The dragged [item] lands on the one at [onto], then both give way to the
  /// item the board now holds there, which pops in and is selected.
  Future<void> _landAndReplace(
    BoardPosition from,
    BoardPosition onto,
    PositionComponent item,
  ) async {
    _itemComponents.remove(from);
    _marks.hold(onto);
    await _land(item, itemPosition(onto));
    unawaited(HapticFeedback.mediumImpact());
    item.removeFromParent();
    _itemComponents[onto]?.removeFromParent();
    final replacement = _componentFor(onto, board.itemAt(onto)!);
    await add(replacement);
    _marks.release(onto);
    unawaited(_popIn(replacement));
    // The frame grows on its own; the item has just popped in.
    _bouncedAlready = onto;
    selection.value = onto;
  }

  /// Removes the selected item, if the player can: its cell is freed and
  /// nothing is selected any more. [undoRemoval] brings it back until the
  /// player does something else on the board.
  void removeSelected() {
    final selected = selection.value;
    if (selected == null || _dragged != null) {
      return;
    }
    final removed = board.remove(selected);
    if (removed == null) {
      return;
    }
    // The undo is offered before the selection moves on: listeners see both.
    final before = board;
    board = removed;
    onChanged?.call(board);
    _itemComponents.remove(selected)?.removeFromParent();
    removal.value = (before: before, position: selected);
    selection.value = null;
  }

  /// Takes the bee out of the selected hive, if it has made nothing yet: it
  /// pops out on the nearest free cell and the hive is empty again, or the
  /// board shows it is full.
  Future<void> releaseSelectedBee() async {
    final hive = selection.value;
    if (hive == null || _dragged != null) {
      return;
    }
    switch (board.releaseBee(hive)) {
      case BeeReleased(board: final updated, :final position):
        _forgetRemoval();
        board = updated;
        onChanged?.call(board);
        // The info panel follows now, not once the sprites have loaded.
        itemChanged.value++;
        unawaited(HapticFeedback.lightImpact());
        _itemComponents[hive]?.removeFromParent();
        await add(_componentFor(hive, board.itemAt(hive)!));
        final bee = _componentFor(position, board.itemAt(position)!);
        await add(bee);
        unawaited(_popIn(bee));
      case BeeReleaseBoardFull():
        _forgetRemoval();
        await _signalBoardFull(hive);
      case null:
        // Nothing to let go: whatever was undoable stays so.
        break;
    }
  }

  /// Puts back the item the last removal took, selected, as it was.
  Future<void> undoRemoval() async {
    final undone = removal.value;
    if (undone == null) {
      return;
    }
    final (:before, :position) = undone;
    _forgetRemoval();
    board = before;
    onChanged?.call(board);
    await add(_componentFor(position, board.itemAt(position)!));
    selection.value = position;
  }

  void _forgetRemoval() => removal.value = null;

  /// A component drawing [item], at [position] in its parent.
  static PositionComponent componentOf(BoardItem item, {Vector2? position}) =>
      switch (item) {
        Queen(:final family) => QueenComponent(
          family: family,
          position: position,
        ),
        Larva(:final family) => LarvaComponent(
          family: family,
          position: position,
        ),
        Bee(:final family, :final level) => BeeComponent(
          family: family,
          level: level,
          position: position,
        ),
        Hive(:final bee) => HiveComponent(bee: bee, position: position),
        Resource(:final branch, :final tier) => ResourceComponent(
          branch: branch,
          tier: tier,
          position: position,
        ),
      };

  PositionComponent _componentFor(BoardPosition position, BoardItem item) =>
      _itemComponents[position] = componentOf(
        item,
        position: itemPosition(position),
      );

  Future<void> _spawnLarva(BoardPosition queen) async {
    if (!energy.canAfford(Energy.productionCost)) {
      await _signalMissingEnergy(queen);
      return;
    }
    switch (board.spawnLarva(queen)) {
      case LarvaCreated(board: final updated, :final position):
        energy.trySpend(Energy.productionCost);
        board = updated;
        onChanged?.call(board);
        unawaited(HapticFeedback.lightImpact());
        unawaited(_bounce(_itemComponents[queen]!, itemPosition(queen)));
        await add(_componentFor(position, board.itemAt(position)!));
      case BoardFull():
        await _signalBoardFull(queen);
    }
  }

  Future<void> _produceResource(BoardPosition hive) async {
    if (!energy.canAfford(Energy.productionCost)) {
      await _signalMissingEnergy(hive);
      return;
    }
    switch (board.produceResource(hive, _random)) {
      case ResourceCreated(board: final updated, :final position):
        energy.trySpend(Energy.productionCost);
        board = updated;
        onChanged?.call(board);
        unawaited(HapticFeedback.lightImpact());
        if ((board.itemAt(hive)! as Hive).bee == null) {
          // The bee is spent: the hive is drawn empty, and what shows the
          // selected item follows.
          _itemComponents[hive]?.removeFromParent();
          final spent = _componentFor(hive, board.itemAt(hive)!);
          await add(spent);
          unawaited(_bounce(spent, itemPosition(hive)));
        } else {
          unawaited(_bounce(_itemComponents[hive]!, itemPosition(hive)));
        }
        // The hive is not what it was: it can no longer let its bee go, or
        // it is empty.
        itemChanged.value++;
        await add(_componentFor(position, board.itemAt(position)!));
      case ResourceBoardFull():
        await _signalBoardFull(hive);
    }
  }

  // The generator at [position] cannot make anything: a heavy impact, the
  // banner, and the generator shakes.
  Future<void> _signalBoardFull(BoardPosition position) async {
    unawaited(HapticFeedback.heavyImpact());
    // The middle of the top row, where the eye is not on a finger.
    _fullBanner.show(Vector2(size.x / 2, ScreenLayout.cellSize / 2));
    await _shake(position);
  }

  // The generator at [position] cannot make anything for lack of energy: a
  // heavy impact, the banner, the gauge and the generator shakes. Nothing is
  // spent and the board is as it was.
  Future<void> _signalMissingEnergy(BoardPosition position) async {
    unawaited(HapticFeedback.heavyImpact());
    _missingEnergyBanner.show(Vector2(size.x / 2, ScreenLayout.cellSize / 2));
    energyMissing.value++;
    await _shake(position);
  }

  // Back and forth around the item's cell, ending exactly where it started.
  // A shake already under way is dropped first, so taps in a row cannot make
  // the item drift.
  Future<void> _shake(BoardPosition position) async {
    final item = _itemComponents[position]!;
    _stopEffects(item);
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

  // A shake still under way would keep moving the item from its new cell.
  void _stopEffects(PositionComponent item) {
    for (final effect in item.children.whereType<Effect>().toList()) {
      // Removal waits for the next update, which it must not take part in.
      effect
        ..pause()
        ..removeFromParent();
    }
    item.scale.setAll(1);
  }

  // Bounces the selection frame and the newly selected item, unless it is the
  // one being dragged: that one is already held up by the finger.
  void _bounceSelected() {
    final selected = selection.value;
    if (selected == null || _dragged != null) {
      return;
    }
    unawaited(_growFrame());
    final item = _itemComponents[selected];
    final popping = _bouncedAlready == selected;
    _bouncedAlready = null;
    if (item != null && !popping) {
      unawaited(_bounce(item, itemPosition(selected)));
    }
  }

  // The selection frame lands on its cell small and grows into it.
  Future<void> _growFrame() async {
    _stopEffects(_selectionFrame);
    await _selectionFrame.add(
      CenteredScaleEffect(
        from: frameStartScale,
        to: 1,
        duration: frameDuration,
        curve: Curves.easeOutBack,
      ),
    );
  }

  // [home] is where [component] rests: a bounce in progress is cut short.
  Future<void> _bounce(PositionComponent component, Vector2 home) async {
    _stopEffects(component);
    component.position.setFrom(home);
    await component.add(BounceEffect(duration: bounceDuration));
  }

  // A new item grows into its cell from small, with a little overshoot.
  Future<void> _popIn(PositionComponent component) => _play(
    component,
    CenteredScaleEffect(
      from: popStartScale,
      to: 1,
      duration: popDuration,
      curve: Curves.easeOutBack,
    ),
  );

  Future<void> _play(PositionComponent component, Effect effect) async {
    await component.add(effect);
  }

  // Slides [item], held up, onto [to] and sets it down; completes once it has.
  Future<void> _land(PositionComponent item, Vector2 to) async {
    item.priority = 0;
    final landed = Completer<void>();
    await item.add(
      CenteredScaleEffect(
        from: liftScale,
        to: 1,
        duration: landDuration,
        curve: Curves.easeIn,
        slideTo: to,
        onComplete: landed.complete,
      ),
    );
    await landed.future;
  }

  // Brings [component] to [to] with a bounce, from where it is.
  Future<void> _slide(PositionComponent component, Vector2 to) async {
    _stopEffects(component);
    await component.add(
      MoveToEffect(
        to,
        EffectController(duration: slideDuration, curve: Curves.easeOutBack),
      ),
    );
  }

  void _updateSelectionFrame() {
    final selected = selection.value;
    // Hidden while an item is dragged: the item itself shows it is held.
    _selectionFrame.opacity = selected == null || _dragged != null ? 0 : 1;
    if (selected != null) {
      _stopEffects(_selectionFrame);
      _selectionFrame.position.setValues(
        selected.column * ScreenLayout.cellSize,
        selected.row * ScreenLayout.cellSize,
      );
    }
  }
}
