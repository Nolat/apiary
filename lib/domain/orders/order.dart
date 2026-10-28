// 📦 Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

// 🌎 Project imports:
import 'package:apiary/domain/board/board_item.dart';
import 'package:apiary/domain/orders/customer.dart';

part 'order.freezed.dart';

/// An order of the day (see "Journées et commandes" in `docs/DESIGN.md`): the
/// one or two [resources] a [customer] asks for, one of each, and the [coins]
/// it pays once delivered.
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
  @Assert('coins >= 0', 'coins cannot be negative')
  factory Order({
    required Customer customer,
    required List<Resource> resources,
    required int coins,
  }) = _Order;
}
