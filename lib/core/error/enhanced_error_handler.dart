import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:codexa_pass/core/error/enhanced_app_error.dart';
import 'package:codexa_pass/core/logging/logging.dart';

/// Улучшенный результат операции с типизированными ошибками
sealed class Result<T> {
  const Result();

  /// Проверка на успешность
  bool get isSuccess => this is Success<T>;

  /// Проверка на ошибку
  bool get isFailure => this is Failure<T>;

  /// Получение значения (если успешно)
  T? get value => switch (this) {
    Success<T>(value: final value) => value,
    Failure<T>() => null,
  };

  /// Получение ошибки (если есть)
  BaseAppError? get error => switch (this) {
    Success<T>() => null,
    Failure<T>(error: final error) => error,
  };

  /// Безопасное выполнение функции с результатом
  R fold<R>(
    R Function(T value) onSuccess,
    R Function(BaseAppError error) onFailure,
  ) {
    return switch (this) {
      Success<T>(value: final value) => onSuccess(value),
      Failure<T>(error: final error) => onFailure(error),
    };
  }

  /// Преобразование значения при успехе
  Result<R> map<R>(R Function(T value) transform) {
    return switch (this) {
      Success<T>(value: final value) => Success(transform(value)),
      Failure<T>(error: final error) => Failure(error),
    };
  }

  /// Асинхронное преобразование значения
  Future<Result<R>> mapAsync<R>(Future<R> Function(T value) transform) async {
    return switch (this) {
      Success<T>(value: final value) => Success(await transform(value)),
      Failure<T>(error: final error) => Failure(error),
    };
  }

  /// Цепочка операций
  Result<R> flatMap<R>(Result<R> Function(T value) transform) {
    return switch (this) {
      Success<T>(value: final value) => transform(value),
      Failure<T>(error: final error) => Failure(error),
    };
  }

  /// Асинхронная цепочка операций
  Future<Result<R>> flatMapAsync<R>(
    Future<Result<R>> Function(T value) transform,
  ) async {
    return switch (this) {
      Success<T>(value: final value) => await transform(value),
      Failure<T>(error: final error) => Failure(error),
    };
  }

  /// Фильтрация результата
  Result<T> where(bool Function(T value) predicate, BaseAppError error) {
    return switch (this) {
      Success<T>(value: final value) when predicate(value) => this,
      Success<T>() => Failure(error),
      Failure<T>() => this,
    };
  }

  /// Восстановление после ошибки
  Result<T> recover(T Function(BaseAppError error) recovery) {
    return switch (this) {
      Success<T>() => this,
      Failure<T>(error: final error) => Success(recovery(error)),
    };
  }

  /// Асинхронное восстановление
  Future<Result<T>> recoverAsync(
    Future<T> Function(BaseAppError error) recovery,
  ) async {
    return switch (this) {
      Success<T>() => this,
      Failure<T>(error: final error) => Success(await recovery(error)),
    };
  }

  /// Восстановление с новым Result
  Result<T> recoverWith(Result<T> Function(BaseAppError error) recovery) {
    return switch (this) {
      Success<T>() => this,
      Failure<T>(error: final error) => recovery(error),
    };
  }

  /// Получение значения или значения по умолчанию
  T getOrElse(T defaultValue) {
    return switch (this) {
      Success<T>(value: final value) => value,
      Failure<T>() => defaultValue,
    };
  }

  /// Получение значения или выполнение функции
  T getOrElseGet(T Function() defaultValue) {
    return switch (this) {
      Success<T>(value: final value) => value,
      Failure<T>() => defaultValue(),
    };
  }

  /// Выбрасывание ошибки при неудаче
  T orThrow() {
    return switch (this) {
      Success<T>(value: final value) => value,
      Failure<T>(error: final error) => throw error,
    };
  }

  /// Выполнение побочных эффектов при успехе
  Result<T> onSuccess(void Function(T value) action) {
    if (this case Success<T>(value: final value)) {
      action(value);
    }
    return this;
  }

  /// Выполнение побочных эффектов при ошибке
  Result<T> onFailure(void Function(BaseAppError error) action) {
    if (this case Failure<T>(error: final error)) {
      action(error);
    }
    return this;
  }

  /// Преобразование в JSON
  Map<String, dynamic> toJson() {
    return switch (this) {
      Success<T>(value: final value) => {'success': true, 'value': value},
      Failure<T>(error: final error) => {
        'success': false,
        'error': error.toJson(),
      },
    };
  }
}

/// Успешный результат
final class Success<T> extends Result<T> {
  final T value;

