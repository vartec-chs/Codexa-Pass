import 'package:uuid/uuid.dart';
import 'error_severity.dart';
import 'error_display_type.dart';

/// Базовый абстрактный класс для всех ошибок приложения
abstract class AppError {
  const AppError({
    required this.code,
    required this.message,
    required this.severity,
    required this.timestamp,
    this.id,
    this.stackTrace,
    this.metadata,
    this.originalError,
    this.module,
    this.userContext,
    this.canRetry = false,
    this.maxRetries = 0,
    this.retryCount = 0,
    this.displayType = ErrorDisplayType.snackbar,
    this.shouldReport = true,
    this.shouldShowDetails = true,
  });

  /// Уникальный идентификатор ошибки
  final String? id;

  /// Код ошибки для категоризации
  final String code;

  /// Человекочитаемое сообщение
  final String message;

  /// Уровень критичности
  final ErrorSeverity severity;

  /// Время возникновения ошибки
  final DateTime timestamp;

  /// Стек вызовов
  final StackTrace? stackTrace;

  /// Дополнительные метаданные
  final Map<String, dynamic>? metadata;

  /// Оригинальная ошибка (если есть)
  final Object? originalError;

  /// Модуль, в котором произошла ошибка
  final String? module;

  /// Контекст пользователя
  final Map<String, dynamic>? userContext;

  /// Можно ли повторить операцию
  final bool canRetry;

  /// Максимальное количество попыток
  final int maxRetries;

  /// Текущее количество попыток
  final int retryCount;

  /// Тип отображения в UI
  final ErrorDisplayType displayType;

  /// Следует ли отправлять отчет об ошибке
  final bool shouldReport;

  /// Следует ли показывать детали ошибки пользователю
  final bool shouldShowDetails;

  /// Генерация уникального ID если не передан
  String get errorId => id ?? const Uuid().v4();

  /// Локализованное сообщение (базовая реализация)
  String get localizedMessage => message;

  /// Краткое описание для UI
  String get userFriendlyMessage => localizedMessage;

  /// Детальная информация об ошибке
  String get detailedMessage {
    final buffer = StringBuffer();
    buffer.writeln('Error: $code');
    buffer.writeln('Message: $message');
    buffer.writeln('Severity: ${severity.name}');
    buffer.writeln('Time: ${timestamp.toIso8601String()}');

    if (module != null) {
      buffer.writeln('Module: $module');
    }

    if (metadata != null && metadata!.isNotEmpty) {
      buffer.writeln('Metadata: $metadata');
    }

    if (originalError != null) {
      buffer.writeln('Original Error: $originalError');
    }

    if (stackTrace != null) {
      buffer.writeln('Stack Trace:');
      buffer.writeln(stackTrace.toString());
    }

    return buffer.toString();
  }

  /// Проверка возможности повтора
  bool get canRetryOperation => canRetry && retryCount < maxRetries;

  /// Создание копии с увеличенным счетчиком попыток
  AppError copyWithIncrementedRetry();

  /// Создание копии с новыми параметрами
  AppError copyWith({
    String? id,
    String? code,
    String? message,
    ErrorSeverity? severity,
    DateTime? timestamp,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
    Object? originalError,
    String? module,
    Map<String, dynamic>? userContext,
    bool? canRetry,
    int? maxRetries,
    int? retryCount,
    ErrorDisplayType? displayType,
    bool? shouldReport,
    bool? shouldShowDetails,
  });

  /// Конвертация в JSON для логирования
  Map<String, dynamic> toJson() {
    return {
      'id': errorId,
      'code': code,
      'message': message,
      'severity': severity.name,
      'timestamp': timestamp.toIso8601String(),
      'module': module,
      'canRetry': canRetry,
      'maxRetries': maxRetries,
      'retryCount': retryCount,
      'displayType': displayType.name,
      'shouldReport': shouldReport,
      'shouldShowDetails': shouldShowDetails,
      'metadata': metadata,
      'originalError': originalError?.toString(),
      'userContext': userContext,
      'stackTrace': stackTrace?.toString(),
    };
  }

  /// Равенство ошибок по основным свойствам
  bool equals(AppError other) {
    return id == other.id &&
        code == other.code &&
        message == other.message &&
        severity == other.severity &&
        module == other.module;
  }

  /// Хеш-код для сравнения
  @override
  int get hashCode {
    return Object.hash(id, code, message, severity, module);
  }

