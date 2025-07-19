import 'dart:io';
import 'package:flutter/foundation.dart';
import 'app_logger.dart';

/// Утилиты для работы с логами
class LogUtils {
  static final AppLogger _logger = AppLogger.instance;

  /// Логирование информации о приложении при запуске
  static void logAppInfo() {
    _logger.info('=== Запуск приложения ===');
    _logger.info('Платформа: ${Platform.operatingSystem}');
    _logger.info('Версия: ${Platform.operatingSystemVersion}');
    _logger.info('Debug режим: $kDebugMode');
    _logger.info('Release режим: $kReleaseMode');
    _logger.info('Profile режим: $kProfileMode');
  }

  /// Логирование производительности
  static void logPerformance(String operation, Duration duration) {
    _logger.info(
      '⏱️ Производительность: $operation - ${duration.inMilliseconds}ms',
    );
  }

  /// Измерение времени выполнения функции
  static Future<T> measurePerformance<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await operation();
      stopwatch.stop();
      logPerformance(operationName, stopwatch.elapsed);
      return result;
    } catch (e, stackTrace) {
      stopwatch.stop();
      _logger.error(
        'Ошибка в операции "$operationName" (${stopwatch.elapsed.inMilliseconds}ms)',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Логирование навигации
  static void logNavigation(String from, String to) {
    _logger.info('🧭 Навигация: $from → $to');
  }

  /// Логирование пользовательских действий
  static void logUserAction(String action, {Map<String, dynamic>? details}) {
    final String message = details != null
        ? '👤 Действие пользователя: $action - $details'
        : '👤 Действие пользователя: $action';
    _logger.info(message);
  }

  /// Логирование жизненного цикла виджетов
  static void logWidgetLifecycle(String widgetName, String event) {
    _logger.debug('📱 Жизненный цикл: $widgetName - $event');
  }

  /// Логирование состояния подключения
  static void logConnectivityStatus(bool isConnected) {
    final String status = isConnected ? 'подключено' : 'отключено';
    _logger.info('🌐 Интернет-соединение: $status');
  }

  /// Логирование работы с базой данных
  static void logDatabaseOperation(
    String operation, {
    String? table,
    dynamic data,
  }) {
    final String message = table != null
        ? '🗄️ БД операция: $operation в таблице $table'
        : '🗄️ БД операция: $operation';
    _logger.debug(message, data);
  }

  /// Логирование работы с файлами
  static void logFileOperation(String operation, String filePath) {
    _logger.debug('📁 Файловая операция: $operation - $filePath');
  }

  /// Логирование критических ошибок с контекстом
  static void logCriticalError(
    String context,
    dynamic error,
    StackTrace stackTrace, {
    Map<String, dynamic>? additionalInfo,
  }) {
    final String message = additionalInfo != null
        ? '💥 Критическая ошибка в $context - Дополнительно: $additionalInfo'
        : '💥 Критическая ошибка в $context';
    _logger.fatal(message, error, stackTrace);
  }

  /// Логирование состояния памяти (только в debug режиме)
  static void logMemoryInfo() {
    if (kDebugMode) {
      // В release режиме ProcessInfo недоступен
      _logger.debug(
        '💾 Использование памяти: информация недоступна в текущей версии',
      );
    }
  }

  /// Форматирование размера файла для логов
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Получение краткой информации об ошибке
  static String getErrorSummary(dynamic error) {
    if (error == null) return 'Неизвестная ошибка';

    final String errorString = error.toString();
    if (errorString.length > 200) {
      return '${errorString.substring(0, 200)}...';
    }
    return errorString;
  }
}
