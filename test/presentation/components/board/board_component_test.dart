// 🎯 Dart imports:
import 'dart:ui';

// 📦 Package imports:
import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:apiary/presentation/components/board/board_component.dart';
import 'package:apiary/presentation/game/apiary_game.dart';

void main() {
  // The board's sprites load from the asset bundle, which needs the binding.
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BoardComponent', () {
    Future<List<SpriteComponent>> cellsOf(ApiaryGame game) async {
      await game.ready();
      return game.world
          .descendants()
          .whereType<BoardComponent>()
          .single
          .children
          .whereType<SpriteComponent>()
          .toList();
    }

    testWithGame<ApiaryGame>(
      'is a 224×288 grid of 7×9 cells of 32×32',
      ApiaryGame.new,
      (game) async {
        final cells = await cellsOf(game);
        final board = game.world
            .descendants()
            .whereType<BoardComponent>()
            .single;

        expect(board.size, Vector2(224, 288));
        expect(cells, hasLength(63));
        for (final cell in cells) {
          expect(cell.size, Vector2.all(32));
        }
        final columns = cells.map((cell) => cell.position.x).toSet();
        final rows = cells.map((cell) => cell.position.y).toSet();
        expect(columns, {for (var i = 0; i < 7; i++) i * 32.0});
        expect(rows, {for (var i = 0; i < 9; i++) i * 32.0});
        expect(
          cells.map((cell) => (cell.position.x, cell.position.y)).toSet(),
          hasLength(63),
        );
      },
    );

    testWithGame<ApiaryGame>(
      'alternates light and dark cells in a checkerboard',
      ApiaryGame.new,
      (game) async {
        final cells = {
          for (final cell in await cellsOf(game))
            (cell.position.x ~/ 32, cell.position.y ~/ 32): cell,
        };

        for (final MapEntry(key: (column, row), value: cell) in cells.entries) {
          final right = cells[(column + 1, row)];
          final below = cells[(column, row + 1)];
          if (right != null) {
            expect(cell.sprite!.image, isNot(same(right.sprite!.image)));
          }
          if (below != null) {
            expect(cell.sprite!.image, isNot(same(below.sprite!.image)));
          }
        }
        expect(
          cells.values.map((cell) => cell.sprite!.image).toSet(),
          hasLength(2),
        );
      },
    );

    testWithGame<ApiaryGame>(
      'draws its sprites nearest-neighbor',
      ApiaryGame.new,
      (game) async {
        for (final cell in await cellsOf(game)) {
          expect(cell.paint.filterQuality, FilterQuality.none);
        }
      },
    );
  });
}
