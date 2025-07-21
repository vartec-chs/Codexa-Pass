import 'dart:async';
import 'dart:io';

import 'package:window_manager/window_manager.dart';

import '../database/credentials_database.dart';
import '../models/database_metadata.dart';
import '../../core/error/models/app_error.dart';
import '../../core/error/models/error_severity.dart';

class CredentialsService with WindowListener {
  static CredentialsService? _instance;
  CredentialsDatabase? _database;
  Timer? _inactivityTimer;
  static const Duration _inactivityTimeout = Duration(minutes: 15);

  CredentialsService._internal();

  static CredentialsService get instance {
    _instance ??= CredentialsService._internal();
    return _instance!;
  }

  Future<void> initialize() async {
    // Регистрируем слушатель событий окна для автоблокировки
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      windowManager.addListener(this);
    }
  }

  /// Открыть базу данных с паролем
  Future<CredentialsDatabase> openDatabase(String password) async {
    try {
      _database = await CredentialsDatabase.getInstance(password);
      _resetInactivityTimer();
      return _database!;
    } catch (e) {
      if (e is DatabaseError) {
        rethrow;
      }
      throw DatabaseError(
        code: 'DB_OPEN_FAILED',
        message: 'Не удалось открыть базу данных',
        timestamp: DateTime.now(),
        originalError: e,
        severity: ErrorSeverity.critical,
      );
    }
  }

  /// Закрыть базу данных
  Future<void> closeDatabase() async {
    try {
      _inactivityTimer?.cancel();
      await _database?.closeDatabase();
      _database = null;
    } catch (e) {
      throw DatabaseError(
        code: 'DB_CLOSE_FAILED',
        message: 'Ошибка при закрытии базы данных',
        timestamp: DateTime.now(),
        originalError: e,
        severity: ErrorSeverity.error,
      );
    }
  }

  /// Заблокировать базу данных
  void lockDatabase() {
    _inactivityTimer?.cancel();
    CredentialsDatabase.lockDatabase();
    _database = null;
  }

  /// Проверить, открыта ли база данных
  bool get isDatabaseOpen => _database != null;

  /// Создать новую запись метаданных базы данных
  Future<DatabaseMetadata> createDatabaseMetadata({
    required String name,
    required String description,
    required String password,
  }) async {
    _ensureDatabaseOpen();
    _resetInactivityTimer();

    try {
      return await _database!.createDatabaseMetadata(
        name: name,
        description: description,
        password: password,
      );
    } catch (e) {
      if (e is DatabaseError) {
        rethrow;
      }
      throw DatabaseError(
        code: 'METADATA_CREATE_FAILED',
        message: 'Не удалось создать метаданные базы данных',
        timestamp: DateTime.now(),
        originalError: e,
        severity: ErrorSeverity.error,
      );
    }
  }

  /// Получить все метаданные баз данных
  Future<List<DatabaseMetadata>> getAllDatabaseMetadata() async {
    _ensureDatabaseOpen();
    _resetInactivityTimer();

    try {
      return await _database!.getAllDatabaseMetadata();
    } catch (e) {
      if (e is DatabaseError) {
        rethrow;
      }
      throw DatabaseError(
        code: 'METADATA_FETCH_FAILED',
        message: 'Не удалось получить метаданные баз данных',
        timestamp: DateTime.now(),
        originalError: e,
        severity: ErrorSeverity.error,
      );
    }
  }

  /// Обновить время последнего открытия
  Future<void> updateLastOpenedAt(int id) async {
    _ensureDatabaseOpen();
    _resetInactivityTimer();

    try {
      await _database!.updateLastOpenedAt(id);
    } catch (e) {
      if (e is DatabaseError) {
        rethrow;
      }
      throw DatabaseError(
        code: 'METADATA_UPDATE_FAILED',
        message: 'Не удалось обновить время последнего открытия',
        timestamp: DateTime.now(),
        originalError: e,
        severity: ErrorSeverity.warning,
      );
    }
  }

  /// Установить статус блокировки базы данных
  Future<void> setDatabaseLocked(int id, bool isLocked) async {
    _ensureDatabaseOpen();
    _resetInactivityTimer();

    try {
      await _database!.setDatabaseLocked(id, isLocked);
    } catch (e) {
      if (e is DatabaseError) {
        rethrow;
      }
      throw DatabaseError(
        code: 'METADATA_LOCK_FAILED',
        message: 'Не удалось изменить статус блокировки',
        timestamp: DateTime.now(),
        originalError: e,
        severity: ErrorSeverity.error,
      );
    }
  }

  /// Удалить метаданные базы данных
  Future<void> deleteDatabaseMetadata(int id) async {
    _ensureDatabaseOpen();
    _resetInactivityTimer();

    try {
      await _database!.deleteDatabaseMetadata(id);
    } catch (e) {
      if (e is DatabaseError) {
        rethrow;
      }
      throw DatabaseError(
        code: 'METADATA_DELETE_FAILED',
        message: 'Не удалось удалить метаданные базы данных',
        timestamp: DateTime.now(),
        originalError: e,
        severity: ErrorSeverity.error,
      );
    }
  }

  /// Проверить пароль
  bool verifyPassword(String password, String hash) {
    _ensureDatabaseOpen();
    _resetInactivityTimer();
    return _database!.verifyPassword(password, hash);
  }

  /// Сбросить таймер неактивности
  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(_inactivityTimeout, () {
      lockDatabase();
    });
  }

  /// Убедиться, что база данных открыта
  void _ensureDatabaseOpen() {
    if (_database == null) {
      throw DatabaseError(
        code: 'DB_NOT_OPEN',
        message: 'База данных не открыта',
        timestamp: DateTime.now(),
        severity: ErrorSeverity.error,
      );
    }
  }

  // Методы WindowListener для автоблокировки при сворачивании окна
  @override
  void onWindowMinimize() {
    lockDatabase();
  }

  @override
  void onWindowClose() {
    closeDatabase();
  }

  @override
  void onWindowFocus() {
    _resetInactivityTimer();
  }

  @override
  void onWindowBlur() {
    // Можно добавить дополнительную логику при потере фокуса
  }

  void dispose() {
    _inactivityTimer?.cancel();
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      windowManager.removeListener(this);
    }
  }
}
