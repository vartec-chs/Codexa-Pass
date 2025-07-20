import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_error.dart';
import '../models/error_severity.dart';
import '../models/error_display_type.dart';
import '../utils/error_config.dart';
import '../utils/error_formatter.dart';
import '../handlers/error_handler.dart';
import '../handlers/error_recovery_handler.dart';
import '../handlers/error_analytics_handler.dart';
import '../ui/global_error_details_service.dart';
import 'error_queue_controller.dart';

/// Основной контроллер системы обработки ошибок
class ErrorController {
  ErrorController({
    required this.config,
    required this.formatter,
    this.queueController,
  }) {
    _queueController = queueController ?? ErrorQueueController(config: config);
    _initializeHandlers();
  }

  final ErrorConfig config;
  final ErrorFormatter formatter;
  ErrorQueueController? queueController;
  late final ErrorQueueController _queueController;

  /// Обработчики ошибок
  late final ErrorHandler _errorHandler;
  late final ErrorRecoveryHandler _recoveryHandler;
  late final ErrorAnalyticsHandler _analyticsHandler;

  /// Контроллер для уведомлений пользователя
  final StreamController<ErrorNotification> _notificationController =
      StreamController<ErrorNotification>.broadcast();

  /// Кеш для Circuit Breaker
  final Map<String, _CircuitBreakerState> _circuitBreakers = {};

  /// История ошибок для просмотра деталей
  final List<AppError> _errorHistory = [];
  final Map<String, AppError> _persistedErrors = {};

  /// Контроллер для уведомлений об изменениях истории
  final StreamController<List<AppError>> _historyController =
      StreamController<List<AppError>>.broadcast();

  /// Флаг инициализации
  bool _isInitialized = false;

  /// Стрим истории ошибок для UI
  Stream<List<AppError>> get historyStream => _historyController.stream;

  /// Стрим уведомлений для UI
  Stream<ErrorNotification> get notificationStream =>
      _notificationController.stream;

  /// Статистика обработки ошибок
  Map<String, dynamic> get statistics => {
    'queueController': _queueController.statistics,
    'circuitBreakers': _circuitBreakers.map(
      (key, value) => MapEntry(key, value.toJson()),
    ),
    'isInitialized': _isInitialized,
  };

  /// Инициализация контроллера
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _queueController.initialize();
    await _errorHandler.initialize();
    await _recoveryHandler.initialize();

    if (config.enableAnalytics) {
      await _analyticsHandler.initialize();
    }

    // Подписываемся на ошибки из очереди
    _queueController.addErrorHandler(_handleError);

    // Отправляем начальное состояние истории
    _historyController.add(List.unmodifiable(_errorHistory));

