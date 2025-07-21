// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credentials_database.dart';

// ignore_for_file: type=lint
class $DatabaseMetadataTableTable extends DatabaseMetadataTable
    with TableInfo<$DatabaseMetadataTableTable, DatabaseMetadataTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DatabaseMetadataTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 1000),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _passwordHashMeta = const VerificationMeta(
    'passwordHash',
  );
  @override
  late final GeneratedColumn<String> passwordHash = GeneratedColumn<String>(
    'password_hash',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 1),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastOpenedAtMeta = const VerificationMeta(
    'lastOpenedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastOpenedAt = GeneratedColumn<DateTime>(
    'last_opened_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isLockedMeta = const VerificationMeta(
    'isLocked',
  );
  @override
  late final GeneratedColumn<bool> isLocked = GeneratedColumn<bool>(
    'is_locked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_locked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    passwordHash,
    createdAt,
    lastOpenedAt,
    isLocked,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'database_metadata_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<DatabaseMetadataTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('password_hash')) {
      context.handle(
        _passwordHashMeta,
        passwordHash.isAcceptableOrUnknown(
          data['password_hash']!,
          _passwordHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_passwordHashMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_opened_at')) {
      context.handle(
        _lastOpenedAtMeta,
        lastOpenedAt.isAcceptableOrUnknown(
          data['last_opened_at']!,
          _lastOpenedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastOpenedAtMeta);
    }
    if (data.containsKey('is_locked')) {
      context.handle(
        _isLockedMeta,
        isLocked.isAcceptableOrUnknown(data['is_locked']!, _isLockedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DatabaseMetadataTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DatabaseMetadataTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      passwordHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}password_hash'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      lastOpenedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_opened_at'],
      )!,
      isLocked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_locked'],
      )!,
    );
  }

  @override
  $DatabaseMetadataTableTable createAlias(String alias) {
    return $DatabaseMetadataTableTable(attachedDatabase, alias);
  }
}

class DatabaseMetadataTableData extends DataClass
    implements Insertable<DatabaseMetadataTableData> {
  final int id;
  final String name;
  final String description;
  final String passwordHash;
  final DateTime createdAt;
  final DateTime lastOpenedAt;
  final bool isLocked;
  const DatabaseMetadataTableData({
    required this.id,
    required this.name,
    required this.description,
    required this.passwordHash,
    required this.createdAt,
    required this.lastOpenedAt,
    required this.isLocked,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    map['password_hash'] = Variable<String>(passwordHash);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['last_opened_at'] = Variable<DateTime>(lastOpenedAt);
    map['is_locked'] = Variable<bool>(isLocked);
    return map;
  }

  DatabaseMetadataTableCompanion toCompanion(bool nullToAbsent) {
    return DatabaseMetadataTableCompanion(
      id: Value(id),
      name: Value(name),
      description: Value(description),
      passwordHash: Value(passwordHash),
      createdAt: Value(createdAt),
      lastOpenedAt: Value(lastOpenedAt),
      isLocked: Value(isLocked),
    );
  }

  factory DatabaseMetadataTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DatabaseMetadataTableData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      passwordHash: serializer.fromJson<String>(json['passwordHash']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastOpenedAt: serializer.fromJson<DateTime>(json['lastOpenedAt']),
      isLocked: serializer.fromJson<bool>(json['isLocked']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
      'passwordHash': serializer.toJson<String>(passwordHash),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastOpenedAt': serializer.toJson<DateTime>(lastOpenedAt),
      'isLocked': serializer.toJson<bool>(isLocked),
    };
  }

  DatabaseMetadataTableData copyWith({
    int? id,
    String? name,
    String? description,
    String? passwordHash,
    DateTime? createdAt,
    DateTime? lastOpenedAt,
    bool? isLocked,
  }) => DatabaseMetadataTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    passwordHash: passwordHash ?? this.passwordHash,
    createdAt: createdAt ?? this.createdAt,
    lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
    isLocked: isLocked ?? this.isLocked,
  );
  DatabaseMetadataTableData copyWithCompanion(
    DatabaseMetadataTableCompanion data,
  ) {
    return DatabaseMetadataTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      passwordHash: data.passwordHash.present
          ? data.passwordHash.value
          : this.passwordHash,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastOpenedAt: data.lastOpenedAt.present
          ? data.lastOpenedAt.value
          : this.lastOpenedAt,
      isLocked: data.isLocked.present ? data.isLocked.value : this.isLocked,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DatabaseMetadataTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastOpenedAt: $lastOpenedAt, ')
          ..write('isLocked: $isLocked')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    passwordHash,
    createdAt,
    lastOpenedAt,
    isLocked,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DatabaseMetadataTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.passwordHash == this.passwordHash &&
          other.createdAt == this.createdAt &&
          other.lastOpenedAt == this.lastOpenedAt &&
          other.isLocked == this.isLocked);
}

