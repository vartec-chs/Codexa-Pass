import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/credentials_service.dart';
import '../models/database_metadata.dart';
import '../../core/error/models/app_error.dart';
import '../../core/error/models/error_severity.dart';
import 'credentials_store_state.dart';

/// Основной провайдер для управления состоянием credentials store
final credentialsStoreProvider =
    StateNotifierProvider<CredentialsStoreNotifier, CredentialsStoreState>(
      (ref) => CredentialsStoreNotifier(),
    );

class CredentialsStoreNotifier extends StateNotifier<CredentialsStoreState> {
  late final CredentialsService _service;
  Timer? _activityTimer;
  bool _disposed = false;

  CredentialsStoreNotifier() : super(const CredentialsStoreState()) {
    _service = CredentialsService.instance;
    _initializeService();
  }

  Future<void> _initializeService() async {
    if (_disposed) return;

    try {
      if (!_disposed) {
        state = state.copyWith(isLoading: true);
      }

      await _service.initialize();

      if (!_disposed) {
        state = state.copyWith(
          isInitialized: true,
          isLoading: false,
          status: DatabaseConnectionStatus.disconnected,
        );
      }
    } catch (e) {
      if (!_disposed) {
        state = state.copyWith(
          isLoading: false,
          status: DatabaseConnectionStatus.error,
          errorMessage: 'Ошибка инициализации: ${e.toString()}',
        );
      }
    }
  }

  /// Открыть базу данных
  Future<void> openDatabase(String password) async {
    if (state.isLoading || _disposed) return;

    try {
      if (_disposed) return;
      state = state.copyWith(
        isLoading: true,
        status: DatabaseConnectionStatus.connecting,
        errorMessage: null,
      );

      await _service.openDatabase(password);
      await _loadDatabases();

      if (_disposed) return;
      state = state.copyWith(
        isDatabaseOpen: true,
        isLoading: false,
        status: DatabaseConnectionStatus.connected,
        currentDatabasePassword: password,
        lastActivity: DateTime.now(),
        errorMessage: null,
      );

      _startActivityTimer();
    } catch (e) {
      if (_disposed) return;
      final errorMessage = e is DatabaseError
          ? e.userFriendlyMessage
          : e.toString();
      state = state.copyWith(
        isDatabaseOpen: false,
        isLoading: false,
        status: DatabaseConnectionStatus.error,
        errorMessage: errorMessage,
        currentDatabasePassword: null,
      );
      rethrow;
    }
  }

  /// Закрыть базу данных
  Future<void> closeDatabase() async {
    if (state.isLoading) return;

    try {
      state = state.copyWith(isLoading: true);

      _stopActivityTimer();
      await _service.closeDatabase();

      state = state.copyWith(
        isDatabaseOpen: false,
        isLoading: false,
        status: DatabaseConnectionStatus.disconnected,
        databases: [],
        currentDatabasePassword: null,
        lastActivity: null,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Ошибка закрытия БД: ${e.toString()}',
      );
      rethrow;
    }
  }

  /// Заблокировать базу данных
  void lockDatabase() {
    _stopActivityTimer();
    _service.lockDatabase();

    state = state.copyWith(
      isDatabaseOpen: false,
      status: DatabaseConnectionStatus.locked,
      databases: [],
      currentDatabasePassword: null,
      lastActivity: null,
      errorMessage: null,
    );
  }

