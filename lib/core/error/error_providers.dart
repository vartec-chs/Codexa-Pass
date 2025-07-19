import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codexa_pass/core/logging/app_logger.dart';
import 'app_error.dart';
import 'error_handler.dart';

/// Расширение для автоматической обработки ошибок в Riverpod провайдерах
extension AsyncValueErrorHandler<T> on AsyncValue<T> {
  /// Обрабатывает ошибки в AsyncValue для Consumer виджетов
  void handleErrorInWidget(WidgetRef ref) {
    whenOrNull(
      error: (error, stackTrace) {
        final appError = _convertToAppError(error, stackTrace);
        ref.read(errorManagerProvider.notifier).handleError(appError);
      },
    );
  }

  /// Конвертирует исключение в AppError
  AppError _convertToAppError(Object error, StackTrace stackTrace) {
    // Попытка распознать тип ошибки
    if (error is AppError) {
      return error;
    }

    // Сетевые ошибки
    if (error.toString().contains('SocketException') ||
        error.toString().contains('HandshakeException') ||
        error.toString().contains('TimeoutException')) {
      return AppError.network(
        type: NetworkErrorType.noConnection,
        message: 'Ошибка сетевого соединения',
        details: error.toString(),
      );
    }

    // Ошибки файловой системы
    if (error.toString().contains('FileSystemException') ||
        error.toString().contains('PathNotFoundException')) {
      return AppError.storage(
        type: StorageErrorType.fileNotFound,
        message: 'Ошибка доступа к файлу',
        details: error.toString(),
      );
    }

    // Ошибки разрешений
    if (error.toString().contains('PermissionException') ||
        error.toString().contains('Access denied')) {
      return AppError.storage(
        type: StorageErrorType.accessDenied,
        message: 'Нет прав доступа',
        details: error.toString(),
      );
    }

    // Ошибки валидации форм
    if (error.toString().contains('FormatException') ||
        error.toString().contains('ArgumentError')) {
      return AppError.validation(
        type: ValidationErrorType.invalidFormat,
        message: 'Неверный формат данных',
        details: error.toString(),
      );
    }

    // По умолчанию - неизвестная ошибка
    return AppError.unknown(
      message: 'Произошла неожиданная ошибка',
      details: error.toString(),
      originalError: error,
      stackTrace: stackTrace,
    );
  }
}

/// Мixin для провайдеров с автоматической обработкой ошибок
mixin ErrorHandlingProviderMixin {
  /// Безопасно выполняет асинхронную операцию
  Future<Result<T>> safeExecute<T>(
    Future<T> Function() operation, {
    String? context,
  }) async {
    try {
      final result = await operation();
      return Success(result);
    } catch (error, stackTrace) {
      final appError = _convertToAppError(error, stackTrace, context);
      AppLogger.instance.error(
        'Error in ${context ?? 'operation'}',
        error,
        stackTrace,
      );
      return Failure(appError);
    }
  }

  /// Безопасно выполняет синхронную операцию
  Result<T> safeExecuteSync<T>(T Function() operation, {String? context}) {
    try {
      final result = operation();
      return Success(result);
    } catch (error, stackTrace) {
      final appError = _convertToAppError(error, stackTrace, context);
      AppLogger.instance.error(
        'Error in ${context ?? 'operation'}',
        error,
        stackTrace,
      );
      return Failure(appError);
    }
  }

  AppError _convertToAppError(
    Object error,
    StackTrace stackTrace,
    String? context,
  ) {
    if (error is AppError) {
      return error;
    }

    final errorString = error.toString().toLowerCase();

    // Анализируем контекст для более точного определения типа ошибки
    if (context != null) {
      final contextLower = context.toLowerCase();

      if (contextLower.contains('auth') || contextLower.contains('login')) {
        return AppError.authentication(
          type: AuthenticationErrorType.invalidCredentials,
          message: 'Ошибка аутентификации',
          details: error.toString(),
        );
      }

      if (contextLower.contains('encrypt') ||
          contextLower.contains('decrypt')) {
        return AppError.encryption(
          type: EncryptionErrorType.encryptionFailed,
          message: 'Ошибка шифрования',
          details: error.toString(),
        );
      }

      if (contextLower.contains('database') || contextLower.contains('db')) {
        return AppError.database(
          type: DatabaseErrorType.queryFailed,
          message: 'Ошибка базы данных',
          details: error.toString(),
        );
      }
    }

    // Анализируем сообщение об ошибке
    if (errorString.contains('socket') || errorString.contains('network')) {
      return AppError.network(
        type: NetworkErrorType.noConnection,
        message: 'Ошибка сетевого соединения',
        details: error.toString(),
      );
    }

    if (errorString.contains('timeout')) {
      return AppError.network(
        type: NetworkErrorType.timeout,
        message: 'Превышено время ожидания',
        details: error.toString(),
      );
    }

    if (errorString.contains('permission') ||
        errorString.contains('access denied')) {
      return AppError.system(
        type: SystemErrorType.permissionDenied,
        message: 'Нет необходимых разрешений',
        details: error.toString(),
      );
    }

    if (errorString.contains('memory') || errorString.contains('outofmemory')) {
      return AppError.system(
        type: SystemErrorType.outOfMemory,
        message: 'Недостаточно памяти',
        details: error.toString(),
        isCritical: true,
      );
    }

    if (errorString.contains('space') || errorString.contains('disk full')) {
      return AppError.system(
        type: SystemErrorType.diskFull,
        message: 'Недостаточно места на диске',
        details: error.toString(),
      );
    }

    // По умолчанию
    return AppError.unknown(
      message: 'Произошла неожиданная ошибка',
      details: error.toString(),
      originalError: error,
      stackTrace: stackTrace,
    );
  }
}