class DatabaseMetadataTableCompanion
    extends UpdateCompanion<DatabaseMetadataTableData> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> description;
  final Value<String> passwordHash;
  final Value<DateTime> createdAt;
  final Value<DateTime> lastOpenedAt;
  final Value<bool> isLocked;
  const DatabaseMetadataTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.passwordHash = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastOpenedAt = const Value.absent(),
    this.isLocked = const Value.absent(),
  });
  DatabaseMetadataTableCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String description,
    required String passwordHash,
    required DateTime createdAt,
    required DateTime lastOpenedAt,
    this.isLocked = const Value.absent(),
  }) : name = Value(name),
       description = Value(description),
       passwordHash = Value(passwordHash),
       createdAt = Value(createdAt),
       lastOpenedAt = Value(lastOpenedAt);
  static Insertable<DatabaseMetadataTableData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? passwordHash,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastOpenedAt,
    Expression<bool>? isLocked,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (passwordHash != null) 'password_hash': passwordHash,
      if (createdAt != null) 'created_at': createdAt,
      if (lastOpenedAt != null) 'last_opened_at': lastOpenedAt,
      if (isLocked != null) 'is_locked': isLocked,
    });
  }

  DatabaseMetadataTableCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? description,
    Value<String>? passwordHash,
    Value<DateTime>? createdAt,
    Value<DateTime>? lastOpenedAt,
    Value<bool>? isLocked,
  }) {
    return DatabaseMetadataTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      passwordHash: passwordHash ?? this.passwordHash,
      createdAt: createdAt ?? this.createdAt,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      isLocked: isLocked ?? this.isLocked,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (passwordHash.present) {
      map['password_hash'] = Variable<String>(passwordHash.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastOpenedAt.present) {
      map['last_opened_at'] = Variable<DateTime>(lastOpenedAt.value);
    }
    if (isLocked.present) {
      map['is_locked'] = Variable<bool>(isLocked.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DatabaseMetadataTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastOpenedAt: $lastOpenedAt, ')
          ..write('isLocked: $isLocked')
          ..write(')'))
        .toString();
  }
}

abstract class _$CredentialsDatabase extends GeneratedDatabase {
  _$CredentialsDatabase(QueryExecutor e) : super(e);
  $CredentialsDatabaseManager get managers => $CredentialsDatabaseManager(this);
  late final $DatabaseMetadataTableTable databaseMetadataTable =
      $DatabaseMetadataTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [databaseMetadataTable];
}

typedef $$DatabaseMetadataTableTableCreateCompanionBuilder =
    DatabaseMetadataTableCompanion Function({
      Value<int> id,
      required String name,
      required String description,
      required String passwordHash,
      required DateTime createdAt,
      required DateTime lastOpenedAt,
      Value<bool> isLocked,
    });
typedef $$DatabaseMetadataTableTableUpdateCompanionBuilder =
    DatabaseMetadataTableCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> description,
      Value<String> passwordHash,
      Value<DateTime> createdAt,
      Value<DateTime> lastOpenedAt,
      Value<bool> isLocked,
    });