  const Success(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Success($value)';
}

/// Неуспешный результат
final class Failure<T> extends Result<T> {
  final BaseAppError error;

  const Failure(this.error);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          error == other.error;

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'Failure($error)';
}

/// Глобальный обработчик ошибок
class ErrorHandler {
  static ErrorHandler? _instance;
  static ErrorHandler get instance => _instance ??= ErrorHandler._();

  ErrorHandler._();

  late final AppLogger _logger;
  late final CrashReporter _crashReporter;

  /// Инициализация обработчика ошибок
  Future<void> initialize() async {
    _logger = AppLogger.instance;
    _crashReporter = CrashReporter.instance;

    // Настройка глобальных обработчиков ошибок
    FlutterError.onError = _handleFlutterError;
    PlatformDispatcher.instance.onError = _handlePlatformError;
  }

  /// Обработка ошибок Flutter Framework
  void _handleFlutterError(FlutterErrorDetails details) {
    final widgetName = details.context?.toString() ?? 'Unknown';
    final error = UIError.widgetBuildFailed(
      widgetName,
      details.exception.toString(),
    );

    handleError(
      error,
      stackTrace: details.stack,
      context: {
        'library': details.library ?? 'unknown',
        'informationCollector': details.informationCollector?.toString(),
      },
    );

    // В debug режиме показываем красный экран
    if (kDebugMode) {
      FlutterError.presentError(details);
    }
  }

  /// Обработка ошибок платформы
  bool _handlePlatformError(Object error, StackTrace stackTrace) {
    final appError = SystemError(
      code: 'system_platform_error',
      message: 'Системная ошибка',
      technicalDetails: error.toString(),
      originalError: error,
      stackTrace: stackTrace,
    );

    handleError(appError, stackTrace: stackTrace);
    return true; // Ошибка обработана
  }

  /// Основной метод обработки ошибок
  void handleError(
    BaseAppError error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
    bool logToConsole = true,
  }) {
    try {
      // Логирование ошибки
      if (error.isCritical) {
        _logger.fatal(
          error.message,
          error.originalError ?? error,
          stackTrace ?? error.stackTrace,
        );
      } else {
        _logger.error(
          error.message,
          error.originalError ?? error,
          stackTrace ?? error.stackTrace,
        );
      }

      // Создание краш-репорта при необходимости
      if (error.shouldCreateCrashReport) {
        final report = CrashReport.fromException(
          type: error.crashReportType,
          title: error.message,
          exception: error.originalError ?? error,
          stackTrace: stackTrace ?? error.stackTrace,
          additionalData: {'appError': error.toJson(), ...?context},
        );
        _crashReporter.saveCrashReport(report);
      }

      // Логирование в консоль для отладки
      if (logToConsole && kDebugMode) {
        developer.log(
          error.message,
          name: 'ErrorHandler',
          error: error,
          stackTrace: stackTrace ?? error.stackTrace,
          level: error.isCritical ? 1000 : 800,
        );
      }
    } catch (handlingError) {
      // Если произошла ошибка при обработке ошибки
      if (kDebugMode) {
        developer.log(
          'Ошибка при обработке ошибки: $handlingError',
          name: 'ErrorHandler',
          error: handlingError,
          level: 1200,
        );
      }
    }
  }

  /// Безопасное выполнение операции
  static Result<T> safe<T>(
    T Function() operation, {
    String? errorCode,
    String? errorMessage,
    ErrorCategory category = ErrorCategory.unknown,
    Map<String, dynamic>? context,
  }) {
    try {
      final result = operation();
      return Success(result);
    } catch (error, stackTrace) {
      final appError = AppError.fromException(
        error,
        code: errorCode,
        message: errorMessage,
        category: category,
        context: context,
        stackTrace: stackTrace,
      );

      ErrorHandler.instance.handleError(appError, stackTrace: stackTrace);
      return Failure(appError);
    }
  }

  /// Безопасное выполнение асинхронной операции
  static Future<Result<T>> safeAsync<T>(
    Future<T> Function() operation, {
    String? errorCode,
    String? errorMessage,
    ErrorCategory category = ErrorCategory.unknown,
    Map<String, dynamic>? context,
  }) async {
    try {
      final result = await operation();
      return Success(result);
    } catch (error, stackTrace) {
      final appError = AppError.fromException(
        error,
        code: errorCode,
        message: errorMessage,
        category: category,
        context: context,
        stackTrace: stackTrace,
      );

      ErrorHandler.instance.handleError(appError, stackTrace: stackTrace);
      return Failure(appError);
    }
  }

