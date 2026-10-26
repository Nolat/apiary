// 📦 Package imports:
import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:apiary/domain/bees/family.dart';
import 'package:apiary/domain/board/board.dart';
import 'package:apiary/domain/board/board_item.dart';
import 'package:apiary/domain/board/board_position.dart';
import 'package:apiary/presentation/components/board/board_component.dart';
import 'package:apiary/presentation/components/board/family_sprites.dart';
import 'package:apiary/presentation/components/board/item_info_component.dart';
import 'package:apiary/presentation/components/board/larva_component.dart';
import 'package:apiary/presentation/components/board/queen_component.dart';
import 'package:apiary/presentation/game/apiary_game.dart';

import '../../../helpers/board_tap.dart';
import '../../../helpers/game_text.dart';

void main() {
  // The sprites load from the asset bundle, which needs the binding.
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadGameText);

  group('Tapping a queen', () {
    const queen = Board.startingQueenPosition;
    // The nearest free cell of the starting board: above the queen.
    const firstLarva = BoardPosition(column: 3, row: 3);

    Iterable<LarvaComponent> larvaeOf(BoardComponent board) =>
        board.children.whereType<LarvaComponent>();

    // Taps the queen until the board holds [count] items.
    Future<void> fillBoard(ApiaryGame game, BoardComponent board) async {
      tapCell(game, board, queen);
      while (board.board.items.length < Board.columns * Board.rows) {
        tapCell(game, board, queen);
      }
      await game.ready();
    }

    testWithGame<ApiaryGame>(
      'only selects her the first time, without creating a larva',
      ApiaryGame.new,
      (game) async {
        final board = await boardOf(game);

        tapCell(game, board, queen);
        await game.ready();

        expect(board.selection.value, queen);
        expect(board.board, Board.initial());
        expect(larvaeOf(board), isEmpty);
      },
    );

    testWithGame<ApiaryGame>(
      'creates a larva on the nearest free cell when already selected',
      ApiaryGame.new,
      (game) async {
        final board = await boardOf(game);

        tapCell(game, board, queen);
        tapCell(game, board, queen);
        await game.ready();

        expect(
          board.board.itemAt(firstLarva),
          const BoardItem.larva(family: Family.common),
        );
        final larva = larvaeOf(board).single;
        expect(larva.family, Family.common);
        expect(larva.size, Vector2.all(16));
        expect(
          larva.position,
          Vector2(firstLarva.column * 20.0 + 2, firstLarva.row * 20.0 + 2),
        );
      },
    );

    testWithGame<ApiaryGame>(
      'stacks the outline under the family larva',
      ApiaryGame.new,
      (game) async {
        final board = await boardOf(game);

        tapCell(game, board, queen);
        tapCell(game, board, queen);
        await game.ready();

        final layers = larvaeOf(board).single.children
            .whereType<SpriteComponent>()
            .toList();
        expect(layers, hasLength(2));
        for (final (index, path) in [
          Family.common.larvaBorderImage,
          Family.common.larvaImage,
        ].indexed) {
          expect(layers[index].sprite!.image.width, 16);
          expect(layers[index].sprite!.image.height, 16);
          expect(
            layers[index].sprite!.image,
            same(game.images.fromCache(path)),
          );
        }
      },
    );

    testWithGame<ApiaryGame>(
      'creates one larva per tap, keeping the queen in place and selected',
      ApiaryGame.new,
      (game) async {
        final board = await boardOf(game);

        tapCell(game, board, queen);
        for (var taps = 1; taps <= 10; taps++) {
          tapCell(game, board, queen);
          await game.ready();

          expect(larvaeOf(board), hasLength(taps));
          expect(board.board.items, hasLength(1 + taps));
          expect(board.selection.value, queen);
          expect(
            board.board.itemAt(queen),
            const BoardItem.queen(family: Family.common),
          );
        }
        expect(board.children.whereType<QueenComponent>(), hasLength(1));
      },
    );

    testWithGame<ApiaryGame>(
      'keeps the selection frame above the larvae',
      ApiaryGame.new,
      (game) async {
        final board = await boardOf(game);

        tapCell(game, board, queen);
        tapCell(game, board, queen);
        await game.ready();

        final frame = board.children.whereType<SpriteComponent>().singleWhere(
          (sprite) =>
              sprite.sprite!.image ==
              game.images.fromCache(BoardComponent.selectionImage),
        );
        expect(frame.priority, greaterThan(larvaeOf(board).single.priority));
      },
    );

    testWithGame<ApiaryGame>(
      'creates the same larvae in the same order on every game',
      ApiaryGame.new,
      (game) async {
        final board = await boardOf(game);

        tapCell(game, board, queen);
        for (var taps = 0; taps < 3; taps++) {
          tapCell(game, board, queen);
        }
        await game.ready();

        expect(board.board.items.keys.toSet(), {
          queen,
          const BoardPosition(column: 3, row: 3),
          const BoardPosition(column: 4, row: 3),
          const BoardPosition(column: 4, row: 4),
        });
      },
    );

    testWithGame<ApiaryGame>(
      'creates no larva on a full board, and shakes her instead',
      ApiaryGame.new,
      (game) async {
        final board = await boardOf(game);
        await fillBoard(game, board);
        final full = board.board;
        final queenComponent = board.children
            .whereType<QueenComponent>()
            .single;
        final home = BoardComponent.itemPosition(queen);
        expect(queenComponent.position, home);

        tapCell(game, board, queen);
        await game.ready();
        game.update(BoardComponent.shakeStep);

        expect(board.board, full);
        expect(larvaeOf(board), hasLength(Board.columns * Board.rows - 1));
        expect(queenComponent.position.x, greaterThan(home.x));
        expect(queenComponent.position.y, home.y);

        // The shake ends exactly where the queen started.
        for (var i = 0; i < 10; i++) {
          game.update(BoardComponent.shakeStep);
        }
        expect(queenComponent.position, home);
        expect(board.selection.value, queen);
      },
    );

    testWithGame<ApiaryGame>(
      'does not let the queen drift when tapped again mid-shake',
      ApiaryGame.new,
      (game) async {
        final board = await boardOf(game);
        await fillBoard(game, board);
        final queenComponent = board.children
            .whereType<QueenComponent>()
            .single;

        for (var i = 0; i < 4; i++) {
          tapCell(game, board, queen);
          await game.ready();
          game.update(BoardComponent.shakeStep * 1.5);
        }
        for (var i = 0; i < 10; i++) {
          game.update(BoardComponent.shakeStep);
        }

        expect(queenComponent.position, BoardComponent.itemPosition(queen));
      },
    );

    testWithGame<ApiaryGame>(
      'selects a larva like any item, without creating another',
      ApiaryGame.new,
      (game) async {
        final board = await boardOf(game);
        tapCell(game, board, queen);
        tapCell(game, board, queen);
        await game.ready();

        tapCell(game, board, firstLarva);
        tapCell(game, board, firstLarva);
        await game.ready();

        expect(board.selection.value, firstLarva);
        expect(board.board.items, hasLength(2));
        final info = game.world
            .descendants()
            .whereType<ItemInfoComponent>()
            .single;
        expect(info.titleText, 'Larve Commune');
        expect(info.tipText, 'Fusionnez deux larves identiques');
      },
    );
  });
}