class $$DatabaseMetadataTableTableFilterComposer
    extends Composer<_$CredentialsDatabase, $DatabaseMetadataTableTable> {
  $$DatabaseMetadataTableTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastOpenedAt => $composableBuilder(
    column: $table.lastOpenedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLocked => $composableBuilder(
    column: $table.isLocked,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DatabaseMetadataTableTableOrderingComposer
    extends Composer<_$CredentialsDatabase, $DatabaseMetadataTableTable> {
  $$DatabaseMetadataTableTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastOpenedAt => $composableBuilder(
    column: $table.lastOpenedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLocked => $composableBuilder(
    column: $table.isLocked,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DatabaseMetadataTableTableAnnotationComposer
    extends Composer<_$CredentialsDatabase, $DatabaseMetadataTableTable> {
  $$DatabaseMetadataTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastOpenedAt => $composableBuilder(
    column: $table.lastOpenedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isLocked =>
      $composableBuilder(column: $table.isLocked, builder: (column) => column);
}

class $$DatabaseMetadataTableTableTableManager
    extends
        RootTableManager<
          _$CredentialsDatabase,
          $DatabaseMetadataTableTable,
          DatabaseMetadataTableData,
          $$DatabaseMetadataTableTableFilterComposer,
          $$DatabaseMetadataTableTableOrderingComposer,
          $$DatabaseMetadataTableTableAnnotationComposer,
          $$DatabaseMetadataTableTableCreateCompanionBuilder,
          $$DatabaseMetadataTableTableUpdateCompanionBuilder,
          (
            DatabaseMetadataTableData,
            BaseReferences<
              _$CredentialsDatabase,
              $DatabaseMetadataTableTable,
              DatabaseMetadataTableData
            >,
          ),
          DatabaseMetadataTableData,
          PrefetchHooks Function()
        > {
  $$DatabaseMetadataTableTableTableManager(
    _$CredentialsDatabase db,
    $DatabaseMetadataTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DatabaseMetadataTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$DatabaseMetadataTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$DatabaseMetadataTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> passwordHash = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> lastOpenedAt = const Value.absent(),
                Value<bool> isLocked = const Value.absent(),
              }) => DatabaseMetadataTableCompanion(
                id: id,
                name: name,
                description: description,
                passwordHash: passwordHash,
                createdAt: createdAt,
                lastOpenedAt: lastOpenedAt,
                isLocked: isLocked,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String description,
                required String passwordHash,
                required DateTime createdAt,
                required DateTime lastOpenedAt,
                Value<bool> isLocked = const Value.absent(),
              }) => DatabaseMetadataTableCompanion.insert(
                id: id,
                name: name,
                description: description,
                passwordHash: passwordHash,
                createdAt: createdAt,
                lastOpenedAt: lastOpenedAt,
                isLocked: isLocked,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DatabaseMetadataTableTableProcessedTableManager =
    ProcessedTableManager<
      _$CredentialsDatabase,
      $DatabaseMetadataTableTable,
      DatabaseMetadataTableData,
      $$DatabaseMetadataTableTableFilterComposer,
      $$DatabaseMetadataTableTableOrderingComposer,
      $$DatabaseMetadataTableTableAnnotationComposer,
      $$DatabaseMetadataTableTableCreateCompanionBuilder,
      $$DatabaseMetadataTableTableUpdateCompanionBuilder,
      (
        DatabaseMetadataTableData,
        BaseReferences<
          _$CredentialsDatabase,
          $DatabaseMetadataTableTable,
          DatabaseMetadataTableData
        >,
      ),
      DatabaseMetadataTableData,
      PrefetchHooks Function()
    >;

class $CredentialsDatabaseManager {
  final _$CredentialsDatabase _db;
  $CredentialsDatabaseManager(this._db);
  $$DatabaseMetadataTableTableTableManager get databaseMetadataTable =>
      $$DatabaseMetadataTableTableTableManager(_db, _db.databaseMetadataTable);
}
