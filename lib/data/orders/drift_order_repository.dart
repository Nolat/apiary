// 📦 Package imports:
import 'package:drift/drift.dart';
import 'package:talker_flutter/talker_flutter.dart';

// 🌎 Project imports:
import 'package:apiary/data/local/app_database.dart';
import 'package:apiary/domain/board/board_item.dart';
import 'package:apiary/domain/orders/customer.dart';
import 'package:apiary/domain/orders/order.dart';
import 'package:apiary/domain/orders/order_repository.dart';
import 'package:apiary/domain/resources/resource_branch.dart';

/// Keeps the orders of the day in the local SQLite database: a row per order
/// and a row per resource it asks for.
class DriftOrderRepository implements OrderRepository {
  DriftOrderRepository(this._database, this._talker);

  final AppDatabase _database;
  final Talker _talker;

  @override
  Future<List<Order>?> load() async {
    final rows = await (_database.select(
      _database.dayOrders,
    )..orderBy([(order) => OrderingTerm.asc(order.position)])).get();
    final resourceRows =
        await (_database.select(_database.dayOrderResources)..orderBy([
              (resource) => OrderingTerm.asc(resource.orderPosition),
              (resource) => OrderingTerm.asc(resource.slot),
            ]))
            .get();
    final orders = <Order>[];
    for (final row in rows) {
      final order = _orderOf(
        row,
        resourceRows.where(
          (resource) => resource.orderPosition == row.position,
        ),
      );
      // An order the current code cannot read is dropped, not fatal: the
      // player keeps the others.
      if (order == null) {
        _talker.warning(
          'Ignoring unreadable order ${row.position} '
          '(${row.customer}, ${row.coins} coins)',
        );
        continue;
      }
      orders.add(order);
    }
    return orders.isEmpty ? null : orders;
  }

  @override
  Future<void> save(List<Order> orders) => _database.transaction(() async {
    await _database.delete(_database.dayOrderResources).go();
    await _database.delete(_database.dayOrders).go();
    await _database.batch((batch) {
      for (final (position, order) in orders.indexed) {
        batch
          ..insert(
            _database.dayOrders,
            DayOrdersCompanion.insert(
              position: Value(position),
              customer: order.customer.name,
              coins: order.coins,
            ),
          )
          ..insertAll(_database.dayOrderResources, [
            for (final (slot, resource) in order.resources.indexed)
              DayOrderResourcesCompanion.insert(
                orderPosition: position,
                slot: slot,
                branch: resource.branch.name,
                tier: resource.tier,
                quantity: Value(order.quantityOf(resource)),
              ),
          ]);
      }
    });
  });

  static Order? _orderOf(
    DayOrder row,
    Iterable<DayOrderResource> resourceRows,
  ) {
    final customer = Customer.values.asNameMap()[row.customer];
    final resources = [
      for (final resource in resourceRows) _resourceOf(resource),
    ];
    final quantities = {
      for (final row in resourceRows)
        if (_resourceOf(row) case final resource? when row.quantity > 1)
          resource: row.quantity,
    };
    // One unreadable resource makes the whole order unreadable: a card
    // missing one would ask for less than it pays for.
    if (customer == null ||
        row.coins < 0 ||
        resources.isEmpty ||
        resources.length > 2 ||
        resources.contains(null) ||
        resourceRows.any((resource) => resource.quantity < 1)) {
      return null;
    }
    final known = resources.whereType<Resource>().toList();
    return known.toSet().length == known.length
        ? Order(
            customer: customer,
            resources: known,
            coins: row.coins,
            quantities: quantities,
          )
        : null;
  }

  static Resource? _resourceOf(DayOrderResource row) {
    final branch = ResourceBranch.values.asNameMap()[row.branch];
    return branch == null || row.tier < 1 || row.tier > branch.maxTier
        ? null
        : Resource(branch: branch, tier: row.tier);
  }
}
