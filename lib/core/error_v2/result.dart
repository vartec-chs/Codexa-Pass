/// Система Result для безопасного выполнения операций без исключений
///
/// Эта система позволяет обрабатывать ошибки функциональным способом,
/// избегая try-catch блоков и делая код более предсказуемым

import 'dart:async';
import 'error_base.dart';

/// Базовый класс для представления результата операции
sealed class ResultV2<T> {
  const ResultV2();

  /// Проверка успешности операции
  bool get isSuccess => this is SuccessV2<T>;

  /// Проверка наличия ошибки
  bool get isFailure => this is FailureV2<T>;

  /// Получение значения (null если ошибка)
  T? get value => switch (this) {
    SuccessV2<T> success => success.value,
    FailureV2<T>() => null,
  };

  /// Получение ошибки (null если успех)
  AppErrorV2? get error => switch (this) {
    SuccessV2<T>() => null,
    FailureV2<T> failure => failure.error,
  };

  /// Обработка результата с помощью функций
  R fold<R>(
    R Function(T value) onSuccess,
    R Function(AppErrorV2 error) onFailure,
  ) {
    return switch (this) {
      SuccessV2<T> success => onSuccess(success.value),
      FailureV2<T> failure => onFailure(failure.error),
    };
  }

  /// Преобразование значения при успехе
  ResultV2<R> map<R>(R Function(T value) transform) {
    return switch (this) {
      SuccessV2<T> success => SuccessV2(transform(success.value)),
      FailureV2<T> failure => FailureV2(failure.error),
    };
  }

  /// Асинхронное преобразование значения
  Future<ResultV2<R>> mapAsync<R>(Future<R> Function(T value) transform) async {
    return switch (this) {
      SuccessV2<T> success => SuccessV2(await transform(success.value)),
      FailureV2<T> failure => FailureV2(failure.error),
    };
  }

  /// Цепочка операций (flatMap)
  ResultV2<R> flatMap<R>(ResultV2<R> Function(T value) transform) {
    return switch (this) {
      SuccessV2<T> success => transform(success.value),
      FailureV2<T> failure => FailureV2(failure.error),
    };
  }

  /// Асинхронная цепочка операций
  Future<ResultV2<R>> flatMapAsync<R>(
    Future<ResultV2<R>> Function(T value) transform,
  ) async {
    return switch (this) {
      SuccessV2<T> success => await transform(success.value),
      FailureV2<T> failure => FailureV2(failure.error),
    };
  }

  /// Фильтрация результата с условием
  ResultV2<T> where(bool Function(T value) predicate, AppErrorV2 error) {
    return switch (this) {
      SuccessV2<T> success when predicate(success.value) => this,
      SuccessV2<T>() => FailureV2(error),
      FailureV2<T>() => this,
    };
  }

  /// Восстановление после ошибки
  ResultV2<T> recover(T Function(AppErrorV2 error) recovery) {
    return switch (this) {
      SuccessV2<T>() => this,
      FailureV2<T> failure => SuccessV2(recovery(failure.error)),
    };
  }

  /// Асинхронное восстановление
  Future<ResultV2<T>> recoverAsync(
    Future<T> Function(AppErrorV2 error) recovery,
  ) async {
    return switch (this) {
      SuccessV2<T>() => this,
      FailureV2<T> failure => SuccessV2(await recovery(failure.error)),
    };
  }

  /// Восстановление с другим Result
  ResultV2<T> recoverWith(ResultV2<T> Function(AppErrorV2 error) recovery) {
    return switch (this) {
      SuccessV2<T>() => this,
      FailureV2<T> failure => recovery(failure.error),
    };
  }

  /// Асинхронное восстановление с другим Result
  Future<ResultV2<T>> recoverWithAsync(
    Future<ResultV2<T>> Function(AppErrorV2 error) recovery,
  ) async {
    return switch (this) {
      SuccessV2<T>() => this,
      FailureV2<T> failure => await recovery(failure.error),
    };
  }

  /// Выполнение побочных эффектов
  ResultV2<T> onSuccess(void Function(T value) action) {
    if (this case SuccessV2<T> success) {
      action(success.value);
    }
    return this;
  }

  /// Выполнение побочных эффектов при ошибке
  ResultV2<T> onFailure(void Function(AppErrorV2 error) action) {
    if (this case FailureV2<T> failure) {
      action(failure.error);
    }
    return this;
  }

  /// Асинхронное выполнение побочных эффектов
  Future<ResultV2<T>> onSuccessAsync(
    Future<void> Function(T value) action,
  ) async {
    if (this case SuccessV2<T> success) {
      await action(success.value);
    }
    return this;
  }

  /// Асинхронное выполнение побочных эффектов при ошибке
  Future<ResultV2<T>> onFailureAsync(
    Future<void> Function(AppErrorV2 error) action,
  ) async {
    if (this case FailureV2<T> failure) {
      await action(failure.error);
    }
    return this;
  }

  /// Преобразование в nullable значение
  T? toNullable() => value;

  /// Получение значения или значения по умолчанию
  T getOrElse(T defaultValue) => value ?? defaultValue;

  /// Получение значения или результата функции
  T getOrElseCall(T Function() defaultValue) => value ?? defaultValue();

  /// Выброс исключения если ошибка
  T getOrThrow() {
    return switch (this) {
      SuccessV2<T> success => success.value,
      FailureV2<T> failure => throw failure.error,
    };
  }
}

/// Успешный результат операции
final class SuccessV2<T> extends ResultV2<T> {
  final T value;

  const SuccessV2(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SuccessV2<T> &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Success($value)';
}

/// Неудачный результат операции с ошибкой
final class FailureV2<T> extends ResultV2<T> {
  final AppErrorV2 error;

