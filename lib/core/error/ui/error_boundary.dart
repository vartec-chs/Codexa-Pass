import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/error_controller.dart';
import '../models/app_error.dart';
import '../models/error_severity.dart';
import '../models/error_display_type.dart';
import 'error_widgets/error_display_widget.dart';

/// Error Boundary для перехвата ошибок в виджетах
class ErrorBoundary extends ConsumerStatefulWidget {
  const ErrorBoundary({
    Key? key,
    required this.child,
    this.onError,
    this.fallbackBuilder,
    this.enableLogging = true,
  }) : super(key: key);

  final Widget child;
  final void Function(AppError error)? onError;
  final Widget Function(AppError error, VoidCallback retry)? fallbackBuilder;
  final bool enableLogging;

  @override
  ConsumerState<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends ConsumerState<ErrorBoundary> {
  AppError? _currentError;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();

    // Обрабатываем ошибки Flutter
    FlutterError.onError = (FlutterErrorDetails details) {
      _handleFlutterError(details);
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError && _currentError != null) {
      return widget.fallbackBuilder?.call(_currentError!, _retry) ??
          ErrorDisplayWidget(
            error: _currentError!,
            onRetry: _retry,
            onDismiss: _dismiss,
          );
    }

    return widget.child;
  }

  /// Обработка ошибок Flutter
  void _handleFlutterError(FlutterErrorDetails details) {
    final error = BaseAppError(
      code: 'FLUTTER_ERROR',
      message: details.exception.toString(),
      severity: details.silent ? ErrorSeverity.warning : ErrorSeverity.error,
      timestamp: DateTime.now(),
      stackTrace: details.stack,
      originalError: details.exception,
      module: 'Flutter',
      displayType: ErrorDisplayType.dialog,
      metadata: {
        'library': details.library,
        'context': details.context?.toString(),
        'silent': details.silent,
      },
    );

    _handleError(error);
  }

  /// Обработка ошибки
  void _handleError(AppError error) {
    setState(() {
      _currentError = error;
      _hasError = true;
    });

    // Вызываем callback если предоставлен
    widget.onError?.call(error);

    // Логируем через систему обработки ошибок
    if (widget.enableLogging) {
      final errorController = ref.read(errorControllerProvider);
      errorController.handleError(error);
    }
  }

  /// Попытка восстановления
  void _retry() {
    setState(() {
      _hasError = false;
      _currentError = null;
    });

    // Если есть контекст для повтора операции
    if (_currentError != null && _currentError!.canRetryOperation) {
      final errorController = ref.read(errorControllerProvider);
      errorController.retryOperation(_currentError!);
    }
  }

  /// Отклонение ошибки
  void _dismiss() {
    setState(() {
      _hasError = false;
      _currentError = null;
    });

    if (_currentError != null) {
      final errorController = ref.read(errorControllerProvider);
      errorController.dismissError(_currentError!.errorId);
    }
  }
}

/// Глобальный Error Boundary для всего приложения
class GlobalErrorBoundary extends ConsumerWidget {
  const GlobalErrorBoundary({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ErrorBoundary(
      onError: (error) {
        // Все глобальные ошибки обрабатываются через систему
        final errorController = ref.read(errorControllerProvider);
        errorController.handleError(error);
      },
      fallbackBuilder: (error, retry) {
        // Для критических ошибок показываем полноэкранную страницу
        if (error.severity == ErrorSeverity.fatal) {
          return _FatalErrorScreen(error: error, onRetry: retry);
        }

        // Для остальных ошибок показываем стандартный виджет
        return ErrorDisplayWidget(
          error: error,
          onRetry: retry,
          onDismiss: () {
            final errorController = ref.read(errorControllerProvider);
            errorController.dismissError(error.errorId);
          },
        );
      },
      child: child,
    );
  }
}

/// Экран для фатальных ошибок
class _FatalErrorScreen extends StatelessWidget {
  const _FatalErrorScreen({
    Key? key,
    required this.error,
    required this.onRetry,
  }) : super(key: key);

  final AppError error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80, color: Colors.red.shade600),
              const SizedBox(height: 24),
              Text(
                'Критическая ошибка',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.red.shade800,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                error.userFriendlyMessage,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.red.shade700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Попробовать снова'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade700,
                        side: BorderSide(color: Colors.red.shade300),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Перезапуск приложения
                        // В реальном приложении здесь был бы restart
                      },
                      icon: const Icon(Icons.restart_alt),
                      label: const Text('Перезапуск'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (error.shouldShowDetails)
                ExpansionTile(
                  title: const Text('Техническая информация'),
                  iconColor: Colors.red.shade600,
                  textColor: Colors.red.shade700,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SelectableText(
                        error.detailedMessage,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mixin для добавления Error Boundary в StatefulWidget
mixin ErrorBoundaryMixin<T extends StatefulWidget> on State<T> {
  AppError? _boundaryError;

  void handleError(AppError error) {
    setState(() {
      _boundaryError = error;
    });
  }

  void clearError() {
    setState(() {
      _boundaryError = null;
    });
  }

  bool get hasError => _boundaryError != null;
  AppError? get currentError => _boundaryError;
}

/// Функция для создания Error Boundary вокруг виджета
Widget withErrorBoundary(
  Widget child, {
  void Function(AppError error)? onError,
  Widget Function(AppError error, VoidCallback retry)? fallbackBuilder,
  bool enableLogging = true,
}) {
  return ErrorBoundary(
    onError: onError,
    fallbackBuilder: fallbackBuilder,
    enableLogging: enableLogging,
    child: child,
  );
}

/// Zone-based error handling для асинхронных операций
R runWithErrorBoundary<R>(
  R Function() body, {
  void Function(Object error, StackTrace stackTrace)? onError,
}) {
  return runZonedGuarded(body, (error, stackTrace) {
        onError?.call(error, stackTrace);

        // Можно создать AppError и отправить в систему обработки ошибок
        // но пока просто вызываем callback
      }) ??
      body();
}
