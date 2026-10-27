// 🎯 Dart imports:
import 'dart:math';

// 📦 Package imports:
import 'package:drift/drift.dart';
import 'package:talker_flutter/talker_flutter.dart';

// 🌎 Project imports:
import 'package:apiary/data/local/app_database.dart';
import 'package:apiary/domain/bees/bee_lifespan.dart';
import 'package:apiary/domain/bees/family.dart';
import 'package:apiary/domain/board/board.dart';
import 'package:apiary/domain/board/board_item.dart';
import 'package:apiary/domain/board/board_position.dart';
import 'package:apiary/domain/board/board_repository.dart';
import 'package:apiary/domain/resources/resource_branch.dart';

/// Keeps the board in the local SQLite database, one row per item.
class DriftBoardRepository implements BoardRepository {
  DriftBoardRepository(this._database, this._talker);

  final AppDatabase _database;
  final Talker _talker;

  static const _queen = 'queen';
  static const _larva = 'larva';
  static const _bee = 'bee';
  static const _hive = 'hive';
  static const _housedHive = 'housed_hive';
  static const _resource = 'resource';

  // A hive belongs to no family, but the column is not nullable: stored
  // as-is rather than through a migration. An empty hive (`hive`) stores no
  // family; one that holds a bee (`housed_hive`) stores the bee's family and
  // level.
  static const _noFamily = '';

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
    // The name of the family, or of the resource branch, that goes with the
    // kind; empty for an empty hive.
    final (kind, name) = switch (item) {
      Queen(:final family) => (_queen, family.name),
      Larva(:final family) => (_larva, family.name),
      Bee(:final family) => (_bee, family.name),
      Hive(bee: null) => (_hive, _noFamily),
      Hive(:final bee?) => (_housedHive, bee.family.name),
      Resource(:final branch) => (_resource, branch.name),
    };
    return BoardCellsCompanion.insert(
      column: position.column,
      row: position.row,
      kind: kind,
      family: name,
      level: Value(switch (item) {
        Hive(:final bee?) => bee.level,
        _ => item.level ?? 1,
      }),
      remainingLife: Value(switch (item) {
        Hive(bee: _?, :final remainingLife) => remainingLife,
        _ => 1,
      }),
    );
  }

  static BoardItem? _itemOf(BoardCell row) {
    if (row.kind == _resource) {
      final branch = ResourceBranch.values.asNameMap()[row.family];
      return branch == null || row.level < 1 || row.level > branch.maxTier
          ? null
          : BoardItem.resource(branch: branch, tier: row.level);
    }
    final family = Family.values.asNameMap()[row.family];
    // A hive is never lost: one whose bee cannot be read comes back empty.
    if (row.kind == _hive || (row.kind == _housedHive && family == null)) {
      return const BoardItem.hive();
    }
    if (family == null) {
      return null;
    }
    return switch (row.kind) {
      _queen => BoardItem.queen(family: family),
      _larva => BoardItem.larva(family: family),
      _bee when _levelFits(row, family) => BoardItem.bee(
        family: family,
        level: row.level,
      ),
      _housedHive when _levelFits(row, family) && row.remainingLife >= 1 =>
        BoardItem.hive(
          bee: Bee(family: family, level: row.level),
          // Never more than the species has today: a lifespan may have been
          // cut since the save.
          remainingLife: min(row.remainingLife, BeeLifespan.of(family)),
        ),
      _housedHive => const BoardItem.hive(),
      _ => null,
    };
  }

  static bool _levelFits(BoardCell row, Family family) =>
      row.level >= 1 && row.level <= family.maxLevel;
}
