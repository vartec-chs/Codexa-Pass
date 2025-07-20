import '../models/result.dart';
import '../models/app_error.dart';
import '../models/error_severity.dart';
import '../models/error_display_type.dart';

/// Расширения для удобной работы с Result и AppError
extension AppResultExtensions<T> on AppResult<T> {
  /// Преобразовать в Future с автоматической обработкой ошибок
  Future<T> toFutureWithErrorHandling({
    void Function(AppError error)? onError,
  }) async {
    return fold((value) => Future.value(value), (error) {
      onError?.call(error);
      return Future.error(error);
    });
  }

  /// Получить значение или создать ошибку по умолчанию
  T getOrCreateDefault(
    T Function() defaultValue,
    AppError Function()? defaultError,
  ) {
    return fold((value) => value, (error) {
      if (defaultError != null) {
        // Можно логировать defaultError
      }
      return defaultValue();
    });
  }

  /// Преобразовать ошибку с сохранением значения
  AppResult<T> mapErrorWithContext(
    AppError Function(AppError error) transform,
  ) {
    return mapError(transform);
  }

  /// Добавить контекст к ошибке
  AppResult<T> withErrorContext({
    String? module,
    String? operation,
    Map<String, dynamic>? additionalMetadata,
  }) {
    return mapError((error) {
      final metadata = <String, dynamic>{
        if (error.metadata != null) ...error.metadata!,
        if (operation != null) 'operation': operation,
        if (additionalMetadata != null) ...additionalMetadata,
      };

      return error.copyWith(module: module ?? error.module, metadata: metadata);
    });
  }

  /// Retry механизм для Result
  Future<AppResult<T>> retryOnFailure(
    Future<AppResult<T>> Function() operation, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
    bool Function(AppError error)? shouldRetry,
  }) async {
    if (isSuccess) return this;

    final error = this.error;

    if (shouldRetry != null && !shouldRetry(error)) {
      return this;
    }

    if (!error.canRetryOperation || error.retryCount >= maxRetries) {
      return this;
    }

    await Future.delayed(delay);

    try {
      final retryResult = await operation();
      return retryResult.mapError(
        (retryError) => retryError.copyWithIncrementedRetry(),
      );
    } catch (e, stackTrace) {
      return AppResult.failure(
        BaseAppError(
          code: 'RETRY_FAILED',
          message: 'Retry operation failed: $e',
          severity: ErrorSeverity.error,
          timestamp: DateTime.now(),
          stackTrace: stackTrace,
          originalError: e,
          module: error.module,
          retryCount: error.retryCount + 1,
        ),
      );
    }
  }
}

/// Расширения для работы с Future<AppResult>
extension FutureAppResultExtensions<T> on Future<AppResult<T>> {
  /// Обработать результат с автоматическим логированием ошибок
  Future<AppResult<T>> logOnError({String? operation, String? module}) async {
    final result = await this;

    return result.onFailure((error) {
      // Здесь можно добавить автоматическое логирование
      print('Operation failed: $operation, Error: ${error.code}');
    });
  }

  /// Преобразовать в обычный Future с обработкой ошибок
  Future<T> unwrapOrThrow() async {
    final result = await this;
    return result.value;
  }

  /// Получить значение или значение по умолчанию
  Future<T> unwrapOr(T defaultValue) async {
    final result = await this;
    return result.getOrElse(defaultValue);
  }

  /// Цепочка операций с Result
  Future<AppResult<R>> flatMapAsync<R>(
    Future<AppResult<R>> Function(T value) transform,
  ) async {
    final result = await this;
    if (result.isFailure) {
      return AppResult.failure(result.error);
    }
    return await transform(result.value);
  }
}

/// Утилиты для создания стандартных ошибок
class ErrorFactory {
  /// Создать ошибку валидации
  static ValidationError validation({
    required String message,
    String? field,
    dynamic value,
    String? rule,
    List<String>? validationErrors,
  }) {
    return ValidationError(
      code: 'VALIDATION_ERROR',
      message: message,
      timestamp: DateTime.now(),
      field: field,
      value: value,
      rule: rule,
      validationErrors: validationErrors,
    );
  }

