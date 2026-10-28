// 🌎 Project imports:
import 'package:apiary/domain/orders/order.dart';

/// Where the orders of the day in progress are kept between two launches.
abstract interface class OrderRepository {
  /// The saved orders, in the order they are shown, or `null` when none were
  /// saved yet (a first game).
  Future<List<Order>?> load();

  /// Replaces the saved orders by [orders], all or nothing.
  Future<void> save(List<Order> orders);
}