  /// Создать новую запись метаданных
  Future<DatabaseMetadata> createDatabaseMetadata({
    required String name,
    required String description,
    required String password,
  }) async {
    if (!state.isDatabaseOpen) {
      throw DatabaseError(
        code: 'DB_NOT_OPEN',
        message: 'База данных не открыта',
        timestamp: DateTime.now(),
        severity: ErrorSeverity.error,
      );
    }

    try {
      state = state.copyWith(isLoading: true);

      final metadata = await _service.createDatabaseMetadata(
        name: name,
        description: description,
        password: password,
      );

      await _loadDatabases();
      _updateActivity();

      state = state.copyWith(isLoading: false);
      return metadata;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Ошибка создания записи: ${e.toString()}',
      );
      rethrow;
    }
  }

  /// Загрузить все метаданные баз данных
  Future<void> _loadDatabases() async {
    if (!_service.isDatabaseOpen) return;

    try {
      final databases = await _service.getAllDatabaseMetadata();
      state = state.copyWith(databases: databases);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Ошибка загрузки данных: ${e.toString()}',
      );
    }
  }

  /// Обновить время последнего открытия
  Future<void> updateLastOpenedAt(int id) async {
    if (!state.isDatabaseOpen) return;

    try {
      await _service.updateLastOpenedAt(id);
      await _loadDatabases();
      _updateActivity();
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Ошибка обновления времени: ${e.toString()}',
      );
    }
  }

  /// Установить статус блокировки записи
  Future<void> setDatabaseLocked(int id, bool isLocked) async {
    if (!state.isDatabaseOpen) return;

    try {
      state = state.copyWith(isLoading: true);
      await _service.setDatabaseLocked(id, isLocked);
      await _loadDatabases();
      _updateActivity();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Ошибка изменения блокировки: ${e.toString()}',
      );
    }
  }

  /// Удалить запись метаданных
  Future<void> deleteDatabaseMetadata(int id) async {
    if (!state.isDatabaseOpen) return;

    try {
      state = state.copyWith(isLoading: true);
      await _service.deleteDatabaseMetadata(id);
      await _loadDatabases();
      _updateActivity();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Ошибка удаления записи: ${e.toString()}',
      );
    }
  }

  /// Проверить пароль
  bool verifyPassword(String password, String hash) {
    if (!state.isDatabaseOpen) return false;
    _updateActivity();
    return _service.verifyPassword(password, hash);
  }

  /// Очистить сообщение об ошибке
  void clearError() {
    if (_disposed) return;
    state = state.copyWith(errorMessage: null);
  }

  /// Принудительно обновить список баз данных
  Future<void> refreshDatabases() async {
    if (state.isDatabaseOpen) {
      await _loadDatabases();
      _updateActivity();
    }
  }

  /// Обновить активность пользователя
  void _updateActivity() {
    state = state.copyWith(lastActivity: DateTime.now());
    _resetActivityTimer();
  }

  /// Запустить таймер активности
  void _startActivityTimer() {
    _resetActivityTimer();
  }

  /// Сбросить таймер активности
  void _resetActivityTimer() {
    _stopActivityTimer();
    _activityTimer = Timer(const Duration(minutes: 15), () {
      lockDatabase();
    });
  }

  /// Остановить таймер активности
  void _stopActivityTimer() {
    _activityTimer?.cancel();
    _activityTimer = null;
  }

  /// Получить статистику по базам данных
  Map<String, int> get databaseStats {
    final databases = state.databases;
    return {
      'total': databases.length,
      'locked': databases.where((db) => db.isLocked).length,
      'unlocked': databases.where((db) => !db.isLocked).length,
    };
  }

  /// Проверить, была ли активность недавно
  bool get hasRecentActivity {
    final lastActivity = state.lastActivity;
    if (lastActivity == null) return false;

    final now = DateTime.now();
    const threshold = Duration(minutes: 5);
    return now.difference(lastActivity) < threshold;
  }

  /// Время до автоблокировки
  Duration? get timeUntilAutoLock {
    final lastActivity = state.lastActivity;
    if (lastActivity == null || !state.isDatabaseOpen) return null;

    const lockTimeout = Duration(minutes: 15);
    final elapsed = DateTime.now().difference(lastActivity);
    final remaining = lockTimeout - elapsed;

    return remaining.isNegative ? Duration.zero : remaining;
  }

  @override
  void dispose() {
    _disposed = true;
    _stopActivityTimer();
    _service.dispose();
    super.dispose();
  }
}

// Дополнительные провайдеры для удобства

/// Провайдер для статуса подключения к БД
final credentialsConnectionStatusProvider = Provider<DatabaseConnectionStatus>((
  ref,
) {
  return ref.watch(credentialsStoreProvider).status;
});

/// Провайдер для списка баз данных
final credentialsDatabasesProvider = Provider<List<DatabaseMetadata>>((ref) {
  return ref.watch(credentialsStoreProvider).databases;
});

/// Провайдер для статистики баз данных
final credentialsDatabaseStatsProvider = Provider<Map<String, int>>((ref) {
  final notifier = ref.watch(credentialsStoreProvider.notifier);
  ref.watch(credentialsStoreProvider); // Для обновления при изменении состояния
  return notifier.databaseStats;
});

/// Провайдер для проверки состояния загрузки
final credentialsIsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(credentialsStoreProvider).isLoading;
});

/// Провайдер для сообщения об ошибке
final credentialsErrorMessageProvider = Provider<String?>((ref) {
  return ref.watch(credentialsStoreProvider).errorMessage;
});

/// Провайдер для времени до автоблокировки
final credentialsTimeUntilAutoLockProvider = Provider<Duration?>((ref) {
  final notifier = ref.watch(credentialsStoreProvider.notifier);
  ref.watch(credentialsStoreProvider); // Для обновления при изменении состояния
  return notifier.timeUntilAutoLock;
});

/// Провайдер для проверки недавней активности
final credentialsHasRecentActivityProvider = Provider<bool>((ref) {
  final notifier = ref.watch(credentialsStoreProvider.notifier);
  ref.watch(credentialsStoreProvider); // Для обновления при изменении состояния
  return notifier.hasRecentActivity;
});

/// Провайдер для проверки инициализации
final credentialsIsInitializedProvider = Provider<bool>((ref) {
  return ref.watch(credentialsStoreProvider).isInitialized;
});

/// Провайдер для проверки открытия БД
final credentialsIsDatabaseOpenProvider = Provider<bool>((ref) {
  return ref.watch(credentialsStoreProvider).isDatabaseOpen;
});