  /// Создать сетевую ошибку
  static NetworkError network({
    required String code,
    required String message,
    String? url,
    String? method,
    int? statusCode,
    Map<String, String>? responseHeaders,
    Map<String, String>? requestHeaders,
  }) {
    return NetworkError(
      code: code,
      message: message,
      timestamp: DateTime.now(),
      url: url,
      method: method,
      statusCode: statusCode,
      responseHeaders: responseHeaders,
      requestHeaders: requestHeaders,
    );
  }

  /// Создать ошибку базы данных
  static DatabaseError database({
    required String code,
    required String message,
    String? operation,
    String? tableName,
    String? query,
    Object? originalError,
    StackTrace? stackTrace,
  }) {
    return DatabaseError(
      code: code,
      message: message,
      timestamp: DateTime.now(),
      operation: operation,
      tableName: tableName,
      query: query,
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  /// Создать ошибку аутентификации
  static AuthenticationError authentication({
    required String code,
    required String message,
    String? authMethod,
    String? userIdentifier,
  }) {
    return AuthenticationError(
      code: code,
      message: message,
      timestamp: DateTime.now(),
      authMethod: authMethod,
      userIdentifier: userIdentifier,
    );
  }

  /// Создать общую ошибку
  static BaseAppError generic({
    required String code,
    required String message,
    ErrorSeverity severity = ErrorSeverity.error,
    String? module,
    Object? originalError,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
    ErrorDisplayType displayType = ErrorDisplayType.snackbar,
  }) {
    return BaseAppError(
      code: code,
      message: message,
      severity: severity,
      timestamp: DateTime.now(),
      module: module,
      originalError: originalError,
      stackTrace: stackTrace,
      metadata: metadata,
      displayType: displayType,
    );
  }
}

/// Обертки для работы с исключениями
class SafeOperations {
  /// Безопасное выполнение операции с возвратом Result
  static AppResult<T> trySync<T>(
    T Function() operation, {
    String? errorCode,
    String? module,
    Map<String, dynamic>? metadata,
  }) {
    try {
      return AppResult.success(operation());
    } catch (error, stackTrace) {
      return AppResult.failure(
        ErrorFactory.generic(
          code: errorCode ?? 'OPERATION_FAILED',
          message: error.toString(),
          module: module,
          originalError: error,
          stackTrace: stackTrace,
          metadata: metadata,
        ),
      );
    }
  }

  /// Безопасное выполнение асинхронной операции
  static Future<AppResult<T>> tryAsync<T>(
    Future<T> Function() operation, {
    String? errorCode,
    String? module,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final result = await operation();
      return AppResult.success(result);
    } catch (error, stackTrace) {
      return AppResult.failure(
        ErrorFactory.generic(
          code: errorCode ?? 'ASYNC_OPERATION_FAILED',
          message: error.toString(),
          module: module,
          originalError: error,
          stackTrace: stackTrace,
          metadata: metadata,
        ),
      );
    }
  }

  /// Безопасное выполнение операции с возможностью повтора
  static Future<AppResult<T>> tryWithRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
    String? errorCode,
    String? module,
    Map<String, dynamic>? metadata,
  }) async {
    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        final result = await operation();
        return AppResult.success(result);
      } catch (error, stackTrace) {
        if (attempt == maxRetries) {
          return AppResult.failure(
            ErrorFactory.generic(
              code: errorCode ?? 'OPERATION_FAILED_AFTER_RETRIES',
              message: 'Operation failed after $maxRetries retries: $error',
              module: module,
              originalError: error,
              stackTrace: stackTrace,
              metadata: {
                if (metadata != null) ...metadata,
                'attempts': attempt + 1,
                'maxRetries': maxRetries,
              },
            ),
          );
        }

        if (attempt < maxRetries) {
          await Future.delayed(delay);
        }
      }
    }

    // Этот код никогда не должен выполниться
    return AppResult.failure(
      ErrorFactory.generic(
        code: 'UNEXPECTED_ERROR',
        message: 'Unexpected error in retry operation',
        module: module,
      ),
    );
  }
}
