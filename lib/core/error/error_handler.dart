import 'dart:async';
import 'package:codexa_pass/core/error/error_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codexa_pass/core/logging/app_logger.dart';
import 'app_error.dart';
import 'error_localizations.dart';

/// Результат операции с возможной ошибкой
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final AppError error;
  const Failure(this.error);
}

/// Расширения для работы с результатами
extension ResultExtension<T> on Result<T> {
  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get data => this is Success<T> ? (this as Success<T>).data : null;
  AppError? get error => this is Failure<T> ? (this as Failure<T>).error : null;

  /// Выполняет функцию если результат успешен
  Result<R> map<R>(R Function(T data) mapper) {
    return switch (this) {
      Success<T>(:final data) => Success(mapper(data)),
      Failure<T>(:final error) => Failure(error),
    };
  }

  /// Выполняет асинхронную функцию если результат успешен
  Future<Result<R>> mapAsync<R>(Future<R> Function(T data) mapper) async {
    return switch (this) {
      Success<T>(:final data) => Success(await mapper(data)),
      Failure<T>(:final error) => Failure(error),
    };
  }

  /// Связывает результаты
  Result<R> flatMap<R>(Result<R> Function(T data) mapper) {
    return switch (this) {
      Success<T>(:final data) => mapper(data),
      Failure<T>(:final error) => Failure(error),
    };
  }

  /// Обрабатывает ошибку
  Result<T> handleError(T Function(AppError error) handler) {
    return switch (this) {
      Success<T>() => this,
      Failure<T>(:final error) => Success(handler(error)),
    };
  }

  /// Получает данные или бросает исключение
  T get dataOrThrow {
    return switch (this) {
      Success<T>(:final data) => data,
      Failure<T>(:final error) => throw Exception(error.message),
    };
  }

  /// Получает данные или возвращает значение по умолчанию
  T getOrElse(T defaultValue) {
    return switch (this) {
      Success<T>(:final data) => data,
      Failure<T>() => defaultValue,
    };
  }
}

