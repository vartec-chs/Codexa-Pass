import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:codexa_pass/core/logging/app_logger.dart';
import 'enhanced_error_system.dart';

/// Интеграция системы ошибок с основным приложением
class ErrorSystemIntegration {
  static bool _isInitialized = false;

  /// Инициализирует систему ошибок
  static Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    // Инициализация новой системы ошибок
    await ErrorHandler.instance.initialize();

    // Перехват Flutter ошибок через новую систему
    FlutterError.onError = (FlutterErrorDetails details) {
      final error = UIError.widgetBuildFailed(
        details.context?.toString() ?? 'Unknown',
        details.exception.toString(),
      );
      ErrorHandler.instance.handleError(error, stackTrace: details.stack);
    };

    // Перехват Dart ошибок через новую систему
    PlatformDispatcher.instance.onError = (error, stack) {
      final systemError = SystemError(
        code: 'system_dart_error',
        message: 'Системная ошибка Dart',
        technicalDetails: error.toString(),
        originalError: error,
        stackTrace: stack,
      );
      ErrorHandler.instance.handleError(systemError, stackTrace: stack);
      return true;
    };

    // Настройка ErrorWidget.builder для красивых ошибок
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      final error = UIError.widgetBuildFailed(
        errorDetails.context?.toString() ?? 'Unknown',
        errorDetails.exception.toString(),
      );
      ErrorHandler.instance.handleError(error, stackTrace: errorDetails.stack);
      return ErrorWidgetDisplay(errorDetails: errorDetails);
    };
  }

  /// Проверяет, инициализирована ли система
  static bool get isInitialized => _isInitialized;
}

/// Виджет для отображения ошибок билдера
class ErrorWidgetDisplay extends StatelessWidget {
  final FlutterErrorDetails errorDetails;

  const ErrorWidgetDisplay({super.key, required this.errorDetails});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.red.shade50,
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning, size: 24, color: Colors.red.shade700),
            const SizedBox(height: 4),
            Text(
              'Ошибка отображения',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            if (kDebugMode && errorDetails.exception.toString().length < 50)
              Text(
                errorDetails.exception.toString(),
                style: TextStyle(fontSize: 10, color: Colors.red.shade600),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }
}

/// Mixin для автоматической обработки ошибок в State классах
mixin StateErrorHandlerMixin<T extends StatefulWidget> on State<T> {
  /// Обрабатывает ошибку через новую систему ошибок
  void handleError(BaseAppError error) {
    if (!mounted) return;
    ErrorHandler.instance.handleError(error);
  }

  /// Безопасно выполняет setState
  void safeSetState(VoidCallback fn) {
    if (mounted) {
      try {
        setState(fn);
      } catch (e) {
        AppLogger.instance.error('Error in safeSetState', e);
      }
    }
  }

  /// Безопасно выполняет асинхронную операцию с обработкой ошибок
  Future<void> safeAsyncOperation(
    Future<void> Function() operation, {
    String? context,
  }) async {
    if (!mounted) return;

    final result = await ErrorHandler.safeAsync(
      operation,
      errorCode: 'widget_async_operation',
      errorMessage: 'Ошибка в ${context ?? widget.runtimeType}',
      category: ErrorCategory.ui,
    );

    if (result.isFailure && mounted) {
      handleError(result.error!);
    }
  }
}

/// Обертка для безопасного выполнения функций в билдере
class SafeBuilder extends StatelessWidget {
  final Widget Function(BuildContext context) builder;
  final Widget Function(BuildContext context, Object error)? errorBuilder;

  const SafeBuilder({super.key, required this.builder, this.errorBuilder});

  @override
  Widget build(BuildContext context) {
    try {
      return builder(context);
    } catch (error, stackTrace) {
      AppLogger.instance.error('Error in SafeBuilder', error, stackTrace);

      if (errorBuilder != null) {
        return errorBuilder!(context, error);
      }

      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          border: Border.all(color: Colors.red.shade200),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 16, color: Colors.red.shade700),
            const SizedBox(width: 4),
            Text(
              'Ошибка отображения',
              style: TextStyle(fontSize: 12, color: Colors.red.shade700),
            ),
          ],
        ),
      );
    }
  }
}

/// Провайдер для безопасного получения ErrorHandler
final safeErrorHandlerProvider = Provider<ErrorHandler>((ref) {
  return ErrorHandler.instance;
});

/// Утилиты для безопасной работы с системой ошибок
class SafeErrorHandling {
  /// Безопасно обрабатывает ошибку
  static void handleError(WidgetRef ref, BaseAppError error) {
    try {
      ref.read(safeErrorHandlerProvider).handleError(error);
    } catch (e) {
      AppLogger.instance.error('Failed to handle error safely', e);
      // Fallback - показываем простое сообщение
      _showFallbackError();
    }
  }

  /// Безопасно обрабатывает ошибку через контекст
  static void handleErrorWithContext(BuildContext context, BaseAppError error) {
    try {
      ErrorHandler.instance.handleError(error);
    } catch (e) {
      AppLogger.instance.error('Failed to handle error with context', e);
      _showFallbackError();
    }
  }

  /// Безопасно выполняет операцию и возвращает Result
  static Future<Result<T>> safeOperation<T>(
    Future<T> Function() operation, {
    String? errorCode,
    String? errorMessage,
    ErrorCategory category = ErrorCategory.unknown,
  }) {
    return ErrorHandler.safeAsync(
      operation,
      errorCode: errorCode,
      errorMessage: errorMessage,
      category: category,
    );
  }

  /// Безопасно выполняет операцию с таймаутом
  static Future<Result<T>> safeOperationWithTimeout<T>(
    Future<T> Function() operation,
    Duration timeout, {
    String? errorCode,
    String? errorMessage,
    ErrorCategory category = ErrorCategory.network,
  }) {
    return ErrorHandler.safeAsyncWithTimeout(
      operation,
      timeout,
      errorCode: errorCode,
      errorMessage: errorMessage,
      category: category,
    );
  }

  static void _showFallbackError() {
    if (kDebugMode) {
      debugPrint('Fallback error handling triggered');
    }
  }
}
