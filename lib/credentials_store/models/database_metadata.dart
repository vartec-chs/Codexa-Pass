import 'package:drift/drift.dart';

// Простая модель без freezed для начала
class DatabaseMetadata {
  final int id;
  final String name;
  final String description;
  final String passwordHash;
  final DateTime createdAt;
  final DateTime lastOpenedAt;
  final bool isLocked;

  const DatabaseMetadata({
    required this.id,
    required this.name,
    required this.description,
    required this.passwordHash,
    required this.createdAt,
    required this.lastOpenedAt,
    this.isLocked = false,
  });

  DatabaseMetadata copyWith({
    int? id,
    String? name,
    String? description,
    String? passwordHash,
    DateTime? createdAt,
    DateTime? lastOpenedAt,
    bool? isLocked,
  }) {
    return DatabaseMetadata(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      passwordHash: passwordHash ?? this.passwordHash,
      createdAt: createdAt ?? this.createdAt,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      isLocked: isLocked ?? this.isLocked,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'passwordHash': passwordHash,
      'createdAt': createdAt.toIso8601String(),
      'lastOpenedAt': lastOpenedAt.toIso8601String(),
      'isLocked': isLocked,
    };
  }

  factory DatabaseMetadata.fromJson(Map<String, dynamic> json) {
    return DatabaseMetadata(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      passwordHash: json['passwordHash'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastOpenedAt: DateTime.parse(json['lastOpenedAt'] as String),
      isLocked: json['isLocked'] as bool? ?? false,
    );
  }
}

// Drift таблица для метаданных баз данных
class DatabaseMetadataTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get description => text().withLength(max: 1000)();
  TextColumn get passwordHash => text().withLength(min: 1)();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastOpenedAt => dateTime()();
  BoolColumn get isLocked => boolean().withDefault(const Constant(false))();
}