/// Утилиты для создания результатов
class ResultUtils {
  /// Безопасно выполняет функцию и возвращает результат
  static Result<T> safe<T>(T Function() action) {
    try {
      return Success(action());
    } catch (e, stackTrace) {
      AppLogger.instance.error('Error in safe execution', e, stackTrace);
      return Failure(
        AppError.unknown(
          message: 'Произошла неожиданная ошибка',
          details: e.toString(),
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Безопасно выполняет асинхронную функцию и возвращает результат
  static Future<Result<T>> safeAsync<T>(Future<T> Function() action) async {
    try {
      final result = await action();
      return Success(result);
    } catch (e, stackTrace) {
      AppLogger.instance.error('Error in async safe execution', e, stackTrace);
      return Failure(
        AppError.unknown(
          message: 'Произошла неожиданная ошибка',
          details: e.toString(),
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Комбинирует несколько результатов
  static Result<List<T>> combine<T>(List<Result<T>> results) {
    final data = <T>[];
    for (final result in results) {
      switch (result) {
        case Success<T>(data: final resultData):
          data.add(resultData);
        case Failure<T>(error: final error):
          return Failure(error);
      }
    }
    return Success(data);
  }
}

/// Провайдер для получения контекста для отображения ошибок
final navigatorKeyProvider = Provider<GlobalKey<NavigatorState>>((ref) {
  return GlobalKey<NavigatorState>();
});

/// Состояние менеджера ошибок
@immutable
class ErrorManagerState {
  final List<AppError> errors;
  final AppError? currentError;
  final bool isShowingDialog;

  const ErrorManagerState({
    this.errors = const [],
    this.currentError,
    this.isShowingDialog = false,
  });

  ErrorManagerState copyWith({
    List<AppError>? errors,
    AppError? currentError,
    bool? isShowingDialog,
  }) {
    return ErrorManagerState(
      errors: errors ?? this.errors,
      currentError: currentError,
      isShowingDialog: isShowingDialog ?? this.isShowingDialog,
    );
  }
}

/// Менеджер ошибок
class ErrorManager extends StateNotifier<ErrorManagerState> {
  final GlobalKey<NavigatorState> _navigatorKey;
  final ErrorLocalizations _localizations;

  ErrorManager(this._navigatorKey, this._localizations)
    : super(const ErrorManagerState());

  /// Обрабатывает ошибку
  void handleError(AppError error) {
    AppLogger.instance.error(
      'Handling error: ${error.runtimeType}',
      error,
      StackTrace.current,
    );

    state = state.copyWith(
      errors: [...state.errors, error],
      currentError: error,
    );

    _showError(error);
  }

  /// Очищает текущую ошибку
  void clearCurrentError() {
    state = state.copyWith(currentError: null);
  }

  /// Очищает все ошибки
  void clearAllErrors() {
    state = const ErrorManagerState();
  }

  /// Отображает ошибку пользователю
  void _showError(AppError error) {
    try {
      final context = _navigatorKey.currentContext;
      if (context == null || !context.mounted) {
        AppLogger.instance.warning(
          'Cannot show error: no valid context available',
        );
        return;
      }

      final localizedMessage = _localizations.getLocalizedMessage(error);

      if (error.isCritical) {
        _showCriticalErrorDialog(context, error, localizedMessage);
      } else {
        _showErrorSnackBar(context, error, localizedMessage);
      }
    } catch (e, stackTrace) {
      AppLogger.instance.error('Error while showing error UI', e, stackTrace);
    }
  }

  /// Показывает критическую ошибку в диалоге
  void _showCriticalErrorDialog(
    BuildContext context,
    AppError error,
    String message,
  ) {
    if (state.isShowingDialog || !context.mounted) return;

    try {
      state = state.copyWith(isShowingDialog: true);

      showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (context) => CriticalErrorDialog(
              error: error,
              message: message,
              onRetry: () => _onDialogRetry(context, error),
              onClose: () => _onDialogClose(context),
            ),
          )
          .then((_) {
            // Проверяем, что StateNotifier еще активен
            try {
              state = state.copyWith(isShowingDialog: false);
            } catch (e) {
              // StateNotifier уже dispose, игнорируем
            }
          })
          .catchError((e) {
            AppLogger.instance.error('Error showing critical error dialog', e);
            try {
              state = state.copyWith(isShowingDialog: false);
            } catch (e) {
              // StateNotifier уже dispose, игнорируем
            }
          });
    } catch (e) {
      AppLogger.instance.error('Failed to show critical error dialog', e);
      state = state.copyWith(isShowingDialog: false);
    }
  }

  /// Показывает ошибку в SnackBar
  void _showErrorSnackBar(
    BuildContext context,
    AppError error,
    String message,
  ) {
    if (!context.mounted) return;

    try {
      final screenWidth = MediaQuery.of(context).size.width;
      final isSmallScreen = screenWidth < 400;

      if (isSmallScreen) {
        // На маленьких экранах показываем SnackBar без кнопки действия
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: GestureDetector(
              onTap: () => _showErrorDetails(context, error),
              child: ErrorSnackBarContent(
                error: error,
                message: message,
                showTapHint: true, // Показываем подсказку о нажатии
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5), // Больше времени для чтения
            margin: EdgeInsets.symmetric(
              horizontal: 8,
              vertical: MediaQuery.of(context).viewInsets.bottom + 8,
            ),
          ),
        );
      } else {
        // На больших экранах показываем с кнопкой
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: ErrorSnackBarContent(error: error, message: message),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Подробнее',
              textColor: Theme.of(context).colorScheme.onError,
              onPressed: () => _showErrorDetails(context, error),
            ),
          ),
        );
      }
    } catch (e) {
      AppLogger.instance.error('Failed to show error snackbar', e);
    }
  }

  /// Показывает подробности ошибки
  void _showErrorDetails(BuildContext context, AppError error) {
    if (!context.mounted) return;

    try {
      showDialog<void>(
        context: context,
        builder: (context) => ErrorDetailsDialog(error: error),
      );
    } catch (e) {
      AppLogger.instance.error('Failed to show error details', e);
    }
  }

  /// Обработка повтора в диалоге критической ошибки
  void _onDialogRetry(BuildContext context, AppError error) {
    Navigator.of(context).pop();
    // Здесь можно добавить логику повтора операции
  }

  /// Обработка закрытия диалога критической ошибки
  void _onDialogClose(BuildContext context) {
    Navigator.of(context).pop();
    clearCurrentError();
  }
}

/// Провайдер менеджера ошибок
final errorManagerProvider =
    StateNotifierProvider<ErrorManager, ErrorManagerState>((ref) {
      final navigatorKey = ref.watch(navigatorKeyProvider);
      final localizations = ref.watch(errorLocalizationsProvider);
      return ErrorManager(navigatorKey, localizations);
    });

/// Мixin для автоматической обработки ошибок в виджетах
mixin ErrorHandlerMixin {
  void handleError(WidgetRef ref, AppError error) {
    ref.read(errorManagerProvider.notifier).handleError(error);
  }

  void handleResult<T>(WidgetRef ref, Result<T> result) {
    if (result.isFailure) {
      handleError(ref, result.error!);
    }
  }
}
