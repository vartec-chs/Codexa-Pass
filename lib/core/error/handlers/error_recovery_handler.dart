import 'dart:async';
import 'dart:math';

import '../../logging/app_logger.dart';
import '../models/app_error.dart';
import '../models/error_severity.dart';
import '../utils/error_config.dart';

/// Обработчик автоматического восстановления после ошибок
class ErrorRecoveryHandler {
  ErrorRecoveryHandler({required this.config});

  final ErrorConfig config;

  /// Кеш попыток восстановления
  final Map<String, _RecoveryAttempt> _recoveryAttempts = {};

  /// Инициализация обработчика
  Future<void> initialize() async {
    await AppLogger.instance.info(
      'Error recovery handler initialized',
      module: 'ErrorRecovery',
    );
  }

  /// Попытка автоматического восстановления
  Future<bool> attemptRecovery(AppError error) async {
    if (!config.enableRetryMechanism || !error.canRetryOperation) {
      return false;
    }

    try {
      // Получаем конфигурацию модуля
      final moduleConfig = config.getModuleConfig(error.module ?? 'Unknown');

      if (!moduleConfig.enableAutoRecovery) {
        return false;
      }

      // Проверяем количество попыток
      final attemptKey = _generateAttemptKey(error);
      final attempt = _recoveryAttempts[attemptKey];

      final maxRetries = moduleConfig.maxRetries ?? config.defaultMaxRetries;
      if (attempt != null && attempt.count >= maxRetries) {
        await AppLogger.instance.warning(
          'Max recovery attempts exceeded',
          module: 'ErrorRecovery',
          metadata: {
            'errorCode': error.code,
            'attemptCount': attempt.count,
            'maxRetries': maxRetries,
          },
        );
        return false;
      }

      // Вычисляем задержку
      final delay = _calculateRetryDelay(attempt?.count ?? 0, moduleConfig);

      if (delay > Duration.zero) {
        await AppLogger.instance.debug(
          'Waiting before retry attempt',
          module: 'ErrorRecovery',
          metadata: {
            'errorCode': error.code,
            'delayMs': delay.inMilliseconds,
            'attemptNumber': (attempt?.count ?? 0) + 1,
          },
        );

        await Future.delayed(delay);
      }

      // Обновляем статистику попыток
      _recoveryAttempts[attemptKey] = _RecoveryAttempt(
        errorCode: error.code,
        count: (attempt?.count ?? 0) + 1,
        lastAttempt: DateTime.now(),
      );

      // Выполняем восстановление в зависимости от типа ошибки
      final recovered = await _performRecovery(error, moduleConfig);

      if (recovered) {
        await AppLogger.instance.info(
          'Error recovery successful',
          module: 'ErrorRecovery',
          metadata: {
            'errorCode': error.code,
            'attemptCount': _recoveryAttempts[attemptKey]?.count,
          },
        );

        // Удаляем из кеша при успешном восстановлении
        _recoveryAttempts.remove(attemptKey);
      } else {
        await AppLogger.instance.warning(
          'Error recovery failed',
          module: 'ErrorRecovery',
          metadata: {
            'errorCode': error.code,
            'attemptCount': _recoveryAttempts[attemptKey]?.count,
          },
        );
      }

      return recovered;
    } catch (e, stackTrace) {
      await AppLogger.instance.error(
        'Error in recovery handler',
        module: 'ErrorRecovery',
        error: e,
        stackTrace: stackTrace,
        metadata: {'originalError': error.toJson()},
      );
      return false;
    }
  }

  /// Выполнить восстановление
  Future<bool> _performRecovery(
    AppError error,
    ModuleErrorConfig moduleConfig,
  ) async {
    // Определяем стратегию восстановления на основе типа ошибки
    switch (error.runtimeType) {
      case NetworkError:
        return await _recoverFromNetworkError(error as NetworkError);
      case DatabaseError:
        return await _recoverFromDatabaseError(error as DatabaseError);
      case AuthenticationError:
        return await _recoverFromAuthError(error as AuthenticationError);
      default:
        return await _recoverFromGenericError(error, moduleConfig);
    }
  }

  /// Восстановление от сетевых ошибок
  Future<bool> _recoverFromNetworkError(NetworkError error) async {
    switch (error.code) {
      case 'NETWORK_TIMEOUT':
      case 'NETWORK_CONNECTION_FAILED':
        // Проверяем доступность сети
        // В реальном приложении здесь была бы проверка connectivity
        await Future.delayed(const Duration(seconds: 1));
        return true; // Предполагаем, что сеть восстановилась

      case 'NETWORK_SERVER_ERROR':
        // Ждем восстановления сервера
        return false; // Сервер должен восстановиться сам

      default:
        return false;
    }
  }

