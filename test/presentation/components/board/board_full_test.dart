// 📦 Package imports:
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:apiary/domain/board/board.dart';
import 'package:apiary/presentation/components/board/board_component.dart';
import 'package:apiary/presentation/components/board/board_full_banner_component.dart';
import 'package:apiary/presentation/game/apiary_game.dart';

import '../../../helpers/board_tap.dart';
import '../../../helpers/game_text.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadGameText);

  group('Tapping a queen on a full board', () {
    const queen = Board.startingQueenPosition;

    BoardFullBannerComponent bannerOf(BoardComponent board) =>
        board.children.whereType<BoardFullBannerComponent>().single;

    // Taps the queen until the board is full.
    Future<void> fillBoard(ApiaryGame game, BoardComponent board) async {
      tapCell(game, board, queen);
      while (board.board.items.length < Board.columns * Board.rows) {
        tapCell(game, board, queen);
      }
      await game.ready();
    }

    testWithGame<ApiaryGame>(
      'shows no banner while there is room',
      ApiaryGame.new,
      (game) async {
        final board = await boardOf(game);

        tapCell(game, board, queen);
        tapCell(game, board, queen);
        await game.ready();

        expect(bannerOf(board).isShown, isFalse);
      },
    );

    testWithGame<ApiaryGame>(
      'pops the banner in on the top row, then fades it out',
      ApiaryGame.new,
      (game) async {
        final board = await boardOf(game);
        await fillBoard(game, board);
        expect(bannerOf(board).isShown, isFalse, reason: 'full, not tapped');

        tapCell(game, board, queen);
        await game.ready();
        final banner = bannerOf(board);
        expect(banner.isShown, isTrue);
        expect(banner.position.x, board.size.x / 2);
        expect(banner.scale.x, lessThan(1));

        game.update(BoardFullBannerComponent.popDuration);
        expect(banner.scale.x, closeTo(1, 0.001));
        expect(banner.opacity, 1);

        game.update(BoardFullBannerComponent.holdDuration);
        expect(banner.isShown, isTrue);

        game.update(BoardFullBannerComponent.fadeDuration + 0.05);
        expect(banner.isShown, isFalse);
      },
    );

    testWithGame<ApiaryGame>(
      'starts the banner over when tapped again while it is up',
      ApiaryGame.new,
      (game) async {
        final board = await boardOf(game);
        await fillBoard(game, board);
        tapCell(game, board, queen);
        await game.ready();
        final banner = bannerOf(board);
        game.update(BoardFullBannerComponent.popDuration + 1.5);

        tapCell(game, board, queen);
        await game.ready();
        game.update(0.01);

        expect(banner.opacity, 1);
        expect(banner.scale.x, lessThan(1));
        game.update(BoardFullBannerComponent.popDuration + 1.5);
        expect(banner.isShown, isTrue);
      },
    );
  });
}
