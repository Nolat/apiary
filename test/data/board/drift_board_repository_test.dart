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
          family: Family.common,
        ),
        const BoardPosition(column: 0, row: 0): const BoardItem.larva(
          family: Family.common,
        ),
        const BoardPosition(column: 6, row: 8): const BoardItem.bee(
          family: Family.common,
          level: 3,
        ),
      },
    );

    await repository.save(board);

    expect(await repository.load(), board);
  });

  test('replaces the previous board on each save', () async {
    await repository.save(Board.initial());
    const moved = BoardPosition(column: 1, row: 1);
    final board = Board(
      items: {moved: const BoardItem.queen(family: Family.common)},
    );

    await repository.save(board);

    expect(await repository.load(), board);
  });

  test('ignores a row it cannot read and keeps the others', () async {
    await repository.save(Board.initial());
    await database.customStatement(
      'INSERT INTO board_cells ("column", row, kind, family, level) VALUES '
      "(0, 0, 'bee', 'common', 99), (1, 0, 'hive', 'common', 1), "
      "(2, 0, 'larva', 'unknown', 1), (50, 0, 'larva', 'common', 1)",
    );

    expect(await repository.load(), Board.initial());
  });
}
