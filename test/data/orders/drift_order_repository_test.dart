// 📦 Package imports:
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talker_flutter/talker_flutter.dart';

// 🌎 Project imports:
import 'package:apiary/data/local/app_database.dart';
import 'package:apiary/data/orders/drift_order_repository.dart';
import 'package:apiary/domain/board/board_item.dart';
import 'package:apiary/domain/orders/customer.dart';
import 'package:apiary/domain/orders/first_day_orders.dart';
import 'package:apiary/domain/orders/order.dart';
import 'package:apiary/domain/resources/resource_branch.dart';

void main() {
  late AppDatabase database;
  late DriftOrderRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = DriftOrderRepository(database, Talker());
  });

  tearDown(() => database.close());

  const wax = Resource(branch: ResourceBranch.wax);
  const honey = Resource(branch: ResourceBranch.honey, tier: 3);

  test('finds nothing before the first save', () async {
    expect(await repository.load(), isNull);
  });

  test('gives back the orders it saved, in the same order', () async {
    final orders = [
      Order(
        customer: Customer.herbalist,
        resources: const [honey, wax],
        coins: 35,
      ),
      Order(customer: Customer.baker, resources: const [wax], coins: 10),
    ];

    await repository.save(orders);

    expect(await repository.load(), orders);
  });

  test('gives back the first day orders', () async {
    await repository.save(FirstDayOrders.orders);

    expect(await repository.load(), FirstDayOrders.orders);
  });

  test('replaces the orders of an earlier save', () async {
    await repository.save(FirstDayOrders.orders);
    final later = [
      Order(
        customer: Customer.candleMaker,
        resources: const [wax],
        coins: 5,
      ),
    ];

    await repository.save(later);

    expect(await repository.load(), later);
    expect(
      await database.select(database.dayOrderResources).get(),
      hasLength(1),
    );
  });

  // Three orders, the first two of two resources each.
  final saved = [
    Order(customer: Customer.baker, resources: const [wax, honey], coins: 10),
    Order(
      customer: Customer.candleMaker,
      resources: const [wax, honey],
      coins: 20,
    ),
    Order(customer: Customer.herbalist, resources: const [wax], coins: 30),
  ];

  test('drops an order that cannot be read and keeps the others', () async {
    await repository.save(saved);
    // The first loses its customer, the second its resources.
    await database.customStatement(
      "UPDATE day_orders SET customer = 'unknown' WHERE position = 0",
    );
    await database.customStatement(
      'DELETE FROM day_order_resources WHERE order_position = 1',
    );

    expect(await repository.load(), [saved[2]]);
  });

  test('drops an order with a resource it cannot read, not just it', () async {
    await repository.save(saved);
    await database.customStatement(
      "UPDATE day_order_resources SET branch = 'unknown' "
      'WHERE order_position = 0 AND slot = 1',
    );

    expect(await repository.load(), saved.sublist(1));
  });

  test('drops an order asking for a tier its branch does not have', () async {
    await repository.save(saved);
    await database.customStatement(
      'UPDATE day_order_resources SET tier = 9 '
      'WHERE order_position = 2 AND slot = 0',
    );

    expect(await repository.load(), saved.sublist(0, 2));
  });

  test('drops an order asking for the same resource twice', () async {
    await repository.save(saved);
    await database.customStatement(
      "UPDATE day_order_resources SET branch = 'wax', tier = 1 "
      'WHERE order_position = 0 AND slot = 1',
    );

    expect(await repository.load(), saved.sublist(1));
  });

  test('drops an order asking for more than two resources', () async {
    await repository.save(saved);
    await database.customStatement(
      "INSERT INTO day_order_resources VALUES (2, 1, 'honey', 1, 1), "
      "(2, 2, 'honey', 2, 1)",
    );

    expect(await repository.load(), saved.sublist(0, 2));
  });

  test('gives back what an order asks for more than once', () async {
    final orders = [
      Order(
        customer: Customer.baker,
        resources: const [wax, honey],
        coins: 10,
        quantities: {honey: 3},
      ),
    ];

    await repository.save(orders);

    final [loaded] = (await repository.load())!;
    expect(loaded, orders.single);
    expect(loaded.quantityOf(wax), 1);
    expect(loaded.quantityOf(honey), 3);
  });

  test('drops an order asking for none of a resource', () async {
    await repository.save(saved);
    await database.customStatement(
      'UPDATE day_order_resources SET quantity = 0 '
      'WHERE order_position = 0 AND slot = 1',
    );

    expect(await repository.load(), saved.sublist(1));
  });
}
