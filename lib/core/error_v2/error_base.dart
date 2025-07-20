/// Улучшенная система ошибок v2 для CodexaPass
///
/// Основные улучшения:
/// - Более четкая типизация ошибок
/// - Улучшенная локализация
/// - Автоматическое восстановление для некритических ошибок
/// - Расширенная система метрик и аналитики
/// - Поддержка async/await patterns
/// - Интеграция с состоянием приложения

/// Базовый интерфейс для всех ошибок в системе v2
abstract class AppErrorV2 implements Exception {
  /// Уникальный идентификатор ошибки
  String get id;

  /// Категория ошибки для группировки
  ErrorCategoryV2 get category;

  /// Тип ошибки для более детальной классификации
  String get type;

  /// Человекочитаемое сообщение
  String get message;

  /// Техническое описание для разработчиков
  String? get technicalDetails;

  /// Контекстная информация для отладки
  Map<String, Object?> get context;

  /// Уровень критичности ошибки
  ErrorSeverityV2 get severity;

  /// Время возникновения ошибки
  DateTime get timestamp;

  /// Оригинальная ошибка (если есть)
  Object? get originalError;

  /// Стек вызовов
  StackTrace? get stackTrace;

  /// Может ли ошибка быть автоматически исправлена
  bool get isRecoverable;

  /// Стратегия восстановления для этой ошибки
  RecoveryStrategyV2? get recoveryStrategy;

  /// Должна ли ошибка отправляться в аналитику
  bool get shouldTrack;

  /// Должна ли ошибка показываться пользователю
  bool get shouldDisplay;

  /// Приоритет отображения (для случаев множественных ошибок)
  int get displayPriority;

  /// Максимальное количество попыток восстановления
  int get maxRetryAttempts;

  /// Интервал между попытками восстановления
  Duration get retryDelay;

  /// Метаданные для аналитики
  Map<String, Object?> get analyticsData;

  /// Преобразование в JSON для логирования и аналитики
  Map<String, Object?> toJson();

  /// Создание копии с новыми параметрами
  AppErrorV2 copyWith({
    String? message,
    String? technicalDetails,
    Map<String, Object?>? context,
    ErrorSeverityV2? severity,
    Object? originalError,
    StackTrace? stackTrace,
  });

  @override
  String toString() => '${category.name}:$type - $message';
}

/// Категории ошибок v2 с расширенной классификацией
enum ErrorCategoryV2 {
  /// Ошибки аутентификации и авторизации
  authentication('AUTH'),

  /// Ошибки криптографии и шифрования
  encryption('CRYPT'),

  /// Ошибки работы с базой данных
  database('DB'),

  /// Сетевые ошибки и API
  network('NET'),

  /// Ошибки валидации данных
  validation('VALID'),

  /// Ошибки файловой системы и хранилища
  storage('STORAGE'),

  /// Ошибки безопасности
  security('SEC'),

  /// Системные ошибки ОС
  system('SYS'),

  /// Ошибки пользовательского интерфейса
  ui('UI'),

  /// Бизнес-логические ошибки
  business('BIZ'),

  /// Ошибки конфигурации
  configuration('CONFIG'),

  /// Ошибки интеграции с внешними сервисами
  integration('INTEG'),

  /// Ошибки производительности
  performance('PERF'),

  /// Неизвестные ошибки
  unknown('UNKNOWN');

  const ErrorCategoryV2(this.code);

  /// Короткий код категории
  final String code;

  /// Получение категории по коду
  static ErrorCategoryV2? fromCode(String code) {
    for (final category in ErrorCategoryV2.values) {
      if (category.code == code) return category;
    }
    return null;
  }
}

/// Уровни критичности ошибок v2
enum ErrorSeverityV2 {
  /// Информационные сообщения
  info(0, 'INFO'),

  /// Предупреждения, не влияющие на работу
  warning(1, 'WARN'),

  /// Ошибки, влияющие на функциональность
  error(2, 'ERROR'),

  /// Критические ошибки, требующие вмешательства
  critical(3, 'CRITICAL'),

  /// Фатальные ошибки, приводящие к сбою приложения
  fatal(4, 'FATAL');

  const ErrorSeverityV2(this.level, this.code);

  /// Числовой уровень критичности
  final int level;

  /// Строковый код уровня
  final String code;

  /// Проверка критичности
  bool get isCritical => level >= critical.level;