  /// Безопасное выполнение операции с таймаутом
  static Future<Result<T>> safeAsyncWithTimeout<T>(
    Future<T> Function() operation,
    Duration timeout, {
    String? errorCode,
    String? errorMessage,
    ErrorCategory category = ErrorCategory.network,
    Map<String, dynamic>? context,
  }) async {
    try {
      final result = await operation().timeout(timeout);
      return Success(result);
    } on TimeoutException {
      final error = NetworkError.timeout(
        'Операция превысила время ожидания (${timeout.inSeconds}с)',
      );
      ErrorHandler.instance.handleError(error);
      return Failure(error);
    } catch (error, stackTrace) {
      final appError = AppError.fromException(
        error,
        code: errorCode,
        message: errorMessage,
        category: category,
        context: context,
        stackTrace: stackTrace,
      );

      ErrorHandler.instance.handleError(appError, stackTrace: stackTrace);
      return Failure(appError);
    }
  }

  /// Retry логика для операций
  static Future<Result<T>> retry<T>(
    Future<Result<T>> Function() operation, {
    int maxAttempts = 3,
    Duration delay = const Duration(seconds: 1),
    bool Function(BaseAppError error)? retryIf,
  }) async {
    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      final result = await operation();

      if (result.isSuccess) {
        return result;
      }

      // Проверяем, нужно ли повторять операцию
      if (attempt < maxAttempts) {
        final error = result.error!;
        if (retryIf == null || retryIf(error)) {
          ErrorHandler.instance._logger.warning(
            'Повтор операции ${attempt + 1}/$maxAttempts через ${delay.inSeconds}с',
          );
          await Future.delayed(delay);
          continue;
        }
      }

      return result;
    }

    // Этот код никогда не должен выполниться
    throw StateError('Retry logic error');
  }

  /// Создание цепочки операций
  static ChainBuilder<T> chain<T>(Result<T> initial) {
    return ChainBuilder(initial);
  }
}

/// Строитель цепочек операций
class ChainBuilder<T> {
  final Result<T> _result;

  ChainBuilder(this._result);

  /// Добавление следующей операции в цепочку
  ChainBuilder<R> then<R>(
    Result<R> Function(T value) operation, {
    String? errorCode,
    String? errorMessage,
    ErrorCategory category = ErrorCategory.unknown,
  }) {
    final nextResult = _result.flatMap((value) {
      return ErrorHandler.safe(
        () => operation(value).orThrow(),
        errorCode: errorCode,
        errorMessage: errorMessage,
        category: category,
      );
    });

    return ChainBuilder(nextResult);
  }

  /// Добавление асинхронной операции в цепочку
  Future<ChainBuilder<R>> thenAsync<R>(
    Future<Result<R>> Function(T value) operation, {
    String? errorCode,
    String? errorMessage,
    ErrorCategory category = ErrorCategory.unknown,
  }) async {
    final nextResult = await _result.flatMapAsync((value) async {
      final result = await ErrorHandler.safeAsync(
        () async => (await operation(value)).orThrow(),
        errorCode: errorCode,
        errorMessage: errorMessage,
        category: category,
      );
      return result;
    });

    return ChainBuilder(nextResult);
  }

  /// Получение финального результата
  Result<T> build() => _result;
}

/// Расширения для удобной работы с Result
extension ResultExtensions<T> on Future<T> {
  /// Преобразование Future в Result
  Future<Result<T>> toResult({
    String? errorCode,
    String? errorMessage,
    ErrorCategory category = ErrorCategory.unknown,
    Map<String, dynamic>? context,
  }) {
    return ErrorHandler.safeAsync(
      () => this,
      errorCode: errorCode,
      errorMessage: errorMessage,
      category: category,
      context: context,
    );
  }

  /// Преобразование Future в Result с таймаутом
  Future<Result<T>> toResultWithTimeout(
    Duration timeout, {
    String? errorCode,
    String? errorMessage,
    ErrorCategory category = ErrorCategory.network,
    Map<String, dynamic>? context,
  }) {
    return ErrorHandler.safeAsyncWithTimeout(
      () => this,
      timeout,
      errorCode: errorCode,
      errorMessage: errorMessage,
      category: category,
      context: context,
    );
  }
}

extension FutureResultExtensions<T> on Future<Result<T>> {
  /// Повтор операции при ошибке
  Future<Result<T>> retry({
    int maxAttempts = 3,
    Duration delay = const Duration(seconds: 1),
    bool Function(BaseAppError error)? retryIf,
  }) {
    return ErrorHandler.retry(
      () => this,
      maxAttempts: maxAttempts,
      delay: delay,
      retryIf: retryIf,
    );
  }
}