    _isInitialized = true;
  }

  /// Обработать ошибку
  Future<void> handleError(AppError error) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Сразу сохраняем в историю при получении любой ошибки
    persistError(error);

    // Проверяем Circuit Breaker
    if (config.enableCircuitBreaker && error.module != null) {
      if (_isCircuitBreakerOpen(error.module!)) {
        // Circuit Breaker открыт, пропускаем обработку
        return;
      }
    }

    try {
      // Добавляем ошибку в очередь для асинхронной обработки
      await _queueController.enqueueError(error);

      // Обновляем состояние Circuit Breaker
      if (config.enableCircuitBreaker && error.module != null) {
        _updateCircuitBreakerState(error.module!, success: false);
      }
    } catch (e) {
      // Если не удалось добавить в очередь, обрабатываем синхронно
      await _handleError(error);
    }
  }

  /// Обработать успешную операцию (для Circuit Breaker)
  void handleSuccess(String module) {
    if (config.enableCircuitBreaker) {
      _updateCircuitBreakerState(module, success: true);
    }
  }

  /// Внутренняя обработка ошибки
  Future<void> _handleError(AppError error) async {
    try {
      // Логируем ошибку
      await _errorHandler.handle(error);

      // Аналитика
      if (config.enableAnalytics) {
        await _analyticsHandler.handle(error);
      }

      // Попытка автоматического восстановления
      if (config.enableRetryMechanism && error.canRetryOperation) {
        final recovered = await _recoveryHandler.attemptRecovery(error);
        if (recovered) {
          return; // Ошибка была устранена
        }
      }

      // Показываем уведомление пользователю
      await _showUserNotification(error);
    } catch (e) {
      // Если обработка ошибки сама вызвала ошибку, логируем без рекурсии
      print('Error in error handler: $e');
    }
  }

  /// Показать уведомление пользователю
  Future<void> _showUserNotification(AppError error) async {
    // Определяем тип отображения
    ErrorDisplayType displayType = error.displayType;

    // Переопределяем на основе конфигурации и критичности
    final configDisplayType = config.getDisplayTypeForSeverity(error.severity);
    if (configDisplayType != config.defaultDisplayType) {
      displayType = configDisplayType;
    }

    // Создаем уведомление
    final notification = ErrorNotification(
      error: error,
      displayType: displayType,
      message: formatter.formatUserMessage(error),
      details: config.showErrorDetails
          ? formatter.formatLogMessage(error)
          : null,
      canRetry: error.canRetryOperation,
      canDismiss: !error.severity.isCritical,
      timestamp: DateTime.now(),
    );

    // Отправляем в UI
    _notificationController.add(notification);
  }

  /// Показать ошибку через SnackBar с кнопкой "Детали"
  void showErrorSnackBarWithDetails(BuildContext context, AppError error, String message) {
    GlobalErrorDetailsService.showErrorSnackBarWithDetails(context, error, message);
  }

  /// Показать детали ошибки в диалоге
  void showErrorDetails(BuildContext context, AppError error) {
    GlobalErrorDetailsService.showErrorDetails(context, error);
  }

  /// Повторить операцию
  Future<void> retryOperation(AppError error) async {
    if (!error.canRetryOperation) return;

    final retryError = error.copyWithIncrementedRetry();
    await handleError(retryError);
  }

  /// Отклонить ошибку
  void dismissError(String errorId) {
    // Уведомляем UI об отклонении
    final dismissNotification = ErrorNotification(
      error: BaseAppError(
        code: 'ERROR_DISMISSED',
        message: 'Error dismissed',
        severity: ErrorSeverity.info,
        timestamp: DateTime.now(),
        id: errorId,
      ),
      displayType: ErrorDisplayType.none,
      message: '',
      canRetry: false,
      canDismiss: false,
      timestamp: DateTime.now(),
      isDismissal: true,
    );

    _notificationController.add(dismissNotification);
  }

  /// Получить историю ошибок
  List<AppError> getErrorHistory({Duration? period}) {
    return _queueController.getUniqueErrors(period: period);
  }

  /// Получить статистику ошибок
  Map<String, int> getErrorStatistics() {
    return _queueController.getErrorStatistics();
  }

  /// Очистить историю ошибок
  void clearErrorHistory() {
    _queueController.clearQueue();
    _errorHistory.clear();
    _persistedErrors.clear();

    // Уведомляем об изменении истории
    _historyController.add(List.unmodifiable(_errorHistory));
  }

  /// Обновить конфигурацию
  Future<void> updateConfig(ErrorConfig newConfig) async {
    // Создаем новый контроллер очереди с новой конфигурацией
    await _queueController.dispose();
    _queueController = ErrorQueueController(config: newConfig);
    await _queueController.initialize();
    _queueController.addErrorHandler(_handleError);
  }

  /// Проверка состояния Circuit Breaker
  bool _isCircuitBreakerOpen(String module) {
    final state = _circuitBreakers[module];
    if (state == null) return false;

    final now = DateTime.now();

    // Если Circuit Breaker открыт, проверяем время восстановления
    if (state.isOpen) {
      if (now.difference(state.lastFailureTime) >
          config.circuitBreakerRecoveryTimeout) {
        // Переводим в полуоткрытое состояние
        _circuitBreakers[module] = state.copyWith(isHalfOpen: true);
        return false;
      }
      return true;
    }

    return false;
  }

  /// Обновление состояния Circuit Breaker
  void _updateCircuitBreakerState(String module, {required bool success}) {
    final now = DateTime.now();
    final state =
        _circuitBreakers[module] ??
        _CircuitBreakerState(
          module: module,
          failureCount: 0,
          lastFailureTime: now,
          windowStartTime: now,
        );

    if (success) {
      // Успешная операция - сбрасываем счетчик
      _circuitBreakers[module] = state.copyWith(
        failureCount: 0,
        isOpen: false,
        isHalfOpen: false,
      );
    } else {
      // Неудачная операция
      final newFailureCount = state.failureCount + 1;
      final shouldOpen =
          newFailureCount >= config.circuitBreakerFailureThreshold;

      _circuitBreakers[module] = state.copyWith(
        failureCount: newFailureCount,
        lastFailureTime: now,
        isOpen: shouldOpen,
        isHalfOpen: false,
      );
    }
  }

  /// Инициализация обработчиков
  void _initializeHandlers() {
    _errorHandler = ErrorHandler(config: config, formatter: formatter);
    _recoveryHandler = ErrorRecoveryHandler(config: config);
    _analyticsHandler = ErrorAnalyticsHandler(config: config);
  }

  /// Закрытие контроллера
  Future<void> dispose() async {
    await _queueController.dispose();
    await _errorHandler.dispose();
    await _recoveryHandler.dispose();
    await _analyticsHandler.dispose();
    await _notificationController.close();
    await _historyController.close();
    _circuitBreakers.clear();
    _errorHistory.clear();
    _persistedErrors.clear();
    _isInitialized = false;
  }

  /// Сохранить ошибку для последующего просмотра
  void persistError(AppError error) {
    _persistedErrors[error.errorId] = error;
    _errorHistory.add(error);

    // Ограничиваем размер истории
    if (_errorHistory.length > config.maxErrorHistorySize) {
      final removedError = _errorHistory.removeAt(0);
      _persistedErrors.remove(removedError.errorId);
    }

    // Уведомляем об изменении истории
    _historyController.add(List.unmodifiable(_errorHistory));
  }

  /// Получить ошибку по ID
  AppError? getPersistedError(String errorId) {
    return _persistedErrors[errorId];
  }

  /// Получить историю ошибок
  List<AppError> get errorHistory => List.unmodifiable(_errorHistory);

  /// Получить последние ошибки определенного типа
  List<AppError> getErrorsByType(Type errorType) {
    return _errorHistory
        .where((error) => error.runtimeType == errorType)
        .toList();
  }

  /// Получить ошибки по модулю
  List<AppError> getErrorsByModule(String module) {
    return _errorHistory.where((error) => error.module == module).toList();
  }

  /// Удалить конкретную ошибку из истории
  void removeErrorFromHistory(String errorId) {
    _persistedErrors.remove(errorId);
    _errorHistory.removeWhere((error) => error.errorId == errorId);

    // Уведомляем об изменении истории
    _historyController.add(List.unmodifiable(_errorHistory));
  }
}

