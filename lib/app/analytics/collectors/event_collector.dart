import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/analytics_event.dart';
import '../models/analytics_metrics.dart';
import '../storage/analytics_storage.dart';

/// Коллектор событий
class EventCollector {
  final AnalyticsStorage storage;
  bool _isInitialized = false;

  EventCollector({required this.storage});

  /// Инициализация коллектора
  Future<void> initialize() async {
    if (_isInitialized) return;

    if (kDebugMode) {
      print('EventCollector initialized');
    }

    _isInitialized = true;
  }

  /// Сбор события
  Future<void> collectEvent(AnalyticsEvent event) async {
    if (!_isInitialized) {
      throw StateError('EventCollector not initialized');
    }

    try {
      await storage.saveEvent(event);

      if (kDebugMode) {
        print('Event collected: ${event.eventName} at ${event.timestamp}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error collecting event: $e');
      }
      rethrow;
    }
  }

  /// Получение метрик ошибок
  Future<ErrorMetrics?> getErrorMetrics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (!_isInitialized) return null;

    try {
      final events = await storage.getEvents(
        startDate: startDate,
        endDate: endDate,
        eventType: 'error',
      );

      if (events.isEmpty) {
        return const ErrorMetrics(
          totalErrors: 0,
          criticalErrors: 0,
          errorsByType: {},
          errorsByScreen: {},
          networkErrors: 0,
          databaseErrors: 0,
          encryptionErrors: 0,
          authenticationErrors: 0,
          syncErrors: 0,
          errorRecoveries: 0,
        );
      }

      final errorsByType = <String, int>{};
      final errorsByScreen = <String, int>{};
      int criticalErrors = 0;
      int networkErrors = 0;
      int databaseErrors = 0;
      int encryptionErrors = 0;
      int authenticationErrors = 0;
      int syncErrors = 0;
      int errorRecoveries = 0;

      for (final event in events) {
        final errorType =
            event.parameters['error_type'] as String? ?? 'unknown';
        final screenName = event.context['screen_name'] as String? ?? 'unknown';
        final severity = event.parameters['severity'] as String? ?? 'normal';

        // Подсчет по типам
        errorsByType[errorType] = (errorsByType[errorType] ?? 0) + 1;

        // Подсчет по экранам
        errorsByScreen[screenName] = (errorsByScreen[screenName] ?? 0) + 1;

        // Критические ошибки
        if (severity == 'critical') {
          criticalErrors++;
        }

        // Специфичные типы ошибок
        switch (errorType.toLowerCase()) {
          case 'network':
          case 'connection':
          case 'timeout':
            networkErrors++;
            break;
          case 'database':
          case 'sql':
          case 'storage':
            databaseErrors++;
            break;
          case 'encryption':
          case 'decryption':
          case 'crypto':
            encryptionErrors++;
            break;
          case 'authentication':
          case 'auth':
          case 'login':
            authenticationErrors++;
            break;
          case 'sync':
          case 'synchronization':
            syncErrors++;
            break;
          case 'recovery':
            errorRecoveries++;
            break;
        }
      }

      return ErrorMetrics(
        totalErrors: events.length,
        criticalErrors: criticalErrors,
        errorsByType: errorsByType,
        errorsByScreen: errorsByScreen,
        networkErrors: networkErrors,
        databaseErrors: databaseErrors,
        encryptionErrors: encryptionErrors,
        authenticationErrors: authenticationErrors,
        syncErrors: syncErrors,
        errorRecoveries: errorRecoveries,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error getting error metrics: $e');
      }
      return null;
    }
  }

  /// Получение общей статистики событий
  Future<Map<String, dynamic>> getEventStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (!_isInitialized) return {};

    try {
      final events = await storage.getEvents(
        startDate: startDate,
        endDate: endDate,
      );

      final eventsByType = <String, int>{};
      final eventsByHour = <int, int>{};
      final eventsByDay = <String, int>{};

      for (final event in events) {
        // По типам
        eventsByType[event.eventType] =
            (eventsByType[event.eventType] ?? 0) + 1;

        // По часам
        final hour = event.timestamp.hour;
        eventsByHour[hour] = (eventsByHour[hour] ?? 0) + 1;

        // По дням
        final day =
            '${event.timestamp.year}-${event.timestamp.month.toString().padLeft(2, '0')}-${event.timestamp.day.toString().padLeft(2, '0')}';
        eventsByDay[day] = (eventsByDay[day] ?? 0) + 1;
      }

      return {
        'total_events': events.length,
        'events_by_type': eventsByType,
        'events_by_hour': eventsByHour,
        'events_by_day': eventsByDay,
        'most_active_hour': eventsByHour.entries.isNotEmpty
            ? eventsByHour.entries
                  .reduce((a, b) => a.value > b.value ? a : b)
                  .key
            : null,
        'most_active_day': eventsByDay.entries.isNotEmpty
            ? eventsByDay.entries
                  .reduce((a, b) => a.value > b.value ? a : b)
                  .key
            : null,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error getting event statistics: $e');
      }
      return {};
    }
  }
}
