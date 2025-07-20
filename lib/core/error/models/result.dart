import 'app_error.dart';

/// Паттерн Result для обработки операций, которые могут завершиться ошибкой
sealed class Result<T, E> {
  const Result();

  /// Создать успешный результат
  const factory Result.success(T value) = Success<T, E>;

  /// Создать результат с ошибкой
  const factory Result.failure(E error) = Failure<T, E>;

  /// Проверка на успех
  bool get isSuccess => this is Success<T, E>;

  /// Проверка на ошибку
  bool get isFailure => this is Failure<T, E>;

  /// Получить значение или null
  T? get valueOrNull => switch (this) {
    Success<T, E>(value: final value) => value,
    Failure<T, E>() => null,
  };

  /// Получить ошибку или null
  E? get errorOrNull => switch (this) {
    Success<T, E>() => null,
    Failure<T, E>(error: final error) => error,
  };

  /// Получить значение или выбросить исключение
  T get value => switch (this) {
    Success<T, E>(value: final value) => value,
    Failure<T, E>(error: final error) => throw Exception(error.toString()),
  };

  /// Получить ошибку или выбросить исключение
  E get error => switch (this) {
    Success<T, E>() => throw StateError('Called error on Success'),
    Failure<T, E>(error: final error) => error,
  };

  /// Получить значение или значение по умолчанию
  T getOrElse(T defaultValue) => switch (this) {
    Success<T, E>(value: final value) => value,
    Failure<T, E>() => defaultValue,
  };

  /// Получить значение или вызвать функцию
  T getOrCall(T Function() defaultFunction) => switch (this) {
    Success<T, E>(value: final value) => value,
    Failure<T, E>() => defaultFunction(),
  };

  /// Преобразовать значение при успехе
  Result<R, E> map<R>(R Function(T value) transform) => switch (this) {
    Success<T, E>(value: final value) => Result.success(transform(value)),
    Failure<T, E>(error: final error) => Result.failure(error),
  };

  /// Преобразовать ошибку при неудаче
  Result<T, R> mapError<R>(R Function(E error) transform) => switch (this) {
    Success<T, E>(value: final value) => Result.success(value),
    Failure<T, E>(error: final error) => Result.failure(transform(error)),
  };

  /// Применить функцию и вернуть новый Result
  Result<R, E> flatMap<R>(Result<R, E> Function(T value) transform) =>
      switch (this) {
        Success<T, E>(value: final value) => transform(value),
        Failure<T, E>(error: final error) => Result.failure(error),
      };

  /// Выполнить действие при успехе
  Result<T, E> onSuccess(void Function(T value) action) {
    if (this case Success<T, E>(value: final value)) {
      action(value);
    }
    return this;
  }

  /// Выполнить действие при ошибке
  Result<T, E> onFailure(void Function(E error) action) {
    if (this case Failure<T, E>(error: final error)) {
      action(error);
    }
    return this;
  }

  /// Выполнить действие в любом случае
  Result<T, E> onComplete(void Function() action) {
    action();
    return this;
  }

  /// Свернуть результат в единое значение
  R fold<R>(R Function(T value) onSuccess, R Function(E error) onFailure) =>
      switch (this) {
        Success<T, E>(value: final value) => onSuccess(value),
        Failure<T, E>(error: final error) => onFailure(error),
      };

  /// Преобразовать в Future
  Future<T> toFuture() => switch (this) {
    Success<T, E>(value: final value) => Future.value(value),
    Failure<T, E>(error: final error) => Future.error(
      Exception(error.toString()),
    ),
  };

  @override
  String toString() => switch (this) {
    Success<T, E>(value: final value) => 'Success($value)',
    Failure<T, E>(error: final error) => 'Failure($error)',
  };
}

/// Класс для успешного результата
final class Success<T, E> extends Result<T, E> {
  const Success(this.value);

  final T value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Success<T, E> && value == other.value);

  @override
  int get hashCode => value.hashCode;
}

/// Класс для результата с ошибкой
final class Failure<T, E> extends Result<T, E> {
  const Failure(this.error);

  final E error;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Failure<T, E> && error == other.error);

  @override
  int get hashCode => error.hashCode;
}

/// Типы для удобства использования с AppError
typedef AppResult<T> = Result<T, AppError>;

/// Вспомогательные функции для создания результатов
extension ResultHelper on Result {
  /// Создать успешный результат
  static Result<T, E> success<T, E>(T value) => Success(value);

  /// Создать результат с ошибкой
  static Result<T, E> failure<T, E>(E error) => Failure(error);
}

/// Расширение для Future<Result>
extension FutureResultExtension<T, E> on Future<Result<T, E>> {
  /// Преобразовать Future<Result<T, E>> в Result<Future<T>, E>
  Future<Result<R, E>> mapAsync<R>(
    Future<R> Function(T value) transform,
  ) async {
    final result = await this;
    return switch (result) {
      Success<T, E>(value: final value) => Result.success(
        await transform(value),
      ),
      Failure<T, E>(error: final error) => Result.failure(error),
    };
  }

  /// Обработать результат асинхронно
  Future<Result<R, E>> flatMapAsync<R>(
    Future<Result<R, E>> Function(T value) transform,
  ) async {
    final result = await this;
    return switch (result) {
      Success<T, E>(value: final value) => await transform(value),
      Failure<T, E>(error: final error) => Result.failure(error),
    };
  }

  /// Получить значение или выбросить исключение асинхронно
  Future<T> unwrap() async {
    final result = await this;
    return result.value;
  }

  /// Получить значение или значение по умолчанию асинхронно
  Future<T> getOrElseAsync(T defaultValue) async {
    final result = await this;
    return result.getOrElse(defaultValue);
  }
}

/// Расширение для Try-catch с Result
extension TryResult on Object {
  /// Выполнить функцию с обработкой исключений
  static Result<T, E> tryCall<T, E>(
    T Function() function,
    E Function(Object error, StackTrace stackTrace) onError,
  ) {
    try {
      return Result.success(function());
    } catch (error, stackTrace) {
      return Result.failure(onError(error, stackTrace));
    }
  }

  /// Выполнить асинхронную функцию с обработкой исключений
  static Future<Result<T, E>> tryCallAsync<T, E>(
    Future<T> Function() function,
    E Function(Object error, StackTrace stackTrace) onError,
  ) async {
    try {
      final value = await function();
      return Result.success(value);
    } catch (error, stackTrace) {
      return Result.failure(onError(error, stackTrace));
    }
  }
}
