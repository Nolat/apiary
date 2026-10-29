// 📦 Package imports:
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:apiary/domain/board/board_item.dart';
import 'package:apiary/domain/orders/customer.dart';
import 'package:apiary/domain/orders/first_day_orders.dart';
import 'package:apiary/domain/orders/order.dart';
import 'package:apiary/domain/orders/order_repository.dart';
import 'package:apiary/domain/resources/resource_branch.dart';
import 'package:apiary/presentation/components/orders/orders_component.dart';
import 'package:apiary/presentation/game/apiary_game.dart';
import '../../helpers/game_text.dart';

class _MemoryOrders implements OrderRepository {
  _MemoryOrders([this.saved]);

  List<Order>? saved;
  int saves = 0;

  @override
  Future<List<Order>?> load() async => saved;

  @override
  Future<void> save(List<Order> orders) async {
    saved = orders;
    saves++;
  }
}

class _BrokenOrders extends _MemoryOrders {
  @override
  Future<List<Order>?> load() => Future.error(StateError('database locked'));
}

Future<List<Order>> _shownOrders(ApiaryGame game) async {
  await game.ready();
  return game.world
      .descendants()
      .whereType<OrdersComponent>()
      .single
      .cards
      .map((card) => card.order)
      .toList();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadGameText);

  group('The orders of the day', () {
    testWithGame<ApiaryGame>(
      'are the first day orders on a first game, saved from then on',
      () => ApiaryGame(orderRepository: _MemoryOrders()),
      (game) async {
        expect(await _shownOrders(game), FirstDayOrders.orders);
        expect(
          (game.orderRepository! as _MemoryOrders).saved,
          FirstDayOrders.orders,
        );
      },
    );

    final saved = [
      Order(
        customer: Customer.candleMaker,
        resources: const [Resource(branch: ResourceBranch.wax, tier: 4)],
        coins: 99,
      ),
    ];

    testWithGame<ApiaryGame>(
      'come back the same when the game is reopened',
      () => ApiaryGame(orderRepository: _MemoryOrders(saved)),
      (game) async {
        expect(await _shownOrders(game), saved);
        expect((game.orderRepository! as _MemoryOrders).saves, 0);
      },
    );

    testWithGame<ApiaryGame>(
      'are the first day orders when loading fails, and nothing is overwritten',
      () => ApiaryGame(orderRepository: _BrokenOrders()),
      (game) async {
        expect(await _shownOrders(game), FirstDayOrders.orders);
        expect((game.orderRepository! as _MemoryOrders).saves, 0);
      },
    );

    testWithGame<ApiaryGame>(
      'are the first day orders without a repository',
      ApiaryGame.new,
      (game) async {
        expect(await _shownOrders(game), FirstDayOrders.orders);
      },
    );

    testWithGame<ApiaryGame>(
      'are the first day orders again after a restart from scratch',
      () => ApiaryGame(orderRepository: _MemoryOrders(saved)),
      (game) async {
        await game.ready();

        await game.restartFromScratch();

        expect(await _shownOrders(game), FirstDayOrders.orders);
      },
    );
  });
}