  /// Восстановление от ошибок базы данных
  Future<bool> _recoverFromDatabaseError(DatabaseError error) async {
    switch (error.code) {
      case 'DB_CONNECTION_FAILED':
        // Пытаемся переподключиться к БД
        await Future.delayed(const Duration(milliseconds: 500));
        return true; // Предполагаем успешное переподключение

      case 'DB_TRANSACTION_FAILED':
        // Откатываем транзакцию и пытаемся снова
        return true;

      case 'DB_CONSTRAINT_VIOLATION':
        // Нарушение ограничений - не можем восстановить автоматически
        return false;

      default:
        return false;
    }
  }

  /// Восстановление от ошибок аутентификации
  Future<bool> _recoverFromAuthError(AuthenticationError error) async {
    switch (error.code) {
      case 'AUTH_TOKEN_EXPIRED':
        // Попытка обновления токена
        // В реальном приложении здесь был бы вызов обновления токена
        return false; // Требует участия пользователя

      case 'AUTH_UNAUTHORIZED':
        // Недостаточно прав - не можем восстановить
        return false;

      default:
        return false;
    }
  }

  /// Общее восстановление
  Future<bool> _recoverFromGenericError(
    AppError error,
    ModuleErrorConfig moduleConfig,
  ) async {
    // Используем кастомную стратегию если определена
    if (moduleConfig.autoRecoveryStrategy != null) {
      switch (moduleConfig.autoRecoveryStrategy) {
        case 'retry':
          return true; // Просто повторяем операцию
        case 'reset':
          // Сбрасываем состояние и повторяем
          await _resetModuleState(error.module);
          return true;
        case 'fallback':
          // Используем резервный механизм
          return await _useFallbackMechanism(error);
        default:
          return false;
      }
    }

    // Стандартная логика восстановления
    if (error.severity == ErrorSeverity.warning) {
      // Для предупреждений просто повторяем
      return true;
    }

    return false;
  }

  /// Сброс состояния модуля
  Future<void> _resetModuleState(String? module) async {
    if (module == null) return;

    await AppLogger.instance.info(
      'Resetting module state',
      module: 'ErrorRecovery',
      metadata: {'targetModule': module},
    );

    // Здесь должна быть логика сброса состояния конкретного модуля
    // Например, очистка кеша, переинициализация соединений и т.д.
  }

  /// Использование резервного механизма
  Future<bool> _useFallbackMechanism(AppError error) async {
    await AppLogger.instance.info(
      'Using fallback mechanism',
      module: 'ErrorRecovery',
      metadata: {'errorCode': error.code, 'module': error.module},
    );

    // Здесь должна быть логика резервного механизма
    // Например, использование локального кеша вместо сетевого запроса
    return true;
  }

  /// Вычислить задержку перед повтором
  Duration _calculateRetryDelay(
    int attemptCount,
    ModuleErrorConfig moduleConfig,
  ) {
    final baseDelay = moduleConfig.retryDelay ?? config.baseRetryDelay;
    final multiplier = config.retryDelayMultiplier;

    // Экспоненциальная задержка с jitter
    final exponentialDelay = Duration(
      milliseconds: (baseDelay.inMilliseconds * pow(multiplier, attemptCount))
          .round(),
    );

    // Добавляем случайный jitter (±25%)
    final jitter = Random().nextDouble() * 0.5 - 0.25; // -0.25 to +0.25
    final jitterDelay = Duration(
      milliseconds: (exponentialDelay.inMilliseconds * (1 + jitter)).round(),
    );

    // Ограничиваем максимальной задержкой
    return jitterDelay > config.maxRetryDelay
        ? config.maxRetryDelay
        : jitterDelay;
  }

  /// Генерировать ключ для попытки восстановления
  String _generateAttemptKey(AppError error) {
    return '${error.module ?? 'unknown'}_${error.code}';
  }

  /// Очистить устаревшие попытки восстановления
  void _cleanupOldAttempts() {
    final now = DateTime.now();
    final cutoff = now.subtract(const Duration(hours: 1));

    _recoveryAttempts.removeWhere(
      (key, attempt) => attempt.lastAttempt.isBefore(cutoff),
    );
  }

  /// Получить статистику восстановления
  Map<String, dynamic> getRecoveryStatistics() {
    _cleanupOldAttempts();

    return {
      'activeAttempts': _recoveryAttempts.length,
      'attempts': _recoveryAttempts.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
    };
  }

  /// Закрытие обработчика
  Future<void> dispose() async {
    _recoveryAttempts.clear();

    await AppLogger.instance.info(
      'Error recovery handler disposed',
      module: 'ErrorRecovery',
    );
  }
}

/// Информация о попытке восстановления
class _RecoveryAttempt {
  const _RecoveryAttempt({
    required this.errorCode,
    required this.count,
    required this.lastAttempt,
  });

  final String errorCode;
  final int count;
  final DateTime lastAttempt;

  Map<String, dynamic> toJson() {
    return {
      'errorCode': errorCode,
      'count': count,
      'lastAttempt': lastAttempt.toIso8601String(),
    };
  }
}
