// 📦 Package imports:
import 'package:glados/glados.dart';

// 🌎 Project imports:
import 'package:apiary/domain/bees/family.dart';
import 'package:apiary/domain/board/board.dart';
import 'package:apiary/domain/board/board_item.dart';
import 'package:apiary/domain/board/board_position.dart';
import 'package:apiary/domain/orders/customer.dart';
import 'package:apiary/domain/orders/order.dart';
import 'package:apiary/domain/orders/order_progress.dart';
import 'package:apiary/domain/resources/resource_branch.dart';

void main() {
  const wax = Resource(branch: ResourceBranch.wax);
  const waxTwo = Resource(branch: ResourceBranch.wax, tier: 2);
  const honey = Resource(branch: ResourceBranch.honey);

  BoardPosition cell(int column, int row) =>
      BoardPosition(column: column, row: row);

  Board boardOf(Map<BoardPosition, BoardItem> items) => Board(items: items);

  Order order(
    List<Resource> resources, {
    Map<Resource, int> quantities = const {},
  }) => Order(
    customer: Customer.baker,
    resources: resources,
    coins: 10,
    quantities: quantities,
  );

  group('OrderProgress', () {
    test('counts nothing on a board without the resources', () {
      final progress = OrderProgress.of(
        order([wax, honey]),
        Board.initial(),
      );

      expect(progress.resources.map((r) => r.have), [0, 0]);
      expect(progress.resources.map((r) => r.ready), [false, false]);
      expect(progress.ready, isFalse);
      expect(progress.marked, isEmpty);
    });

    test('counts a resource the board holds', () {
      final progress = OrderProgress.of(
        order([wax, honey]),
        boardOf({cell(2, 3): wax}),
      );

      expect(progress.resources.map((r) => r.ready), [true, false]);
      expect(progress.ready, isFalse);
      expect(progress.marked, {cell(2, 3)});
    });

    test('is ready once the board holds every resource', () {
      final progress = OrderProgress.of(
        order([wax, honey]),
        boardOf({cell(0, 0): honey, cell(5, 5): wax}),
      );

      expect(progress.ready, isTrue);
      expect(progress.marked, {cell(0, 0), cell(5, 5)});
    });

    test('does not count a resource of another tier', () {
      final progress = OrderProgress.of(
        order([wax]),
        boardOf({cell(1, 1): waxTwo}),
      );

      expect(progress.resources.single.have, 0);
      expect(progress.marked, isEmpty);
    });

    test('does not count what is not a resource', () {
      final progress = OrderProgress.of(
        order([wax]),
        boardOf({
          cell(1, 1): const BoardItem.hive(),
          cell(2, 1): const BoardItem.larva(family: Family.honeybee),
        }),
      );

      expect(progress.resources.single.have, 0);
    });

    test('counts up to the quantity asked for', () {
      final board = boardOf({cell(0, 0): wax, cell(1, 0): wax});
      final partial = OrderProgress.of(
        order([wax], quantities: {wax: 3}),
        board,
      );

      final progress = partial.resources.single;
      expect(progress.needed, 3);
      expect(progress.have, 2);
      expect(progress.ready, isFalse);
      expect(partial.marked, {cell(0, 0), cell(1, 0)});
    });

    test('marks only as many cells as asked for, in reading order', () {
      final board = boardOf({
        cell(4, 2): wax,
        cell(1, 2): wax,
        cell(6, 0): wax,
        cell(0, 5): wax,
      });

      final progress = OrderProgress.of(
        order([wax], quantities: {wax: 2}),
        board,
      );

      expect(progress.resources.single.ready, isTrue);
      expect(progress.marked, {cell(6, 0), cell(1, 2)});
    });

    test('lets two orders count the same resource', () {
      final board = boardOf({cell(3, 3): wax});

      final first = OrderProgress.of(order([wax]), board);
      final second = OrderProgress.of(order([wax, honey]), board);

      expect(first.ready, isTrue);
      expect(second.resources.first.ready, isTrue);
      expect(first.marked, second.marked);
    });

    test('shows a different item for each order when there are enough', () {
      final board = boardOf({
        cell(1, 1): wax,
        cell(4, 5): wax,
        cell(0, 8): wax,
      });

      final progress = OrderProgress.allOf(
        [
          order([wax]),
          order([wax, honey]),
          order([wax]),
        ],
        board,
      );

      expect(progress.map((p) => p.marked), [
        {cell(1, 1)},
        {cell(4, 5)},
        {cell(0, 8)},
      ]);
    });

    test('shows the same item again when there are not enough', () {
      final board = boardOf({cell(1, 1): wax, cell(4, 5): wax});

      final progress = OrderProgress.allOf(
        [
          order([wax]),
          order([wax]),
          order([wax]),
        ],
        board,
      );

      expect(progress.map((p) => p.marked), [
        {cell(1, 1)},
        {cell(4, 5)},
        {cell(1, 1)},
      ]);
      expect(progress.every((p) => p.ready), isTrue);
    });

    Glados(any.intInRange(0, 30)).test(
      'never counts more than asked for',
      (held) {
        final board = boardOf({
          for (var i = 0; i < held; i++) cell(i % Board.columns, i ~/ 7): wax,
        });

        final progress = OrderProgress.of(
          order([wax], quantities: {wax: 4}),
          board,
        );

        final resource = progress.resources.single;
        expect(resource.have, held < 4 ? held : 4);
        expect(resource.ready, held >= 4);
        expect(progress.marked, hasLength(resource.have));
      },
    );
  });
}
