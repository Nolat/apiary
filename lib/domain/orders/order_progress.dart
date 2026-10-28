// 📦 Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

// 🌎 Project imports:
import 'package:apiary/domain/board/board.dart';
import 'package:apiary/domain/board/board_item.dart';
import 'package:apiary/domain/board/board_position.dart';
import 'package:apiary/domain/orders/order.dart';

part 'order_progress.freezed.dart';

/// How much of one resource of an order the board holds.
@freezed
abstract class ResourceProgress with _$ResourceProgress {
  @Assert('needed >= 1', 'an order asks for at least one')
  @Assert('positions.length <= needed', 'no more cells than asked for')
  const factory ResourceProgress({
    required Resource resource,

    /// How many the order asks for.
    required int needed,

    /// The cells whose resource would go to the delivery: those of the
    /// identical resources the board holds, at most [needed] of them.
    required List<BoardPosition> positions,
  }) = _ResourceProgress;

  const ResourceProgress._();

  /// How many of the resource the board holds, up to [needed].
  int get have => positions.length;

  /// Whether the board holds all the order asks for of this resource.
  bool get ready => have == needed;
}

/// How much of an [Order] the board holds. Nothing is reserved: each order is
/// measured on its own, so two orders asking for the same resource both count
/// it (see "Journées et commandes" in `docs/DESIGN.md`).
@freezed
abstract class OrderProgress with _$OrderProgress {
  const factory OrderProgress({
    required List<ResourceProgress> resources,
  }) = _OrderProgress;

  const OrderProgress._();

  /// What [board] holds of [order]: a resource counts when the board holds
  /// one identical to it (same branch and same tier). When it holds more than
  /// asked for, the ones counted are the first in reading order (top row
  /// first, left to right), those in [avoiding] last — provisional, until the
  /// delivery fixes which ones it takes. [avoiding] changes which items are
  /// shown, never how many count.
  factory OrderProgress.of(
    Order order,
    Board board, {
    Set<BoardPosition> avoiding = const {},
  }) {
    final cells = board.items.keys.toList()
      ..sort(
        (a, b) => a.row != b.row
            ? a.row.compareTo(b.row)
            : a.column.compareTo(b.column),
      );
    List<BoardPosition> pick(Resource resource) {
      final identical = cells
          .where((cell) => board.itemAt(cell) == resource)
          .toList();
      return [
        ...identical.where((cell) => !avoiding.contains(cell)),
        ...identical.where(avoiding.contains),
      ].take(order.quantityOf(resource)).toList();
    }

    return OrderProgress(
      resources: [
        for (final resource in order.resources)
          ResourceProgress(
            resource: resource,
            needed: order.quantityOf(resource),
            positions: pick(resource),
          ),
      ],
    );
  }

  /// What [board] holds of each of [orders], in order. Each order counts the
  /// board on its own, but shows items the orders before it have not shown
  /// when the board holds enough: two orders asking for the same resource
  /// mark two items when there are two.
  static List<OrderProgress> allOf(List<Order> orders, Board board) {
    final shown = <BoardPosition>{};
    return [
      for (final order in orders)
        OrderProgress.of(order, board, avoiding: {...shown})
          ..marked.forEach(shown.add),
    ];
  }

  /// Whether the board holds everything the order asks for.
  bool get ready => resources.every((resource) => resource.ready);

  /// The cells whose resource the order counts.
  Set<BoardPosition> get marked => {
    for (final resource in resources) ...resource.positions,
  };
}
