import 'dart:async';

import '../../logging/app_logger.dart';
import '../models/app_error.dart';
import '../models/error_severity.dart';
import '../utils/error_config.dart';
import '../utils/error_formatter.dart';

/// Основной обработчик ошибок
class ErrorHandler {
  ErrorHandler({required this.config, required this.formatter});

  final ErrorConfig config;
  final ErrorFormatter formatter;

  /// Инициализация обработчика
  Future<void> initialize() async {
    await AppLogger.instance.info(
      'Error handler initialized',
      module: 'ErrorHandler',
    );
  }

  /// Обработать ошибку
  Future<void> handle(AppError error) async {
    try {
      // Получаем конфигурацию для модуля
      final moduleConfig = config.getModuleConfig(error.module ?? 'Unknown');

      // Проверяем, нужно ли логировать ошибку
      if (moduleConfig.enableLogging) {
        await _logError(error);
      }

      // Проверяем, нужно ли отправлять отчет
      if (moduleConfig.enableReporting &&
          error.shouldReport &&
          config.enableErrorReporting) {
        await _reportError(error);
      }
    } catch (e, stackTrace) {
      // Логируем ошибку в обработчике ошибок
      await AppLogger.instance.error(
        'Error in error handler',
        module: 'ErrorHandler',
        error: e,
        stackTrace: stackTrace,
        metadata: {'originalError': error.toJson()},
      );
    }
  }

  /// Логирование ошибки
  Future<void> _logError(AppError error) async {
    // Форматируем сообщение для логирования
    final logMessage = formatter.formatLogMessage(error);

    // Определяем уровень логирования на основе критичности
    switch (error.severity) {
      case ErrorSeverity.info:
        await AppLogger.instance.info(
          logMessage,
          module: error.module ?? 'Unknown',
          metadata: error.metadata,
        );
        break;
      case ErrorSeverity.warning:
        await AppLogger.instance.warning(
          logMessage,
          module: error.module ?? 'Unknown',
          metadata: error.metadata,
        );
        break;
      case ErrorSeverity.error:
      case ErrorSeverity.critical:
      case ErrorSeverity.fatal:
        await AppLogger.instance.error(
          logMessage,
          module: error.module ?? 'Unknown',
          error: error.originalError,
          stackTrace: error.stackTrace,
          metadata: error.metadata,
        );
        break;
    }
  }

  /// Отправка отчета об ошибке
  Future<void> _reportError(AppError error) async {
    try {
      // Здесь должна быть логика отправки отчетов
      // Например, в сервис аналитики или краш-репортинг

      await AppLogger.instance.info(
        'Error report sent',
        module: 'ErrorHandler',
        metadata: {
          'errorId': error.errorId,
          'errorCode': error.code,
          'severity': error.severity.name,
        },
      );
    } catch (e, stackTrace) {
      await AppLogger.instance.error(
        'Failed to send error report',
        module: 'ErrorHandler',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Закрытие обработчика
  Future<void> dispose() async {
    await AppLogger.instance.info(
      'Error handler disposed',
      module: 'ErrorHandler',
    );
  }
}