  const FailureV2(this.error);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FailureV2<T> &&
          runtimeType == other.runtimeType &&
          error == other.error;

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'Failure($error)';
}

/// Утилиты для работы с Result
class ResultV2Utils {
  /// Выполнение функции с перехватом исключений
  static ResultV2<T> tryCall<T>(
    T Function() operation, {
    AppErrorV2 Function(Object error, StackTrace stackTrace)? onError,
  }) {
    try {
      return SuccessV2(operation());
    } catch (error, stackTrace) {
      final appError =
          onError?.call(error, stackTrace) ??
          _createDefaultError(error, stackTrace);
      return FailureV2(appError);
    }
  }

  /// Асинхронное выполнение функции с перехватом исключений
  static Future<ResultV2<T>> tryCallAsync<T>(
    Future<T> Function() operation, {
    AppErrorV2 Function(Object error, StackTrace stackTrace)? onError,
  }) async {
    try {
      final result = await operation();
      return SuccessV2(result);
    } catch (error, stackTrace) {
      final appError =
          onError?.call(error, stackTrace) ??
          _createDefaultError(error, stackTrace);
      return FailureV2(appError);
    }
  }

  /// Объединение нескольких результатов
  static ResultV2<List<T>> combine<T>(List<ResultV2<T>> results) {
    final values = <T>[];

    for (final result in results) {
      switch (result) {
        case SuccessV2<T> success:
          values.add(success.value);
        case FailureV2<T> failure:
          return FailureV2(failure.error);
      }
    }

    return SuccessV2(values);
  }

  /// Объединение результатов с аккумулятором ошибок
  static ResultV2<List<T>> combineAll<T>(List<ResultV2<T>> results) {
    final values = <T>[];
    final errors = <AppErrorV2>[];

    for (final result in results) {
      switch (result) {
        case SuccessV2<T> success:
          values.add(success.value);
        case FailureV2<T> failure:
          errors.add(failure.error);
      }
    }

    if (errors.isEmpty) {
      return SuccessV2(values);
    } else {
      // Возвращаем первую ошибку или создаем составную ошибку
      return FailureV2(errors.first);
    }
  }

  /// Параллельное выполнение операций
  static Future<ResultV2<List<T>>> parallel<T>(
    List<Future<ResultV2<T>>> operations,
  ) async {
    final results = await Future.wait(operations);
    return combine(results);
  }

  /// Выполнение операций последовательно до первой ошибки
  static Future<ResultV2<List<T>>> sequence<T>(
    List<Future<ResultV2<T>> Function()> operations,
  ) async {
    final values = <T>[];

    for (final operation in operations) {
      final result = await operation();
      switch (result) {
        case SuccessV2<T> success:
          values.add(success.value);
        case FailureV2<T> failure:
          return FailureV2(failure.error);
      }
    }

    return SuccessV2(values);
  }

  /// Создание ошибки по умолчанию
  static AppErrorV2 _createDefaultError(Object error, StackTrace stackTrace) {
    return UnknownErrorV2(
      message: 'Неожиданная ошибка: ${error.toString()}',
      technicalDetails: error.toString(),
      context: {
        'errorType': error.runtimeType.toString(),
        'stackTrace': stackTrace.toString(),
      },
      originalError: error,
      stackTrace: stackTrace,
    );
  }
}

/// Расширения для удобной работы с Future<Result>
extension FutureResultV2Extensions<T> on Future<ResultV2<T>> {
  /// Преобразование значения в Future<Result>
  Future<ResultV2<R>> mapAsync<R>(Future<R> Function(T value) transform) async {
    final result = await this;
    return result.mapAsync(transform);
  }

  /// Цепочка операций в Future<Result>
  Future<ResultV2<R>> flatMapAsync<R>(
    Future<ResultV2<R>> Function(T value) transform,
  ) async {
    final result = await this;
    return result.flatMapAsync(transform);
  }

  /// Восстановление в Future<Result>
  Future<ResultV2<T>> recoverAsync(
    Future<T> Function(AppErrorV2 error) recovery,
  ) async {
    final result = await this;
    return result.recoverAsync(recovery);
  }

  /// Обработка результата в Future<Result>
  Future<R> foldAsync<R>(
    FutureOr<R> Function(T value) onSuccess,
    FutureOr<R> Function(AppErrorV2 error) onFailure,
  ) async {
    final result = await this;
    return result.fold(onSuccess, onFailure);
  }
}

/// Неизвестная ошибка для внутреннего использования
class UnknownErrorV2 extends BaseAppErrorV2 {
  UnknownErrorV2({
    required String message,
    String? technicalDetails,
    Map<String, Object?> context = const {},
    Object? originalError,
    StackTrace? stackTrace,
    ErrorSeverityV2? severity,
  }) : super(
         id: 'UNKNOWN_${DateTime.now().millisecondsSinceEpoch}',
         category: ErrorCategoryV2.unknown,
         type: 'unknown',
         message: message,
         technicalDetails: technicalDetails,
         context: context,
         severity: severity ?? ErrorSeverityV2.error,
         originalError: originalError,
         stackTrace: stackTrace,
         isRecoverable: false,
         shouldDisplay: true,
         displayPriority: 0,
       );

  @override
  UnknownErrorV2 copyWith({
    String? message,
    String? technicalDetails,
    Map<String, Object?>? context,
    ErrorSeverityV2? severity,
    Object? originalError,
    StackTrace? stackTrace,
  }) {
    return UnknownErrorV2(
      message: message ?? this.message,
      technicalDetails: technicalDetails ?? this.technicalDetails,
      context: context ?? this.context,
      severity: severity ?? this.severity,
      originalError: originalError ?? this.originalError,
      stackTrace: stackTrace ?? this.stackTrace,
    );
  }
}
