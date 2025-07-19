import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:codexa_pass/core/logging/app_logger.dart';
import 'error_system.dart';

/// Интеграция системы ошибок с основным приложением
class ErrorSystemIntegration {
  static bool _isInitialized = false;

  /// Инициализирует систему ошибок
  static void initialize() {
    if (_isInitialized) return;
    _isInitialized = true;

    // Перехват Flutter ошибок
    FlutterError.onError = (FlutterErrorDetails details) {
      AppLogger.instance.fatal(
        'Flutter Error',
        details.exception,
        details.stack,
      );
    };

    // Перехват Dart ошибок
    PlatformDispatcher.instance.onError = (error, stack) {
      AppLogger.instance.fatal('Dart Error', error, stack);
      return true;
    };

    // Настройка ErrorWidget.builder для красивых ошибок
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      AppLogger.instance.error(
        'Widget build error',
        errorDetails.exception,
        errorDetails.stack,
      );

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
  /// Обрабатывает ошибку через ProviderScope
  void handleError(AppError error) {
    if (!mounted) return;

    try {
      final container = ProviderScope.containerOf(context);
      container.read(errorManagerProvider.notifier).handleError(error);
    } catch (e) {
      // Если не можем обработать через систему ошибок, логируем
      AppLogger.instance.error(
        'Failed to handle error through error system',
        e,
      );
    }
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

    try {
      await operation();
    } catch (error, stackTrace) {
      AppLogger.instance.error(
        'Error in ${context ?? widget.runtimeType}',
        error,
        stackTrace,
      );

      if (mounted) {
        if (error is AppError) {
          handleError(error);
        } else {
          handleError(
            AppError.unknown(
              message: 'Ошибка в ${context ?? widget.runtimeType}',
              details: error.toString(),
              originalError: error,
              stackTrace: stackTrace,
            ),
          );
        }
      }
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

/// Провайдер для безопасного получения ошибок
final safeErrorManagerProvider = Provider<ErrorManager?>((ref) {
  try {
    return ref.watch(errorManagerProvider.notifier);
  } catch (e) {
    AppLogger.instance.error('Error accessing ErrorManager', e);
    return null;
  }
});

/// Утилиты для безопасной работы с системой ошибок
class SafeErrorHandling {
  /// Безопасно обрабатывает ошибку
  static void handleError(WidgetRef ref, AppError error) {
    try {
      ref.read(errorManagerProvider.notifier).handleError(error);
    } catch (e) {
      AppLogger.instance.error('Failed to handle error safely', e);
      // Fallback - показываем простое сообщение
      _showFallbackError();
    }
  }

  /// Безопасно обрабатывает ошибку через контекст
  static void handleErrorWithContext(BuildContext context, AppError error) {
    try {
      final container = ProviderScope.containerOf(context);
      container.read(errorManagerProvider.notifier).handleError(error);
    } catch (e) {
      AppLogger.instance.error('Failed to handle error with context', e);
      _showFallbackError();
    }
  }

  static void _showFallbackError() {
    if (kDebugMode) {
      debugPrint('Fallback error handling triggered');
    }
  }
}
