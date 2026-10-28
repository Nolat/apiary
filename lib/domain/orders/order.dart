// 📦 Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

// 🌎 Project imports:
import 'package:apiary/domain/board/board_item.dart';
import 'package:apiary/domain/orders/customer.dart';

part 'order.freezed.dart';

/// An order of the day (see "Journées et commandes" in `docs/DESIGN.md`): the
/// one or two [resources] a [customer] asks for, and the [coins] it pays once
/// delivered. Each resource is asked for once unless [quantities] says more.
@freezed
abstract class Order with _$Order {
  @Assert(
    'resources.length >= 1 && resources.length <= 2',
    'an order asks for one or two resources',
  )
  @Assert(
    'resources.toSet().length == resources.length',
    'an order never asks for the same resource twice',
  )
  @Assert(
    'quantities.keys.every(resources.contains)',
    'a quantity belongs to a resource the order asks for',
  )
  @Assert(
    'quantities.values.every((quantity) => quantity >= 1)',
    'an order asks for at least one of each resource',
  )
  @Assert('coins >= 0', 'coins cannot be negative')
  factory Order({
    required Customer customer,
    required List<Resource> resources,
    required int coins,

    /// How many of a resource the order asks for, when it is not just one.
    @Default({}) Map<Resource, int> quantities,
  }) = _Order;

  const Order._();

  /// How many of [resource] the order asks for.
  int quantityOf(Resource resource) => quantities[resource] ?? 1;
}
