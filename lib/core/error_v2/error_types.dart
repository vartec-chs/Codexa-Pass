/// Конкретные реализации ошибок для различных категорий
///
/// Этот файл содержит специализированные классы ошибок для каждой категории,
/// с предустановленными параметрами и логикой восстановления

import 'error_base.dart';

/// Ошибки аутентификации
class AuthenticationErrorV2 extends BaseAppErrorV2 {
  final AuthenticationErrorType errorType;
  final String? username;
  final int? attemptNumber;

  AuthenticationErrorV2({
    required this.errorType,
    required String message,
    this.username,
    this.attemptNumber,
    String? technicalDetails,
    Map<String, Object?> context = const {},
    ErrorSeverityV2? severity,
    DateTime? timestamp,
    Object? originalError,
    StackTrace? stackTrace,
  }) : super(
         id: _generateId('AUTH', errorType.name),
         category: ErrorCategoryV2.authentication,
         type: errorType.name,
         message: message,
         technicalDetails: technicalDetails,
         context: {
           ...context,
           if (username != null) 'username': username,
           if (attemptNumber != null) 'attemptNumber': attemptNumber,
         },
         severity: severity ?? _getDefaultSeverity(errorType),
         timestamp: timestamp,
         originalError: originalError,
         stackTrace: stackTrace,
         isRecoverable: _isRecoverable(errorType),
         recoveryStrategy: _getRecoveryStrategy(errorType),
         shouldDisplay: _shouldDisplay(errorType),
         displayPriority: _getDisplayPriority(errorType),
         maxRetryAttempts: _getMaxRetryAttempts(errorType),
         retryDelay: _getRetryDelay(errorType),
       );

  @override
  AuthenticationErrorV2 copyWith({
    String? message,
    String? technicalDetails,
    Map<String, Object?>? context,
    ErrorSeverityV2? severity,
    Object? originalError,
    StackTrace? stackTrace,
  }) {
    return AuthenticationErrorV2(
      errorType: errorType,
      message: message ?? this.message,
      username: username,
      attemptNumber: attemptNumber,
      technicalDetails: technicalDetails ?? this.technicalDetails,
      context: context ?? this.context,
      severity: severity ?? this.severity,
      originalError: originalError ?? this.originalError,
      stackTrace: stackTrace ?? this.stackTrace,
    );
  }

  static ErrorSeverityV2 _getDefaultSeverity(AuthenticationErrorType type) {
    switch (type) {
      case AuthenticationErrorType.invalidCredentials:
      case AuthenticationErrorType.pinIncorrect:
        return ErrorSeverityV2.warning;
      case AuthenticationErrorType.accountLocked:
      case AuthenticationErrorType.sessionExpired:
        return ErrorSeverityV2.error;
      case AuthenticationErrorType.biometricFailed:
        return ErrorSeverityV2.critical;
      default:
        return ErrorSeverityV2.error;
    }
  }

  static bool _isRecoverable(AuthenticationErrorType type) {
    switch (type) {
      case AuthenticationErrorType.invalidCredentials:
      case AuthenticationErrorType.pinIncorrect:
      case AuthenticationErrorType.biometricFailed:
        return true;
      default:
        return false;
    }
  }

  static RecoveryStrategyV2? _getRecoveryStrategy(
    AuthenticationErrorType type,
  ) {
    switch (type) {
      case AuthenticationErrorType.invalidCredentials:
      case AuthenticationErrorType.pinIncorrect:
        return RecoveryStrategyV2.retry;
      case AuthenticationErrorType.biometricFailed:
        return RecoveryStrategyV2.fallback;
      case AuthenticationErrorType.sessionExpired:
        return RecoveryStrategyV2.reset;
      default:
        return null;
    }
  }

  static bool _shouldDisplay(AuthenticationErrorType type) => true;

  static int _getDisplayPriority(AuthenticationErrorType type) {
    switch (type) {
      case AuthenticationErrorType.accountLocked:
        return 10;
      case AuthenticationErrorType.sessionExpired:
        return 8;
      default:
        return 5;
    }
  }

  static int _getMaxRetryAttempts(AuthenticationErrorType type) {
    switch (type) {
      case AuthenticationErrorType.invalidCredentials:
      case AuthenticationErrorType.pinIncorrect:
        return 3;
      case AuthenticationErrorType.biometricFailed:
        return 1;
      default:
        return 0;
    }
  }

  static Duration _getRetryDelay(AuthenticationErrorType type) {
    switch (type) {
      case AuthenticationErrorType.invalidCredentials:
        return const Duration(seconds: 2);
      case AuthenticationErrorType.pinIncorrect:
        return const Duration(seconds: 1);
      default:
        return const Duration(seconds: 1);
    }
  }
}

