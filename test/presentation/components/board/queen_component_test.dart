// 🎯 Dart imports:
import 'dart:ui';

// 📦 Package imports:
import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:apiary/domain/bees/family.dart';
import 'package:apiary/domain/board/board.dart';
import 'package:apiary/presentation/components/board/board_component.dart';
import 'package:apiary/presentation/components/board/family_sprites.dart';
import 'package:apiary/presentation/components/board/queen_component.dart';
import 'package:apiary/presentation/game/apiary_game.dart';

void main() {
  // The sprites load from the asset bundle, which needs the binding.
  TestWidgetsFlutterBinding.ensureInitialized();

  group('QueenComponent', () {
    Future<BoardComponent> boardOf(ApiaryGame game) async {
      await game.ready();
      return game.world.descendants().whereType<BoardComponent>().single;
    }

    testWithGame<ApiaryGame>(
      'is the only item on a first game board',
      ApiaryGame.new,
      (game) async {
        final board = await boardOf(game);

        final queens = board.children.whereType<QueenComponent>();
        expect(queens, hasLength(1));
        expect(queens.single.family, Family.common);
      },
    );

    testWithGame<ApiaryGame>(
      'sits on its starting cell, centered with a 2 px margin',
      ApiaryGame.new,
      (game) async {
        final queen = (await boardOf(game)).children
            .whereType<QueenComponent>()
            .single;

        const cell = Board.startingQueenPosition;
        expect(queen.size, Vector2.all(16));
        expect(
          queen.position,
          Vector2(cell.column * 20.0 + 2, cell.row * 20.0 + 2),
        );
      },
    );

    testWithGame<ApiaryGame>(
      'stacks the outline, the family bee and the crown, bottom to top',
      ApiaryGame.new,
      (game) async {
        final queen = (await boardOf(game)).children
            .whereType<QueenComponent>()
            .single;

        final layers = queen.children.whereType<SpriteComponent>().toList();
        expect(layers, hasLength(3));
        for (final layer in layers) {
          expect(layer.position, Vector2.zero());
          expect(layer.size, Vector2.all(16));
          expect(layer.sprite!.image.width, 16);
          expect(layer.sprite!.image.height, 16);
          expect(layer.paint.filterQuality, FilterQuality.none);
        }
        for (final (index, path) in [
          Family.common.beeBorderImage,
          Family.common.beeImage,
          QueenComponent.crownImage,
        ].indexed) {
          expect(
            layers[index].sprite!.image,
            same(game.images.fromCache(path)),
          );
        }
      },
    );

    testWithGame<ApiaryGame>(
      'draws above the cells, under the selection frame',
      ApiaryGame.new,
      (game) async {
        final board = await boardOf(game);

        final children = board.children.toList();
        final queenIndex = children.indexWhere(
          (child) => child is QueenComponent,
        );
        expect(queenIndex, children.length - 2);
        expect(
          (children.last as SpriteComponent).sprite!.image,
          same(game.images.fromCache(BoardComponent.selectionImage)),
        );
      },
    );
  });
}
