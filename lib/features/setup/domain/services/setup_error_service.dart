import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codexa_pass/core/error/error_system.dart';
import '../errors/setup_errors.dart';

/// Сервис для обработки ошибок в setup экране
class SetupErrorService {
  SetupErrorService({
    required this.errorHandler,
    required this.errorController,
  });

  final ErrorHandler errorHandler;
  final ErrorController errorController;

  /// Обработать ошибку сохранения настроек
  Future<void> handlePreferencesError(
    Object error,
    StackTrace stackTrace, {
    BuildContext? context,
  }) async {
    final setupError = SetupPreferencesError(
      originalError: error,
      stackTrace: stackTrace,
      metadata: {
        'context': 'setup_screen',
        'action': 'save_preferences',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    await _handleError(setupError, context);
  }

  /// Обработать ошибку навигации
  Future<void> handleNavigationError(
    Object error,
    StackTrace stackTrace, {
    BuildContext? context,
  }) async {
    final setupError = SetupNavigationError(
      originalError: error,
      stackTrace: stackTrace,
      metadata: {
        'context': 'setup_screen',
        'action': 'navigation',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    await _handleError(setupError, context);
  }

  /// Обработать ошибку изменения темы
  Future<void> handleThemeError(
    String themeMode,
    Object error,
    StackTrace stackTrace, {
    BuildContext? context,
  }) async {
    final setupError = SetupThemeError(
      themeMode: themeMode,
      originalError: error,
      stackTrace: stackTrace,
      metadata: {
        'context': 'setup_screen',
        'action': 'change_theme',
        'attempted_theme': themeMode,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    await _handleError(setupError, context);
  }

  /// Обработать ошибку инициализации
  Future<void> handleInitializationError(
    Object error,
    StackTrace stackTrace, {
    BuildContext? context,
  }) async {
    final setupError = SetupInitializationError(
      originalError: error,
      stackTrace: stackTrace,
      metadata: {
        'context': 'setup_screen',
        'action': 'initialization',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    await _handleError(setupError, context);
  }

  /// Общий обработчик ошибок
  Future<void> _handleError(SetupError error, BuildContext? context) async {
    // Обрабатываем ошибку через систему ошибок
    await errorController.handleError(error);

    // Показываем пользователю если есть контекст
    if (context != null && context.mounted) {
      await _showErrorToUser(error, context);
    }
  }

  /// Показать ошибку пользователю
  Future<void> _showErrorToUser(SetupError error, BuildContext context) async {
    switch (error.displayType) {
      case ErrorDisplayType.snackbar:
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.userFriendlyMessage),
              backgroundColor: _getErrorColor(error.severity),
              action: error.canRetryOperation
                  ? SnackBarAction(
                      label: 'Повторить',
                      onPressed: () => _retryOperation(error),
                    )
                  : null,
            ),
          );
        }
        break;

      case ErrorDisplayType.dialog:
        if (context.mounted) {
          await showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(_getErrorTitle(error.severity)),
              content: Text(error.userFriendlyMessage),
              actions: [
                if (error.canRetryOperation)
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _retryOperation(error);
                    },
                    child: const Text('Повторить'),
                  ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
        break;

      case ErrorDisplayType.banner:
      case ErrorDisplayType.fullscreen:
      case ErrorDisplayType.inline:
      case ErrorDisplayType.toast:
      case ErrorDisplayType.none:
        // Для setup экрана используем snackbar вместо других типов
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.userFriendlyMessage),
              backgroundColor: _getErrorColor(error.severity),
            ),
          );
        }
        break;
    }
  }

  /// Получить цвет для ошибки
  Color _getErrorColor(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.info:
        return Colors.blue;
      case ErrorSeverity.warning:
        return Colors.orange;
      case ErrorSeverity.error:
        return Colors.red;
      case ErrorSeverity.critical:
        return Colors.red.shade700;
      case ErrorSeverity.fatal:
        return Colors.red.shade900;
    }
  }

  /// Получить заголовок для ошибки
  String _getErrorTitle(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.info:
        return 'Информация';
      case ErrorSeverity.warning:
        return 'Предупреждение';
      case ErrorSeverity.error:
        return 'Ошибка';
      case ErrorSeverity.critical:
        return 'Критическая ошибка';
      case ErrorSeverity.fatal:
        return 'Фатальная ошибка';
    }
  }

  /// Повторить операцию
  Future<void> _retryOperation(SetupError error) async {
    if (!error.canRetryOperation) return;

    // Используем метод контроллера для повтора
    await errorController.retryOperation(error);
  }

  /// Очистить все ошибки setup экрана
  void clearErrors() {
    errorController.clearErrorHistory();
  }

  /// Получить все ошибки setup экрана
  List<SetupError> getSetupErrors() {
    return errorController
        .getErrorHistory()
        .where((e) => e.module == 'Setup')
        .cast<SetupError>()
        .toList();
  }
}

/// Провайдер для сервиса ошибок setup экрана
final setupErrorServiceProvider = Provider<SetupErrorService>((ref) {
  final errorController = ref.watch(errorControllerProvider);

  return SetupErrorService(
    errorHandler: ErrorHandler(
      config: const ErrorConfig(),
      formatter: const ErrorFormatter(),
    ),
    errorController: errorController,
  );
});

/// Провайдер для списка ошибок setup экрана
final setupErrorsProvider = Provider<List<SetupError>>((ref) {
  final errorController = ref.watch(errorControllerProvider);
  return errorController
      .getErrorHistory()
      .where((e) => e.module == 'Setup')
      .cast<SetupError>()
      .toList();
});
