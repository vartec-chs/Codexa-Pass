import '../models/error_display_type.dart';
import '../models/error_severity.dart';

/// Конфигурация для системы обработки ошибок
class ErrorConfig {
  const ErrorConfig({
    this.enableErrorReporting = true,
    this.enableCrashReporting = true,
    this.enableUserConsent = true,
    this.showErrorDetails = false,
    this.enableDeduplication = true,
    this.deduplicationTimeWindow = const Duration(minutes: 5),
    this.maxErrorQueueSize = 100,
    this.maxStackTraceLines = 50,
    this.maxMessageLength = 1000,
    this.enableRetryMechanism = true,
    this.defaultMaxRetries = 3,
    this.retryDelayMultiplier = 2.0,
    this.baseRetryDelay = const Duration(seconds: 1),
    this.maxRetryDelay = const Duration(minutes: 5),
    this.enableCircuitBreaker = true,
    this.circuitBreakerFailureThreshold = 5,
    this.circuitBreakerTimeWindow = const Duration(minutes: 1),
    this.circuitBreakerRecoveryTimeout = const Duration(minutes: 5),
    this.enableSensitiveDataMasking = true,
    this.enableLocalization = true,
    this.enableAnalytics = false,
    this.defaultDisplayType = ErrorDisplayType.snackbar,
    this.severityDisplayMapping = const {
      ErrorSeverity.info: ErrorDisplayType.toast,
      ErrorSeverity.warning: ErrorDisplayType.snackbar,
      ErrorSeverity.error: ErrorDisplayType.dialog,
      ErrorSeverity.critical: ErrorDisplayType.dialog,
      ErrorSeverity.fatal: ErrorDisplayType.fullscreen,
    },
    this.moduleConfigs = const {},
  });

  /// Включить отправку отчетов об ошибках
  final bool enableErrorReporting;

  /// Включить отправку краш-репортов
  final bool enableCrashReporting;

  /// Требовать согласие пользователя на отправку отчетов
  final bool enableUserConsent;

  /// Показывать детали ошибок пользователю
  final bool showErrorDetails;

  /// Включить дедупликацию ошибок
  final bool enableDeduplication;

  /// Временное окно для дедупликации
  final Duration deduplicationTimeWindow;

  /// Максимальный размер очереди ошибок
  final int maxErrorQueueSize;

  /// Максимальное количество строк стека вызовов
  final int maxStackTraceLines;

  /// Максимальная длина сообщения об ошибке
  final int maxMessageLength;

  /// Включить механизм повторных попыток
  final bool enableRetryMechanism;

  /// Количество попыток по умолчанию
  final int defaultMaxRetries;

  /// Множитель задержки между попытками
  final double retryDelayMultiplier;

  /// Базовая задержка для первой попытки
  final Duration baseRetryDelay;

  /// Максимальная задержка между попытками
  final Duration maxRetryDelay;

  /// Включить Circuit Breaker
  final bool enableCircuitBreaker;

  /// Порог ошибок для срабатывания Circuit Breaker
  final int circuitBreakerFailureThreshold;

  /// Временное окно для подсчета ошибок
  final Duration circuitBreakerTimeWindow;

  /// Время восстановления Circuit Breaker
  final Duration circuitBreakerRecoveryTimeout;

  /// Включить маскирование чувствительных данных
  final bool enableSensitiveDataMasking;

  /// Включить локализацию ошибок
  final bool enableLocalization;

  /// Включить аналитику ошибок
  final bool enableAnalytics;

  /// Тип отображения по умолчанию
  final ErrorDisplayType defaultDisplayType;

  /// Маппинг критичности на тип отображения
  final Map<ErrorSeverity, ErrorDisplayType> severityDisplayMapping;

  /// Конфигурации для конкретных модулей
  final Map<String, ModuleErrorConfig> moduleConfigs;

  /// Получить тип отображения для ошибки
  ErrorDisplayType getDisplayTypeForSeverity(ErrorSeverity severity) {
    return severityDisplayMapping[severity] ?? defaultDisplayType;
  }

  /// Получить конфигурацию для модуля
  ModuleErrorConfig getModuleConfig(String module) {
    return moduleConfigs[module] ?? const ModuleErrorConfig();
  }