  @override
  String toString() =>
      'AppError(code: $code, message: $message, severity: $severity)';
}

/// Базовая реализация AppError
class BaseAppError extends AppError {
  const BaseAppError({
    required super.code,
    required super.message,
    required super.severity,
    required super.timestamp,
    super.id,
    super.stackTrace,
    super.metadata,
    super.originalError,
    super.module,
    super.userContext,
    super.canRetry,
    super.maxRetries,
    super.retryCount,
    super.displayType,
    super.shouldReport,
    super.shouldShowDetails,
  });

  @override
  BaseAppError copyWithIncrementedRetry() {
    return copyWith(retryCount: retryCount + 1);
  }

  @override
  BaseAppError copyWith({
    String? id,
    String? code,
    String? message,
    ErrorSeverity? severity,
    DateTime? timestamp,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
    Object? originalError,
    String? module,
    Map<String, dynamic>? userContext,
    bool? canRetry,
    int? maxRetries,
    int? retryCount,
    ErrorDisplayType? displayType,
    bool? shouldReport,
    bool? shouldShowDetails,
  }) {
    return BaseAppError(
      id: id ?? this.id,
      code: code ?? this.code,
      message: message ?? this.message,
      severity: severity ?? this.severity,
      timestamp: timestamp ?? this.timestamp,
      stackTrace: stackTrace ?? this.stackTrace,
      metadata: metadata ?? this.metadata,
      originalError: originalError ?? this.originalError,
      module: module ?? this.module,
      userContext: userContext ?? this.userContext,
      canRetry: canRetry ?? this.canRetry,
      maxRetries: maxRetries ?? this.maxRetries,
      retryCount: retryCount ?? this.retryCount,
      displayType: displayType ?? this.displayType,
      shouldReport: shouldReport ?? this.shouldReport,
      shouldShowDetails: shouldShowDetails ?? this.shouldShowDetails,
    );
  }
}

/// Ошибки базы данных
class DatabaseError extends AppError {
  const DatabaseError({
    required super.code,
    required super.message,
    super.severity = ErrorSeverity.error,
    required super.timestamp,
    super.id,
    super.stackTrace,
    super.metadata,
    super.originalError,
    super.module = 'Database',
    super.userContext,
    super.canRetry = true,
    super.maxRetries = 3,
    super.retryCount = 0,
    super.displayType = ErrorDisplayType.snackbar,
    super.shouldReport = true,
    super.shouldShowDetails = false,
    this.operation,
    this.tableName,
    this.query,
  });

  final String? operation;
  final String? tableName;
  final String? query;

  @override
  String get userFriendlyMessage {
    switch (code) {
      case 'DB_CONNECTION_FAILED':
        return 'Не удалось подключиться к базе данных';
      case 'DB_QUERY_FAILED':
        return 'Ошибка выполнения запроса к базе данных';
      case 'DB_TRANSACTION_FAILED':
        return 'Ошибка транзакции базы данных';
      case 'DB_CONSTRAINT_VIOLATION':
        return 'Нарушение ограничений базы данных';
      default:
        return 'Ошибка базы данных';
    }
  }

  @override
  DatabaseError copyWithIncrementedRetry() {
    return copyWith(retryCount: retryCount + 1);
  }

  @override
  DatabaseError copyWith({
    String? id,
    String? code,
    String? message,
    ErrorSeverity? severity,
    DateTime? timestamp,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
    Object? originalError,
    String? module,
    Map<String, dynamic>? userContext,
    bool? canRetry,
    int? maxRetries,
    int? retryCount,
    ErrorDisplayType? displayType,
    bool? shouldReport,
    bool? shouldShowDetails,
    String? operation,
    String? tableName,
    String? query,
  }) {
    return DatabaseError(
      id: id ?? this.id,
      code: code ?? this.code,
      message: message ?? this.message,
      severity: severity ?? this.severity,
      timestamp: timestamp ?? this.timestamp,
      stackTrace: stackTrace ?? this.stackTrace,
      metadata: metadata ?? this.metadata,
      originalError: originalError ?? this.originalError,
      module: module ?? this.module,
      userContext: userContext ?? this.userContext,
      canRetry: canRetry ?? this.canRetry,
      maxRetries: maxRetries ?? this.maxRetries,
      retryCount: retryCount ?? this.retryCount,
      displayType: displayType ?? this.displayType,
      shouldReport: shouldReport ?? this.shouldReport,
      shouldShowDetails: shouldShowDetails ?? this.shouldShowDetails,
      operation: operation ?? this.operation,
      tableName: tableName ?? this.tableName,
      query: query ?? this.query,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'operation': operation,
      'tableName': tableName,
      'query': query,
    });
    return json;
  }
}

