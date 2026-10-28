// 📦 Package imports:
import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:apiary/domain/bees/family.dart';
import 'package:apiary/domain/board/board.dart';
import 'package:apiary/domain/board/board_item.dart';
import 'package:apiary/domain/board/board_repository.dart';
import 'package:apiary/domain/energy/energy.dart';
import 'package:apiary/presentation/game/apiary_game.dart';

import '../../helpers/board_tap.dart';
import '../../helpers/energy_container.dart';
import '../../helpers/fake_trusted_clock.dart';
import '../../helpers/game_text.dart';
import '../../helpers/hive_boards.dart';
import '../../helpers/pixel_grid.dart';

class _MemoryRepository implements BoardRepository {
  _MemoryRepository(this.saved);

  Board? saved;

  @override
  Future<Board?> load() async => saved;

  @override
  Future<void> save(Board board) async => saved = board;
}

/// Every pixel of the board scene sits on the same grid, whatever the screen
/// shows: the sprites are drawn at ×1 on whole game pixels, so the game's
/// scale is the only thing that sets the size of a pixel.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadGameText);

  final start = DateTime.utc(2026, 10, 27, 8);

  // Lets every effect (bounces, pops, fades) run out.
  Future<void> settle(ApiaryGame game) async {
    await game.ready();
    game
      ..update(0)
      ..update(5)
      ..update(0);
  }

  group('The board scene', () {
    testWithGame<ApiaryGame>(
      'sits on whole pixels at launch',
      ApiaryGame.new,
      (game) async {
        await settle(game);

        expect(offPixelGrid(game), isEmpty);
      },
    );

    testWithGame<ApiaryGame>(
      'sits on whole pixels with the energy counting down',
      () {
        final now = start.add(const Duration(seconds: 25));
        return ApiaryGame(
          container: energyContainer(
            clock: FakeTrustedClock(time: now)..serverTime = now,
            saved: Energy(value: 42, countedFrom: start),
          ),
        );
      },
      (game) async {
        await settle(game);

        expect(offPixelGrid(game), isEmpty);
      },
    );

    testWithGame<ApiaryGame>(
      'sits on whole pixels with energy above 100',
      () => ApiaryGame(
        container: energyContainer(saved: const Energy(value: 1234)),
      ),
      (game) async {
        await settle(game);

        expect(offPixelGrid(game), isEmpty);
      },
    );

    testWithGame<ApiaryGame>(
      'sits on whole pixels with an item selected, a hive housing a bee and '
      'resources made',
      () => ApiaryGame(
        boardRepository: _MemoryRepository(
          boardWithBeeInHive(const Bee(family: Family.honeybee)),
        ),
      ),
      (game) async {
        final board = await boardOf(game);

        tapCell(game, board, Board.startingHivePosition);
        tapCell(game, board, Board.startingHivePosition);
        tapCell(game, board, Board.startingHivePosition);
        await settle(game);

        expect(offPixelGrid(game), isEmpty);
      },
    );

    testWithGame<ApiaryGame>(
      'sits on whole pixels with the banners up (board full, energy missing)',
      () => ApiaryGame(
        container: energyContainer(saved: const Energy(value: 0)),
      ),
      (game) async {
        final board = await boardOf(game);

        tapCell(game, board, Board.startingQueenPosition);
        tapCell(game, board, Board.startingQueenPosition);
        await game.ready();
        game.update(0.3);

        expect(offPixelGrid(game), isEmpty);
      },
    );
  });

  group('offPixelGrid', () {
    testWithGame<ApiaryGame>(
      'reports a component on a half pixel',
      ApiaryGame.new,
      (game) async {
        await settle(game);
        await game.world.add(
          PositionComponent(position: Vector2(10.5, 3), size: Vector2.all(8)),
        );
        await game.ready();

        expect(offPixelGrid(game), hasLength(1));
      },
    );

    testWithGame<ApiaryGame>(
      'reports a 9-slice that is not drawn with the pixel paint',
      ApiaryGame.new,
      (game) async {
        await settle(game);
        final image = await game.images.load('ui/bordered_panel.png');
        await game.world.add(
          NineTileBoxComponent(
            nineTileBox: NineTileBox(Sprite(image), tileSize: 3),
            size: Vector2.all(8),
          ),
        );
        await game.ready();

        expect(offPixelGrid(game), contains(contains('anti-aliased')));
      },
    );
  });
}