/// Типы ошибок аутентификации
enum AuthenticationErrorType {
  invalidCredentials,
  userNotFound,
  userAlreadyExists,
  sessionExpired,
  accountLocked,
  biometricNotAvailable,
  biometricNotEnrolled,
  biometricFailed,
  pinIncorrect,
  masterPasswordIncorrect,
  twoFactorRequired,
  twoFactorInvalid,
  tokenExpired,
  tokenInvalid,
  permissionDenied,
}

/// Ошибки шифрования
class EncryptionErrorV2 extends BaseAppErrorV2 {
  final EncryptionErrorType errorType;
  final String? algorithm;
  final String? keyId;

  EncryptionErrorV2({
    required this.errorType,
    required String message,
    this.algorithm,
    this.keyId,
    String? technicalDetails,
    Map<String, Object?> context = const {},
    ErrorSeverityV2? severity,
    DateTime? timestamp,
    Object? originalError,
    StackTrace? stackTrace,
  }) : super(
         id: _generateId('CRYPT', errorType.name),
         category: ErrorCategoryV2.encryption,
         type: errorType.name,
         message: message,
         technicalDetails: technicalDetails,
         context: {
           ...context,
           if (algorithm != null) 'algorithm': algorithm,
           if (keyId != null) 'keyId': keyId,
         },
         severity: severity ?? ErrorSeverityV2.critical,
         timestamp: timestamp,
         originalError: originalError,
         stackTrace: stackTrace,
         isRecoverable: errorType == EncryptionErrorType.keyDerivationFailed,
         recoveryStrategy: errorType == EncryptionErrorType.keyDerivationFailed
             ? RecoveryStrategyV2.retry
             : null,
         shouldDisplay: true,
         displayPriority: 9,
         maxRetryAttempts: errorType == EncryptionErrorType.keyDerivationFailed
             ? 2
             : 0,
         retryDelay: const Duration(seconds: 2),
       );

  @override
  EncryptionErrorV2 copyWith({
    String? message,
    String? technicalDetails,
    Map<String, Object?>? context,
    ErrorSeverityV2? severity,
    Object? originalError,
    StackTrace? stackTrace,
  }) {
    return EncryptionErrorV2(
      errorType: errorType,
      message: message ?? this.message,
      algorithm: algorithm,
      keyId: keyId,
      technicalDetails: technicalDetails ?? this.technicalDetails,
      context: context ?? this.context,
      severity: severity ?? this.severity,
      originalError: originalError ?? this.originalError,
      stackTrace: stackTrace ?? this.stackTrace,
    );
  }
}

/// Типы ошибок шифрования
enum EncryptionErrorType {
  keyGenerationFailed,
  encryptionFailed,
  decryptionFailed,
  keyDerivationFailed,
  invalidKey,
  corruptedData,
  unsupportedAlgorithm,
  hardwareSecurityModuleError,
  keyStorageError,
  certificateError,
}

/// Ошибки базы данных
class DatabaseErrorV2 extends BaseAppErrorV2 {
  final DatabaseErrorType errorType;
  final String? tableName;
  final String? query;
  final int? affectedRows;

  DatabaseErrorV2({
    required this.errorType,
    required String message,
    this.tableName,
    this.query,
    this.affectedRows,
    String? technicalDetails,
    Map<String, Object?> context = const {},
    ErrorSeverityV2? severity,
    DateTime? timestamp,
    Object? originalError,
    StackTrace? stackTrace,
  }) : super(
         id: _generateId('DB', errorType.name),
         category: ErrorCategoryV2.database,
         type: errorType.name,
         message: message,
         technicalDetails: technicalDetails,
         context: {
           ...context,
           if (tableName != null) 'tableName': tableName,
           if (query != null) 'query': query,
           if (affectedRows != null) 'affectedRows': affectedRows,
         },
         severity: severity ?? _getDbSeverity(errorType),
         timestamp: timestamp,
         originalError: originalError,
         stackTrace: stackTrace,
         isRecoverable: _isDbRecoverable(errorType),
         recoveryStrategy: _getDbRecoveryStrategy(errorType),
         shouldDisplay: _shouldDbDisplay(errorType),
         displayPriority: _getDbDisplayPriority(errorType),
         maxRetryAttempts: _getDbMaxRetryAttempts(errorType),
         retryDelay: const Duration(milliseconds: 500),
       );

  @override
  DatabaseErrorV2 copyWith({
    String? message,
    String? technicalDetails,
    Map<String, Object?>? context,
    ErrorSeverityV2? severity,
    Object? originalError,
    StackTrace? stackTrace,
  }) {
    return DatabaseErrorV2(
      errorType: errorType,
      message: message ?? this.message,
      tableName: tableName,
      query: query,
      affectedRows: affectedRows,
      technicalDetails: technicalDetails ?? this.technicalDetails,
      context: context ?? this.context,
      severity: severity ?? this.severity,
      originalError: originalError ?? this.originalError,
      stackTrace: stackTrace ?? this.stackTrace,
    );
  }

