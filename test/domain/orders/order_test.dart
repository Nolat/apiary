// 📦 Package imports:
import 'package:glados/glados.dart';

// 🌎 Project imports:
import 'package:apiary/domain/board/board_item.dart';
import 'package:apiary/domain/orders/customer.dart';
import 'package:apiary/domain/orders/first_day_orders.dart';
import 'package:apiary/domain/orders/order.dart';
import 'package:apiary/domain/resources/resource_branch.dart';

void main() {
  const wax = Resource(branch: ResourceBranch.wax);
  const honey = Resource(branch: ResourceBranch.honey);
  const waxTwo = Resource(branch: ResourceBranch.wax, tier: 2);

  Order order(List<Resource> resources, {int coins = 10}) =>
      Order(customer: Customer.baker, resources: resources, coins: coins);

  group('Order', () {
    test('asks for one or two resources', () {
      expect(order(const [wax]).resources, const [wax]);
      expect(order(const [wax, honey]).resources, const [wax, honey]);
    });

    test('asks for something', () {
      expect(() => order(const []), throwsA(isA<AssertionError>()));
    });

    test('asks for two resources at most', () {
      expect(
        () => order(const [wax, honey, waxTwo]),
        throwsA(isA<AssertionError>()),
      );
    });

    test('never asks for the same resource twice', () {
      expect(() => order(const [wax, wax]), throwsA(isA<AssertionError>()));
    });

    test('asks for the same branch at two tiers', () {
      expect(order(const [wax, waxTwo]).resources, hasLength(2));
    });

    test('cannot pay a negative amount', () {
      expect(
        () => order(const [wax], coins: -1),
        throwsA(isA<AssertionError>()),
      );
    });

    test('asks for one of each resource unless told otherwise', () {
      final asked = order(const [wax, honey]);

      expect(asked.quantityOf(wax), 1);
      expect(asked.quantityOf(honey), 1);
    });

    test('asks for the quantity it is given', () {
      final asked = Order(
        customer: Customer.baker,
        resources: const [wax, honey],
        coins: 10,
        quantities: {honey: 3},
      );

      expect(asked.quantityOf(wax), 1);
      expect(asked.quantityOf(honey), 3);
    });

    test('asks for at least one of each resource', () {
      expect(
        () => Order(
          customer: Customer.baker,
          resources: const [wax],
          coins: 10,
          quantities: {wax: 0},
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('gives a quantity only to a resource it asks for', () {
      expect(
        () => Order(
          customer: Customer.baker,
          resources: const [wax],
          coins: 10,
          quantities: {honey: 2},
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('FirstDayOrders', () {
    test('has orders to show', () {
      expect(FirstDayOrders.orders, isNotEmpty);
    });

    test('asks only for resources that exist', () {
      for (final order in FirstDayOrders.orders) {
        for (final resource in order.resources) {
          expect(resource.tier, greaterThanOrEqualTo(1));
          expect(resource.tier, lessThanOrEqualTo(resource.branch.maxTier));
        }
      }
    });
  });
}
