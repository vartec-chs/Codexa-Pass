import 'dart:io';
import 'package:flutter/foundation.dart';
import 'app_logger.dart';
import 'system_info.dart';
import 'crash_reporter.dart';

/// Утилиты для работы с логами
class LogUtils {
  static final AppLogger _logger = AppLogger.instance;
  static final SystemInfo _systemInfo = SystemInfo.instance;
  static final CrashReporter _crashReporter = CrashReporter.instance;

  /// Инициализация системной информации и краш-репортера
  static Future<void> initializeSystemInfo() async {
    try {
      await _systemInfo.initialize();
      await _crashReporter.initialize();
      _logger.info(
        '✅ Системная информация и краш-репортер успешно инициализированы',
      );
    } catch (e, stackTrace) {
      _logger.error(
        '❌ Ошибка инициализации системной информации',
        e,
        stackTrace,
      );
    }
  }

  /// Логирование расширенной информации о приложении при запуске
  static Future<void> logExtendedAppInfo() async {
    _logger.info('=== ЗАПУСК ПРИЛОЖЕНИЯ ===');

    // Дожидаемся инициализации системной информации, если она ещё не произошла
    if (_systemInfo.appName == 'Unknown') {
      await _systemInfo.initialize();
    }

    // Логируем полную системную информацию
    _logger.info(_systemInfo.getSystemInfoString());
  }

  /// Логирование краткой информации о системе
  static void logShortSystemInfo() {
    _logger.info('📱 ${_systemInfo.getShortSystemInfo()}');
  }

  /// Логирование информации о приложении при запуске (устаревший метод)
  @Deprecated(
    'Используйте logExtendedAppInfo() для получения расширенной информации',
  )
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

  /// Логирование подробной информации об устройстве
  static void logDeviceDetails() {
    final deviceDetails = _systemInfo.getDeviceDetails();
    if (deviceDetails != null) {
      _logger.info('📱 Подробная информация об устройстве:');
      deviceDetails.forEach((key, value) {
        _logger.info('  $key: $value');
      });
    } else {
      _logger.warning('⚠️ Подробная информация об устройстве недоступна');
    }
  }

  /// Логирование информации об окружении
  static void logEnvironmentInfo() {
    _logger.info('🌍 Информация об окружении:');

    final appInfo = _systemInfo.getAppInfo();
    appInfo.forEach((key, value) {
      _logger.info('  App $key: $value');
    });

    final platformInfo = _systemInfo.getPlatformInfo();
    platformInfo.forEach((key, value) {
      _logger.info('  Platform $key: $value');
    });
  }

