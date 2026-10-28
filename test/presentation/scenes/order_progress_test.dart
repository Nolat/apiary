// 📦 Package imports:
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:apiary/domain/board/board.dart';
import 'package:apiary/domain/board/board_item.dart';
import 'package:apiary/domain/board/board_position.dart';
import 'package:apiary/domain/board/board_repository.dart';
import 'package:apiary/domain/orders/customer.dart';
import 'package:apiary/domain/orders/order.dart';
import 'package:apiary/domain/orders/order_repository.dart';
import 'package:apiary/domain/resources/resource_branch.dart';
import 'package:apiary/presentation/components/board/board_component.dart';
import 'package:apiary/presentation/components/orders/order_card_component.dart';
import 'package:apiary/presentation/game/apiary_game.dart';

import '../../helpers/board_tap.dart';
import '../../helpers/game_golden.dart';
import '../../helpers/game_text.dart';
import '../../helpers/orders_drag.dart';

class _MemoryBoard implements BoardRepository {
  _MemoryBoard(this.saved);

  Board? saved;

  @override
  Future<Board?> load() async => saved;

  @override
  Future<void> save(Board board) async => saved = board;
}

class _MemoryOrders implements OrderRepository {
  _MemoryOrders(this.saved);

  List<Order>? saved;

  @override
  Future<List<Order>?> load() async => saved;