/// Ошибки сериализации/десериализации
class SerializationError extends AppError {
  const SerializationError({
    required super.code,
    required super.message,
    super.severity = ErrorSeverity.error,
    required super.timestamp,
    super.id,
    super.stackTrace,
    super.metadata,
    super.originalError,
    super.module = 'Serialization',
    super.userContext,
    super.canRetry = false,
    super.maxRetries = 0,
    super.retryCount = 0,
    super.displayType = ErrorDisplayType.dialog,
    super.shouldReport = true,
    super.shouldShowDetails = true,
    this.dataType,
    this.field,
    this.expectedType,
    this.actualType,
  });

  final String? dataType;
  final String? field;
  final String? expectedType;
  final String? actualType;

  @override
  String get userFriendlyMessage {
    switch (code) {
      case 'SERIALIZATION_FAILED':
        return 'Ошибка сериализации данных';
      case 'DESERIALIZATION_FAILED':
        return 'Ошибка десериализации данных';
      case 'INVALID_JSON_FORMAT':
        return 'Неверный формат JSON';
      case 'MISSING_REQUIRED_FIELD':
        return 'Отсутствует обязательное поле: ${field ?? 'неизвестно'}';
      case 'TYPE_MISMATCH':
        return 'Несоответствие типов данных';
      default:
        return 'Ошибка обработки данных';
    }
  }

  @override
  SerializationError copyWithIncrementedRetry() {
    return copyWith(retryCount: retryCount + 1);
  }

  @override
  SerializationError copyWith({
    String? id,
    String? code,
    String? message,
    ErrorSeverity? severity,
    DateTime? timestamp,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
    Object? originalError,
    String? module,
    Map<String, dynamic>? userContext,
    bool? canRetry,
    int? maxRetries,
    int? retryCount,
    ErrorDisplayType? displayType,
    bool? shouldReport,
    bool? shouldShowDetails,
    String? dataType,
    String? field,
    String? expectedType,
    String? actualType,
  }) {
    return SerializationError(
      id: id ?? this.id,
      code: code ?? this.code,
      message: message ?? this.message,
      severity: severity ?? this.severity,
      timestamp: timestamp ?? this.timestamp,
      stackTrace: stackTrace ?? this.stackTrace,
      metadata: metadata ?? this.metadata,
      originalError: originalError ?? this.originalError,
      module: module ?? this.module,
      userContext: userContext ?? this.userContext,
      canRetry: canRetry ?? this.canRetry,
      maxRetries: maxRetries ?? this.maxRetries,
      retryCount: retryCount ?? this.retryCount,
      displayType: displayType ?? this.displayType,
      shouldReport: shouldReport ?? this.shouldReport,
      shouldShowDetails: shouldShowDetails ?? this.shouldShowDetails,
      dataType: dataType ?? this.dataType,
      field: field ?? this.field,
      expectedType: expectedType ?? this.expectedType,
      actualType: actualType ?? this.actualType,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'dataType': dataType,
      'field': field,
      'expectedType': expectedType,
      'actualType': actualType,
    });
    return json;
  }
}

/// Сетевые ошибки
class NetworkError extends AppError {
  const NetworkError({
    required super.code,
    required super.message,
    super.severity = ErrorSeverity.warning,
    required super.timestamp,
    super.id,
    super.stackTrace,
    super.metadata,
    super.originalError,
    super.module = 'Network',
    super.userContext,
    super.canRetry = true,
    super.maxRetries = 3,
    super.retryCount = 0,
    super.displayType = ErrorDisplayType.snackbar,
    super.shouldReport = true,
    super.shouldShowDetails = false,
    this.url,
    this.method,
    this.statusCode,
    this.responseHeaders,
    this.requestHeaders,
  });

  final String? url;
  final String? method;
  final int? statusCode;
  final Map<String, String>? responseHeaders;
  final Map<String, String>? requestHeaders;

