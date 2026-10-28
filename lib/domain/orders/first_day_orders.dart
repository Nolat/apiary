// 🌎 Project imports:
import 'package:apiary/domain/board/board_item.dart';
import 'package:apiary/domain/orders/customer.dart';
import 'package:apiary/domain/orders/order.dart';
import 'package:apiary/domain/resources/resource_branch.dart';

/// The orders of a first game's first day: a fixed list, until the day's
/// orders are generated. What they ask for and pay is provisional (see
/// "Journées et commandes" and "Pièces" in `docs/DESIGN.md`).
abstract final class FirstDayOrders {
  static final List<Order> orders = [
    Order(
      customer: Customer.baker,
      resources: const [Resource(branch: ResourceBranch.honey)],
      coins: 10,
    ),
    Order(
      customer: Customer.candleMaker,
      resources: const [
        Resource(branch: ResourceBranch.wax, tier: 2),
        Resource(branch: ResourceBranch.wax),
      ],
      coins: 20,
    ),
    Order(
      customer: Customer.herbalist,
      resources: const [
        Resource(branch: ResourceBranch.honey, tier: 2),
        Resource(branch: ResourceBranch.wax),
      ],
      coins: 35,
    ),
    Order(
      customer: Customer.baker,
      resources: const [
        Resource(branch: ResourceBranch.honey, tier: 3),
        Resource(branch: ResourceBranch.wax, tier: 3),
      ],
      coins: 60,
    ),
  ];
}
