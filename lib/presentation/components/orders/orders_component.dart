// 🎯 Dart imports:
import 'dart:math';
import 'dart:ui';

// 📦 Package imports:
import 'package:flame/components.dart';
import 'package:flame/events.dart';

// 🌎 Project imports:
import 'package:apiary/domain/orders/order.dart';
import 'package:apiary/domain/orders/order_progress.dart';
import 'package:apiary/presentation/components/orders/order_card_component.dart';

/// The orders band: one [OrderCardComponent] per order of the day, side by
/// side in order, which the player scrolls sideways by dragging when they
/// outgrow the band. The cards are cut where the band ends. A drag here
/// moves the cards only: the board is not under it. Its parent places it on
/// the band of the screen layout with [place].
class OrdersComponent extends PositionComponent with DragCallbacks {
  OrdersComponent({required this.orders}) {
    var left = 0.0;
    for (final order in orders) {
      final card = OrderCardComponent(order)..position.setValues(left, 0);
      cards.add(card);
      left += card.size.x + gap;
    }
    // The gap after the last card is not content.
    _contentWidth = max(0, left - gap);
  }

  final List<Order> orders;

  /// The cards, in the order of [orders], whether or not they are in view.
  final cards = <OrderCardComponent>[];

  /// Shows what the board holds of each order, one entry per order in the
  /// order of [orders].
  // ignore: avoid_setters_without_getters
  set progress(List<OrderProgress> progress) {
    for (final (i, card) in cards.indexed) {
      card.progress = progress[i];
    }
  }

  /// The room between two cards.
  static const gap = 2.0;

  final _content = PositionComponent();
  late final double _contentWidth;

  // Kept as the finger moved it: rounding each small move would lose it.
  var _offset = 0.0;

  /// How far the cards have been scrolled, in whole game pixels.
  double get scroll => _offset.roundToDouble();

  /// How far the cards can be scrolled at most: what does not fit in the
  /// band; 0 when all the cards do.
  double get maxScroll => max(0, _contentWidth - size.x);

  @override
  Future<void> onLoad() async {
    await add(_content);
    await _content.addAll(cards);
  }

  /// Puts the strip on [band], the part of the screen layout's orders band
  /// the cards use, keeping the scroll in range.
  void place(Rect band) {
    position.setValues(band.left, band.top);
    size.setValues(band.width, band.height);
    _scrollTo(_offset);
  }

  void _scrollTo(double value) {
    _offset = value.clamp(0, maxScroll).toDouble();
    // Whole pixels, so that every card stays on the pixel grid.
    _content.position.x = -scroll;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) =>
      _scrollTo(_offset - event.localDelta.x);

  // Hard edges, not anti-aliased: at a fractional scale a smoothed edge would
  // blur the pixels of the card it cuts.
  @override
  void render(Canvas canvas) {
    canvas.clipRect(size.toRect(), doAntiAlias: false);
  }
}
