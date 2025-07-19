/// Базовый абстрактный класс для всех ошибок приложения
sealed class AppError {
  const AppError();

  /// Получает сообщение ошибки
  String get message;

  /// Получает детали ошибки
  String? get details;

  /// Проверяет, является ли ошибка критической
  bool get isCritical;

  /// Фабричные конструкторы для различных типов ошибок

  /// Ошибки аутентификации
  const factory AppError.authentication({
    required AuthenticationErrorType type,
    required String message,
    String? details,
    bool isCritical,
  }) = AuthenticationError;

  /// Ошибки шифрования/дешифрования
  const factory AppError.encryption({
    required EncryptionErrorType type,
    required String message,
    String? details,
    bool isCritical,
  }) = EncryptionError;

  /// Ошибки базы данных
  const factory AppError.database({
    required DatabaseErrorType type,
    required String message,
    String? details,
    bool isCritical,
  }) = DatabaseError;

  /// Сетевые ошибки
  const factory AppError.network({
    required NetworkErrorType type,
    required String message,
    String? details,
    bool isCritical,
  }) = NetworkError;

  /// Ошибки валидации
  const factory AppError.validation({
    required ValidationErrorType type,
    required String message,
    String? field,
    String? details,
    bool isCritical,
  }) = ValidationError;

  /// Ошибки файловой системы
  const factory AppError.storage({
    required StorageErrorType type,
    required String message,
    String? details,
    bool isCritical,
  }) = StorageError;

  /// Ошибки безопасности
  const factory AppError.security({
    required SecurityErrorType type,
    required String message,
    String? details,
    bool isCritical,
  }) = SecurityError;

  /// Системные ошибки
  const factory AppError.system({
    required SystemErrorType type,
    required String message,
    String? details,
    bool isCritical,
  }) = SystemError;

  /// Неизвестные ошибки
  const factory AppError.unknown({
    required String message,
    String? details,
    Object? originalError,
    StackTrace? stackTrace,
    bool isCritical,
  }) = UnknownError;
}

/// Реализация ошибок аутентификации
class AuthenticationError extends AppError {
  final AuthenticationErrorType type;
  @override
  final String message;
  @override
  final String? details;
  @override
  final bool isCritical;

  const AuthenticationError({
    required this.type,
    required this.message,
    this.details,
    this.isCritical = false,
  });
}

/// Реализация ошибок шифрования
class EncryptionError extends AppError {
  final EncryptionErrorType type;
  @override
  final String message;
  @override
  final String? details;
  @override
  final bool isCritical;

  const EncryptionError({
    required this.type,
    required this.message,
    this.details,
    this.isCritical = true,
  });
}

/// Реализация ошибок базы данных
class DatabaseError extends AppError {
  final DatabaseErrorType type;
  @override
  final String message;
  @override
  final String? details;
  @override
  final bool isCritical;

  const DatabaseError({
    required this.type,
    required this.message,
    this.details,
    this.isCritical = false,
  });
}

/// Реализация сетевых ошибок
class NetworkError extends AppError {
  final NetworkErrorType type;
  @override
  final String message;
  @override
  final String? details;
  @override
  final bool isCritical;

  const NetworkError({
    required this.type,
    required this.message,
    this.details,
    this.isCritical = false,
  });
}

/// Реализация ошибок валидации
class ValidationError extends AppError {
  final ValidationErrorType type;
  @override
  final String message;
  final String? field;
  @override
  final String? details;
  @override
  final bool isCritical;

  const ValidationError({
    required this.type,
    required this.message,
    this.field,
    this.details,
    this.isCritical = false,
  });
}

/// Реализация ошибок хранилища
class StorageError extends AppError {
  final StorageErrorType type;
  @override
  final String message;
  @override
  final String? details;
  @override
  final bool isCritical;

  const StorageError({
    required this.type,
    required this.message,
    this.details,
    this.isCritical = false,
  });
}

/// Реализация ошибок безопасности
class SecurityError extends AppError {
  final SecurityErrorType type;
  @override
  final String message;
  @override
  final String? details;
  @override
  final bool isCritical;

  const SecurityError({
    required this.type,
    required this.message,
    this.details,
    this.isCritical = true,
  });
}

/// Реализация системных ошибок
class SystemError extends AppError {
  final SystemErrorType type;
  @override
  final String message;
  @override
  final String? details;
  @override
  final bool isCritical;

  const SystemError({
    required this.type,
    required this.message,
    this.details,
    this.isCritical = true,
  });
}

/// Реализация неизвестных ошибок
class UnknownError extends AppError {
  @override
  final String message;
  @override
  final String? details;
  final Object? originalError;
  final StackTrace? stackTrace;
  @override
  final bool isCritical;

  const UnknownError({
    required this.message,
    this.details,
    this.originalError,
    this.stackTrace,
    this.isCritical = false,
  });
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
}

/// Типы ошибок хранилища
enum StorageErrorType {
  fileNotFound,
  accessDenied,
  insufficientSpace,
  corruptedFile,
  backupFailed,
  restoreFailed,
  exportFailed,
  importFailed,
  syncFailed,
}

/// Типы ошибок безопасности
enum SecurityErrorType {
  dataBreachDetected,
  unauthorizedAccess,
  maliciousActivity,
  certificateExpired,
  integrityCheckFailed,
  suspiciousLogin,
  deviceCompromised,
  dataLeakage,
}

/// Типы системных ошибок
enum SystemErrorType {
  outOfMemory,
  diskFull,
  permissionDenied,
  platformNotSupported,
  serviceUnavailable,
  configurationError,
  initializationFailed,
  unexpectedShutdown,
}
