import 'dart:async';
import 'dart:collection';

import '../../logging/app_logger.dart';
import '../models/app_error.dart';
import '../utils/error_config.dart';

/// Обработчик аналитики ошибок
class ErrorAnalyticsHandler {
  ErrorAnalyticsHandler({required this.config});

  final ErrorConfig config;

  /// Статистика ошибок
  final Map<String, _ErrorStats> _errorStats = {};

  /// История ошибок для анализа трендов
  final Queue<_ErrorEvent> _errorHistory = Queue<_ErrorEvent>();

  /// Максимальный размер истории
  static const int _maxHistorySize = 1000;

  /// Инициализация обработчика
  Future<void> initialize() async {
    await AppLogger.instance.info(
      'Error analytics handler initialized',
      module: 'ErrorAnalytics',
    );
  }

  /// Обработать ошибку для аналитики
  Future<void> handle(AppError error) async {
    if (!config.enableAnalytics) return;

    try {
      // Записываем событие в историю
      _recordErrorEvent(error);

      // Обновляем статистику
      _updateErrorStats(error);

      // Анализируем тренды
      await _analyzeTrends();

      // Отправляем в внешние аналитические сервисы
      await _sendToAnalyticsService(error);
    } catch (e, stackTrace) {
      await AppLogger.instance.error(
        'Error in analytics handler',
        module: 'ErrorAnalytics',
        error: e,
        stackTrace: stackTrace,
        metadata: {'originalError': error.toJson()},
      );
    }
  }

  /// Записать событие ошибки
  void _recordErrorEvent(AppError error) {
    final event = _ErrorEvent(error: error, timestamp: DateTime.now());

    _errorHistory.add(event);

    // Ограничиваем размер истории
    while (_errorHistory.length > _maxHistorySize) {
      _errorHistory.removeFirst();
    }
  }

  /// Обновить статистику ошибок
  void _updateErrorStats(AppError error) {
    final key = '${error.module ?? 'unknown'}_${error.code}';
    final now = DateTime.now();

    final stats =
        _errorStats[key] ??
        _ErrorStats(
          errorCode: error.code,
          module: error.module ?? 'unknown',
          count: 0,
          firstOccurrence: now,
          lastOccurrence: now,
          severityDistribution: {},
        );

    // Обновляем статистику
    final updatedStats = stats.copyWith(
      count: stats.count + 1,
      lastOccurrence: now,
      severityDistribution: {
        ...stats.severityDistribution,
        error.severity.name:
            (stats.severityDistribution[error.severity.name] ?? 0) + 1,
      },
    );

    _errorStats[key] = updatedStats;
  }

  /// Анализ трендов ошибок
  Future<void> _analyzeTrends() async {
    final now = DateTime.now();
    final lastHour = now.subtract(const Duration(hours: 1));

    // Подсчитываем ошибки за последний час
    final recentErrors = _errorHistory
        .where((event) => event.timestamp.isAfter(lastHour))
        .toList();

    if (recentErrors.length > 50) {
      // Слишком много ошибок за час - возможна проблема
      await _reportErrorSpike(recentErrors);
    }

    // Анализируем частые ошибки
    await _analyzeFrequentErrors();
  }

  /// Сообщить о всплеске ошибок
  Future<void> _reportErrorSpike(List<_ErrorEvent> recentErrors) async {
    final errorsByModule = <String, int>{};
    final errorsBySeverity = <String, int>{};

    for (final event in recentErrors) {
      final module = event.error.module ?? 'unknown';
      errorsByModule[module] = (errorsByModule[module] ?? 0) + 1;

      final severity = event.error.severity.name;
      errorsBySeverity[severity] = (errorsBySeverity[severity] ?? 0) + 1;
    }

    await AppLogger.instance.warning(
      'Error spike detected',
      module: 'ErrorAnalytics',
      metadata: {
        'errorCount': recentErrors.length,
        'timeWindow': 'last hour',
        'errorsByModule': errorsByModule,
        'errorsBySeverity': errorsBySeverity,
      },
    );
  }

  /// Анализ частых ошибок
  Future<void> _analyzeFrequentErrors() async {
    final frequentErrors =
        _errorStats.values.where((stats) => stats.count > 10).toList()
          ..sort((a, b) => b.count.compareTo(a.count));

    if (frequentErrors.isNotEmpty) {
      await AppLogger.instance.info(
        'Frequent errors detected',
        module: 'ErrorAnalytics',
        metadata: {
          'topErrors': frequentErrors
              .take(5)
              .map(
                (stats) => {
                  'code': stats.errorCode,
                  'module': stats.module,
                  'count': stats.count,
                  'firstOccurrence': stats.firstOccurrence.toIso8601String(),
                  'lastOccurrence': stats.lastOccurrence.toIso8601String(),
                },
              )
              .toList(),
        },
      );
    }
  }

  /// Отправить в аналитический сервис
  Future<void> _sendToAnalyticsService(AppError error) async {
    // Здесь должна быть интеграция с внешними сервисами аналитики
    // Например, Firebase Analytics, Sentry, Crashlytics и т.д.

    await AppLogger.instance.debug(
      'Sending error to analytics service',
      module: 'ErrorAnalytics',
      metadata: {
        'errorId': error.errorId,
        'errorCode': error.code,
        'module': error.module,
        'severity': error.severity.name,
      },
    );
  }