  @override
  String get userFriendlyMessage {
    switch (code) {
      case 'NETWORK_UNAVAILABLE':
        return 'Отсутствует подключение к интернету';
      case 'NETWORK_TIMEOUT':
        return 'Превышено время ожидания сети';
      case 'NETWORK_SERVER_ERROR':
        return 'Ошибка сервера';
      case 'NETWORK_CLIENT_ERROR':
        return 'Ошибка запроса';
      case 'NETWORK_CONNECTION_FAILED':
        return 'Не удалось подключиться к серверу';
      default:
        return 'Сетевая ошибка';
    }
  }

  @override
  NetworkError copyWithIncrementedRetry() {
    return copyWith(retryCount: retryCount + 1);
  }

  @override
  NetworkError copyWith({
    String? id,
    String? code,
    String? message,
    ErrorSeverity? severity,
    DateTime? timestamp,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
    Object? originalError,
    String? module,
    Map<String, dynamic>? userContext,
    bool? canRetry,
    int? maxRetries,
    int? retryCount,
    ErrorDisplayType? displayType,
    bool? shouldReport,
    bool? shouldShowDetails,
    String? url,
    String? method,
    int? statusCode,
    Map<String, String>? responseHeaders,
    Map<String, String>? requestHeaders,
  }) {
    return NetworkError(
      id: id ?? this.id,
      code: code ?? this.code,
      message: message ?? this.message,
      severity: severity ?? this.severity,
      timestamp: timestamp ?? this.timestamp,
      stackTrace: stackTrace ?? this.stackTrace,
      metadata: metadata ?? this.metadata,
      originalError: originalError ?? this.originalError,
      module: module ?? this.module,
      userContext: userContext ?? this.userContext,
      canRetry: canRetry ?? this.canRetry,
      maxRetries: maxRetries ?? this.maxRetries,
      retryCount: retryCount ?? this.retryCount,
      displayType: displayType ?? this.displayType,
      shouldReport: shouldReport ?? this.shouldReport,
      shouldShowDetails: shouldShowDetails ?? this.shouldShowDetails,
      url: url ?? this.url,
      method: method ?? this.method,
      statusCode: statusCode ?? this.statusCode,
      responseHeaders: responseHeaders ?? this.responseHeaders,
      requestHeaders: requestHeaders ?? this.requestHeaders,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'url': url,
      'method': method,
      'statusCode': statusCode,
      'responseHeaders': responseHeaders,
      'requestHeaders': requestHeaders,
    });
    return json;
  }
}

/// Ошибки аутентификации
class AuthenticationError extends AppError {
  const AuthenticationError({
    required super.code,
    required super.message,
    super.severity = ErrorSeverity.error,
    required super.timestamp,
    super.id,
    super.stackTrace,
    super.metadata,
    super.originalError,
    super.module = 'Auth',
    super.userContext,
    super.canRetry = false,
    super.maxRetries = 0,
    super.retryCount = 0,
    super.displayType = ErrorDisplayType.dialog,
    super.shouldReport = true,
    super.shouldShowDetails = false,
    this.authMethod,
    this.userIdentifier,
  });

  final String? authMethod;
  final String? userIdentifier;

  @override
  String get userFriendlyMessage {
    switch (code) {
      case 'AUTH_INVALID_CREDENTIALS':
        return 'Неверные учетные данные';
      case 'AUTH_TOKEN_EXPIRED':
        return 'Сессия истекла, войдите заново';
      case 'AUTH_UNAUTHORIZED':
        return 'Недостаточно прав доступа';
      case 'AUTH_ACCOUNT_LOCKED':
        return 'Аккаунт заблокирован';
      case 'AUTH_BIOMETRIC_FAILED':
        return 'Биометрическая аутентификация не удалась';
      default:
        return 'Ошибка аутентификации';
    }
  }

  @override
  AuthenticationError copyWithIncrementedRetry() {
    return copyWith(retryCount: retryCount + 1);
  }

