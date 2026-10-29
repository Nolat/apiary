// 🎯 Dart imports:
import 'dart:ui' show Rect;

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
import 'package:apiary/presentation/components/board/item_info_component.dart';
import 'package:apiary/presentation/game/apiary_game.dart';
import 'package:apiary/presentation/game/screen_layout.dart';
import '../../../helpers/board_tap.dart';
import '../../../helpers/game_text.dart';

void main() {
  // The sprites load from the asset bundle, which needs the binding.
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadGameText);

  group('Selecting an item', () {
    const queen = Board.startingQueenPosition;
    const emptyCell = BoardPosition(column: 0, row: 0);
    const otherEmptyCell = BoardPosition(column: 6, row: 8);

    SpriteComponent frameOf(BoardComponent board) =>
        board.children.whereType<SpriteComponent>().singleWhere(
          (sprite) =>
              sprite.sprite!.image ==
              board.game.images.fromCache(BoardComponent.selectionImage),
        );

    ItemInfoComponent infoOf(ApiaryGame game) =>
        game.world.descendants().whereType<ItemInfoComponent>().single;

    testWithGame<ApiaryGame>(
      'starts with nothing selected',
      ApiaryGame.new,
      (game) async {
        final board = await boardOf(game);

        expect(board.selection.value, isNull);
        expect(board.selectedItem, isNull);
        expect(frameOf(board).opacity, 0);
        // Hiding the frame must not hide the grid.
        final cells = board.children.whereType<SpriteComponent>().where(
          (sprite) => sprite != frameOf(board),
        );
        for (final cell in cells) {
          expect(cell.opacity, 1);
        }
      },
    );

    testWithGame<ApiaryGame>(
      'selects a tapped item and frames its cell',
      ApiaryGame.new,
      (game) async {
        final board = await boardOf(game);

        tapCell(game, board, queen);

        expect(board.selection.value, queen);
        expect(board.selectedItem, board.board.itemAt(queen));
        final frame = frameOf(board);
        expect(frame.opacity, 1);
        expect(frame.size, Vector2.all(20));
        expect(
          frame.position,
          Vector2(queen.column * 20.0, queen.row * 20.0),
        );
      },
    );

    testWithGame<ApiaryGame>(
      'keeps the selection when the same item is tapped again',
      ApiaryGame.new,
      (game) async {
        final board = await boardOf(game);

        tapCell(game, board, queen);
        tapCell(game, board, queen);

        expect(board.selection.value, queen);
        expect(frameOf(board).opacity, 1);
      },
    );

    testWithGame<ApiaryGame>(
      'keeps the selection when an empty cell is tapped',
      ApiaryGame.new,
      (game) async {
        final board = await boardOf(game);

        tapCell(game, board, emptyCell);
        expect(board.selection.value, isNull);

        tapCell(game, board, queen);
        tapCell(game, board, emptyCell);
        tapCell(game, board, otherEmptyCell);
        expect(board.selection.value, queen);
      },
    );

    testWithGame<ApiaryGame>(
      'does not change the board',
      ApiaryGame.new,
      (game) async {
        final board = await boardOf(game);
        final before = board.board;

        tapCell(game, board, queen);

        expect(board.board, before);
      },
    );

    testWithGame<ApiaryGame>(
      'shows the item in the info panel, and the invitation otherwise',
      ApiaryGame.new,
      (game) async {
        final board = await boardOf(game);
        final info = infoOf(game);
        expect(
          '${info.titleText} ${info.tipText}'.trim(),
          'Touchez un objet pour consulter ses détails ici.',
        );
        final invitation = info.titleText;

        tapCell(game, board, queen);

        expect(info.titleText, isNot(invitation));
        expect(info.titleText, 'Reine mellifère · Niv. 1');
        expect(info.tipText, 'TOUCHEZ pour produire des abeilles');
      },
    );

    testWithGame<ApiaryGame>(
      'wraps the invitation on the narrowest screen',
      ApiaryGame.new,
      (game) async {
        await game.ready();
        game.onGameResize(ApiaryGame.minimumSize);

        final info = infoOf(game);
        expect(info.titleText, isNotEmpty);
        expect(info.tipText, isNotEmpty);
        expect(
          '${info.titleText} ${info.tipText}',
          'Touchez un objet pour consulter ses détails ici.',
        );
      },
    );

    test(
      'fits the texts of every item on the four lines of the narrowest panel',
      () {
        // The narrowest screen's bottom bar, less its padding on both sides.
        final panelWidth =
            ApiaryGame.minimumSize.x - 2 * ScreenLayout.bottomBarPadding;

        expect(
          ItemInfoComponent.lineCount(null, panelWidth),
          lessThanOrEqualTo(4),
        );
        for (final family in Family.values) {
          expect(
            ItemInfoComponent.lineCount(
              BoardItem.queen(family: family),
              panelWidth,
            ),
            lessThanOrEqualTo(4),
            reason: 'the $family queen',
          );
          for (final level in [1, family.maxLevel]) {
            expect(
              ItemInfoComponent.lineCount(
                BoardItem.bee(family: family, level: level),
                panelWidth,
              ),
              lessThanOrEqualTo(4),
              reason: 'the $family bee of level $level',
            );
          }
        }
      },
    );

    testWithGame<ApiaryGame>(
      'titles a bee with the name of its species, one per level',
      ApiaryGame.new,
      (game) async {
        await game.ready();
        final info = infoOf(game);
        final titles = <String>{};

        for (final family in Family.values) {
          for (var level = 1; level <= family.maxLevel; level++) {
            info.show(BoardItem.bee(family: family, level: level));
            titles.add(info.titleText);
            expect(info.titleText, isNot(contains('species.')));
          }
        }

        expect(titles, hasLength(Family.honeybee.maxLevel));
        info.show(const BoardItem.bee(family: Family.honeybee));
        expect(info.titleText, 'Abeille commune · Niv. 1');
      },
    );

    testWithGame<ApiaryGame>(
      'tells a bee of the last level from one that can still merge',
      ApiaryGame.new,
      (game) async {
        await game.ready();
        final info = infoOf(game)
          ..show(const BoardItem.bee(family: Family.honeybee));
        final mergeable = info.tipText;

        info.show(
          BoardItem.bee(
            family: Family.honeybee,
            level: Family.honeybee.maxLevel,
          ),
        );

        expect(info.tipText, isNotEmpty);
        expect(info.tipText, isNot(mergeable));
      },
    );

    testWithGame<ApiaryGame>(
      'wraps again once the panel is placed after it loaded',
      ApiaryGame.new,
      (game) async {
        await game.ready();
        // Loaded with no size yet, as when it loads before the first resize.
        final info = ItemInfoComponent();
        await game.world.add(info);
        await game.ready();
        expect(info.tipText, isEmpty);

        info.place(const Rect.fromLTWH(0, 0, 136, 22));

        expect(info.tipText, isNotEmpty);
        expect(
          '${info.titleText} ${info.tipText}',
          'Touchez un objet pour consulter ses détails ici.',
        );
      },
    );

    testWithGame<ApiaryGame>(
      'releases the selection notifier when the board leaves the game',
      ApiaryGame.new,
      (game) async {
        final board = await boardOf(game);

        board.removeFromParent();
        await game.ready();

        expect(() => board.selection.addListener(() {}), throwsFlutterError);
      },
    );

    testWithGame<ApiaryGame>(
      'places the info panel on the bottom bar',
      ApiaryGame.new,
      (game) async {
        await game.ready();
        game.onGameResize(Vector2(393, 852));

        final info = infoOf(game);
        final band = game.layout.bottomBar;
        // Inside the padding that keeps it off the board and the screen's
        // rounded corners.
        expect(info.position, Vector2(band.left + 2, band.top + 2));
        expect(info.size, Vector2(band.width - 4, 38));
        expect(info.position.y, greaterThan(game.layout.board.bottom));
      },
    );
  });

  group('ItemInfoComponent.wrap', () {
    // Every character is 4 px wide.
    double measure(String text) => text.length * 4;

    test('keeps a text that fits on one line', () {
      expect(ItemInfoComponent.wrap('un deux', 40, measure), ['un deux']);
    });

    test('breaks at spaces, never inside a word', () {
      expect(
        ItemInfoComponent.wrap('un deux trois quatre', 40, measure),
        ['un deux', 'trois', 'quatre'],
      );
      expect(
        ItemInfoComponent.wrap('un deux trois', 48, measure),
        ['un deux', 'trois'],
      );
    });

    test('leaves a word wider than the line alone on its own line', () {
      expect(
        ItemInfoComponent.wrap('un extraordinaire de', 20, measure),
        ['un', 'extraordinaire', 'de'],
      );
    });

    test('has no line for an empty text', () {
      expect(ItemInfoComponent.wrap('', 40, measure), isEmpty);
    });
  });
}