  /// Получить статистику ошибок
  Map<String, dynamic> getErrorStatistics() {
    final now = DateTime.now();

    // Общая статистика
    final totalErrors = _errorStats.values.fold(
      0,
      (sum, stats) => sum + stats.count,
    );

    // Статистика по модулям
    final moduleStats = <String, int>{};
    for (final stats in _errorStats.values) {
      moduleStats[stats.module] =
          (moduleStats[stats.module] ?? 0) + stats.count;
    }

    // Статистика по критичности
    final severityStats = <String, int>{};
    for (final stats in _errorStats.values) {
      stats.severityDistribution.forEach((severity, count) {
        severityStats[severity] = (severityStats[severity] ?? 0) + count;
      });
    }

    // Статистика за последние периоды
    final last24h = now.subtract(const Duration(hours: 24));
    final last7d = now.subtract(const Duration(days: 7));

    final errors24h = _errorHistory
        .where((event) => event.timestamp.isAfter(last24h))
        .length;

    final errors7d = _errorHistory
        .where((event) => event.timestamp.isAfter(last7d))
        .length;

    return {
      'totalErrors': totalErrors,
      'errors24h': errors24h,
      'errors7d': errors7d,
      'uniqueErrorTypes': _errorStats.length,
      'moduleStats': moduleStats,
      'severityStats': severityStats,
      'topErrors': _errorStats.values.toList()
        ..sort((a, b) => b.count.compareTo(a.count))
        ..take(10)
        ..map(
          (stats) => {
            'code': stats.errorCode,
            'module': stats.module,
            'count': stats.count,
            'firstOccurrence': stats.firstOccurrence.toIso8601String(),
            'lastOccurrence': stats.lastOccurrence.toIso8601String(),
          },
        ).toList(),
    };
  }

  /// Получить тренды ошибок
  Map<String, dynamic> getErrorTrends() {
    final now = DateTime.now();
    final periods = [
      const Duration(hours: 1),
      const Duration(hours: 6),
      const Duration(hours: 24),
      const Duration(days: 7),
    ];

    final trends = <String, List<int>>{};

    for (final period in periods) {
      final cutoff = now.subtract(period);
      final errorsInPeriod = _errorHistory
          .where((event) => event.timestamp.isAfter(cutoff))
          .toList();

      // Группируем по часам
      final hourlyData = <int, int>{};
      for (final event in errorsInPeriod) {
        final hour = event.timestamp.hour;
        hourlyData[hour] = (hourlyData[hour] ?? 0) + 1;
      }

      trends[period.toString()] = List.generate(
        24,
        (hour) => hourlyData[hour] ?? 0,
      );
    }

    return trends;
  }

  /// Экспорт данных аналитики
  Map<String, dynamic> exportAnalyticsData() {
    return {
      'statistics': getErrorStatistics(),
      'trends': getErrorTrends(),
      'errorHistory': _errorHistory
          .map(
            (event) => {
              'timestamp': event.timestamp.toIso8601String(),
              'error': event.error.toJson(),
            },
          )
          .toList(),
      'detailedStats': _errorStats.map(
        (key, stats) => MapEntry(key, stats.toJson()),
      ),
    };
  }

  /// Очистить устаревшие данные
  void cleanupOldData({Duration? maxAge}) {
    final cutoff = DateTime.now().subtract(maxAge ?? const Duration(days: 30));

    // Очищаем историю
    while (_errorHistory.isNotEmpty &&
        _errorHistory.first.timestamp.isBefore(cutoff)) {
      _errorHistory.removeFirst();
    }

    // Очищаем статистику для ошибок, которые не встречались давно
    _errorStats.removeWhere(
      (key, stats) => stats.lastOccurrence.isBefore(cutoff),
    );
  }

  /// Закрытие обработчика
  Future<void> dispose() async {
    _errorStats.clear();
    _errorHistory.clear();

    await AppLogger.instance.info(
      'Error analytics handler disposed',
      module: 'ErrorAnalytics',
    );
  }
}

/// Событие ошибки для аналитики
class _ErrorEvent {
  const _ErrorEvent({required this.error, required this.timestamp});

  final AppError error;
  final DateTime timestamp;
}

/// Статистика конкретной ошибки
class _ErrorStats {
  const _ErrorStats({
    required this.errorCode,
    required this.module,
    required this.count,
    required this.firstOccurrence,
    required this.lastOccurrence,
    required this.severityDistribution,
  });

  final String errorCode;
  final String module;
  final int count;
  final DateTime firstOccurrence;
  final DateTime lastOccurrence;
  final Map<String, int> severityDistribution;

  _ErrorStats copyWith({
    String? errorCode,
    String? module,
    int? count,
    DateTime? firstOccurrence,
    DateTime? lastOccurrence,
    Map<String, int>? severityDistribution,
  }) {
    return _ErrorStats(
      errorCode: errorCode ?? this.errorCode,
      module: module ?? this.module,
      count: count ?? this.count,
      firstOccurrence: firstOccurrence ?? this.firstOccurrence,
      lastOccurrence: lastOccurrence ?? this.lastOccurrence,
      severityDistribution: severityDistribution ?? this.severityDistribution,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'errorCode': errorCode,
      'module': module,
      'count': count,
      'firstOccurrence': firstOccurrence.toIso8601String(),
      'lastOccurrence': lastOccurrence.toIso8601String(),
      'severityDistribution': severityDistribution,
    };
  }
}