  @override
  Future<void> save(List<Order> orders) async => saved = orders;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadGameText);

  const wax = Resource(branch: ResourceBranch.wax);
  const waxTwo = Resource(branch: ResourceBranch.wax, tier: 2);
  const honey = Resource(branch: ResourceBranch.honey);
  const firstWax = BoardPosition(column: 1, row: 1);
  const secondWax = BoardPosition(column: 2, row: 1);
  const honeyCell = BoardPosition(column: 5, row: 5);

  // The first order asks for what the two wax make once merged, the second
  // for two wax and one honey.
  final orders = [
    Order(customer: Customer.baker, resources: const [waxTwo], coins: 10),
    Order(
      customer: Customer.herbalist,
      resources: const [wax, honey],
      coins: 20,
      quantities: {wax: 2},
    ),
  ];

  ApiaryGame gameWith(
    Map<BoardPosition, BoardItem> items, {
    List<Order>? asked,
  }) => ApiaryGame(
    boardRepository: _MemoryBoard(Board(items: items)),
    orderRepository: _MemoryOrders(asked ?? orders),
  );

  Map<BoardPosition, BoardItem> boardItems() => {
    firstWax: wax,
    secondWax: wax,
    honeyCell: honey,
  };

  List<OrderCardComponent> cardsOf(ApiaryGame game) => ordersOf(game).cards;

  Future<void> merge(ApiaryGame game, BoardComponent board) async {
    CellDrag(game, board)
      ..start(firstWax)
      ..moveTo(secondWax.column, secondWax.row)
      ..end();
    game
      ..update(0)
      ..update(1)
      ..update(0);
    await game.ready();
  }

  group('The orders, against the board', () {
    testWithGame<ApiaryGame>(
      'turns a cell green when the board holds what it asks for',
      () => gameWith(boardItems()),
      (game) async {
        await game.ready();

        final [baker, herbalist] = cardsOf(game);
        expect(baker.readyCells, [false]);
        expect(herbalist.readyCells, [true, true]);
      },
    );

    testWithGame<ApiaryGame>(
      'reads n/N for a resource asked for more than once, capped at N',
      () => gameWith({
        ...boardItems(),
        const BoardPosition(column: 0, row: 0): wax,
      }),
      (game) async {
        await game.ready();

        final [baker, herbalist] = cardsOf(game);
        expect(baker.counts, [null]);
        expect(herbalist.counts, ['2/2', null]);
      },
    );

    testWithGame<ApiaryGame>(
      'counts a resource short of the quantity without turning green',
      () => gameWith({firstWax: wax, honeyCell: honey}),
      (game) async {
        await game.ready();

        final [_, herbalist] = cardsOf(game);
        expect(herbalist.counts, ['1/2', null]);
        expect(herbalist.readyCells, [false, true]);
      },
    );

    testWithGame<ApiaryGame>(
      'shows nothing ready on a board without what is asked',
      () => gameWith({honeyCell: waxTwo}, asked: [orders[1]]),
      (game) async {
        final board = await boardOf(game);

        final [herbalist] = cardsOf(game);
        expect(herbalist.readyCells, [false, false]);
        expect(herbalist.counts, ['0/2', null]);
        expect(board.marked, isEmpty);
      },
    );

    testWithGame<ApiaryGame>(
      'marks on the board each resource an order counts',
      () => gameWith(boardItems()),
      (game) async {
        final board = await boardOf(game);

        expect(board.marked, {firstWax, secondWax, honeyCell});
      },
    );

    testWithGame<ApiaryGame>(
      'does not mark a resource of another tier',
      () => gameWith({firstWax: waxTwo}, asked: [orders[1]]),
      (game) async {
        final board = await boardOf(game);

        expect(board.marked, isEmpty);
      },
    );

    testWithGame<ApiaryGame>(
      'lets two orders count the same resource',
      () => gameWith(
        {firstWax: wax},
        asked: [
          Order(customer: Customer.baker, resources: const [wax], coins: 5),
          Order(customer: Customer.herbalist, resources: const [wax], coins: 6),
        ],
      ),
      (game) async {
        final board = await boardOf(game);

        expect(
          [for (final card in cardsOf(game)) card.readyCells],
          [
            [true],
            [true],
          ],
        );
        expect(board.marked, {firstWax});
      },
    );

    testWithGame<ApiaryGame>(
      'marks one item per order asking for the same resource',
      () => gameWith(
        {firstWax: wax, secondWax: wax, honeyCell: wax},
        asked: [
          Order(customer: Customer.baker, resources: const [wax], coins: 5),
          Order(customer: Customer.herbalist, resources: const [wax], coins: 6),
        ],
      ),
      (game) async {
        final board = await boardOf(game);

        expect(board.marked, {firstWax, secondWax});
      },
    );

    testWithGame<ApiaryGame>(
      'follows a merge on the board',
      () => gameWith(boardItems()),
      (game) async {
        final board = await boardOf(game);

        await merge(game, board);

        final [baker, herbalist] = cardsOf(game);
        expect(baker.readyCells, [true]);
        expect(herbalist.readyCells, [false, true]);
        expect(herbalist.counts, ['0/2', null]);
        expect(board.marked, {secondWax, honeyCell});
      },
    );

    testWithGame<ApiaryGame>(
      'follows a move on the board',
      () => gameWith(boardItems()),
      (game) async {
        final board = await boardOf(game);
        const free = BoardPosition(column: 6, row: 8);

        CellDrag(game, board)
          ..start(honeyCell)
          ..moveTo(free.column, free.row)
          ..end();
        await game.ready();

        expect(board.marked, {firstWax, secondWax, free});
      },
    );

    testWithGame<ApiaryGame>(
      'follows a removal and its undo',
      () => gameWith(boardItems()),
      (game) async {
        final board = await boardOf(game);

        board
          ..selection.value = honeyCell
          ..removeSelected();

        final [_, herbalist] = cardsOf(game);
        expect(herbalist.readyCells, [true, false]);
        expect(board.marked, {firstWax, secondWax});

        await board.undoRemoval();

        expect(herbalist.readyCells, [true, true]);
        expect(board.marked, {firstWax, secondWax, honeyCell});
      },
    );

    testWithGame<ApiaryGame>(
      'follows any other change of the board',
      () => gameWith(
        {honeyCell: honey},
        asked: [
          Order(customer: Customer.baker, resources: const [wax], coins: 5),
        ],
      ),
      (game) async {
        final board = await boardOf(game);
        expect(cardsOf(game).single.readyCells, [false]);

        board.board = board.board.copyWith(
          items: {...board.board.items, firstWax: wax},
        );

        expect(cardsOf(game).single.readyCells, [true]);
        expect(board.marked, {firstWax});
      },
    );
  });

  group('Orders goldens', () {
    testGameGolden(
      'renders the cards and the board with the resources they count',
      goldenFile: 'goldens/board_scene_orders_progress.png',
      newGame: () => gameWith({
        ...boardItems(),
        const BoardPosition(column: 0, row: 0): wax,
        const BoardPosition(column: 3, row: 3): waxTwo,
      }),
    );
  });
}
