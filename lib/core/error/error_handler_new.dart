import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codexa_pass/core/error/enhanced_app_error.dart';
import 'package:codexa_pass/core/error/error_dialogs.dart';
import 'package:codexa_pass/core/logging/logging.dart';

/// Провайдер глобального ключа навигатора
final navigatorKeyProvider = Provider<GlobalKey<NavigatorState>>((ref) {
  return GlobalKey<NavigatorState>();
});

/// Миксин для обработки ошибок в виджетах
mixin ErrorHandlerMixin<T extends StatefulWidget> on State<T> {
  /// Обрабатывает ошибку с контекстом
  void handleError(BaseAppError error) {
    SafeErrorHandling.handleErrorWithContext(context, error);
  }

  /// Обрабатывает ошибку без контекста
  void handleErrorSafely(BaseAppError error) {
    SafeErrorHandling.handleErrorSafely(error);
  }

  /// Показывает сообщение об ошибке как SnackBar
  void showErrorSnackBar(BaseAppError error) {
    SafeErrorHandling.showErrorSnackBar(context, error);
  }

  /// Показывает критический диалог ошибки
  void showCriticalErrorDialog(BaseAppError error) {
    SafeErrorHandling.showCriticalErrorDialog(context, error);
  }
}

/// Безопасная обработка ошибок
class SafeErrorHandling {
  /// Обрабатывает ошибку с контекстом
  static void handleErrorWithContext(BuildContext context, BaseAppError error) {
    logError(error);

    if (error.isCritical) {
      showCriticalErrorDialog(context, error);
    } else {
      showErrorSnackBar(context, error);
    }
  }

  /// Обрабатывает ошибку без контекста
  static void handleErrorSafely(BaseAppError error) {
    logError(error);
    AppLogger.instance.error('Error handled safely', error);
  }

  /// Показывает SnackBar с ошибкой
  static void showErrorSnackBar(BuildContext context, BaseAppError error) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: ErrorSnackBarContent(error: error, message: error.message),
        backgroundColor: Colors.red[600],
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Подробности',
          textColor: Colors.white,
          onPressed: () => showErrorDetailsDialog(context, error),
        ),
      ),
    );
  }

  /// Показывает критический диалог ошибки
  static void showCriticalErrorDialog(
    BuildContext context,
    BaseAppError error,
  ) {
    if (!context.mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CriticalErrorDialog(
        error: error,
        message: error.message,
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  /// Показывает диалог с подробностями ошибки
  static void showErrorDetailsDialog(BuildContext context, BaseAppError error) {
    if (!context.mounted) return;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Подробности ошибки'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Код: ${error.code}'),
              const SizedBox(height: 8),
              Text('Сообщение: ${error.message}'),
              if (error.technicalDetails != null) ...[
                const SizedBox(height: 8),
                Text('Техническая информация: ${error.technicalDetails}'),
              ],
              if (error.context != null) ...[
                const SizedBox(height: 8),
                Text('Контекст: ${error.context}'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  /// Логирует ошибку
  static void logError(BaseAppError error) {
    if (error.isCritical) {
      AppLogger.instance.fatal(
        'Critical Error: ${error.code}',
        error,
        error.stackTrace,
      );
    } else {
      AppLogger.instance.error('Error: ${error.code}', error, error.stackTrace);
    }

    // Создаем краш-репорт для критических ошибок
    if (error.shouldCreateCrashReport) {
      LogUtils.reportCustomCrash(
        error.code,
        error,
        stackTrace: error.stackTrace ?? StackTrace.current,
        additionalInfo: error.context ?? {},
      );
    }
  }
}

/// Глобальный обработчик ошибок
class GlobalErrorHandler {
  static final GlobalErrorHandler _instance = GlobalErrorHandler._internal();
  factory GlobalErrorHandler() => _instance;
  GlobalErrorHandler._internal();

  GlobalKey<NavigatorState>? _navigatorKey;

  /// Инициализация с ключом навигатора
  void initialize(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
  }

  /// Обработка ошибки на глобальном уровне
  void handleError(BaseAppError error) {
    final context = _navigatorKey?.currentContext;

    if (context != null) {
      SafeErrorHandling.handleErrorWithContext(context, error);
    } else {
      SafeErrorHandling.handleErrorSafely(error);
    }
  }
}