  /// Создать копию с изменениями
  ErrorConfig copyWith({
    bool? enableErrorReporting,
    bool? enableCrashReporting,
    bool? enableUserConsent,
    bool? showErrorDetails,
    bool? enableDeduplication,
    Duration? deduplicationTimeWindow,
    int? maxErrorQueueSize,
    int? maxStackTraceLines,
    int? maxMessageLength,
    bool? enableRetryMechanism,
    int? defaultMaxRetries,
    double? retryDelayMultiplier,
    Duration? baseRetryDelay,
    Duration? maxRetryDelay,
    bool? enableCircuitBreaker,
    int? circuitBreakerFailureThreshold,
    Duration? circuitBreakerTimeWindow,
    Duration? circuitBreakerRecoveryTimeout,
    bool? enableSensitiveDataMasking,
    bool? enableLocalization,
    bool? enableAnalytics,
    ErrorDisplayType? defaultDisplayType,
    Map<ErrorSeverity, ErrorDisplayType>? severityDisplayMapping,
    Map<String, ModuleErrorConfig>? moduleConfigs,
  }) {
    return ErrorConfig(
      enableErrorReporting: enableErrorReporting ?? this.enableErrorReporting,
      enableCrashReporting: enableCrashReporting ?? this.enableCrashReporting,
      enableUserConsent: enableUserConsent ?? this.enableUserConsent,
      showErrorDetails: showErrorDetails ?? this.showErrorDetails,
      enableDeduplication: enableDeduplication ?? this.enableDeduplication,
      deduplicationTimeWindow:
          deduplicationTimeWindow ?? this.deduplicationTimeWindow,
      maxErrorQueueSize: maxErrorQueueSize ?? this.maxErrorQueueSize,
      maxStackTraceLines: maxStackTraceLines ?? this.maxStackTraceLines,
      maxMessageLength: maxMessageLength ?? this.maxMessageLength,
      enableRetryMechanism: enableRetryMechanism ?? this.enableRetryMechanism,
      defaultMaxRetries: defaultMaxRetries ?? this.defaultMaxRetries,
      retryDelayMultiplier: retryDelayMultiplier ?? this.retryDelayMultiplier,
      baseRetryDelay: baseRetryDelay ?? this.baseRetryDelay,
      maxRetryDelay: maxRetryDelay ?? this.maxRetryDelay,
      enableCircuitBreaker: enableCircuitBreaker ?? this.enableCircuitBreaker,
      circuitBreakerFailureThreshold:
          circuitBreakerFailureThreshold ?? this.circuitBreakerFailureThreshold,
      circuitBreakerTimeWindow:
          circuitBreakerTimeWindow ?? this.circuitBreakerTimeWindow,
      circuitBreakerRecoveryTimeout:
          circuitBreakerRecoveryTimeout ?? this.circuitBreakerRecoveryTimeout,
      enableSensitiveDataMasking:
          enableSensitiveDataMasking ?? this.enableSensitiveDataMasking,
      enableLocalization: enableLocalization ?? this.enableLocalization,
      enableAnalytics: enableAnalytics ?? this.enableAnalytics,
      defaultDisplayType: defaultDisplayType ?? this.defaultDisplayType,
      severityDisplayMapping:
          severityDisplayMapping ?? this.severityDisplayMapping,
      moduleConfigs: moduleConfigs ?? this.moduleConfigs,
    );
  }