  /// Проверка фатальности
  bool get isFatal => this == fatal;

  /// Получение уровня по коду
  static ErrorSeverityV2? fromCode(String code) {
    for (final severity in ErrorSeverityV2.values) {
      if (severity.code == code) return severity;
    }
    return null;
  }
}

/// Стратегии восстановления после ошибок
enum RecoveryStrategyV2 {
  /// Никакого восстановления
  none,

  /// Повторная попытка
  retry,

  /// Повторная попытка с экспоненциальной задержкой
  retryWithBackoff,

  /// Переключение на резервный механизм
  fallback,

  /// Сброс состояния компонента
  reset,

  /// Перезапуск сервиса
  restart,

  /// Переключение в безопасный режим
  safeMode,

  /// Пользовательское восстановление
  custom,
}

/// Расширенная информация об ошибке для аналитики
class ErrorAnalyticsData {
  final String userId;
  final String sessionId;
  final String deviceId;
  final String appVersion;
  final String buildNumber;
  final String platform;
  final String platformVersion;
  final Map<String, Object?> userContext;
  final Map<String, Object?> systemContext;
  final Map<String, Object?> featureFlags;

  const ErrorAnalyticsData({
    required this.userId,
    required this.sessionId,
    required this.deviceId,
    required this.appVersion,
    required this.buildNumber,
    required this.platform,
    required this.platformVersion,
    this.userContext = const {},
    this.systemContext = const {},
    this.featureFlags = const {},
  });

  Map<String, Object?> toJson() => {
    'userId': userId,
    'sessionId': sessionId,
    'deviceId': deviceId,
    'appVersion': appVersion,
    'buildNumber': buildNumber,
    'platform': platform,
    'platformVersion': platformVersion,
    'userContext': userContext,
    'systemContext': systemContext,
    'featureFlags': featureFlags,
  };
}

/// Базовая реализация ошибки приложения v2
abstract class BaseAppErrorV2 implements AppErrorV2 {
  @override
  final String id;

  @override
  final ErrorCategoryV2 category;

  @override
  final String type;

  @override
  final String message;

  @override
  final String? technicalDetails;

  @override
  final Map<String, Object?> context;

  @override
  final ErrorSeverityV2 severity;

  @override
  final DateTime timestamp;

  @override
  final Object? originalError;

  @override
  final StackTrace? stackTrace;

  @override
  final bool isRecoverable;

  @override
  final RecoveryStrategyV2? recoveryStrategy;

  @override
  final bool shouldTrack;

  @override
  final bool shouldDisplay;

  @override
  final int displayPriority;

  @override
  final int maxRetryAttempts;

  @override
  final Duration retryDelay;

  BaseAppErrorV2({
    required this.id,
    required this.category,
    required this.type,
    required this.message,
    this.technicalDetails,
    this.context = const {},
    required this.severity,
    DateTime? timestamp,
    this.originalError,
    this.stackTrace,
    this.isRecoverable = false,
    this.recoveryStrategy,
    this.shouldTrack = true,
    this.shouldDisplay = true,
    this.displayPriority = 0,
    this.maxRetryAttempts = 3,
    this.retryDelay = const Duration(seconds: 1),
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  Map<String, Object?> get analyticsData => {
    'errorId': id,
    'category': category.code,
    'type': type,
    'severity': severity.code,
    'isRecoverable': isRecoverable,
    'recoveryStrategy': recoveryStrategy?.name,
    'maxRetryAttempts': maxRetryAttempts,
    'retryDelay': retryDelay.inMilliseconds,
    'context': context,
  };

  @override
  Map<String, Object?> toJson() => {
    'id': id,
    'category': category.code,
    'type': type,
    'message': message,
    'technicalDetails': technicalDetails,
    'context': context,
    'severity': severity.code,
    'timestamp': timestamp.toIso8601String(),
    'originalError': originalError?.toString(),
    'stackTrace': stackTrace?.toString(),
    'isRecoverable': isRecoverable,
    'recoveryStrategy': recoveryStrategy?.name,
    'shouldTrack': shouldTrack,
    'shouldDisplay': shouldDisplay,
    'displayPriority': displayPriority,
    'maxRetryAttempts': maxRetryAttempts,
    'retryDelay': retryDelay.inMilliseconds,
    'analyticsData': analyticsData,
  };
}