/// Провайдер для отслеживания состояния ошибок приложения
final appErrorStateProvider = StateProvider<List<AppError>>((ref) => []);

/// Провайдер для получения последней ошибки
final lastErrorProvider = Provider<AppError?>((ref) {
  final errors = ref.watch(appErrorStateProvider);
  return errors.isNotEmpty ? errors.last : null;
});

/// Провайдер для получения критических ошибок
final criticalErrorsProvider = Provider<List<AppError>>((ref) {
  final errors = ref.watch(appErrorStateProvider);
  return errors.where((error) => error.isCritical).toList();
});

/// Провайдер для получения некритических ошибок
final nonCriticalErrorsProvider = Provider<List<AppError>>((ref) {
  final errors = ref.watch(appErrorStateProvider);
  return errors.where((error) => !error.isCritical).toList();
});

/// Утилиты для работы с ошибками в провайдерах
class ErrorProviderUtils {
  /// Создает провайдер с автоматической обработкой ошибок
  static Provider<AsyncValue<T>> withErrorHandling<T>(
    Provider<AsyncValue<T>> provider,
  ) {
    return Provider<AsyncValue<T>>((ref) {
      final asyncValue = ref.watch(provider);
      asyncValue.handleErrorInWidget(ref as WidgetRef);
      return asyncValue;
    });
  }

  /// Создает FutureProvider с автоматической обработкой ошибок
  static FutureProvider<T> futureWithErrorHandling<T>(
    Future<T> Function(FutureProviderRef<T> ref) create, {
    String? context,
  }) {
    return FutureProvider<T>((ref) async {
      try {
        return await create(ref);
      } catch (error, stackTrace) {
        final appError = _convertToAppError(error, stackTrace, context);
        // Не можем использовать errorManagerProvider здесь, так как ref не WidgetRef
        AppLogger.instance.error(
          'Error in provider${context != null ? ' ($context)' : ''}',
          error,
          stackTrace,
        );
        rethrow;
      }
    });
  }

  static AppError _convertToAppError(
    Object error,
    StackTrace stackTrace,
    String? context,
  ) {
    if (error is AppError) {
      return error;
    }

    return AppError.unknown(
      message: 'Ошибка в провайдере${context != null ? ' ($context)' : ''}',
      details: error.toString(),
      originalError: error,
      stackTrace: stackTrace,
    );
  }
}
