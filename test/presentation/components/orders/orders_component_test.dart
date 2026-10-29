// 📦 Package imports:
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:apiary/domain/board/board.dart';
import 'package:apiary/domain/board/board_item.dart';
import 'package:apiary/domain/orders/customer.dart';
import 'package:apiary/domain/orders/first_day_orders.dart';
import 'package:apiary/domain/orders/order.dart';
import 'package:apiary/domain/orders/order_repository.dart';
import 'package:apiary/domain/resources/resource_branch.dart';
import 'package:apiary/presentation/components/board/resource_component.dart';
import 'package:apiary/presentation/components/orders/order_card_component.dart';
import 'package:apiary/presentation/components/orders/orders_component.dart';
import 'package:apiary/presentation/game/apiary_game.dart';
import '../../../helpers/board_tap.dart';
import '../../../helpers/game_text.dart';
import '../../../helpers/orders_drag.dart';

class _MemoryOrders implements OrderRepository {
  _MemoryOrders([this.saved]);

  List<Order>? saved;

  @override
  Future<List<Order>?> load() async => saved;

  @override
  Future<void> save(List<Order> orders) async => saved = orders;
}

// The cards of the strip, in the order they are shown.
List<OrderCardComponent> _cards(ApiaryGame game) => ordersOf(game).cards;

Offset _screenOf(ApiaryGame game, PositionComponent component, Vector2 at) {
  final screen = game.camera.localToGlobal(component.absolutePositionOf(at));
  return Offset(screen.x, screen.y);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadGameText);

  const wax = Resource(branch: ResourceBranch.wax);
  const honey3 = Resource(branch: ResourceBranch.honey, tier: 3);
  final small = [
    Order(
      customer: Customer.herbalist,
      resources: const [honey3, wax],
      coins: 35,
    ),
  ];

  group('The orders band', () {
    testWithGame<ApiaryGame>(
      'shows a card for each order of the day',
      ApiaryGame.new,
      (game) async {
        await game.ready();

        expect(_cards(game), hasLength(FirstDayOrders.orders.length));
        expect(
          _cards(game).map((card) => card.order),
          FirstDayOrders.orders,
        );
      },
    );

    testWithGame<ApiaryGame>(
      'shows who asks, what for and what it pays',
      () => ApiaryGame(orderRepository: _MemoryOrders(small)),
      (game) async {
        await game.ready();

        final [card] = _cards(game);
        expect(card.order.customer, Customer.herbalist);
        final resources = card.descendants().whereType<ResourceComponent>();
        expect(
          [for (final r in resources) Resource(branch: r.branch, tier: r.tier)],
          [honey3, wax],
        );
        expect(card.coinsText, '35');
      },
    );

    testWithGame<ApiaryGame>(
      'puts the cards side by side, in order, inside the orders band',
      ApiaryGame.new,
      (game) async {
        await game.ready();
        game.onGameResize(Vector2(140, 285));

        final cards = _cards(game);
        for (final (i, card) in cards.indexed.skip(1)) {
          final before = cards[i - 1];
          expect(card.position.y, 0);
          expect(
            card.position.x,
            before.position.x + before.size.x + OrdersComponent.gap,
          );
        }
        final band = game.layout.orders;
        final strip = ordersOf(game);
        expect(strip.position.y, band.top);
        expect(strip.size.y, band.height);
        expect(cards.first.size.y, band.height);
        // Aligned on the left of the band, under the energy gauge.
        expect(strip.position.x, band.left);
        expect(strip.size.x, band.width);
      },
    );

    testWithGame<ApiaryGame>(
      'scrolls sideways by dragging, up to the last card',
      ApiaryGame.new,
      (game) async {
        await game.ready();
        game.onGameResize(Vector2(140, 285));
        final strip = ordersOf(game);
        expect(strip.maxScroll, greaterThan(0));
        final first = _cards(game).first;

        dragOrders(game, -20);

        expect(strip.scroll, 20);
        expect(first.absoluteTopLeftPosition.x, strip.position.x - 20);

        dragOrders(game, -1000);
        expect(strip.scroll, strip.maxScroll);
        final last = _cards(game).last;
        expect(
          last.absoluteTopLeftPosition.x + last.size.x,
          closeTo(strip.position.x + strip.size.x, 1),
        );

        dragOrders(game, 1000);
        expect(strip.scroll, 0);
      },
    );

    testWithGame<ApiaryGame>(
      'scrolls whole pixels, even for a finger moving by small steps',
      ApiaryGame.new,
      (game) async {
        await game.ready();
        game.onGameResize(Vector2(140, 285));
        final strip = ordersOf(game);

        for (var i = 0; i < 10; i++) {
          dragOrders(game, -0.3);
        }

        expect(strip.scroll, 3);
        expect(strip.scroll, strip.scroll.roundToDouble());
      },
    );

    testWithGame<ApiaryGame>(
      'does not scroll when every card fits',
      () => ApiaryGame(orderRepository: _MemoryOrders(small)),
      (game) async {
        await game.ready();
        game.onGameResize(Vector2(600, 800));
        final strip = ordersOf(game);
        expect(strip.maxScroll, 0);

        dragOrders(game, -50);

        expect(strip.scroll, 0);
      },
    );

    testWithGame<ApiaryGame>(
      'leaves the board alone when it scrolls',
      ApiaryGame.new,
      (game) async {
        final board = await boardOf(game);
        game.onGameResize(Vector2(140, 285));
        board.selection.value = Board.startingQueenPosition;
        final before = board.board;

        dragOrders(game, -30);

        expect(board.board, before);
        expect(board.selection.value, Board.startingQueenPosition);
      },
    );

    testWithGame<ApiaryGame>(
      'does nothing when a card is tapped',
      ApiaryGame.new,
      (game) async {
        final board = await boardOf(game);
        game.onGameResize(Vector2(140, 285));
        board.selection.value = Board.startingQueenPosition;
        final before = board.board;
        final energy = game.energyValue;
        final card = _cards(game).first;
        final at = _screenOf(game, card, card.size / 2);

        (game.findByKey(const MultiTapDispatcherKey())! as MultiTapDispatcher)
          ..onTapDown(createTapDownEvents(game: game, globalPosition: at))
          ..onTapUp(createTapUpEvents(game: game, globalPosition: at));
        await game.ready();

        expect(board.board, before);
        expect(board.selection.value, Board.startingQueenPosition);
        expect(game.energyValue, energy);
        expect(ordersOf(game).scroll, 0);
      },
    );
  });
}
