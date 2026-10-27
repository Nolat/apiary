// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $BoardCellsTable extends BoardCells
    with TableInfo<$BoardCellsTable, BoardCell> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BoardCellsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _columnMeta = const VerificationMeta('column');
  @override
  late final GeneratedColumn<int> column = GeneratedColumn<int>(
    'column',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rowMeta = const VerificationMeta('row');
  @override
  late final GeneratedColumn<int> row = GeneratedColumn<int>(
    'row',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _familyMeta = const VerificationMeta('family');
  @override
  late final GeneratedColumn<String> family = GeneratedColumn<String>(
    'family',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [column, row, kind, family, level];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'board_cells';
  @override
  VerificationContext validateIntegrity(
    Insertable<BoardCell> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('column')) {
      context.handle(
        _columnMeta,
        column.isAcceptableOrUnknown(data['column']!, _columnMeta),
      );
    } else if (isInserting) {
      context.missing(_columnMeta);
    }
    if (data.containsKey('row')) {
      context.handle(
        _rowMeta,
        row.isAcceptableOrUnknown(data['row']!, _rowMeta),
      );
    } else if (isInserting) {
      context.missing(_rowMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('family')) {
      context.handle(
        _familyMeta,
        family.isAcceptableOrUnknown(data['family']!, _familyMeta),
      );
    } else if (isInserting) {
      context.missing(_familyMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {column, row};
  @override
  BoardCell map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BoardCell(
      column: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}column'],
      )!,
      row: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}row'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      family: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level'],
      )!,
    );
  }

  @override
  $BoardCellsTable createAlias(String alias) {
    return $BoardCellsTable(attachedDatabase, alias);
  }
}

class BoardCell extends DataClass implements Insertable<BoardCell> {
  final int column;
  final int row;

  /// `queen`, `larva`, `bee` or `hive`.
  final String kind;

  /// A `Family` name; empty for a hive, which has none.
  final String family;

