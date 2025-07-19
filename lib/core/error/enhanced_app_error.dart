import 'package:codexa_pass/core/logging/logging.dart';

/// Базовый интерфейс для всех ошибок приложения
abstract class BaseAppError implements Exception {
  /// Уникальный код ошибки
  String get code;

  /// Человекочитаемое сообщение
  String get message;

  /// Техническое описание ошибки
  String? get technicalDetails;

  /// Контекстная информация
  Map<String, dynamic>? get context;

  /// Является ли ошибка критической
  bool get isCritical;

  /// Категория ошибки для группировки
  ErrorCategory get category;

  /// Время возникновения ошибки
  DateTime get timestamp;

  /// Оригинальная ошибка (если есть)
  Object? get originalError;

  /// Стек вызовов
  StackTrace? get stackTrace;

  /// Должна ли ошибка автоматически создавать краш-репорт
  bool get shouldCreateCrashReport => isCritical;

  /// Тип краш-репорта для этой ошибки
  CrashType get crashReportType => CrashType.custom;

  /// Преобразование в строку для отладки
  @override
  String toString() => '$code: $message';

  /// Преобразование в JSON для логирования
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      'technicalDetails': technicalDetails,
      'context': context,
      'isCritical': isCritical,
      'category': category.name,
      'timestamp': timestamp.toIso8601String(),
      'originalError': originalError?.toString(),
      'stackTrace': stackTrace?.toString(),
    };
  }
}

/// Категории ошибок для группировки и обработки
enum ErrorCategory {
  authentication('auth'),
  encryption('crypto'),
  database('db'),
  network('net'),
  validation('validation'),
  storage('storage'),
  security('security'),
  system('system'),
  ui('ui'),
  business('business'),
  unknown('unknown');

  const ErrorCategory(this.prefix);
  final String prefix;
}

/// Базовый класс для реализации ошибок приложения
abstract class AppError extends BaseAppError {
  @override
  final String code;

  @override
  final String message;

  @override
  final String? technicalDetails;

  @override
  final Map<String, dynamic>? context;

  @override
  final bool isCritical;

  @override
  final ErrorCategory category;

  @override
  final DateTime timestamp;

  @override
  final Object? originalError;

  @override
  final StackTrace? stackTrace;

