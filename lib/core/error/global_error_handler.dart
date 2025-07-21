import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'controllers/error_controller.dart';
import 'models/app_error.dart';
import 'models/error_severity.dart';
import 'models/error_display_type.dart';
import 'utils/error_config.dart';
import 'utils/error_formatter.dart';

/// Глобальная инициализация системы обработки ошибок
class GlobalErrorHandler {
  static bool _isInitialized = false;
  static ErrorController? _errorController;

  /// Инициализация глобального обработчика ошибок
  static Future<void> initialize({
    ErrorConfig? config,
    ProviderContainer? container,
  }) async {
    if (_isInitialized) return;

    // Создаем контроллер ошибок
    final errorConfig = config ?? const ErrorConfig();
    const formatter = ErrorFormatter();

    _errorController = ErrorController(
      config: errorConfig,
      formatter: formatter,
    );

    await _errorController!.initialize();

    // Настраиваем обработчики Flutter
    _setupFlutterErrorHandling();

    // Настраиваем обработчики Dart
    _setupDartErrorHandling();

    // Настраиваем обработчики для изолятов
    _setupIsolateErrorHandling();

    _isInitialized = true;

    print('Global error handler initialized');
  }

  /// Настройка обработки ошибок Flutter
  static void _setupFlutterErrorHandling() {
    // Сохраняем оригинальный обработчик
    final originalOnError = FlutterError.onError;

    FlutterError.onError = (FlutterErrorDetails details) {
      // Вызываем оригинальный обработчик для отладки
      originalOnError?.call(details);

      // Создаем AppError
      final error = BaseAppError(
        code: 'FLUTTER_ERROR',
        message: details.exception.toString(),
        severity: details.silent ? ErrorSeverity.warning : ErrorSeverity.error,
        timestamp: DateTime.now(),
        stackTrace: details.stack,
        originalError: details.exception,
        module: 'Flutter',
        displayType: details.silent
            ? ErrorDisplayType.none
            : ErrorDisplayType.dialog,
        metadata: {
          'library': details.library,
          'context': details.context?.toString(),
          'silent': details.silent,
          'informationCollector': details.informationCollector?.toString(),
        },
        shouldReport: !details.silent,
        shouldShowDetails: kDebugMode,
      );

      // Обрабатываем через систему
      _handleError(error);
    };
  }

  /// Настройка обработки ошибок Dart
  static void _setupDartErrorHandling() {
    PlatformDispatcher.instance.onError = (error, stack) {
      final appError = BaseAppError(
        code: 'DART_ERROR',
        message: error.toString(),
        severity: ErrorSeverity.error,
        timestamp: DateTime.now(),
        stackTrace: stack,
        originalError: error,
        module: 'Dart',
        displayType: ErrorDisplayType.dialog,
        shouldReport: true,
        shouldShowDetails: kDebugMode,
      );

      _handleError(appError);

      // Возвращаем true, чтобы показать, что ошибка обработана
      return true;
    };
  }

  /// Настройка обработки ошибок в изолятах
  static void _setupIsolateErrorHandling() {
    Isolate.current.addErrorListener(
      RawReceivePort((List<dynamic> errorAndStacktrace) {
        final error = errorAndStacktrace[0];
        final stackTrace = errorAndStacktrace[1] as String?;

        final appError = BaseAppError(
          code: 'ISOLATE_ERROR',
          message: error.toString(),
          severity: ErrorSeverity.critical,
          timestamp: DateTime.now(),
          stackTrace: stackTrace != null
              ? StackTrace.fromString(stackTrace)
              : null,
          originalError: error,
          module: 'Isolate',
          displayType: ErrorDisplayType.dialog,
          shouldReport: true,
          shouldShowDetails: kDebugMode,
        );

        _handleError(appError);
      }).sendPort,
    );
  }

  /// Обработка ошибки через систему
  static void _handleError(AppError error) {
    try {
      if (_errorController != null) {
        // Обрабатываем асинхронно, чтобы не блокировать основной поток
        _errorController!.handleError(error).catchError((e) {
          // Если обработка ошибки сама вызвала ошибку, логируем это
          print('Error in error handler: $e');
        });
      } else {
        // Fallback если контроллер не инициализирован
        print(
          'Error occurred before error controller initialization: ${error.message}',
        );
      }
    } catch (e) {
      // Последний fallback
      print('Critical error in error handling system: $e');
      print('Original error: ${error.message}');
    }
  }

