import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'dart:io';
import 'dart:async';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import '../models/database_metadata.dart';
import '../../core/error/models/app_error.dart';
import '../../core/error/models/error_severity.dart';

part 'credentials_database.g.dart';

@DriftDatabase(tables: [DatabaseMetadataTable])
class CredentialsDatabase extends _$CredentialsDatabase {
  CredentialsDatabase._internal(QueryExecutor e) : super(e);

  // Singleton pattern
  static CredentialsDatabase? _instance;
  static String? _currentPassword;
  static Timer? _lockTimer;
  static const int _lockTimeoutMinutes = 15;

  static Future<CredentialsDatabase> getInstance(String password) async {
    if (_instance != null && _currentPassword == password) {
      _resetLockTimer();
      return _instance!;
    }

    try {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'credentials.db'));

      // Инициализация SQLCipher
      await applyWorkaroundToOpenSqlCipherOnOldAndroidVersions();

      final executor = NativeDatabase(
        file,
        setup: (rawDb) {
          rawDb.execute("PRAGMA key = '$password'");
          rawDb.execute('PRAGMA cipher_compatibility = 4');
        },
      );

      _instance = CredentialsDatabase._internal(executor);
      _currentPassword = password;
      _resetLockTimer();

      // Проверяем подключение и создаем таблицы если нужно
      await _instance!._verifyConnection();

      return _instance!;
    } catch (e) {
      throw DatabaseError(
        code: 'DB_CONNECTION_FAILED',
        message: 'Ошибка подключения к базе данных',
        timestamp: DateTime.now(),
        originalError: e,
        severity: ErrorSeverity.critical,
      );
    }
  }

  Future<void> _verifyConnection() async {
    try {
      // Проверяем подключение, выполнив простой запрос
      await select(databaseMetadataTable).get();
    } catch (e) {
      throw DatabaseError(
        code: 'DB_AUTH_FAILED',
        message: 'Неверный пароль или поврежденная база данных',
        timestamp: DateTime.now(),
        originalError: e,
        severity: ErrorSeverity.error,
      );
    }
  }

  static void _resetLockTimer() {
    _lockTimer?.cancel();
    _lockTimer = Timer(Duration(minutes: _lockTimeoutMinutes), () {
      lockDatabase();
    });
  }

  static void lockDatabase() {
    _instance?.close();
    _instance = null;
    _currentPassword = null;
    _lockTimer?.cancel();
    _lockTimer = null;
  }

  Future<void> closeDatabase() async {
    try {
      await close();
      _instance = null;
      _currentPassword = null;
      _lockTimer?.cancel();
      _lockTimer = null;
    } catch (e) {
      throw DatabaseError(
        code: 'DB_CLOSE_FAILED',
        message: 'Ошибка закрытия базы данных',
        timestamp: DateTime.now(),
        originalError: e,
        severity: ErrorSeverity.error,
      );
    }
  }

  // Создание новой базы данных с метаданными
  Future<DatabaseMetadata> createDatabaseMetadata({
    required String name,
    required String description,
    required String password,
  }) async {
    try {
      final passwordHash = _hashPassword(password);
      final now = DateTime.now();

      final id = await into(databaseMetadataTable).insert(
        DatabaseMetadataTableCompanion.insert(
          name: name,
          description: description,
          passwordHash: passwordHash,
          createdAt: now,
          lastOpenedAt: now,
        ),
      );

      return DatabaseMetadata(
        id: id,
        name: name,
        description: description,
        passwordHash: passwordHash,
        createdAt: now,
        lastOpenedAt: now,
      );
    } catch (e) {
      throw DatabaseError(
        code: 'DB_INSERT_FAILED',
        message: 'Ошибка создания метаданных базы данных',
        timestamp: DateTime.now(),
        originalError: e,
        severity: ErrorSeverity.error,
      );
    }
  }

  // Получение всех метаданных баз данных
  Future<List<DatabaseMetadata>> getAllDatabaseMetadata() async {
    try {
      final rows = await select(databaseMetadataTable).get();
      return rows
          .map(
            (row) => DatabaseMetadata(
              id: row.id,
              name: row.name,
              description: row.description,
              passwordHash: row.passwordHash,
              createdAt: row.createdAt,
              lastOpenedAt: row.lastOpenedAt,
              isLocked: row.isLocked,
            ),
          )
          .toList();
    } catch (e) {
      throw DatabaseError(
        code: 'DB_SELECT_FAILED',
        message: 'Ошибка получения метаданных баз данных',
        timestamp: DateTime.now(),
        originalError: e,
        severity: ErrorSeverity.error,
      );
    }
  }

  // Обновление времени последнего открытия
  Future<void> updateLastOpenedAt(int id) async {
    try {
      await (update(
        databaseMetadataTable,
      )..where((t) => t.id.equals(id))).write(
        DatabaseMetadataTableCompanion(lastOpenedAt: Value(DateTime.now())),
      );
    } catch (e) {
      throw DatabaseError(
        code: 'DB_UPDATE_FAILED',
        message: 'Ошибка обновления времени последнего открытия',
        timestamp: DateTime.now(),
        originalError: e,
        severity: ErrorSeverity.warning,
      );
    }
  }

  // Блокировка/разблокировка базы данных
  Future<void> setDatabaseLocked(int id, bool isLocked) async {
    try {
      await (update(databaseMetadataTable)..where((t) => t.id.equals(id)))
          .write(DatabaseMetadataTableCompanion(isLocked: Value(isLocked)));
    } catch (e) {
      throw DatabaseError(
        code: 'DB_UPDATE_FAILED',
        message: 'Ошибка изменения статуса блокировки',
        timestamp: DateTime.now(),
        originalError: e,
        severity: ErrorSeverity.error,
      );
    }
  }

  // Удаление метаданных базы данных
  Future<void> deleteDatabaseMetadata(int id) async {
    try {
      await (delete(databaseMetadataTable)..where((t) => t.id.equals(id))).go();
    } catch (e) {
      throw DatabaseError(
        code: 'DB_DELETE_FAILED',
        message: 'Ошибка удаления метаданных базы данных',
        timestamp: DateTime.now(),
        originalError: e,
        severity: ErrorSeverity.error,
      );
    }
  }

  // Проверка пароля
  bool verifyPassword(String password, String hash) {
    return _hashPassword(password) == hash;
  }

  // Хеширование пароля
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Здесь можно добавить миграции для будущих версий
    },
  );
}