  AppError({
    required this.code,
    required this.message,
    required this.category,
    this.technicalDetails,
    this.context,
    this.isCritical = false,
    DateTime? timestamp,
    this.originalError,
    this.stackTrace,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Создание ошибки из исключения
  factory AppError.fromException(
    Object exception, {
    String? code,
    String? message,
    ErrorCategory category = ErrorCategory.unknown,
    String? technicalDetails,
    Map<String, dynamic>? context,
    bool isCritical = false,
    StackTrace? stackTrace,
  }) {
    return UnknownAppError(
      code: code ?? '${category.prefix}_exception',
      message:
          message ?? 'Произошла неожиданная ошибка: ${exception.toString()}',
      category: category,
      technicalDetails: technicalDetails ?? exception.toString(),
      context: context,
      isCritical: isCritical,
      originalError: exception,
      stackTrace: stackTrace,
    );
  }

  /// Создание ошибки с автоматической генерацией кода
  factory AppError.create({
    required String message,
    required ErrorCategory category,
    String? technicalDetails,
    Map<String, dynamic>? context,
    bool isCritical = false,
    Object? originalError,
    StackTrace? stackTrace,
  }) {
    final code = '${category.prefix}_${DateTime.now().millisecondsSinceEpoch}';
    return UnknownAppError(
      code: code,
      message: message,
      category: category,
      technicalDetails: technicalDetails,
      context: context,
      isCritical: isCritical,
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }
}

/// Реализация для неизвестных ошибок
class UnknownAppError extends AppError {
  UnknownAppError({
    required super.code,
    required super.message,
    super.category = ErrorCategory.unknown,
    super.technicalDetails,
    super.context,
    super.isCritical,
    super.timestamp,
    super.originalError,
    super.stackTrace,
  });
}

/// Ошибки аутентификации
class AuthenticationError extends AppError {
  @override
  CrashType get crashReportType => CrashType.custom;

  AuthenticationError({
    required String code,
    required String message,
    String? technicalDetails,
    Map<String, dynamic>? context,
    bool isCritical = false,
    Object? originalError,
    StackTrace? stackTrace,
  }) : super(
         code: code,
         message: message,
         category: ErrorCategory.authentication,
         technicalDetails: technicalDetails,
         context: context,
         isCritical: isCritical,
         originalError: originalError,
         stackTrace: stackTrace,
       );

  /// Предопределенные типы ошибок аутентификации
  factory AuthenticationError.invalidCredentials([String? details]) =>
      AuthenticationError(
        code: 'auth_invalid_credentials',
        message: 'Неверные учетные данные',
        technicalDetails: details,
      );

  factory AuthenticationError.sessionExpired([String? details]) =>
      AuthenticationError(
        code: 'auth_session_expired',
        message: 'Сессия истекла',
        technicalDetails: details,
      );

  factory AuthenticationError.biometricFailed([String? details]) =>
      AuthenticationError(
        code: 'auth_biometric_failed',
        message: 'Биометрическая аутентификация не удалась',
        technicalDetails: details,
      );
}

/// Ошибки шифрования
class EncryptionError extends AppError {
  @override
  bool get isCritical => true;

  @override
  CrashType get crashReportType => CrashType.fatal;

  EncryptionError({
    required String code,
    required String message,
    String? technicalDetails,
    Map<String, dynamic>? context,
    Object? originalError,
    StackTrace? stackTrace,
  }) : super(
         code: code,
         message: message,
         category: ErrorCategory.encryption,
         technicalDetails: technicalDetails,
         context: context,
         isCritical: true,
         originalError: originalError,
         stackTrace: stackTrace,
       );

  /// Предопределенные типы ошибок шифрования
  factory EncryptionError.keyGenerationFailed([String? details]) =>
      EncryptionError(
        code: 'crypto_key_generation_failed',
        message: 'Не удалось сгенерировать ключ шифрования',
        technicalDetails: details,
      );

  factory EncryptionError.decryptionFailed([String? details]) =>
      EncryptionError(
        code: 'crypto_decryption_failed',
        message: 'Не удалось расшифровать данные',
        technicalDetails: details,
      );

  factory EncryptionError.corruptedData([String? details]) => EncryptionError(
    code: 'crypto_corrupted_data',
    message: 'Поврежденные зашифрованные данные',
    technicalDetails: details,
  );
}

/// Ошибки базы данных
class DatabaseError extends AppError {
  @override
  CrashType get crashReportType => CrashType.custom;

  DatabaseError({
    required String code,
    required String message,
    String? technicalDetails,
    Map<String, dynamic>? context,
    bool isCritical = false,
    Object? originalError,
    StackTrace? stackTrace,
  }) : super(
         code: code,
         message: message,
         category: ErrorCategory.database,
         technicalDetails: technicalDetails,
         context: context,
         isCritical: isCritical,
         originalError: originalError,
         stackTrace: stackTrace,
       );

  /// Предопределенные типы ошибок базы данных
  factory DatabaseError.connectionFailed([String? details]) => DatabaseError(
    code: 'db_connection_failed',
    message: 'Не удалось подключиться к базе данных',
    technicalDetails: details,
    isCritical: true,
  );

  factory DatabaseError.queryFailed(String query, [String? details]) =>
      DatabaseError(
        code: 'db_query_failed',
        message: 'Ошибка выполнения запроса к базе данных',
        technicalDetails: details,
        context: {'query': query},
      );

  factory DatabaseError.recordNotFound(String table, [dynamic id]) =>
      DatabaseError(
        code: 'db_record_not_found',
        message: 'Запись не найдена',
        context: {'table': table, 'id': id?.toString()},
      );
}

/// Ошибки сети
class NetworkError extends AppError {
  @override
  CrashType get crashReportType => CrashType.custom;

  NetworkError({
    required String code,
    required String message,
    String? technicalDetails,
    Map<String, dynamic>? context,
    bool isCritical = false,
    Object? originalError,
    StackTrace? stackTrace,
  }) : super(
         code: code,
         message: message,
         category: ErrorCategory.network,
         technicalDetails: technicalDetails,
         context: context,
         isCritical: isCritical,
         originalError: originalError,
         stackTrace: stackTrace,
       );

  /// Предопределенные типы сетевых ошибок
  factory NetworkError.noConnection([String? details]) => NetworkError(
    code: 'net_no_connection',
    message: 'Отсутствует подключение к интернету',
    technicalDetails: details,
  );

  factory NetworkError.timeout([String? details]) => NetworkError(
    code: 'net_timeout',
    message: 'Превышено время ожидания ответа',
    technicalDetails: details,
  );

  factory NetworkError.serverError(int statusCode, [String? details]) =>
      NetworkError(
        code: 'net_server_error',
        message: 'Ошибка сервера ($statusCode)',
        technicalDetails: details,
        context: {'statusCode': statusCode},
        isCritical: statusCode >= 500,
      );
}

/// Ошибки валидации
class ValidationError extends AppError {
  final String? field;

  @override
  CrashType get crashReportType => CrashType.custom;

  ValidationError({
    required String code,
    required String message,
    this.field,
    String? technicalDetails,
    Map<String, dynamic>? context,
    Object? originalError,
    StackTrace? stackTrace,
  }) : super(
         code: code,
         message: message,
         category: ErrorCategory.validation,
         technicalDetails: technicalDetails,
         context: context,
         isCritical: false,
         originalError: originalError,
         stackTrace: stackTrace,
       );

  /// Предопределенные типы ошибок валидации
  factory ValidationError.required(String field) => ValidationError(
    code: 'validation_required',
    message: 'Поле "$field" обязательно для заполнения',
    field: field,
  );

  factory ValidationError.invalidFormat(String field, [String? details]) =>
      ValidationError(
        code: 'validation_invalid_format',
        message: 'Неверный формат поля "$field"',
        field: field,
        technicalDetails: details,
      );

  factory ValidationError.tooShort(String field, int minLength) =>
      ValidationError(
        code: 'validation_too_short',
        message: 'Поле "$field" должно содержать не менее $minLength символов',
        field: field,
        context: {'minLength': minLength},
      );

  factory ValidationError.weakPassword([String? details]) => ValidationError(
    code: 'validation_weak_password',
    message: 'Пароль слишком слабый',
    field: 'password',
    technicalDetails: details,
  );
}

/// Ошибки хранилища
class StorageError extends AppError {
  @override
  CrashType get crashReportType => CrashType.custom;

  StorageError({
    required String code,
    required String message,
    String? technicalDetails,
    Map<String, dynamic>? context,
    bool isCritical = false,
    Object? originalError,
    StackTrace? stackTrace,
  }) : super(
         code: code,
         message: message,
         category: ErrorCategory.storage,
         technicalDetails: technicalDetails,
         context: context,
         isCritical: isCritical,
         originalError: originalError,
         stackTrace: stackTrace,
       );

  /// Предопределенные типы ошибок хранилища
  factory StorageError.fileNotFound(String path) => StorageError(
    code: 'storage_file_not_found',
    message: 'Файл не найден',
    context: {'path': path},
  );

  factory StorageError.accessDenied(String path) => StorageError(
    code: 'storage_access_denied',
    message: 'Доступ к файлу запрещен',
    context: {'path': path},
  );

  factory StorageError.insufficientSpace([String? details]) => StorageError(
    code: 'storage_insufficient_space',
    message: 'Недостаточно места на диске',
    technicalDetails: details,
    isCritical: true,
  );
}

/// Ошибки безопасности
class SecurityError extends AppError {
  @override
  bool get isCritical => true;

  @override
  CrashType get crashReportType => CrashType.fatal;

  SecurityError({
    required String code,
    required String message,
    String? technicalDetails,
    Map<String, dynamic>? context,
    Object? originalError,
    StackTrace? stackTrace,
  }) : super(
         code: code,
         message: message,
         category: ErrorCategory.security,
         technicalDetails: technicalDetails,
         context: context,
         isCritical: true,
         originalError: originalError,
         stackTrace: stackTrace,
       );

  /// Предопределенные типы ошибок безопасности
  factory SecurityError.unauthorizedAccess([String? details]) => SecurityError(
    code: 'security_unauthorized_access',
    message: 'Несанкционированный доступ',
    technicalDetails: details,
  );

  factory SecurityError.integrityCheckFailed([String? details]) =>
      SecurityError(
        code: 'security_integrity_check_failed',
        message: 'Проверка целостности данных не удалась',
        technicalDetails: details,
      );

  factory SecurityError.suspiciousActivity([String? details]) => SecurityError(
    code: 'security_suspicious_activity',
    message: 'Обнаружена подозрительная активность',
    technicalDetails: details,
  );
}

/// Системные ошибки
class SystemError extends AppError {
  @override
  bool get isCritical => true;

  @override
  CrashType get crashReportType => CrashType.fatal;

  SystemError({
    required String code,
    required String message,
    String? technicalDetails,
    Map<String, dynamic>? context,
    Object? originalError,
    StackTrace? stackTrace,
  }) : super(
         code: code,
         message: message,
         category: ErrorCategory.system,
         technicalDetails: technicalDetails,
         context: context,
         isCritical: true,
         originalError: originalError,
         stackTrace: stackTrace,
       );

  /// Предопределенные типы системных ошибок
  factory SystemError.outOfMemory([String? details]) => SystemError(
    code: 'system_out_of_memory',
    message: 'Недостаточно оперативной памяти',
    technicalDetails: details,
  );

  factory SystemError.initializationFailed(
    String component, [
    String? details,
  ]) => SystemError(
    code: 'system_initialization_failed',
    message: 'Не удалось инициализировать компонент: $component',
    technicalDetails: details,
    context: {'component': component},
  );

  factory SystemError.platformNotSupported([String? details]) => SystemError(
    code: 'system_platform_not_supported',
    message: 'Платформа не поддерживается',
    technicalDetails: details,
  );
}

/// Ошибки пользовательского интерфейса
class UIError extends AppError {
  @override
  CrashType get crashReportType => CrashType.flutter;

  UIError({
    required String code,
    required String message,
    String? technicalDetails,
    Map<String, dynamic>? context,
    bool isCritical = false,
    Object? originalError,
    StackTrace? stackTrace,
  }) : super(
         code: code,
         message: message,
         category: ErrorCategory.ui,
         technicalDetails: technicalDetails,
         context: context,
         isCritical: isCritical,
         originalError: originalError,
         stackTrace: stackTrace,
       );

  /// Предопределенные типы ошибок UI
  factory UIError.widgetBuildFailed(String widget, [String? details]) =>
      UIError(
        code: 'ui_widget_build_failed',
        message: 'Ошибка построения виджета: $widget',
        technicalDetails: details,
        context: {'widget': widget},
        isCritical: true,
      );

  factory UIError.navigationFailed(String route, [String? details]) => UIError(
    code: 'ui_navigation_failed',
    message: 'Ошибка навигации к маршруту: $route',
    technicalDetails: details,
    context: {'route': route},
  );

  factory UIError.invalidState(String component, [String? details]) => UIError(
    code: 'ui_invalid_state',
    message: 'Недопустимое состояние компонента: $component',
    technicalDetails: details,
    context: {'component': component},
  );
}

/// Бизнес-логические ошибки
class BusinessError extends AppError {
  @override
  CrashType get crashReportType => CrashType.custom;

  BusinessError({
    required String code,
    required String message,
    String? technicalDetails,
    Map<String, dynamic>? context,
    bool isCritical = false,
    Object? originalError,
    StackTrace? stackTrace,
  }) : super(
         code: code,
         message: message,
         category: ErrorCategory.business,
         technicalDetails: technicalDetails,
         context: context,
         isCritical: isCritical,
         originalError: originalError,
         stackTrace: stackTrace,
       );

  /// Предопределенные типы бизнес-ошибок
  factory BusinessError.operationNotAllowed([String? details]) => BusinessError(
    code: 'business_operation_not_allowed',
    message: 'Операция не разрешена',
    technicalDetails: details,
  );

  factory BusinessError.resourceNotAvailable(
    String resource, [
    String? details,
  ]) => BusinessError(
    code: 'business_resource_not_available',
    message: 'Ресурс недоступен: $resource',
    technicalDetails: details,
    context: {'resource': resource},
  );

  factory BusinessError.limitExceeded(String limit, [dynamic value]) =>
      BusinessError(
        code: 'business_limit_exceeded',
        message: 'Превышен лимит: $limit',
        context: {'limit': limit, 'value': value?.toString()},
      );
}