  /// Обработка ошибки вручную
  static Future<void> handleError(AppError error) async {
    if (_errorController != null) {
      await _errorController!.handleError(error);
    } else {
      print('Error controller not initialized: ${error.message}');
    }
  }

  /// Получить контроллер ошибок
  static ErrorController? get errorController => _errorController;

  /// Закрытие системы
  static Future<void> dispose() async {
    if (_errorController != null) {
      await _errorController!.dispose();
      _errorController = null;
    }
    _isInitialized = false;
  }
}

/// Обертка для runApp с обработкой ошибок
Future<void> runAppWithErrorHandling(
  Widget app, {
  ErrorConfig? errorConfig,
  ProviderContainer? container,
}) async {
  // Инициализируем систему обработки ошибок
  await GlobalErrorHandler.initialize(
    config: errorConfig,
    container: container,
  );

  // Запускаем приложение в зоне с обработкой ошибок
  runZonedGuarded(
    () {
      runApp(app);
    },
    (error, stackTrace) {
      final appError = BaseAppError(
        code: 'ZONE_ERROR',
        message: error.toString(),
        severity: ErrorSeverity.error,
        timestamp: DateTime.now(),
        stackTrace: stackTrace,
        originalError: error,
        module: 'Zone',
        displayType: ErrorDisplayType.snackbar,
        shouldReport: true,
        shouldShowDetails: kDebugMode,
      );

      GlobalErrorHandler.handleError(appError);
    },
  );
}

/// Mixin для виджетов с автоматической обработкой ошибок
mixin ErrorHandlingMixin<T extends StatefulWidget> on State<T> {
  /// Безопасное выполнение операции с обработкой ошибок
  Future<void> safeExecute(
    Future<void> Function() operation, {
    String? operationName,
    void Function(AppError error)? onError,
  }) async {
    try {
      await operation();
    } catch (error, stackTrace) {
      final appError = BaseAppError(
        code: 'WIDGET_OPERATION_ERROR',
        message: 'Error in ${operationName ?? 'widget operation'}: $error',
        severity: ErrorSeverity.error,
        timestamp: DateTime.now(),
        stackTrace: stackTrace,
        originalError: error,
        module: widget.runtimeType.toString(),
        displayType: ErrorDisplayType.snackbar,
        shouldReport: true,
        shouldShowDetails: kDebugMode,
        metadata: {
          'widget': widget.runtimeType.toString(),
          'operation': operationName,
        },
      );

      onError?.call(appError);
      await GlobalErrorHandler.handleError(appError);
    }
  }

  /// Безопасное выполнение setState с обработкой ошибок
  void safeSetState(VoidCallback fn) {
    try {
      if (mounted) {
        setState(fn);
      }
    } catch (error, stackTrace) {
      final appError = BaseAppError(
        code: 'SET_STATE_ERROR',
        message: 'Error in setState: $error',
        severity: ErrorSeverity.warning,
        timestamp: DateTime.now(),
        stackTrace: stackTrace,
        originalError: error,
        module: widget.runtimeType.toString(),
        displayType: ErrorDisplayType.none,
        shouldReport: false,
        shouldShowDetails: kDebugMode,
      );

      GlobalErrorHandler.handleError(appError);
    }
  }
}

/// Consumer widget с автоматической обработкой ошибок
class SafeConsumerWidget extends ConsumerWidget {
  const SafeConsumerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    try {
      return buildSafe(context, ref);
    } catch (error, stackTrace) {
      final appError = BaseAppError(
        code: 'WIDGET_BUILD_ERROR',
        message: 'Error building widget: $error',
        severity: ErrorSeverity.error,
        timestamp: DateTime.now(),
        stackTrace: stackTrace,
        originalError: error,
        module: runtimeType.toString(),
        displayType: ErrorDisplayType.inline,
        shouldReport: true,
        shouldShowDetails: kDebugMode,
      );

      GlobalErrorHandler.handleError(appError);

      // Возвращаем fallback UI
      return Container(
        padding: const EdgeInsets.all(16),
        color: Colors.red.shade50,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade600),
            const SizedBox(height: 8),
            Text(
              'Ошибка отображения',
              style: TextStyle(
                color: Colors.red.shade800,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (kDebugMode) ...[
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: TextStyle(color: Colors.red.shade700, fontSize: 12),
              ),
            ],
          ],
        ),
      );
    }
  }

  /// Переопределите этот метод вместо build
  Widget buildSafe(BuildContext context, WidgetRef ref) {
    return const SizedBox.shrink();
  }
}
