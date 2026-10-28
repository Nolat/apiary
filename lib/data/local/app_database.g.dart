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
  static const VerificationMeta _remainingLifeMeta = const VerificationMeta(
    'remainingLife',
  );
  @override
  late final GeneratedColumn<int> remainingLife = GeneratedColumn<int>(
    'remaining_life',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    column,
    row,
    kind,
    family,
    level,
    remainingLife,
  ];
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
    if (data.containsKey('remaining_life')) {
      context.handle(
        _remainingLifeMeta,
        remainingLife.isAcceptableOrUnknown(
          data['remaining_life']!,
          _remainingLifeMeta,
        ),
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
      remainingLife: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remaining_life'],
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

  /// `queen`, `larva`, `bee`, `hive`, `housed_hive` or `resource`.
  final String kind;

  /// A `Family` name; empty for an empty hive, which has none. A hive that
  /// holds a bee has the bee's. A `ResourceBranch` name for a resource.
  final String family;

  /// The level of a bee, or of the bee a hive holds, or the tier of a
  /// resource; 1 for the other items, which have none to speak of.
  final int level;

  /// How many resources the bee of a hive has left to make; 1 for the other
  /// items, which have none to speak of.
  final int remainingLife;
  const BoardCell({
    required this.column,
    required this.row,
    required this.kind,
    required this.family,
    required this.level,
    required this.remainingLife,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['column'] = Variable<int>(column);
    map['row'] = Variable<int>(row);
    map['kind'] = Variable<String>(kind);
    map['family'] = Variable<String>(family);
    map['level'] = Variable<int>(level);
    map['remaining_life'] = Variable<int>(remainingLife);
    return map;
  }

  BoardCellsCompanion toCompanion(bool nullToAbsent) {
    return BoardCellsCompanion(
      column: Value(column),
      row: Value(row),
      kind: Value(kind),
      family: Value(family),
      level: Value(level),
      remainingLife: Value(remainingLife),
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
      remainingLife: serializer.fromJson<int>(json['remainingLife']),
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
      'remainingLife': serializer.toJson<int>(remainingLife),
    };
  }

  BoardCell copyWith({
    int? column,
    int? row,
    String? kind,
    String? family,
    int? level,
    int? remainingLife,
  }) => BoardCell(
    column: column ?? this.column,
    row: row ?? this.row,
    kind: kind ?? this.kind,
    family: family ?? this.family,
    level: level ?? this.level,
    remainingLife: remainingLife ?? this.remainingLife,
  );
  BoardCell copyWithCompanion(BoardCellsCompanion data) {
    return BoardCell(
      column: data.column.present ? data.column.value : this.column,
      row: data.row.present ? data.row.value : this.row,
      kind: data.kind.present ? data.kind.value : this.kind,
      family: data.family.present ? data.family.value : this.family,
      level: data.level.present ? data.level.value : this.level,
      remainingLife: data.remainingLife.present
          ? data.remainingLife.value
          : this.remainingLife,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BoardCell(')
          ..write('column: $column, ')
          ..write('row: $row, ')
          ..write('kind: $kind, ')
          ..write('family: $family, ')
          ..write('level: $level, ')
          ..write('remainingLife: $remainingLife')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(column, row, kind, family, level, remainingLife);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BoardCell &&
          other.column == this.column &&
          other.row == this.row &&
          other.kind == this.kind &&
          other.family == this.family &&
          other.level == this.level &&
          other.remainingLife == this.remainingLife);
}

class BoardCellsCompanion extends UpdateCompanion<BoardCell> {
  final Value<int> column;
  final Value<int> row;
  final Value<String> kind;
  final Value<String> family;
  final Value<int> level;
  final Value<int> remainingLife;
  final Value<int> rowid;
  const BoardCellsCompanion({
    this.column = const Value.absent(),
    this.row = const Value.absent(),
    this.kind = const Value.absent(),
    this.family = const Value.absent(),
    this.level = const Value.absent(),
    this.remainingLife = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BoardCellsCompanion.insert({
    required int column,
    required int row,
    required String kind,
    required String family,
    this.level = const Value.absent(),
    this.remainingLife = const Value.absent(),
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
    Expression<int>? remainingLife,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (column != null) 'column': column,
      if (row != null) 'row': row,
      if (kind != null) 'kind': kind,
      if (family != null) 'family': family,
      if (level != null) 'level': level,
      if (remainingLife != null) 'remaining_life': remainingLife,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BoardCellsCompanion copyWith({
    Value<int>? column,
    Value<int>? row,
    Value<String>? kind,
    Value<String>? family,
    Value<int>? level,
    Value<int>? remainingLife,
    Value<int>? rowid,
  }) {
    return BoardCellsCompanion(
      column: column ?? this.column,
      row: row ?? this.row,
      kind: kind ?? this.kind,
      family: family ?? this.family,
      level: level ?? this.level,
      remainingLife: remainingLife ?? this.remainingLife,
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
    if (remainingLife.present) {
      map['remaining_life'] = Variable<int>(remainingLife.value);
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
          ..write('remainingLife: $remainingLife, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EnergyStatesTable extends EnergyStates
    with TableInfo<$EnergyStatesTable, EnergyState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EnergyStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<int> value = GeneratedColumn<int>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countedFromMsMeta = const VerificationMeta(
    'countedFromMs',
  );
  @override
  late final GeneratedColumn<int> countedFromMs = GeneratedColumn<int>(
    'counted_from_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, value, countedFromMs];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'energy_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<EnergyState> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('counted_from_ms')) {
      context.handle(
        _countedFromMsMeta,
        countedFromMs.isAcceptableOrUnknown(
          data['counted_from_ms']!,
          _countedFromMsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EnergyState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EnergyState(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}value'],
      )!,
      countedFromMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}counted_from_ms'],
      ),
    );
  }

  @override
  $EnergyStatesTable createAlias(String alias) {
    return $EnergyStatesTable(attachedDatabase, alias);
  }
}

class EnergyState extends DataClass implements Insertable<EnergyState> {
  final int id;
  final int value;

  /// The trusted instant the next unit is counted from, in milliseconds since
  /// the epoch; `null` while the gauge is full or no trusted time was known.
  final int? countedFromMs;
  const EnergyState({
    required this.id,
    required this.value,
    this.countedFromMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['value'] = Variable<int>(value);
    if (!nullToAbsent || countedFromMs != null) {
      map['counted_from_ms'] = Variable<int>(countedFromMs);
    }
    return map;
  }

  EnergyStatesCompanion toCompanion(bool nullToAbsent) {
    return EnergyStatesCompanion(
      id: Value(id),
      value: Value(value),
      countedFromMs: countedFromMs == null && nullToAbsent
          ? const Value.absent()
          : Value(countedFromMs),
    );
  }

  factory EnergyState.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EnergyState(
      id: serializer.fromJson<int>(json['id']),
      value: serializer.fromJson<int>(json['value']),
      countedFromMs: serializer.fromJson<int?>(json['countedFromMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'value': serializer.toJson<int>(value),
      'countedFromMs': serializer.toJson<int?>(countedFromMs),
    };
  }

  EnergyState copyWith({
    int? id,
    int? value,
    Value<int?> countedFromMs = const Value.absent(),
  }) => EnergyState(
    id: id ?? this.id,
    value: value ?? this.value,
    countedFromMs: countedFromMs.present
        ? countedFromMs.value
        : this.countedFromMs,
  );
  EnergyState copyWithCompanion(EnergyStatesCompanion data) {
    return EnergyState(
      id: data.id.present ? data.id.value : this.id,
      value: data.value.present ? data.value.value : this.value,
      countedFromMs: data.countedFromMs.present
          ? data.countedFromMs.value
          : this.countedFromMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EnergyState(')
          ..write('id: $id, ')
          ..write('value: $value, ')
          ..write('countedFromMs: $countedFromMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, value, countedFromMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EnergyState &&
          other.id == this.id &&
          other.value == this.value &&
          other.countedFromMs == this.countedFromMs);
}

class EnergyStatesCompanion extends UpdateCompanion<EnergyState> {
  final Value<int> id;
  final Value<int> value;
  final Value<int?> countedFromMs;
  const EnergyStatesCompanion({
    this.id = const Value.absent(),
    this.value = const Value.absent(),
    this.countedFromMs = const Value.absent(),
  });
  EnergyStatesCompanion.insert({
    this.id = const Value.absent(),
    required int value,
    this.countedFromMs = const Value.absent(),
  }) : value = Value(value);
  static Insertable<EnergyState> custom({
    Expression<int>? id,
    Expression<int>? value,
    Expression<int>? countedFromMs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (value != null) 'value': value,
      if (countedFromMs != null) 'counted_from_ms': countedFromMs,
    });
  }

  EnergyStatesCompanion copyWith({
    Value<int>? id,
    Value<int>? value,
    Value<int?>? countedFromMs,
  }) {
    return EnergyStatesCompanion(
      id: id ?? this.id,
      value: value ?? this.value,
      countedFromMs: countedFromMs ?? this.countedFromMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (value.present) {
      map['value'] = Variable<int>(value.value);
    }
    if (countedFromMs.present) {
      map['counted_from_ms'] = Variable<int>(countedFromMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EnergyStatesCompanion(')
          ..write('id: $id, ')
          ..write('value: $value, ')
          ..write('countedFromMs: $countedFromMs')
          ..write(')'))
        .toString();
  }
}

class $DayOrdersTable extends DayOrders
    with TableInfo<$DayOrdersTable, DayOrder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DayOrdersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customerMeta = const VerificationMeta(
    'customer',
  );
  @override
  late final GeneratedColumn<String> customer = GeneratedColumn<String>(
    'customer',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coinsMeta = const VerificationMeta('coins');
  @override
  late final GeneratedColumn<int> coins = GeneratedColumn<int>(
    'coins',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [position, customer, coins];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'day_orders';
  @override
  VerificationContext validateIntegrity(
    Insertable<DayOrder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    if (data.containsKey('customer')) {
      context.handle(
        _customerMeta,
        customer.isAcceptableOrUnknown(data['customer']!, _customerMeta),
      );
    } else if (isInserting) {
      context.missing(_customerMeta);
    }
    if (data.containsKey('coins')) {
      context.handle(
        _coinsMeta,
        coins.isAcceptableOrUnknown(data['coins']!, _coinsMeta),
      );
    } else if (isInserting) {
      context.missing(_coinsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {position};
  @override
  DayOrder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DayOrder(
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      customer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer'],
      )!,
      coins: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}coins'],
      )!,
    );
  }

  @override
  $DayOrdersTable createAlias(String alias) {
    return $DayOrdersTable(attachedDatabase, alias);
  }
}

class DayOrder extends DataClass implements Insertable<DayOrder> {
  final int position;

  /// A `Customer` name.
  final String customer;
  final int coins;
  const DayOrder({
    required this.position,
    required this.customer,
    required this.coins,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['position'] = Variable<int>(position);
    map['customer'] = Variable<String>(customer);
    map['coins'] = Variable<int>(coins);
    return map;
  }

  DayOrdersCompanion toCompanion(bool nullToAbsent) {
    return DayOrdersCompanion(
      position: Value(position),
      customer: Value(customer),
      coins: Value(coins),
    );
  }

  factory DayOrder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DayOrder(
      position: serializer.fromJson<int>(json['position']),
      customer: serializer.fromJson<String>(json['customer']),
      coins: serializer.fromJson<int>(json['coins']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'position': serializer.toJson<int>(position),
      'customer': serializer.toJson<String>(customer),
      'coins': serializer.toJson<int>(coins),
    };
  }

  DayOrder copyWith({int? position, String? customer, int? coins}) => DayOrder(
    position: position ?? this.position,
    customer: customer ?? this.customer,
    coins: coins ?? this.coins,
  );
  DayOrder copyWithCompanion(DayOrdersCompanion data) {
    return DayOrder(
      position: data.position.present ? data.position.value : this.position,
      customer: data.customer.present ? data.customer.value : this.customer,
      coins: data.coins.present ? data.coins.value : this.coins,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DayOrder(')
          ..write('position: $position, ')
          ..write('customer: $customer, ')
          ..write('coins: $coins')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(position, customer, coins);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DayOrder &&
          other.position == this.position &&
          other.customer == this.customer &&
          other.coins == this.coins);
}

class DayOrdersCompanion extends UpdateCompanion<DayOrder> {
  final Value<int> position;
  final Value<String> customer;
  final Value<int> coins;
  const DayOrdersCompanion({
    this.position = const Value.absent(),
    this.customer = const Value.absent(),
    this.coins = const Value.absent(),
  });
  DayOrdersCompanion.insert({
    this.position = const Value.absent(),
    required String customer,
    required int coins,
  }) : customer = Value(customer),
       coins = Value(coins);
  static Insertable<DayOrder> custom({
    Expression<int>? position,
    Expression<String>? customer,
    Expression<int>? coins,
  }) {
    return RawValuesInsertable({
      if (position != null) 'position': position,
      if (customer != null) 'customer': customer,
      if (coins != null) 'coins': coins,
    });
  }

  DayOrdersCompanion copyWith({
    Value<int>? position,
    Value<String>? customer,
    Value<int>? coins,
  }) {
    return DayOrdersCompanion(
      position: position ?? this.position,
      customer: customer ?? this.customer,
      coins: coins ?? this.coins,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (customer.present) {
      map['customer'] = Variable<String>(customer.value);
    }
    if (coins.present) {
      map['coins'] = Variable<int>(coins.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DayOrdersCompanion(')
          ..write('position: $position, ')
          ..write('customer: $customer, ')
          ..write('coins: $coins')
          ..write(')'))
        .toString();
  }
}

class $DayOrderResourcesTable extends DayOrderResources
    with TableInfo<$DayOrderResourcesTable, DayOrderResource> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DayOrderResourcesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _orderPositionMeta = const VerificationMeta(
    'orderPosition',
  );
  @override
  late final GeneratedColumn<int> orderPosition = GeneratedColumn<int>(
    'order_position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _slotMeta = const VerificationMeta('slot');
  @override
  late final GeneratedColumn<int> slot = GeneratedColumn<int>(
    'slot',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _branchMeta = const VerificationMeta('branch');
  @override
  late final GeneratedColumn<String> branch = GeneratedColumn<String>(
    'branch',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tierMeta = const VerificationMeta('tier');
  @override
  late final GeneratedColumn<int> tier = GeneratedColumn<int>(
    'tier',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [orderPosition, slot, branch, tier];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'day_order_resources';
  @override
  VerificationContext validateIntegrity(
    Insertable<DayOrderResource> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('order_position')) {
      context.handle(
        _orderPositionMeta,
        orderPosition.isAcceptableOrUnknown(
          data['order_position']!,
          _orderPositionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_orderPositionMeta);
    }
    if (data.containsKey('slot')) {
      context.handle(
        _slotMeta,
        slot.isAcceptableOrUnknown(data['slot']!, _slotMeta),
      );
    } else if (isInserting) {
      context.missing(_slotMeta);
    }
    if (data.containsKey('branch')) {
      context.handle(
        _branchMeta,
        branch.isAcceptableOrUnknown(data['branch']!, _branchMeta),
      );
    } else if (isInserting) {
      context.missing(_branchMeta);
    }
    if (data.containsKey('tier')) {
      context.handle(
        _tierMeta,
        tier.isAcceptableOrUnknown(data['tier']!, _tierMeta),
      );
    } else if (isInserting) {
      context.missing(_tierMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {orderPosition, slot};
  @override
  DayOrderResource map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DayOrderResource(
      orderPosition: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_position'],
      )!,
      slot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}slot'],
      )!,
      branch: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}branch'],
      )!,
      tier: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tier'],
      )!,
    );
  }

  @override
  $DayOrderResourcesTable createAlias(String alias) {
    return $DayOrderResourcesTable(attachedDatabase, alias);
  }
}

class DayOrderResource extends DataClass
    implements Insertable<DayOrderResource> {
  final int orderPosition;
  final int slot;

  /// A `ResourceBranch` name.
  final String branch;
  final int tier;
  const DayOrderResource({
    required this.orderPosition,
    required this.slot,
    required this.branch,
    required this.tier,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['order_position'] = Variable<int>(orderPosition);
    map['slot'] = Variable<int>(slot);
    map['branch'] = Variable<String>(branch);
    map['tier'] = Variable<int>(tier);
    return map;
  }

  DayOrderResourcesCompanion toCompanion(bool nullToAbsent) {
    return DayOrderResourcesCompanion(
      orderPosition: Value(orderPosition),
      slot: Value(slot),
      branch: Value(branch),
      tier: Value(tier),
    );
  }

  factory DayOrderResource.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DayOrderResource(
      orderPosition: serializer.fromJson<int>(json['orderPosition']),
      slot: serializer.fromJson<int>(json['slot']),
      branch: serializer.fromJson<String>(json['branch']),
      tier: serializer.fromJson<int>(json['tier']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'orderPosition': serializer.toJson<int>(orderPosition),
      'slot': serializer.toJson<int>(slot),
      'branch': serializer.toJson<String>(branch),
      'tier': serializer.toJson<int>(tier),
    };
  }

  DayOrderResource copyWith({
    int? orderPosition,
    int? slot,
    String? branch,
    int? tier,
  }) => DayOrderResource(
    orderPosition: orderPosition ?? this.orderPosition,
    slot: slot ?? this.slot,
    branch: branch ?? this.branch,
    tier: tier ?? this.tier,
  );
  DayOrderResource copyWithCompanion(DayOrderResourcesCompanion data) {
    return DayOrderResource(
      orderPosition: data.orderPosition.present
          ? data.orderPosition.value
          : this.orderPosition,
      slot: data.slot.present ? data.slot.value : this.slot,
      branch: data.branch.present ? data.branch.value : this.branch,
      tier: data.tier.present ? data.tier.value : this.tier,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DayOrderResource(')
          ..write('orderPosition: $orderPosition, ')
          ..write('slot: $slot, ')
          ..write('branch: $branch, ')
          ..write('tier: $tier')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(orderPosition, slot, branch, tier);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DayOrderResource &&
          other.orderPosition == this.orderPosition &&
          other.slot == this.slot &&
          other.branch == this.branch &&
          other.tier == this.tier);
}

class DayOrderResourcesCompanion extends UpdateCompanion<DayOrderResource> {
  final Value<int> orderPosition;
  final Value<int> slot;
  final Value<String> branch;
  final Value<int> tier;
  final Value<int> rowid;
  const DayOrderResourcesCompanion({
    this.orderPosition = const Value.absent(),
    this.slot = const Value.absent(),
    this.branch = const Value.absent(),
    this.tier = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DayOrderResourcesCompanion.insert({
    required int orderPosition,
    required int slot,
    required String branch,
    required int tier,
    this.rowid = const Value.absent(),
  }) : orderPosition = Value(orderPosition),
       slot = Value(slot),
       branch = Value(branch),
       tier = Value(tier);
  static Insertable<DayOrderResource> custom({
    Expression<int>? orderPosition,
    Expression<int>? slot,
    Expression<String>? branch,
    Expression<int>? tier,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (orderPosition != null) 'order_position': orderPosition,
      if (slot != null) 'slot': slot,
      if (branch != null) 'branch': branch,
      if (tier != null) 'tier': tier,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DayOrderResourcesCompanion copyWith({
    Value<int>? orderPosition,
    Value<int>? slot,
    Value<String>? branch,
    Value<int>? tier,
    Value<int>? rowid,
  }) {
    return DayOrderResourcesCompanion(
      orderPosition: orderPosition ?? this.orderPosition,
      slot: slot ?? this.slot,
      branch: branch ?? this.branch,
      tier: tier ?? this.tier,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (orderPosition.present) {
      map['order_position'] = Variable<int>(orderPosition.value);
    }
    if (slot.present) {
      map['slot'] = Variable<int>(slot.value);
    }
    if (branch.present) {
      map['branch'] = Variable<String>(branch.value);
    }
    if (tier.present) {
      map['tier'] = Variable<int>(tier.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DayOrderResourcesCompanion(')
          ..write('orderPosition: $orderPosition, ')
          ..write('slot: $slot, ')
          ..write('branch: $branch, ')
          ..write('tier: $tier, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BoardCellsTable boardCells = $BoardCellsTable(this);
  late final $EnergyStatesTable energyStates = $EnergyStatesTable(this);
  late final $DayOrdersTable dayOrders = $DayOrdersTable(this);
  late final $DayOrderResourcesTable dayOrderResources =
      $DayOrderResourcesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    boardCells,
    energyStates,
    dayOrders,
    dayOrderResources,
  ];
}

typedef $$BoardCellsTableCreateCompanionBuilder = BoardCellsCompanion Function({
  required int column,
  required int row,
  required String kind,
  required String family,
  Value<int> level,
  Value<int> remainingLife,
  Value<int> rowid,
});
typedef $$BoardCellsTableUpdateCompanionBuilder = BoardCellsCompanion Function({
  Value<int> column,
  Value<int> row,
  Value<String> kind,
  Value<String> family,
  Value<int> level,
  Value<int> remainingLife,
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

  ColumnFilters<int> get remainingLife => $composableBuilder(
    column: $table.remainingLife,
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

  ColumnOrderings<int> get remainingLife => $composableBuilder(
    column: $table.remainingLife,
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

  GeneratedColumn<int> get remainingLife => $composableBuilder(
    column: $table.remainingLife,
    builder: (column) => column,
  );
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
                Value<int> remainingLife = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BoardCellsCompanion(
                column: column,
                row: row,
                kind: kind,
                family: family,
                level: level,
                remainingLife: remainingLife,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int column,
                required int row,
                required String kind,
                required String family,
                Value<int> level = const Value.absent(),
                Value<int> remainingLife = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BoardCellsCompanion.insert(
                column: column,
                row: row,
                kind: kind,
                family: family,
                level: level,
                remainingLife: remainingLife,
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
typedef $$EnergyStatesTableCreateCompanionBuilder =
    EnergyStatesCompanion Function({
      Value<int> id,
      required int value,
      Value<int?> countedFromMs,
    });
typedef $$EnergyStatesTableUpdateCompanionBuilder =
    EnergyStatesCompanion Function({
      Value<int> id,
      Value<int> value,
      Value<int?> countedFromMs,
    });

class $$EnergyStatesTableFilterComposer
    extends Composer<_$AppDatabase, $EnergyStatesTable> {
  $$EnergyStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get countedFromMs => $composableBuilder(
    column: $table.countedFromMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EnergyStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $EnergyStatesTable> {
  $$EnergyStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get countedFromMs => $composableBuilder(
    column: $table.countedFromMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EnergyStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EnergyStatesTable> {
  $$EnergyStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<int> get countedFromMs => $composableBuilder(
    column: $table.countedFromMs,
    builder: (column) => column,
  );
}

class $$EnergyStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EnergyStatesTable,
          EnergyState,
          $$EnergyStatesTableFilterComposer,
          $$EnergyStatesTableOrderingComposer,
          $$EnergyStatesTableAnnotationComposer,
          $$EnergyStatesTableCreateCompanionBuilder,
          $$EnergyStatesTableUpdateCompanionBuilder,
          (
            EnergyState,
            BaseReferences<_$AppDatabase, $EnergyStatesTable, EnergyState>,
          ),
          EnergyState,
          PrefetchHooks Function()
        > {
  $$EnergyStatesTableTableManager(_$AppDatabase db, $EnergyStatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EnergyStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EnergyStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EnergyStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> value = const Value.absent(),
                Value<int?> countedFromMs = const Value.absent(),
              }) => EnergyStatesCompanion(
                id: id,
                value: value,
                countedFromMs: countedFromMs,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int value,
                Value<int?> countedFromMs = const Value.absent(),
              }) => EnergyStatesCompanion.insert(
                id: id,
                value: value,
                countedFromMs: countedFromMs,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EnergyStatesTable, EnergyState>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $EnergyStatesTable,
                    EnergyState
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EnergyStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EnergyStatesTable,
      EnergyState,
      $$EnergyStatesTableFilterComposer,
      $$EnergyStatesTableOrderingComposer,
      $$EnergyStatesTableAnnotationComposer,
      $$EnergyStatesTableCreateCompanionBuilder,
      $$EnergyStatesTableUpdateCompanionBuilder,
      (
        EnergyState,
        BaseReferences<_$AppDatabase, $EnergyStatesTable, EnergyState>,
      ),
      EnergyState,
      PrefetchHooks Function()
    >;
typedef $$DayOrdersTableCreateCompanionBuilder = DayOrdersCompanion Function({
  Value<int> position,
  required String customer,
  required int coins,
});
typedef $$DayOrdersTableUpdateCompanionBuilder = DayOrdersCompanion Function({
  Value<int> position,
  Value<String> customer,
  Value<int> coins,
});

class $$DayOrdersTableFilterComposer
    extends Composer<_$AppDatabase, $DayOrdersTable> {
  $$DayOrdersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customer => $composableBuilder(
    column: $table.customer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get coins => $composableBuilder(
    column: $table.coins,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DayOrdersTableOrderingComposer
    extends Composer<_$AppDatabase, $DayOrdersTable> {
  $$DayOrdersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customer => $composableBuilder(
    column: $table.customer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get coins => $composableBuilder(
    column: $table.coins,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DayOrdersTableAnnotationComposer
    extends Composer<_$AppDatabase, $DayOrdersTable> {
  $$DayOrdersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get customer =>
      $composableBuilder(column: $table.customer, builder: (column) => column);

  GeneratedColumn<int> get coins =>
      $composableBuilder(column: $table.coins, builder: (column) => column);
}

class $$DayOrdersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DayOrdersTable,
          DayOrder,
          $$DayOrdersTableFilterComposer,
          $$DayOrdersTableOrderingComposer,
          $$DayOrdersTableAnnotationComposer,
          $$DayOrdersTableCreateCompanionBuilder,
          $$DayOrdersTableUpdateCompanionBuilder,
          (DayOrder, BaseReferences<_$AppDatabase, $DayOrdersTable, DayOrder>),
          DayOrder,
          PrefetchHooks Function()
        > {
  $$DayOrdersTableTableManager(_$AppDatabase db, $DayOrdersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DayOrdersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DayOrdersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DayOrdersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> position = const Value.absent(),
                Value<String> customer = const Value.absent(),
                Value<int> coins = const Value.absent(),
              }) => DayOrdersCompanion(
                position: position,
                customer: customer,
                coins: coins,
              ),
          createCompanionCallback:
              ({
                Value<int> position = const Value.absent(),
                required String customer,
                required int coins,
              }) => DayOrdersCompanion.insert(
                position: position,
                customer: customer,
                coins: coins,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DayOrdersTable, DayOrder>(table),
                  BaseReferences<_$AppDatabase, $DayOrdersTable, DayOrder>(
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

typedef $$DayOrdersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DayOrdersTable,
      DayOrder,
      $$DayOrdersTableFilterComposer,
      $$DayOrdersTableOrderingComposer,
      $$DayOrdersTableAnnotationComposer,
      $$DayOrdersTableCreateCompanionBuilder,
      $$DayOrdersTableUpdateCompanionBuilder,
      (DayOrder, BaseReferences<_$AppDatabase, $DayOrdersTable, DayOrder>),
      DayOrder,
      PrefetchHooks Function()
    >;
typedef $$DayOrderResourcesTableCreateCompanionBuilder =
    DayOrderResourcesCompanion Function({
      required int orderPosition,
      required int slot,
      required String branch,
      required int tier,
      Value<int> rowid,
    });
typedef $$DayOrderResourcesTableUpdateCompanionBuilder =
    DayOrderResourcesCompanion Function({
      Value<int> orderPosition,
      Value<int> slot,
      Value<String> branch,
      Value<int> tier,
      Value<int> rowid,
    });

class $$DayOrderResourcesTableFilterComposer
    extends Composer<_$AppDatabase, $DayOrderResourcesTable> {
  $$DayOrderResourcesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get orderPosition => $composableBuilder(
    column: $table.orderPosition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get slot => $composableBuilder(
    column: $table.slot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get branch => $composableBuilder(
    column: $table.branch,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tier => $composableBuilder(
    column: $table.tier,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DayOrderResourcesTableOrderingComposer
    extends Composer<_$AppDatabase, $DayOrderResourcesTable> {
  $$DayOrderResourcesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get orderPosition => $composableBuilder(
    column: $table.orderPosition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get slot => $composableBuilder(
    column: $table.slot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get branch => $composableBuilder(
    column: $table.branch,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tier => $composableBuilder(
    column: $table.tier,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DayOrderResourcesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DayOrderResourcesTable> {
  $$DayOrderResourcesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get orderPosition => $composableBuilder(
    column: $table.orderPosition,
    builder: (column) => column,
  );

  GeneratedColumn<int> get slot =>
      $composableBuilder(column: $table.slot, builder: (column) => column);

  GeneratedColumn<String> get branch =>
      $composableBuilder(column: $table.branch, builder: (column) => column);

  GeneratedColumn<int> get tier =>
      $composableBuilder(column: $table.tier, builder: (column) => column);
}

class $$DayOrderResourcesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DayOrderResourcesTable,
          DayOrderResource,
          $$DayOrderResourcesTableFilterComposer,
          $$DayOrderResourcesTableOrderingComposer,
          $$DayOrderResourcesTableAnnotationComposer,
          $$DayOrderResourcesTableCreateCompanionBuilder,
          $$DayOrderResourcesTableUpdateCompanionBuilder,
          (
            DayOrderResource,
            BaseReferences<
              _$AppDatabase,
              $DayOrderResourcesTable,
              DayOrderResource
            >,
          ),
          DayOrderResource,
          PrefetchHooks Function()
        > {
  $$DayOrderResourcesTableTableManager(
    _$AppDatabase db,
    $DayOrderResourcesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DayOrderResourcesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DayOrderResourcesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DayOrderResourcesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> orderPosition = const Value.absent(),
                Value<int> slot = const Value.absent(),
                Value<String> branch = const Value.absent(),
                Value<int> tier = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DayOrderResourcesCompanion(
                orderPosition: orderPosition,
                slot: slot,
                branch: branch,
                tier: tier,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int orderPosition,
                required int slot,
                required String branch,
                required int tier,
                Value<int> rowid = const Value.absent(),
              }) => DayOrderResourcesCompanion.insert(
                orderPosition: orderPosition,
                slot: slot,
                branch: branch,
                tier: tier,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DayOrderResourcesTable, DayOrderResource>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $DayOrderResourcesTable,
                    DayOrderResource
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DayOrderResourcesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DayOrderResourcesTable,
      DayOrderResource,
      $$DayOrderResourcesTableFilterComposer,
      $$DayOrderResourcesTableOrderingComposer,
      $$DayOrderResourcesTableAnnotationComposer,
      $$DayOrderResourcesTableCreateCompanionBuilder,
      $$DayOrderResourcesTableUpdateCompanionBuilder,
      (
        DayOrderResource,
        BaseReferences<
          _$AppDatabase,
          $DayOrderResourcesTable,
          DayOrderResource
        >,
      ),
      DayOrderResource,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BoardCellsTableTableManager get boardCells =>
      $$BoardCellsTableTableManager(_db, _db.boardCells);
  $$EnergyStatesTableTableManager get energyStates =>
      $$EnergyStatesTableTableManager(_db, _db.energyStates);
  $$DayOrdersTableTableManager get dayOrders =>
      $$DayOrdersTableTableManager(_db, _db.dayOrders);
  $$DayOrderResourcesTableTableManager get dayOrderResources =>
      $$DayOrderResourcesTableTableManager(_db, _db.dayOrderResources);
}