/// Уведомление об ошибке для UI
class ErrorNotification {
  const ErrorNotification({
    required this.error,
    required this.displayType,
    required this.message,
    required this.canRetry,
    required this.canDismiss,
    required this.timestamp,
    this.details,
    this.isDismissal = false,
  });

  final AppError error;
  final ErrorDisplayType displayType;
  final String message;
  final String? details;
  final bool canRetry;
  final bool canDismiss;
  final DateTime timestamp;
  final bool isDismissal;

  Map<String, dynamic> toJson() {
    return {
      'error': error.toJson(),
      'displayType': displayType.name,
      'message': message,
      'details': details,
      'canRetry': canRetry,
      'canDismiss': canDismiss,
      'timestamp': timestamp.toIso8601String(),
      'isDismissal': isDismissal,
    };
  }
}

/// Состояние Circuit Breaker
class _CircuitBreakerState {
  const _CircuitBreakerState({
    required this.module,
    required this.failureCount,
    required this.lastFailureTime,
    required this.windowStartTime,
    this.isOpen = false,
    this.isHalfOpen = false,
  });

  final String module;
  final int failureCount;
  final DateTime lastFailureTime;
  final DateTime windowStartTime;
  final bool isOpen;
  final bool isHalfOpen;

  _CircuitBreakerState copyWith({
    String? module,
    int? failureCount,
    DateTime? lastFailureTime,
    DateTime? windowStartTime,
    bool? isOpen,
    bool? isHalfOpen,
  }) {
    return _CircuitBreakerState(
      module: module ?? this.module,
      failureCount: failureCount ?? this.failureCount,
      lastFailureTime: lastFailureTime ?? this.lastFailureTime,
      windowStartTime: windowStartTime ?? this.windowStartTime,
      isOpen: isOpen ?? this.isOpen,
      isHalfOpen: isHalfOpen ?? this.isHalfOpen,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'module': module,
      'failureCount': failureCount,
      'lastFailureTime': lastFailureTime.toIso8601String(),
      'windowStartTime': windowStartTime.toIso8601String(),
      'isOpen': isOpen,
      'isHalfOpen': isHalfOpen,
    };
  }
}

/// Провайдер для контроллера ошибок
final errorControllerProvider = Provider<ErrorController>((ref) {
  const config = ErrorConfig();
  const formatter = ErrorFormatter();

  final controller = ErrorController(config: config, formatter: formatter);

  ref.onDispose(() => controller.dispose());

  // Автоматически инициализируем контроллер
  Future.microtask(() => controller.initialize());

  return controller;
});

/// Провайдер для истории ошибок
final errorHistoryProvider = Provider<List<AppError>>((ref) {
  final errorController = ref.watch(errorControllerProvider);
  return errorController.errorHistory;
});

/// Провайдер для стрима истории ошибок
final errorHistoryStreamProvider = StreamProvider<List<AppError>>((ref) {
  final controller = ref.watch(errorControllerProvider);
  return controller.historyStream;
});

/// Провайдер для стрима уведомлений об ошибках
final errorNotificationStreamProvider = StreamProvider<ErrorNotification>((
  ref,
) {
  final controller = ref.watch(errorControllerProvider);
  return controller.notificationStream;
});