  /// The level of a bee; 1 for the other items, which have none to speak of.
  final int level;
  const BoardCell({
    required this.column,
    required this.row,
    required this.kind,
    required this.family,
    required this.level,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['column'] = Variable<int>(column);
    map['row'] = Variable<int>(row);
    map['kind'] = Variable<String>(kind);
    map['family'] = Variable<String>(family);
    map['level'] = Variable<int>(level);
    return map;
  }

  BoardCellsCompanion toCompanion(bool nullToAbsent) {
    return BoardCellsCompanion(
      column: Value(column),
      row: Value(row),
      kind: Value(kind),
      family: Value(family),
      level: Value(level),
    );
  }

  factory BoardCell.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BoardCell(
      column: serializer.fromJson<int>(json['column']),
      row: serializer.fromJson<int>(json['row']),
      kind: serializer.fromJson<String>(json['kind']),
      family: serializer.fromJson<String>(json['family']),
      level: serializer.fromJson<int>(json['level']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'column': serializer.toJson<int>(column),
      'row': serializer.toJson<int>(row),
      'kind': serializer.toJson<String>(kind),
      'family': serializer.toJson<String>(family),
      'level': serializer.toJson<int>(level),
    };
  }

  BoardCell copyWith({
    int? column,
    int? row,
    String? kind,
    String? family,
    int? level,
  }) => BoardCell(
    column: column ?? this.column,
    row: row ?? this.row,
    kind: kind ?? this.kind,
    family: family ?? this.family,
    level: level ?? this.level,
  );
  BoardCell copyWithCompanion(BoardCellsCompanion data) {
    return BoardCell(
      column: data.column.present ? data.column.value : this.column,
      row: data.row.present ? data.row.value : this.row,
      kind: data.kind.present ? data.kind.value : this.kind,
      family: data.family.present ? data.family.value : this.family,
      level: data.level.present ? data.level.value : this.level,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BoardCell(')
          ..write('column: $column, ')
          ..write('row: $row, ')
          ..write('kind: $kind, ')
          ..write('family: $family, ')
          ..write('level: $level')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(column, row, kind, family, level);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BoardCell &&
          other.column == this.column &&
          other.row == this.row &&
          other.kind == this.kind &&
          other.family == this.family &&
          other.level == this.level);
}

class BoardCellsCompanion extends UpdateCompanion<BoardCell> {
  final Value<int> column;
  final Value<int> row;
  final Value<String> kind;
  final Value<String> family;
  final Value<int> level;
  final Value<int> rowid;
  const BoardCellsCompanion({
    this.column = const Value.absent(),
    this.row = const Value.absent(),
    this.kind = const Value.absent(),
    this.family = const Value.absent(),
    this.level = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BoardCellsCompanion.insert({
    required int column,
    required int row,
    required String kind,
    required String family,
    this.level = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : column = Value(column),
       row = Value(row),
       kind = Value(kind),
       family = Value(family);
  static Insertable<BoardCell> custom({
    Expression<int>? column,
    Expression<int>? row,
    Expression<String>? kind,
    Expression<String>? family,
    Expression<int>? level,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (column != null) 'column': column,
      if (row != null) 'row': row,
      if (kind != null) 'kind': kind,
      if (family != null) 'family': family,
      if (level != null) 'level': level,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BoardCellsCompanion copyWith({
    Value<int>? column,
    Value<int>? row,
    Value<String>? kind,
    Value<String>? family,
    Value<int>? level,
    Value<int>? rowid,
  }) {
    return BoardCellsCompanion(
      column: column ?? this.column,
      row: row ?? this.row,
      kind: kind ?? this.kind,
      family: family ?? this.family,
      level: level ?? this.level,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (column.present) {
      map['column'] = Variable<int>(column.value);
    }
    if (row.present) {
      map['row'] = Variable<int>(row.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (family.present) {
      map['family'] = Variable<String>(family.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BoardCellsCompanion(')
          ..write('column: $column, ')
          ..write('row: $row, ')
          ..write('kind: $kind, ')
          ..write('family: $family, ')
          ..write('level: $level, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BoardCellsTable boardCells = $BoardCellsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [boardCells];
}

typedef $$BoardCellsTableCreateCompanionBuilder = BoardCellsCompanion Function({
  required int column,
  required int row,
  required String kind,
  required String family,
  Value<int> level,
  Value<int> rowid,
});
typedef $$BoardCellsTableUpdateCompanionBuilder = BoardCellsCompanion Function({
  Value<int> column,
  Value<int> row,
  Value<String> kind,
  Value<String> family,
  Value<int> level,
  Value<int> rowid,
});

class $$BoardCellsTableFilterComposer
    extends Composer<_$AppDatabase, $BoardCellsTable> {
  $$BoardCellsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get column => $composableBuilder(
    column: $table.column,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get row => $composableBuilder(
    column: $table.row,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get family => $composableBuilder(
    column: $table.family,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BoardCellsTableOrderingComposer
    extends Composer<_$AppDatabase, $BoardCellsTable> {
  $$BoardCellsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get column => $composableBuilder(
    column: $table.column,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get row => $composableBuilder(
    column: $table.row,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get family => $composableBuilder(
    column: $table.family,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BoardCellsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BoardCellsTable> {
  $$BoardCellsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get column =>
      $composableBuilder(column: $table.column, builder: (column) => column);

  GeneratedColumn<int> get row =>
      $composableBuilder(column: $table.row, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get family =>
      $composableBuilder(column: $table.family, builder: (column) => column);

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);
}

class $$BoardCellsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BoardCellsTable,
          BoardCell,
          $$BoardCellsTableFilterComposer,
          $$BoardCellsTableOrderingComposer,
          $$BoardCellsTableAnnotationComposer,
          $$BoardCellsTableCreateCompanionBuilder,
          $$BoardCellsTableUpdateCompanionBuilder,
          (
            BoardCell,
            BaseReferences<_$AppDatabase, $BoardCellsTable, BoardCell>,
          ),
          BoardCell,
          PrefetchHooks Function()
        > {
  $$BoardCellsTableTableManager(_$AppDatabase db, $BoardCellsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BoardCellsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BoardCellsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BoardCellsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> column = const Value.absent(),
                Value<int> row = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> family = const Value.absent(),
                Value<int> level = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BoardCellsCompanion(
                column: column,
                row: row,
                kind: kind,
                family: family,
                level: level,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int column,
                required int row,
                required String kind,
                required String family,
                Value<int> level = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BoardCellsCompanion.insert(
                column: column,
                row: row,
                kind: kind,
                family: family,
                level: level,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BoardCellsTable, BoardCell>(table),
                  BaseReferences<_$AppDatabase, $BoardCellsTable, BoardCell>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BoardCellsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BoardCellsTable,
      BoardCell,
      $$BoardCellsTableFilterComposer,
      $$BoardCellsTableOrderingComposer,
      $$BoardCellsTableAnnotationComposer,
      $$BoardCellsTableCreateCompanionBuilder,
      $$BoardCellsTableUpdateCompanionBuilder,
      (BoardCell, BaseReferences<_$AppDatabase, $BoardCellsTable, BoardCell>),
      BoardCell,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BoardCellsTableTableManager get boardCells =>
      $$BoardCellsTableTableManager(_db, _db.boardCells);
}
