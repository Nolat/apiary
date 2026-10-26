// 📦 Package imports:
import 'package:drift/drift.dart';
import 'package:talker_flutter/talker_flutter.dart';

// 🌎 Project imports:
import 'package:apiary/data/local/app_database.dart';
import 'package:apiary/domain/bees/family.dart';
import 'package:apiary/domain/board/board.dart';
import 'package:apiary/domain/board/board_item.dart';
import 'package:apiary/domain/board/board_position.dart';
import 'package:apiary/domain/board/board_repository.dart';

/// Keeps the board in the local SQLite database, one row per item.
class DriftBoardRepository implements BoardRepository {
  DriftBoardRepository(this._database, this._talker);

  final AppDatabase _database;
  final Talker _talker;

  static const _queen = 'queen';
  static const _larva = 'larva';
  static const _bee = 'bee';

  @override
  Future<Board?> load() async {
    final rows = await _database.select(_database.boardCells).get();
    final items = <BoardPosition, BoardItem>{};
    for (final row in rows) {
      final position = BoardPosition(column: row.column, row: row.row);
      final item = _itemOf(row);
      // A row the current code cannot read is dropped, not fatal: the player
      // keeps the rest of the board.
      if (item == null || !const Board().contains(position)) {
        _talker.warning(
          'Ignoring unreadable board cell ${row.column},${row.row} '
          '(${row.kind}, ${row.family}, ${row.level})',
        );
        continue;
      }
      items[position] = item;
    }
    return items.isEmpty ? null : Board(items: items);
  }

  @override
  Future<void> save(Board board) => _database.transaction(() async {
    await _database.delete(_database.boardCells).go();
    await _database.batch(
      (batch) => batch.insertAll(
        _database.boardCells,
        [
          for (final MapEntry(key: position, value: item)
              in board.items.entries)
            _rowOf(position, item),
        ],
      ),
    );
  });

  static BoardCellsCompanion _rowOf(BoardPosition position, BoardItem item) {
    final (kind, family) = switch (item) {
      Queen(:final family) => (_queen, family),
      Larva(:final family) => (_larva, family),
      Bee(:final family) => (_bee, family),
    };
    return BoardCellsCompanion.insert(
      column: position.column,
      row: position.row,
      kind: kind,
      family: family.name,
      level: Value(item.level ?? 1),
    );
  }

  static BoardItem? _itemOf(BoardCell row) {
    final family = Family.values.asNameMap()[row.family];
    if (family == null) {
      return null;
    }
    return switch (row.kind) {
      _queen => BoardItem.queen(family: family),
      _larva => BoardItem.larva(family: family),
      _bee when row.level >= 1 && row.level <= family.maxLevel => BoardItem.bee(
        family: family,
        level: row.level,
      ),
      _ => null,
    };
  }
}