  @override
  AuthenticationError copyWith({
    String? id,
    String? code,
    String? message,
    ErrorSeverity? severity,
    DateTime? timestamp,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
    Object? originalError,
    String? module,
    Map<String, dynamic>? userContext,
    bool? canRetry,
    int? maxRetries,
    int? retryCount,
    ErrorDisplayType? displayType,
    bool? shouldReport,
    bool? shouldShowDetails,
    String? authMethod,
    String? userIdentifier,
  }) {
    return AuthenticationError(
      id: id ?? this.id,
      code: code ?? this.code,
      message: message ?? this.message,
      severity: severity ?? this.severity,
      timestamp: timestamp ?? this.timestamp,
      stackTrace: stackTrace ?? this.stackTrace,
      metadata: metadata ?? this.metadata,
      originalError: originalError ?? this.originalError,
      module: module ?? this.module,
      userContext: userContext ?? this.userContext,
      canRetry: canRetry ?? this.canRetry,
      maxRetries: maxRetries ?? this.maxRetries,
      retryCount: retryCount ?? this.retryCount,
      displayType: displayType ?? this.displayType,
      shouldReport: shouldReport ?? this.shouldReport,
      shouldShowDetails: shouldShowDetails ?? this.shouldShowDetails,
      authMethod: authMethod ?? this.authMethod,
      userIdentifier: userIdentifier ?? this.userIdentifier,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({'authMethod': authMethod, 'userIdentifier': userIdentifier});
    return json;
  }
}

/// Ошибки валидации
class ValidationError extends AppError {
  const ValidationError({
    required super.code,
    required super.message,
    super.severity = ErrorSeverity.warning,
    required super.timestamp,
    super.id,
    super.stackTrace,
    super.metadata,
    super.originalError,
    super.module = 'Validation',
    super.userContext,
    super.canRetry = false,
    super.maxRetries = 0,
    super.retryCount = 0,
    super.displayType = ErrorDisplayType.inline,
    super.shouldReport = false,
    super.shouldShowDetails = true,
    this.field,
    this.value,
    this.rule,
    this.validationErrors,
  });

  final String? field;
  final dynamic value;
  final String? rule;
  final List<String>? validationErrors;

  @override
  String get userFriendlyMessage {
    if (validationErrors != null && validationErrors!.isNotEmpty) {
      return validationErrors!.first;
    }

    switch (code) {
      case 'VALIDATION_REQUIRED':
        return 'Поле "${field ?? 'неизвестно'}" обязательно для заполнения';
      case 'VALIDATION_INVALID_FORMAT':
        return 'Неверный формат поля "${field ?? 'неизвестно'}"';
      case 'VALIDATION_TOO_SHORT':
        return 'Поле "${field ?? 'неизвестно'}" слишком короткое';
      case 'VALIDATION_TOO_LONG':
        return 'Поле "${field ?? 'неизвестно'}" слишком длинное';
      case 'VALIDATION_INVALID_EMAIL':
        return 'Неверный формат email';
      case 'VALIDATION_WEAK_PASSWORD':
        return 'Пароль слишком слабый';
      default:
        return 'Ошибка валидации';
    }
  }

  @override
  ValidationError copyWithIncrementedRetry() {
    return copyWith(retryCount: retryCount + 1);
  }

  @override
  ValidationError copyWith({
    String? id,
    String? code,
    String? message,
    ErrorSeverity? severity,
    DateTime? timestamp,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
    Object? originalError,
    String? module,
    Map<String, dynamic>? userContext,
    bool? canRetry,
    int? maxRetries,
    int? retryCount,
    ErrorDisplayType? displayType,
    bool? shouldReport,
    bool? shouldShowDetails,
    String? field,
    dynamic value,
    String? rule,
    List<String>? validationErrors,
  }) {
    return ValidationError(
      id: id ?? this.id,
      code: code ?? this.code,
      message: message ?? this.message,
      severity: severity ?? this.severity,
      timestamp: timestamp ?? this.timestamp,
      stackTrace: stackTrace ?? this.stackTrace,
      metadata: metadata ?? this.metadata,
      originalError: originalError ?? this.originalError,
      module: module ?? this.module,
      userContext: userContext ?? this.userContext,
      canRetry: canRetry ?? this.canRetry,
      maxRetries: maxRetries ?? this.maxRetries,
      retryCount: retryCount ?? this.retryCount,
      displayType: displayType ?? this.displayType,
      shouldReport: shouldReport ?? this.shouldReport,
      shouldShowDetails: shouldShowDetails ?? this.shouldShowDetails,
      field: field ?? this.field,
      value: value ?? this.value,
      rule: rule ?? this.rule,
      validationErrors: validationErrors ?? this.validationErrors,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'field': field,
      'value': value?.toString(),
      'rule': rule,
      'validationErrors': validationErrors,
    });
    return json;
  }
}
