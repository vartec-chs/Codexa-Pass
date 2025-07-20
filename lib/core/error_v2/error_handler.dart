/// Продвинутый обработчик ошибок v2 с поддержкой восстановления,
/// аналитики, уведомлений и автоматического логирования

import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

import 'error_base.dart';
import 'error_types.dart';
import 'result.dart';

/// Интерфейс для логгера ошибок
abstract class ErrorLoggerV2 {
  Future<void> logError(AppErrorV2 error);
  Future<void> logInfo(String message, {Map<String, Object?>? context});
  Future<void> logWarning(String message, {Map<String, Object?>? context});
}

/// Интерфейс для отправки аналитики
abstract class ErrorAnalyticsV2 {
  Future<void> trackError(AppErrorV2 error, ErrorAnalyticsData analyticsData);
  Future<void> trackRecovery(AppErrorV2 error, bool successful);
  Future<void> trackRetry(AppErrorV2 error, int attemptNumber);
}

/// Интерфейс для показа уведомлений пользователю
abstract class ErrorNotificationV2 {
  Future<void> showError(AppErrorV2 error);
  Future<void> showRecoverySuccess(AppErrorV2 error);
  Future<void> showRecoveryFailure(AppErrorV2 error);
}

/// Интерфейс для стратегий восстановления
abstract class RecoveryHandlerV2 {
  Future<ResultV2<bool>> tryRecover(AppErrorV2 error);
  bool canHandle(AppErrorV2 error);
}

/// Основной обработчик ошибок v2
class ErrorHandlerV2 {
  final ErrorLoggerV2? _logger;
  final ErrorAnalyticsV2? _analytics;
  final ErrorNotificationV2? _notification;
  final List<RecoveryHandlerV2> _recoveryHandlers;
  final Map<String, int> _retryAttempts = {};
  final Map<String, DateTime> _lastRetryTime = {};
  final StreamController<AppErrorV2> _errorStream =
      StreamController.broadcast();

  ErrorHandlerV2({
    ErrorLoggerV2? logger,
    ErrorAnalyticsV2? analytics,
    ErrorNotificationV2? notification,
    List<RecoveryHandlerV2>? recoveryHandlers,
  }) : _logger = logger,
       _analytics = analytics,
       _notification = notification,
       _recoveryHandlers = recoveryHandlers ?? [];

  /// Поток всех обработанных ошибок
  Stream<AppErrorV2> get errorStream => _errorStream.stream;

  /// Обработка ошибки с полным циклом восстановления
  Future<ResultV2<T>> handleError<T>(
    AppErrorV2 error, {
    T? fallbackValue,
    bool shouldAttemptRecovery = true,
    bool shouldNotifyUser = true,
    ErrorAnalyticsData? analyticsData,
  }) async {
    // Логирование ошибки
    await _logError(error);

    // Отправка в аналитику
    if (analyticsData != null && error.shouldTrack) {
      await _trackError(error, analyticsData);
    }

    // Добавление в поток ошибок
    _errorStream.add(error);

    // Попытка восстановления
    if (shouldAttemptRecovery && error.isRecoverable) {
      final recoveryResult = await _attemptRecovery(error, analyticsData);
      if (recoveryResult.isSuccess) {
        if (fallbackValue != null) {
          return SuccessV2(fallbackValue);
        }
      }
    }

    // Уведомление пользователя
    if (shouldNotifyUser && error.shouldDisplay) {
      await _notifyUser(error);
    }

    return FailureV2(error);
  }

  /// Выполнение операции с автоматической обработкой ошибок
  Future<ResultV2<T>> executeWithErrorHandling<T>(
    Future<T> Function() operation, {
    String? operationName,
    Map<String, Object?>? context,
    T? fallbackValue,
    bool shouldAttemptRecovery = true,
    bool shouldNotifyUser = true,
    ErrorAnalyticsData? analyticsData,
    AppErrorV2 Function(Object error, StackTrace stackTrace)? errorMapper,
  }) async {
    try {
      final result = await operation();
      return SuccessV2(result);
    } catch (error, stackTrace) {
      AppErrorV2 appError;

      if (error is AppErrorV2) {
        appError = error;
      } else {
        appError =
            errorMapper?.call(error, stackTrace) ??
            _createUnknownError(error, stackTrace, operationName, context);
      }

      return await handleError<T>(
        appError,
        fallbackValue: fallbackValue,
        shouldAttemptRecovery: shouldAttemptRecovery,
        shouldNotifyUser: shouldNotifyUser,
        analyticsData: analyticsData,
      );
    }
  }