  /// Конвертация в JSON
  Map<String, dynamic> toJson() {
    return {
      'enableErrorReporting': enableErrorReporting,
      'enableCrashReporting': enableCrashReporting,
      'enableUserConsent': enableUserConsent,
      'showErrorDetails': showErrorDetails,
      'enableDeduplication': enableDeduplication,
      'deduplicationTimeWindow': deduplicationTimeWindow.inMilliseconds,
      'maxErrorQueueSize': maxErrorQueueSize,
      'maxStackTraceLines': maxStackTraceLines,
      'maxMessageLength': maxMessageLength,
      'enableRetryMechanism': enableRetryMechanism,
      'defaultMaxRetries': defaultMaxRetries,
      'retryDelayMultiplier': retryDelayMultiplier,
      'baseRetryDelay': baseRetryDelay.inMilliseconds,
      'maxRetryDelay': maxRetryDelay.inMilliseconds,
      'enableCircuitBreaker': enableCircuitBreaker,
      'circuitBreakerFailureThreshold': circuitBreakerFailureThreshold,
      'circuitBreakerTimeWindow': circuitBreakerTimeWindow.inMilliseconds,
      'circuitBreakerRecoveryTimeout':
          circuitBreakerRecoveryTimeout.inMilliseconds,
      'enableSensitiveDataMasking': enableSensitiveDataMasking,
      'enableLocalization': enableLocalization,
      'enableAnalytics': enableAnalytics,
      'defaultDisplayType': defaultDisplayType.name,
      'severityDisplayMapping': severityDisplayMapping.map(
        (key, value) => MapEntry(key.name, value.name),
      ),
      'moduleConfigs': moduleConfigs.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
    };
  }
}

/// Конфигурация обработки ошибок для конкретного модуля
class ModuleErrorConfig {
  const ModuleErrorConfig({
    this.enableLogging = true,
    this.enableReporting = true,
    this.maxRetries,
    this.retryDelay,
    this.displayType,
    this.severity,
    this.enableCircuitBreaker = true,
    this.circuitBreakerThreshold,
    this.enableAutoRecovery = false,
    this.autoRecoveryStrategy,
    this.customErrorMessages = const {},
  });

  /// Включить логирование для модуля
  final bool enableLogging;

  /// Включить отправку отчетов для модуля
  final bool enableReporting;

  /// Максимальное количество попыток для модуля
  final int? maxRetries;

  /// Задержка между попытками для модуля
  final Duration? retryDelay;

  /// Тип отображения для модуля
  final ErrorDisplayType? displayType;

  /// Уровень критичности для модуля
  final ErrorSeverity? severity;

  /// Включить Circuit Breaker для модуля
  final bool enableCircuitBreaker;

  /// Порог срабатывания Circuit Breaker для модуля
  final int? circuitBreakerThreshold;

  /// Включить автоматическое восстановление
  final bool enableAutoRecovery;

  /// Стратегия автоматического восстановления
  final String? autoRecoveryStrategy;

  /// Кастомные сообщения об ошибках для модуля
  final Map<String, String> customErrorMessages;

  /// Создать копию с изменениями
  ModuleErrorConfig copyWith({
    bool? enableLogging,
    bool? enableReporting,
    int? maxRetries,
    Duration? retryDelay,
    ErrorDisplayType? displayType,
    ErrorSeverity? severity,
    bool? enableCircuitBreaker,
    int? circuitBreakerThreshold,
    bool? enableAutoRecovery,
    String? autoRecoveryStrategy,
    Map<String, String>? customErrorMessages,
  }) {
    return ModuleErrorConfig(
      enableLogging: enableLogging ?? this.enableLogging,
      enableReporting: enableReporting ?? this.enableReporting,
      maxRetries: maxRetries ?? this.maxRetries,
      retryDelay: retryDelay ?? this.retryDelay,
      displayType: displayType ?? this.displayType,
      severity: severity ?? this.severity,
      enableCircuitBreaker: enableCircuitBreaker ?? this.enableCircuitBreaker,
      circuitBreakerThreshold:
          circuitBreakerThreshold ?? this.circuitBreakerThreshold,
      enableAutoRecovery: enableAutoRecovery ?? this.enableAutoRecovery,
      autoRecoveryStrategy: autoRecoveryStrategy ?? this.autoRecoveryStrategy,
      customErrorMessages: customErrorMessages ?? this.customErrorMessages,
    );
  }

  /// Конвертация в JSON
  Map<String, dynamic> toJson() {
    return {
      'enableLogging': enableLogging,
      'enableReporting': enableReporting,
      'maxRetries': maxRetries,
      'retryDelay': retryDelay?.inMilliseconds,
      'displayType': displayType?.name,
      'severity': severity?.name,
      'enableCircuitBreaker': enableCircuitBreaker,
      'circuitBreakerThreshold': circuitBreakerThreshold,
      'enableAutoRecovery': enableAutoRecovery,
      'autoRecoveryStrategy': autoRecoveryStrategy,
      'customErrorMessages': customErrorMessages,
    };
  }
}
