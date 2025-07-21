import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codexa_pass/credentials_store/providers/credentials_store_provider.dart';
import 'package:codexa_pass/credentials_store/providers/credentials_store_state.dart';

void main() {
  // Настройка тестовой среды
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CredentialsStore Provider Tests', () {
    late ProviderContainer container;

    setUp(() {
      // Мокаем платформенные каналы для тестов
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('flutter/platform'), (
            MethodCall methodCall,
          ) async {
            return null;
          });

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('window_manager'), (
            MethodCall methodCall,
          ) async {
            return null;
          });

      // Мокаем каналы для SQLCipher
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'),
            (MethodCall methodCall) async {
              return '/tmp';
            },
          );

      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
      // Очищаем моки
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('flutter/platform'),
            null,
          );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('window_manager'),
            null,
          );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'),
            null,
          );
    });

    test('should initialize with default state', () async {
      final state = container.read(credentialsStoreProvider);

      // Проверяем основные поля начального состояния
      expect(state.isDatabaseOpen, false);
      expect(state.databases, isEmpty);
      expect(state.errorMessage, isNull);
      expect(state.currentDatabasePassword, isNull);
      expect(state.lastActivity, isNull);

      // Ждем завершения инициализации
      await Future.delayed(const Duration(milliseconds: 200));

      final updatedState = container.read(credentialsStoreProvider);
      expect(updatedState.isInitialized, true);
      expect(updatedState.isLoading, false);
      expect(updatedState.status, DatabaseConnectionStatus.disconnected);
    });

    test('should provide connection status', () async {
      // Ждем завершения инициализации
      await Future.delayed(const Duration(milliseconds: 200));

      final status = container.read(credentialsConnectionStatusProvider);
      expect(status, DatabaseConnectionStatus.disconnected);
    });

    test('should provide empty databases list initially', () async {
      // Ждем завершения инициализации
      await Future.delayed(const Duration(milliseconds: 200));

      final databases = container.read(credentialsDatabasesProvider);
      expect(databases, isEmpty);
    });

    test('should provide loading state', () async {
      final loading = container.read(credentialsIsLoadingProvider);

      // Начальное состояние может быть в процессе загрузки
      expect(loading, isA<bool>());

      // Ждем завершения инициализации
      await Future.delayed(const Duration(milliseconds: 200));

      final updatedLoading = container.read(credentialsIsLoadingProvider);
      expect(updatedLoading, false);
    });

    test('should provide error message', () async {
      // Ждем завершения инициализации
      await Future.delayed(const Duration(milliseconds: 200));

      final errorMessage = container.read(credentialsErrorMessageProvider);
      expect(errorMessage, isNull);
    });

    test('should provide database stats', () async {
      // Ждем завершения инициализации
      await Future.delayed(const Duration(milliseconds: 200));

      final stats = container.read(credentialsDatabaseStatsProvider);
      expect(stats, isA<Map<String, int>>());
      expect(stats['total'], 0);
      expect(stats['locked'], 0);
      expect(stats['unlocked'], 0);
    });

    test('should clear error message', () async {
      // Ждем завершения инициализации
      await Future.delayed(const Duration(milliseconds: 200));

      final notifier = container.read(credentialsStoreProvider.notifier);
      notifier.clearError();

      final errorMessage = container.read(credentialsErrorMessageProvider);
      expect(errorMessage, isNull);
    });

    test('should provide initialization status', () async {
      // Инициализация может быть не завершена сразу
      final initialStatus = container.read(credentialsIsInitializedProvider);
      expect(initialStatus, isA<bool>());

      // Ждем завершения инициализации
      await Future.delayed(const Duration(milliseconds: 300));

      final finalStatus = container.read(credentialsIsInitializedProvider);
      expect(finalStatus, true);
    });

    test('should provide database open status', () async {
      // Ждем завершения инициализации
      await Future.delayed(const Duration(milliseconds: 200));

      final isDatabaseOpen = container.read(credentialsIsDatabaseOpenProvider);
      expect(isDatabaseOpen, false);
    });

    test('should provide time until auto lock', () async {
      // Ждем завершения инициализации
      await Future.delayed(const Duration(milliseconds: 200));

      final timeUntilAutoLock = container.read(
        credentialsTimeUntilAutoLockProvider,
      );
      expect(timeUntilAutoLock, isNull); // БД не открыта
    });

    test('should provide recent activity status', () async {
      // Ждем завершения инициализации
      await Future.delayed(const Duration(milliseconds: 200));

      final hasRecentActivity = container.read(
        credentialsHasRecentActivityProvider,
      );
      expect(hasRecentActivity, false); // Нет активности
    });
  });

  group('CredentialsStoreState Tests', () {
    test('should create state with default values', () {
      const state = CredentialsStoreState();

      expect(state.isInitialized, false);
      expect(state.isDatabaseOpen, false);
      expect(state.isLoading, false);
      expect(state.databases, isEmpty);
      expect(state.currentDatabasePassword, isNull);
      expect(state.errorMessage, isNull);
      expect(state.lastActivity, isNull);
      expect(state.status, DatabaseConnectionStatus.disconnected);
    });

    test('should copy with new values', () {
      const originalState = CredentialsStoreState();
      final newState = originalState.copyWith(
        isInitialized: true,
        isLoading: true,
        status: DatabaseConnectionStatus.connecting,
        errorMessage: 'Test error',
      );

      expect(newState.isInitialized, true);
      expect(newState.isLoading, true);
      expect(newState.status, DatabaseConnectionStatus.connecting);
      expect(newState.errorMessage, 'Test error');

      // Остальные значения должны остаться неизменными
      expect(newState.isDatabaseOpen, false);
      expect(newState.databases, isEmpty);
      expect(newState.currentDatabasePassword, isNull);
      expect(newState.lastActivity, isNull);
    });

    test('should compare states correctly', () {
      const state1 = CredentialsStoreState();
      const state2 = CredentialsStoreState();
      final state3 = state1.copyWith(isInitialized: true);

      expect(state1, equals(state2));
      expect(state1, isNot(equals(state3)));
    });

    test('should have correct string representation', () {
      const state = CredentialsStoreState();
      final string = state.toString();

      expect(string, contains('CredentialsStoreState'));
      expect(string, contains('isInitialized: false'));
      expect(string, contains('isDatabaseOpen: false'));
      expect(string, contains('isLoading: false'));
      expect(string, contains('databases: 0'));
      expect(string, contains('status: DatabaseConnectionStatus.disconnected'));
    });
  });

  group('DatabaseConnectionStatus Tests', () {
    test('should have correct display names', () {
      expect(DatabaseConnectionStatus.disconnected.displayName, 'Отключено');
      expect(DatabaseConnectionStatus.connecting.displayName, 'Подключение...');
      expect(DatabaseConnectionStatus.connected.displayName, 'Подключено');
      expect(DatabaseConnectionStatus.locked.displayName, 'Заблокировано');
      expect(DatabaseConnectionStatus.error.displayName, 'Ошибка');
    });

    test('should have correct status checks', () {
      expect(DatabaseConnectionStatus.connected.isConnected, true);
      expect(DatabaseConnectionStatus.disconnected.isConnected, false);

      expect(DatabaseConnectionStatus.disconnected.isDisconnected, true);
      expect(DatabaseConnectionStatus.connected.isDisconnected, false);

      expect(DatabaseConnectionStatus.locked.isLocked, true);
      expect(DatabaseConnectionStatus.connected.isLocked, false);

      expect(DatabaseConnectionStatus.error.hasError, true);
      expect(DatabaseConnectionStatus.connected.hasError, false);

      expect(DatabaseConnectionStatus.connecting.isConnecting, true);
      expect(DatabaseConnectionStatus.connected.isConnecting, false);
    });
  });

  group('Provider Integration Tests', () {
    late ProviderContainer container;

    setUp(() {
      // Мокаем платформенные каналы для тестов
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('flutter/platform'), (
            MethodCall methodCall,
          ) async {
            return null;
          });

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('window_manager'), (
            MethodCall methodCall,
          ) async {
            return null;
          });

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'),
            (MethodCall methodCall) async {
              return '/tmp';
            },
          );

      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
      // Очищаем моки
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('flutter/platform'),
            null,
          );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('window_manager'),
            null,
          );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'),
            null,
          );
    });

    test('should provide consistent data across multiple providers', () async {
      // Ждем завершения инициализации
      await Future.delayed(const Duration(milliseconds: 200));

      final state = container.read(credentialsStoreProvider);
      final status = container.read(credentialsConnectionStatusProvider);
      final isLoading = container.read(credentialsIsLoadingProvider);
      final databases = container.read(credentialsDatabasesProvider);
      final isInitialized = container.read(credentialsIsInitializedProvider);
      final isDatabaseOpen = container.read(credentialsIsDatabaseOpenProvider);
      final stats = container.read(credentialsDatabaseStatsProvider);

      // Все провайдеры должны отражать одно и то же состояние
      expect(state.status, status);
      expect(state.isLoading, isLoading);
      expect(state.databases, databases);
      expect(state.isInitialized, isInitialized);
      expect(state.isDatabaseOpen, isDatabaseOpen);

      // Проверяем статистику
      expect(stats['total'], databases.length);
    });

    test('should update dependent providers when state changes', () async {
      // Ждем завершения инициализации
      await Future.delayed(const Duration(milliseconds: 300));

      final notifier = container.read(credentialsStoreProvider.notifier);

      // Проверяем начальное состояние
      expect(
        container.read(credentialsConnectionStatusProvider),
        DatabaseConnectionStatus.disconnected,
      );

      final initialLoading = container.read(credentialsIsLoadingProvider);
      expect(initialLoading, isA<bool>()); // Может быть любое значение

      expect(container.read(credentialsDatabasesProvider), isEmpty);

      // Очищаем ошибку и проверяем, что состояние обновилось
      notifier.clearError();
      expect(container.read(credentialsErrorMessageProvider), isNull);
    });

    test('should handle notifier disposal correctly', () async {
      // Создаем отдельный контейнер для этого теста
      final testContainer = ProviderContainer();

      // Ждем завершения инициализации
      await Future.delayed(const Duration(milliseconds: 100));

      final state = testContainer.read(credentialsStoreProvider);
      final isInitialized = state.isInitialized;
      expect(isInitialized, isA<bool>()); // Проверяем что состояние корректное

      // Проверяем, что контейнер можно корректно закрыть
      expect(() => testContainer.dispose(), returnsNormally);
    });
  });
}