  static ErrorSeverityV2 _getDbSeverity(DatabaseErrorType type) {
    switch (type) {
      case DatabaseErrorType.recordNotFound:
        return ErrorSeverityV2.warning;
      case DatabaseErrorType.duplicateEntry:
        return ErrorSeverityV2.error;
      case DatabaseErrorType.corruptedDatabase:
        return ErrorSeverityV2.fatal;
      default:
        return ErrorSeverityV2.error;
    }
  }

  static bool _isDbRecoverable(DatabaseErrorType type) {
    switch (type) {
      case DatabaseErrorType.connectionFailed:
      case DatabaseErrorType.queryFailed:
      case DatabaseErrorType.transactionFailed:
        return true;
      default:
        return false;
    }
  }

  static RecoveryStrategyV2? _getDbRecoveryStrategy(DatabaseErrorType type) {
    switch (type) {
      case DatabaseErrorType.connectionFailed:
        return RecoveryStrategyV2.retryWithBackoff;
      case DatabaseErrorType.databaseLocked:
        return RecoveryStrategyV2.retry;
      case DatabaseErrorType.corruptedDatabase:
        return RecoveryStrategyV2.reset;
      default:
        return null;
    }
  }

  static bool _shouldDbDisplay(DatabaseErrorType type) {
    switch (type) {
      case DatabaseErrorType.recordNotFound:
        return false;
      default:
        return true;
    }
  }

  static int _getDbDisplayPriority(DatabaseErrorType type) {
    switch (type) {
      case DatabaseErrorType.corruptedDatabase:
        return 10;
      case DatabaseErrorType.connectionFailed:
        return 7;
      default:
        return 3;
    }
  }

  static int _getDbMaxRetryAttempts(DatabaseErrorType type) {
    switch (type) {
      case DatabaseErrorType.connectionFailed:
        return 5;
      case DatabaseErrorType.queryFailed:
      case DatabaseErrorType.transactionFailed:
        return 3;
      case DatabaseErrorType.databaseLocked:
        return 10;
      default:
        return 0;
    }
  }
}

/// Типы ошибок базы данных
enum DatabaseErrorType {
  connectionFailed,
  queryFailed,
  transactionFailed,
  migrationFailed,
  corruptedDatabase,
  databaseLocked,
  insufficientSpace,
  permissionDenied,
  recordNotFound,
  duplicateEntry,
  constraintViolation,
  foreignKeyViolation,
  indexError,
  backupFailed,
  restoreFailed,
}

/// Сетевые ошибки
class NetworkErrorV2 extends BaseAppErrorV2 {
  final NetworkErrorType errorType;
  final String? url;
  final int? statusCode;
  final String? method;
  final Duration? timeout;

  NetworkErrorV2({
    required this.errorType,
    required String message,
    this.url,
    this.statusCode,
    this.method,
    this.timeout,
    String? technicalDetails,
    Map<String, Object?> context = const {},
    ErrorSeverityV2? severity,
    DateTime? timestamp,
    Object? originalError,
    StackTrace? stackTrace,
  }) : super(
         id: _generateId('NET', errorType.name),
         category: ErrorCategoryV2.network,
         type: errorType.name,
         message: message,
         technicalDetails: technicalDetails,
         context: {
           ...context,
           if (url != null) 'url': url,
           if (statusCode != null) 'statusCode': statusCode,
           if (method != null) 'method': method,
           if (timeout != null) 'timeout': timeout.inMilliseconds,
         },
         severity: severity ?? _getNetSeverity(errorType),
         timestamp: timestamp,
         originalError: originalError,
         stackTrace: stackTrace,
         isRecoverable: _isNetRecoverable(errorType),
         recoveryStrategy: _getNetRecoveryStrategy(errorType),
         shouldDisplay: _shouldNetDisplay(errorType),
         displayPriority: 4,
         maxRetryAttempts: _getNetMaxRetryAttempts(errorType),
         retryDelay: _getNetRetryDelay(errorType),
       );

  @override
  NetworkErrorV2 copyWith({
    String? message,
    String? technicalDetails,
    Map<String, Object?>? context,
    ErrorSeverityV2? severity,
    Object? originalError,
    StackTrace? stackTrace,
  }) {
    return NetworkErrorV2(
      errorType: errorType,
      message: message ?? this.message,
      url: url,
      statusCode: statusCode,
      method: method,
      timeout: timeout,
      technicalDetails: technicalDetails ?? this.technicalDetails,
      context: context ?? this.context,
      severity: severity ?? this.severity,
      originalError: originalError ?? this.originalError,
      stackTrace: stackTrace ?? this.stackTrace,
    );
  }

