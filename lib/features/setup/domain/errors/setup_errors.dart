import 'package:codexa_pass/core/error/error_system.dart';

/// Ошибки, связанные с настройкой приложения
abstract class SetupError extends AppError {
  const SetupError({
    required super.code,
    required super.message,
    required super.severity,
    required super.timestamp,
    super.id,
    super.stackTrace,
    super.metadata,
    super.originalError,
    super.canRetry = true,
    super.maxRetries = 3,
    super.displayType = ErrorDisplayType.dialog,
    super.shouldReport = true,
    super.shouldShowDetails = true,
  }) : super(module: 'Setup');

  /// Создать SetupError из общей ошибки
  factory SetupError.fromError(Object error, StackTrace? stackTrace) {
    return SetupPreferencesError(originalError: error, stackTrace: stackTrace);
  }
}

/// Ошибка сохранения настроек
class SetupPreferencesError extends SetupError {
  SetupPreferencesError({super.originalError, super.stackTrace, super.metadata})
    : super(
        code: 'SETUP_PREFERENCES_ERROR',
        message: 'Не удалось сохранить настройки',
        severity: ErrorSeverity.error,
        timestamp: DateTime.now(),
      );

  @override
  String get userFriendlyMessage =>
      'Произошла ошибка при сохранении настроек. Попробуйте еще раз.';

  @override
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
  }) {
    return SetupPreferencesError(
      originalError: originalError ?? this.originalError,
      stackTrace: stackTrace ?? this.stackTrace,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  AppError copyWithIncrementedRetry() {
    return copyWith(retryCount: retryCount + 1);
  }

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'errorType': 'SetupPreferencesError',
  };
}

/// Ошибка навигации после завершения настройки
class SetupNavigationError extends SetupError {
  SetupNavigationError({super.originalError, super.stackTrace, super.metadata})
    : super(
        code: 'SETUP_NAVIGATION_ERROR',
        message: 'Не удалось перейти к главному экрану',
        severity: ErrorSeverity.warning,
        timestamp: DateTime.now(),
        canRetry: false,
      );

  @override
  String get userFriendlyMessage =>
      'Настройка завершена, но возникла проблема с навигацией. Перезапустите приложение.';

  @override
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
  }) {
    return SetupNavigationError(
      originalError: originalError ?? this.originalError,
      stackTrace: stackTrace ?? this.stackTrace,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  AppError copyWithIncrementedRetry() {
    return copyWith(retryCount: retryCount + 1);
  }

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'errorType': 'SetupNavigationError',
  };
}

/// Ошибка изменения темы
class SetupThemeError extends SetupError {
  SetupThemeError({
    required this.themeMode,
    super.originalError,
    super.stackTrace,
    super.metadata,
  }) : super(
         code: 'SETUP_THEME_ERROR',
         message: 'Не удалось изменить тему',
         severity: ErrorSeverity.warning,
         timestamp: DateTime.now(),
         canRetry: true,
         maxRetries: 1,
         displayType: ErrorDisplayType.snackbar,
       );

  final String themeMode;

  @override
  String get userFriendlyMessage =>
      'Не удалось применить выбранную тему. Попробуйте выбрать другую.';

  @override
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
  }) {
    return SetupThemeError(
      themeMode: themeMode,
      originalError: originalError ?? this.originalError,
      stackTrace: stackTrace ?? this.stackTrace,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  AppError copyWithIncrementedRetry() {
    return copyWith(retryCount: retryCount + 1);
  }

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'errorType': 'SetupThemeError',
    'themeMode': themeMode,
  };
}

/// Ошибка инициализации setup экрана
class SetupInitializationError extends SetupError {
  SetupInitializationError({
    super.originalError,
    super.stackTrace,
    super.metadata,
  }) : super(
         code: 'SETUP_INITIALIZATION_ERROR',
         message: 'Не удалось инициализировать экран настройки',
         severity: ErrorSeverity.critical,
         timestamp: DateTime.now(),
         canRetry: true,
         maxRetries: 2,
       );

  @override
  String get userFriendlyMessage =>
      'Возникла проблема при запуске настройки. Перезапустите приложение.';

  @override
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
  }) {
    return SetupInitializationError(
      originalError: originalError ?? this.originalError,
      stackTrace: stackTrace ?? this.stackTrace,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  AppError copyWithIncrementedRetry() {
    return copyWith(retryCount: retryCount + 1);
  }

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'errorType': 'SetupInitializationError',
  };
}