  /// Выполнение операции с повторными попытками
  Future<ResultV2<T>> executeWithRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 1),
    bool useExponentialBackoff = false,
    String? operationName,
    Map<String, Object?>? context,
    ErrorAnalyticsData? analyticsData,
    bool Function(AppErrorV2 error)? shouldRetry,
  }) async {
    int attempts = 0;
    Duration currentDelay = retryDelay;

    while (attempts <= maxRetries) {
      final result = await executeWithErrorHandling(
        operation,
        operationName: operationName,
        context: context,
        shouldAttemptRecovery: false,
        shouldNotifyUser: attempts == maxRetries,
        analyticsData: analyticsData,
      );

      if (result.isSuccess) {
        return result;
      }

      final error = result.error!;

      // Отслеживание попытки в аналитике
      if (analyticsData != null && attempts > 0) {
        await _analytics?.trackRetry(error, attempts);
      }

      attempts++;

      // Проверка, нужно ли повторять
      if (attempts > maxRetries ||
          (shouldRetry != null && !shouldRetry(error))) {
        return result;
      }

      // Задержка перед следующей попыткой
      if (attempts <= maxRetries) {
        await Future.delayed(currentDelay);

        if (useExponentialBackoff) {
          currentDelay = Duration(
            milliseconds: (currentDelay.inMilliseconds * 1.5).round(),
          );
        }
      }
    }

    return FailureV2(
      _createUnknownError(
        'Превышено максимальное количество попыток',
        StackTrace.current,
        operationName,
        context,
      ),
    );
  }

  /// Попытка восстановления после ошибки
  Future<ResultV2<bool>> _attemptRecovery(
    AppErrorV2 error,
    ErrorAnalyticsData? analyticsData,
  ) async {
    // Проверка ограничений на повторные попытки
    if (!_canRetry(error)) {
      return FailureV2(error);
    }

    _incrementRetryAttempt(error);

    // Поиск подходящего обработчика восстановления
    for (final handler in _recoveryHandlers) {
      if (handler.canHandle(error)) {
        try {
          final result = await handler.tryRecover(error);

          // Отслеживание результата восстановления
          if (analyticsData != null) {
            await _analytics?.trackRecovery(error, result.isSuccess);
          }

          if (result.isSuccess) {
            await _notification?.showRecoverySuccess(error);
            return result;
          }
        } catch (recoveryError, stackTrace) {
          await _logError(
            _createUnknownError(
              'Ошибка при попытке восстановления',
              stackTrace,
              'recovery_${error.type}',
              {'originalError': error.toJson()},
            ),
          );
        }
      }
    }

    // Общие стратегии восстановления
    switch (error.recoveryStrategy) {
      case RecoveryStrategyV2.retry:
        if (error.retryDelay > Duration.zero) {
          await Future.delayed(error.retryDelay);
        }
        return SuccessV2(true);

      case RecoveryStrategyV2.retryWithBackoff:
        final attempt = _getRetryAttempt(error);
        final delay = Duration(
          milliseconds: (error.retryDelay.inMilliseconds * (1 + attempt * 0.5))
              .round(),
        );
        await Future.delayed(delay);
        return SuccessV2(true);

      case RecoveryStrategyV2.fallback:
        // Логика переключения на резервный механизм
        await _logger?.logInfo(
          'Переключение на резервный механизм',
          context: {'error': error.toJson()},
        );
        return SuccessV2(true);

      case RecoveryStrategyV2.reset:
        // Логика сброса состояния
        await _logger?.logInfo(
          'Сброс состояния компонента',
          context: {'error': error.toJson()},
        );
        return SuccessV2(true);

      default:
        return FailureV2(error);
    }
  }

  /// Проверка возможности повторной попытки
  bool _canRetry(AppErrorV2 error) {
    final attempts = _getRetryAttempt(error);
    if (attempts >= error.maxRetryAttempts) {
      return false;
    }

    final lastRetry = _lastRetryTime[error.id];
    if (lastRetry != null) {
      final timeSinceLastRetry = DateTime.now().difference(lastRetry);
      if (timeSinceLastRetry < error.retryDelay) {
        return false;
      }
    }

    return true;
  }

  /// Увеличение счетчика попыток
  void _incrementRetryAttempt(AppErrorV2 error) {
    _retryAttempts[error.id] = (_retryAttempts[error.id] ?? 0) + 1;
    _lastRetryTime[error.id] = DateTime.now();
  }

  /// Получение количества попыток
  int _getRetryAttempt(AppErrorV2 error) {
    return _retryAttempts[error.id] ?? 0;
  }

  /// Логирование ошибки
  Future<void> _logError(AppErrorV2 error) async {
    try {
      await _logger?.logError(error);

      // Дополнительное логирование для критических ошибок
      if (error.severity.isCritical && kDebugMode) {
        developer.log(
          error.message,
          name: 'ErrorHandlerV2',
          error: error.originalError,
          stackTrace: error.stackTrace,
          level: _getLogLevel(error.severity),
        );
      }
    } catch (loggingError) {
      // Избегаем бесконечной рекурсии при ошибках логирования
      if (kDebugMode) {
        developer.log(
          'Ошибка при логировании: $loggingError',
          name: 'ErrorHandlerV2',
          level: 1000, // WARNING level
        );
      }
    }
  }

  /// Отправка в аналитику
  Future<void> _trackError(
    AppErrorV2 error,
    ErrorAnalyticsData analyticsData,
  ) async {
    try {
      await _analytics?.trackError(error, analyticsData);
    } catch (analyticsError) {
      await _logger?.logWarning(
        'Ошибка при отправке аналитики',
        context: {
          'originalError': error.toJson(),
          'analyticsError': analyticsError.toString(),
        },
      );
    }
  }

  /// Уведомление пользователя
  Future<void> _notifyUser(AppErrorV2 error) async {
    try {
      await _notification?.showError(error);
    } catch (notificationError) {
      await _logger?.logWarning(
        'Ошибка при показе уведомления',
        context: {
          'originalError': error.toJson(),
          'notificationError': notificationError.toString(),
        },
      );
    }
  }

  /// Создание неизвестной ошибки
  AppErrorV2 _createUnknownError(
    Object error,
    StackTrace stackTrace,
    String? operationName,
    Map<String, Object?>? context,
  ) {
    return UnknownErrorV2(
      message:
          'Неожиданная ошибка${operationName != null ? ' в $operationName' : ''}',
      technicalDetails: error.toString(),
      context: {
        ...?context,
        'errorType': error.runtimeType.toString(),
        'operation': operationName,
      },
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  /// Получение уровня логирования
  int _getLogLevel(ErrorSeverityV2 severity) {
    switch (severity) {
      case ErrorSeverityV2.info:
        return 800; // INFO
      case ErrorSeverityV2.warning:
        return 900; // WARNING
      case ErrorSeverityV2.error:
        return 1000; // SEVERE
      case ErrorSeverityV2.critical:
      case ErrorSeverityV2.fatal:
        return 1200; // SHOUT
    }
  }

  /// Очистка старых данных о попытках
  void clearRetryData({Duration? olderThan}) {
    final cutoff = DateTime.now().subtract(
      olderThan ?? const Duration(hours: 1),
    );

    final expiredIds = _lastRetryTime.entries
        .where((entry) => entry.value.isBefore(cutoff))
        .map((entry) => entry.key)
        .toList();

    for (final id in expiredIds) {
      _retryAttempts.remove(id);
      _lastRetryTime.remove(id);
    }
  }

  /// Добавление обработчика восстановления
  void addRecoveryHandler(RecoveryHandlerV2 handler) {
    _recoveryHandlers.add(handler);
  }

  /// Удаление обработчика восстановления
  void removeRecoveryHandler(RecoveryHandlerV2 handler) {
    _recoveryHandlers.remove(handler);
  }

  /// Получение статистики ошибок
  Map<String, Object> getErrorStats() {
    return {
      'totalErrorsTracked': _retryAttempts.length,
      'activeRetryAttempts': _retryAttempts.values.reduce((a, b) => a + b),
      'recoveryHandlersCount': _recoveryHandlers.length,
      'retryAttempts': Map.from(_retryAttempts),
      'lastRetryTimes': _lastRetryTime.map(
        (k, v) => MapEntry(k, v.toIso8601String()),
      ),
    };
  }

  /// Закрытие обработчика и освобождение ресурсов
  Future<void> dispose() async {
    await _errorStream.close();
    _retryAttempts.clear();
    _lastRetryTime.clear();
    _recoveryHandlers.clear();
  }
}

/// Базовый обработчик восстановления для аутентификации
class AuthRecoveryHandlerV2 implements RecoveryHandlerV2 {
  @override
  bool canHandle(AppErrorV2 error) {
    return error is AuthenticationErrorV2 &&
        error.errorType == AuthenticationErrorType.sessionExpired;
  }

  @override
  Future<ResultV2<bool>> tryRecover(AppErrorV2 error) async {
    // Логика восстановления сессии
    await Future.delayed(const Duration(seconds: 1)); // Имитация запроса
    return SuccessV2(true);
  }
}

/// Базовый обработчик восстановления для сетевых ошибок
class NetworkRecoveryHandlerV2 implements RecoveryHandlerV2 {
  @override
  bool canHandle(AppErrorV2 error) {
    return error is NetworkErrorV2 &&
        (error.errorType == NetworkErrorType.noConnection ||
            error.errorType == NetworkErrorType.timeout);
  }

  @override
  Future<ResultV2<bool>> tryRecover(AppErrorV2 error) async {
    // Логика проверки сетевого соединения
    await Future.delayed(const Duration(seconds: 2)); // Имитация проверки
    return SuccessV2(true);
  }
}

/// Глобальный экземпляр обработчика ошибок
ErrorHandlerV2? _globalErrorHandler;

/// Получение глобального обработчика ошибок
ErrorHandlerV2 getGlobalErrorHandler() {
  return _globalErrorHandler ??= ErrorHandlerV2();
}

/// Установка глобального обработчика ошибок
void setGlobalErrorHandler(ErrorHandlerV2 handler) {
  _globalErrorHandler = handler;
}

/// Удобные функции для быстрого использования
extension QuickErrorHandling on ErrorHandlerV2 {
  /// Быстрое выполнение с обработкой ошибок
  Future<ResultV2<T>> execute<T>(Future<T> Function() operation) async {
    return executeWithErrorHandling(operation);
  }

  /// Быстрое выполнение с повторными попытками
  Future<ResultV2<T>> retry<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
  }) async {
    return executeWithRetry(operation, maxRetries: maxRetries);
  }
}