  /// Логирование информации о сборке приложения
  static void logBuildInfo() {
    _logger.info('🔧 Информация о сборке:');
    _logger.info('  Название: ${_systemInfo.appName}');
    _logger.info('  Пакет: ${_systemInfo.packageName}');
    _logger.info('  Версия: ${_systemInfo.fullVersion}');
    _logger.info(
      '  Режим: ${kDebugMode
          ? 'Debug'
          : kReleaseMode
          ? 'Release'
          : 'Profile'}',
    );
  }

  /// Создание заголовка лога с системной информацией
  static String createLogHeader() {
    final buffer = StringBuffer();
    buffer.writeln('=' * 60);
    buffer.writeln('НОВАЯ СЕССИЯ ЛОГИРОВАНИЯ');
    buffer.writeln('Время запуска: ${DateTime.now().toIso8601String()}');
    buffer.writeln(_systemInfo.getShortSystemInfo());
    buffer.writeln('=' * 60);
    return buffer.toString();
  }

  /// Логирование начала новой сессии с полной информацией
  static Future<void> logSessionStart() async {
    // Инициализируем системную информацию, если ещё не сделали
    if (_systemInfo.appName == 'Unknown') {
      await initializeSystemInfo();
    }

    _logger.info(createLogHeader());
    await logExtendedAppInfo();
  }

  /// Логирование завершения сессии
  static void logSessionEnd() {
    _logger.info('=' * 60);
    _logger.info('ЗАВЕРШЕНИЕ СЕССИИ ЛОГИРОВАНИЯ');
    _logger.info('Время завершения: ${DateTime.now().toIso8601String()}');
    _logger.info('=' * 60);
  }

  /// Логирование критической ошибки с контекстом системы
  static void logCriticalErrorWithContext(
    String context,
    dynamic error,
    StackTrace stackTrace, {
    Map<String, dynamic>? additionalInfo,
  }) {
    _logger.fatal('💥 КРИТИЧЕСКАЯ ОШИБКА 💥');
    _logger.fatal('Контекст: $context');
    _logger.fatal('Системная информация: ${_systemInfo.getShortSystemInfo()}');

    if (additionalInfo != null) {
      _logger.fatal('Дополнительная информация:');
      additionalInfo.forEach((key, value) {
        _logger.fatal('  $key: $value');
      });
    }

    _logger.fatal('Ошибка:', error, stackTrace);
  }

  // === МЕТОДЫ ДЛЯ РАБОТЫ С КРАШ-РЕПОРТАМИ ===

  /// Создание краш-репорта для Flutter ошибки
  static Future<String?> reportFlutterCrash(
    String title,
    dynamic error,
    StackTrace stackTrace, {
    Map<String, dynamic>? additionalInfo,
  }) async {
    return await _crashReporter.reportCrash(
      type: CrashType.flutter,
      title: title,
      exception: error,
      stackTrace: stackTrace,
      additionalData: additionalInfo,
    );
  }

  /// Создание краш-репорта для Dart ошибки
  static Future<String?> reportDartCrash(
    String title,
    dynamic error,
    StackTrace stackTrace, {
    Map<String, dynamic>? additionalInfo,
  }) async {
    return await _crashReporter.reportCrash(
      type: CrashType.dart,
      title: title,
      exception: error,
      stackTrace: stackTrace,
      additionalData: additionalInfo,
    );
  }

  /// Создание краш-репорта для нативной ошибки
  static Future<String?> reportNativeCrash(
    String title,
    dynamic error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? additionalInfo,
  }) async {
    return await _crashReporter.reportCrash(
      type: CrashType.native,
      title: title,
      exception: error,
      stackTrace: stackTrace,
      additionalData: additionalInfo,
    );
  }

  /// Создание пользовательского краш-репорта
  static Future<String?> reportCustomCrash(
    String title,
    dynamic error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? additionalInfo,
  }) async {
    return await _crashReporter.reportCrash(
      type: CrashType.custom,
      title: title,
      exception: error,
      stackTrace: stackTrace,
      additionalData: additionalInfo,
    );
  }

  /// Создание фатального краш-репорта
  static Future<String?> reportFatalCrash(
    String title,
    dynamic error,
    StackTrace stackTrace, {
    Map<String, dynamic>? additionalInfo,
  }) async {
    return await _crashReporter.reportCrash(
      type: CrashType.fatal,
      title: title,
      exception: error,
      stackTrace: stackTrace,
      additionalData: additionalInfo,
    );
  }

  /// Получение статистики краш-репортов
  static Future<Map<CrashType, int>> getCrashReportsStatistics() async {
    return await _crashReporter.getCrashReportsCount();
  }

  /// Логирование статистики краш-репортов
  static Future<void> logCrashReportsStatistics() async {
    try {
      final stats = await getCrashReportsStatistics();
      _logger.info('📊 Статистика краш-репортов:');

      int total = 0;
      stats.forEach((type, count) {
        _logger.info('  ${type.folderName}: $count');
        total += count;
      });

      _logger.info('  Всего: $total');
    } catch (e) {
      _logger.error('Ошибка получения статистики краш-репортов', e);
    }
  }

  /// Очистка всех краш-репортов
  static Future<void> clearAllCrashReports() async {
    try {
      await _crashReporter.clearAllCrashReports();
      _logger.info('🗑️ Все краш-репорты очищены');
    } catch (e) {
      _logger.error('Ошибка очистки краш-репортов', e);
    }
  }

  /// Очистка краш-репортов определенного типа
  static Future<void> clearCrashReportsByType(CrashType type) async {
    try {
      await _crashReporter.clearCrashReportsByType(type);
      _logger.info('🗑️ Краш-репорты типа ${type.folderName} очищены');
    } catch (e) {
      _logger.error('Ошибка очистки краш-репортов типа ${type.folderName}', e);
    }
  }

  /// Получение пути к директории краш-репортов
  static String? getCrashReportsPath() {
    return _crashReporter.crashReportsPath;
  }

  /// Проверка инициализации краш-репортера
  static bool get isCrashReporterInitialized => _crashReporter.isInitialized;
}
