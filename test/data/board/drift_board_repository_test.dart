// 📦 Package imports:
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talker_flutter/talker_flutter.dart';

// 🌎 Project imports:
import 'package:apiary/data/board/drift_board_repository.dart';
import 'package:apiary/data/local/app_database.dart';
import 'package:apiary/domain/bees/family.dart';
import 'package:apiary/domain/board/board.dart';
import 'package:apiary/domain/board/board_item.dart';
import 'package:apiary/domain/board/board_position.dart';
import 'package:apiary/domain/resources/resource_branch.dart';

void main() {
  late AppDatabase database;
  late DriftBoardRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = DriftBoardRepository(database, Talker());
  });

  tearDown(() => database.close());

  test('finds nothing before the first save', () async {
    expect(await repository.load(), isNull);
  });

  test('gives back the board it saved, every item on its own cell', () async {
    final board = Board(
      items: {
        Board.startingQueenPosition: const BoardItem.queen(
          family: Family.honeybee,
        ),
        const BoardPosition(column: 0, row: 0): const BoardItem.larva(
          family: Family.honeybee,
        ),
        const BoardPosition(column: 6, row: 8): const BoardItem.bee(
          family: Family.honeybee,
          level: 3,
        ),
        Board.startingHivePosition: const BoardItem.hive(),
      },
    );

    await repository.save(board);

    expect(await repository.load(), board);
  });

  test('keeps the bee a hive holds', () async {
    final board = Board(
      items: {
        Board.startingHivePosition: const BoardItem.hive(
          bee: Bee(family: Family.honeybee, level: 4),
        ),
        const BoardPosition(column: 0, row: 0): const BoardItem.hive(),
      },
    );

    await repository.save(board);

    expect(await repository.load(), board);
  });

  test('keeps the resources, with their branch and tier', () async {
    final board = Board(
      items: {
        const BoardPosition(column: 0, row: 0): const BoardItem.resource(
          branch: ResourceBranch.wax,
        ),
        const BoardPosition(column: 1, row: 0): const BoardItem.resource(
          branch: ResourceBranch.wax,
          tier: 4,
        ),
        const BoardPosition(column: 2, row: 0): const BoardItem.resource(
          branch: ResourceBranch.honey,
          tier: 3,
        ),
      },
    );

    await repository.save(board);

    expect(await repository.load(), board);
  });

  test('ignores a resource of an unknown branch or an unknown tier', () async {
    await database.customStatement(
      'INSERT INTO board_cells ("column", row, kind, family, level) VALUES '
      "(0, 0, 'resource', 'unknown', 1), (1, 0, 'resource', 'wax', 0), "
      "(2, 0, 'resource', 'wax', 5), (3, 0, 'resource', 'honey', 9)",
    );

    expect((await repository.load())?.items ?? const {}, isEmpty);
  });

  test('keeps the life a hive bee has left', () async {
    final board = Board(
      items: {
        Board.startingHivePosition: const BoardItem.hive(
          bee: Bee(family: Family.honeybee, level: 2),
          remainingLife: 2,
        ),
      },
    );

    await repository.save(board);

    expect(await repository.load(), board);
  });

  test('caps the life left at the lifespan of the species', () async {
    await database.customStatement(
      'INSERT INTO board_cells ("column", row, kind, family, level, '
      "remaining_life) VALUES (0, 0, 'housed_hive', 'honeybee', 1, 99)",
    );

    expect(
      (await repository.load())!.itemAt(const BoardPosition(column: 0, row: 0)),
      const BoardItem.hive(bee: Bee(family: Family.honeybee)),
    );
  });

  test('empties a hive whose life left cannot be read', () async {
    await database.customStatement(
      'INSERT INTO board_cells ("column", row, kind, family, level, '
      "remaining_life) VALUES (0, 0, 'housed_hive', 'honeybee', 1, 0)",
    );

    expect(
      (await repository.load())!.itemAt(const BoardPosition(column: 0, row: 0)),
      const BoardItem.hive(),
    );
  });

  test('replaces the previous board on each save', () async {
    await repository.save(Board.initial());
    const moved = BoardPosition(column: 1, row: 1);
    final board = Board(
      items: {moved: const BoardItem.queen(family: Family.honeybee)},
    );

    await repository.save(board);

    expect(await repository.load(), board);
  });

  test('ignores a row it cannot read and keeps the others', () async {
    await repository.save(Board.initial());
    await database.customStatement(
      'INSERT INTO board_cells ("column", row, kind, family, level) VALUES '
      "(0, 0, 'bee', 'honeybee', 99), (1, 0, 'cocoon', 'honeybee', 1), "
      "(2, 0, 'larva', 'unknown', 1), (50, 0, 'larva', 'honeybee', 1), "
      "(3, 0, 'housed_hive', 'honeybee', 99), "
      "(4, 0, 'housed_hive', 'unknown', 1)",
    );

    // A hive whose bee cannot be read is kept, empty.
    expect(
      await repository.load(),
      Board.initial().copyWith(
        items: {
          ...Board.initial().items,
          const BoardPosition(column: 3, row: 0): const BoardItem.hive(),
          const BoardPosition(column: 4, row: 0): const BoardItem.hive(),
        },
      ),
    );
  });
}