  static ErrorSeverityV2 _getNetSeverity(NetworkErrorType type) {
    switch (type) {
      case NetworkErrorType.noConnection:
        return ErrorSeverityV2.warning;
      case NetworkErrorType.timeout:
        return ErrorSeverityV2.error;
      case NetworkErrorType.serverError:
        return ErrorSeverityV2.critical;
      default:
        return ErrorSeverityV2.error;
    }
  }

  static bool _isNetRecoverable(NetworkErrorType type) {
    switch (type) {
      case NetworkErrorType.noConnection:
      case NetworkErrorType.timeout:
      case NetworkErrorType.serverError:
        return true;
      default:
        return false;
    }
  }

  static RecoveryStrategyV2? _getNetRecoveryStrategy(NetworkErrorType type) {
    switch (type) {
      case NetworkErrorType.noConnection:
      case NetworkErrorType.timeout:
        return RecoveryStrategyV2.retryWithBackoff;
      case NetworkErrorType.serverError:
        return RecoveryStrategyV2.retry;
      default:
        return null;
    }
  }

  static bool _shouldNetDisplay(NetworkErrorType type) {
    switch (type) {
      case NetworkErrorType.noConnection:
        return true;
      default:
        return false;
    }
  }

  static int _getNetMaxRetryAttempts(NetworkErrorType type) {
    switch (type) {
      case NetworkErrorType.noConnection:
        return 3;
      case NetworkErrorType.timeout:
        return 2;
      case NetworkErrorType.serverError:
        return 1;
      default:
        return 0;
    }
  }

  static Duration _getNetRetryDelay(NetworkErrorType type) {
    switch (type) {
      case NetworkErrorType.noConnection:
        return const Duration(seconds: 5);
      case NetworkErrorType.timeout:
        return const Duration(seconds: 2);
      default:
        return const Duration(seconds: 1);
    }
  }
}

/// Типы сетевых ошибок
enum NetworkErrorType {
  noConnection,
  timeout,
  serverError,
  clientError,
  certificateError,
  rateLimitExceeded,
  serviceMaintenance,
  invalidResponse,
  syncFailed,
  backupFailed,
  downloadFailed,
  uploadFailed,
  connectionLost,
  proxyError,
  dnsError,
}

/// Ошибки валидации
class ValidationErrorV2 extends BaseAppErrorV2 {
  final ValidationErrorType errorType;
  final String? field;
  final Object? value;
  final Map<String, Object?>? constraints;

  ValidationErrorV2({
    required this.errorType,
    required String message,
    this.field,
    this.value,
    this.constraints,
    String? technicalDetails,
    Map<String, Object?> context = const {},
    ErrorSeverityV2? severity,
    DateTime? timestamp,
    Object? originalError,
    StackTrace? stackTrace,
  }) : super(
         id: _generateId('VALID', errorType.name),
         category: ErrorCategoryV2.validation,
         type: errorType.name,
         message: message,
         technicalDetails: technicalDetails,
         context: {
           ...context,
           if (field != null) 'field': field,
           if (value != null) 'value': value,
           if (constraints != null) 'constraints': constraints,
         },
         severity: severity ?? ErrorSeverityV2.warning,
         timestamp: timestamp,
         originalError: originalError,
         stackTrace: stackTrace,
         isRecoverable: true,
         recoveryStrategy: RecoveryStrategyV2.none,
         shouldDisplay: true,
         displayPriority: 1,
         maxRetryAttempts: 0,
         retryDelay: Duration.zero,
       );

  @override
  ValidationErrorV2 copyWith({
    String? message,
    String? technicalDetails,
    Map<String, Object?>? context,
    ErrorSeverityV2? severity,
    Object? originalError,
    StackTrace? stackTrace,
  }) {
    return ValidationErrorV2(
      errorType: errorType,
      message: message ?? this.message,
      field: field,
      value: value,
      constraints: constraints,
      technicalDetails: technicalDetails ?? this.technicalDetails,
      context: context ?? this.context,
      severity: severity ?? this.severity,
      originalError: originalError ?? this.originalError,
      stackTrace: stackTrace ?? this.stackTrace,
    );
  }
}

/// Типы ошибок валидации
enum ValidationErrorType {
  required,
  invalidFormat,
  tooShort,
  tooLong,
  weakPassword,
  passwordMismatch,
  invalidEmail,
  invalidUrl,
  duplicateValue,
  outOfRange,
  invalidCharacters,
  patternMismatch,
  numericExpected,
  booleanExpected,
  dateExpected,
  futureDate,
  pastDate,
}

/// Вспомогательная функция для генерации уникальных ID ошибок
String _generateId(String prefix, String type) {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  return '${prefix}_${type}_$timestamp';
}
