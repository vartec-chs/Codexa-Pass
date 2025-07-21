import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/analytics_event.dart';
import '../models/analytics_metrics.dart';
import '../models/analytics_events.dart';
import '../storage/analytics_storage.dart';

/// Коллектор метрик производительности
class PerformanceCollector {
  final AnalyticsStorage storage;
  final bool enabled;
  bool _isInitialized = false;

  final Map<String, DateTime> _operationStartTimes = {};
  final List<Map<String, dynamic>> _performanceData = [];

  PerformanceCollector({required this.storage, this.enabled = true});

  /// Инициализация коллектора
  Future<void> initialize() async {
    if (_isInitialized || !enabled) return;

    if (kDebugMode) {
      print('PerformanceCollector initialized');
    }

    _isInitialized = true;
  }

  /// Начало отслеживания операции
  void startOperation(String operationName) {
    if (!_isInitialized || !enabled) return;

    _operationStartTimes[operationName] = DateTime.now();
  }

  /// Окончание отслеживания операции
  Future<void> endOperation({
    required String operationName,
    String? sessionId,
    String? userId,
    Map<String, dynamic>? additionalData,
  }) async {
    if (!_isInitialized || !enabled) return;

    final startTime = _operationStartTimes[operationName];
    if (startTime == null) {
      if (kDebugMode) {
        print('No start time found for operation: $operationName');
      }
      return;
    }

    final endTime = DateTime.now();
    final duration = endTime.difference(startTime).inMilliseconds;

    await trackPerformance(
      operationName: operationName,
      durationMs: duration,
      sessionId: sessionId,
      userId: userId,
      additionalData: additionalData,
    );

    _operationStartTimes.remove(operationName);
  }

  /// Отслеживание производительности
  Future<void> trackPerformance({
    required String operationName,
    required int durationMs,
    String? sessionId,
    String? userId,
    Map<String, dynamic>? additionalData,
  }) async {
    if (!_isInitialized || !enabled) return;

    try {
      final performanceData = {
        'operation_name': operationName,
        'duration_ms': durationMs,
        'timestamp': DateTime.now().toIso8601String(),
        'session_id': sessionId,
        'user_id': userId,
        ...?additionalData,
      };

      _performanceData.add(performanceData);

      // Создаем событие производительности
      if (sessionId != null && userId != null) {
        final event = AnalyticsEvent(
          id: _generatePerformanceEventId(),
          eventType: EventType.performance.name,
          eventName: _getPerformanceEventName(operationName),
          timestamp: DateTime.now(),
          sessionId: sessionId,
          userId: userId,
          parameters: {
            'operation_name': operationName,
            'duration_ms': durationMs,
            ...?additionalData,
          },
          context: {
            'performance_category': _getPerformanceCategory(operationName),
          },
          metadata: await _getDefaultMetadata(),
        );

        await storage.saveEvent(event);
      }

      // Сохраняем агрегированные метрики
      await _updatePerformanceMetrics(operationName, durationMs);

      if (kDebugMode) {
        print('Performance tracked: $operationName took ${durationMs}ms');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error tracking performance: $e');
      }
    }
  }

  /// Получение метрик производительности
  Future<PerformanceMetrics?> getMetrics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (!_isInitialized || !enabled) return null;

    try {
      final events = await storage.getEvents(
        startDate: startDate,
        endDate: endDate,
        eventType: EventType.performance.name,
      );

      if (events.isEmpty) {
        return const PerformanceMetrics(
          appStartupTime: 0,
          screenLoadTime: 0,
          databaseQueryTime: 0,
          encryptionTime: 0,
          decryptionTime: 0,
          searchTime: 0,
          memoryUsage: 0,
          cpuUsage: 0.0,
          networkRequestTime: 0,
          cacheHits: 0,
          cacheMisses: 0,
        );
      }

      int appStartupTime = 0;
      int screenLoadTime = 0;
      int databaseQueryTime = 0;
      int encryptionTime = 0;
      int decryptionTime = 0;
      int searchTime = 0;
      int memoryUsage = 0;
      double cpuUsage = 0.0;
      int networkRequestTime = 0;
      int cacheHits = 0;
      int cacheMisses = 0;

      int startupCount = 0;
      int screenLoadCount = 0;
      int dbQueryCount = 0;
      int encryptionCount = 0;
      int decryptionCount = 0;
      int searchCount = 0;
      int memoryCount = 0;
      int cpuCount = 0;
      int networkCount = 0;

      for (final event in events) {
        final operationName =
            event.parameters['operation_name'] as String? ?? '';
        final duration = event.parameters['duration_ms'] as int? ?? 0;
        final memory = event.parameters['memory_usage'] as int?;
        final cpu = event.parameters['cpu_usage'] as double?;

        switch (operationName.toLowerCase()) {
          case 'app_startup':
            appStartupTime += duration;
            startupCount++;
            break;
          case 'screen_load':
            screenLoadTime += duration;
            screenLoadCount++;
            break;
          case 'database_query':
          case 'db_query':
            databaseQueryTime += duration;
            dbQueryCount++;
            break;
          case 'encryption':
          case 'encrypt':
            encryptionTime += duration;
            encryptionCount++;
            break;
          case 'decryption':
          case 'decrypt':
            decryptionTime += duration;
            decryptionCount++;
            break;
          case 'search':
            searchTime += duration;
            searchCount++;
            break;
          case 'network_request':
          case 'api_call':
            networkRequestTime += duration;
            networkCount++;
            break;
          case 'cache_hit':
            cacheHits++;
            break;
          case 'cache_miss':
            cacheMisses++;
            break;
        }

        if (memory != null) {
          memoryUsage += memory;
          memoryCount++;
        }

        if (cpu != null) {
          cpuUsage += cpu;
          cpuCount++;
        }
      }

      return PerformanceMetrics(
        appStartupTime: startupCount > 0 ? appStartupTime ~/ startupCount : 0,
        screenLoadTime: screenLoadCount > 0
            ? screenLoadTime ~/ screenLoadCount
            : 0,
        databaseQueryTime: dbQueryCount > 0
            ? databaseQueryTime ~/ dbQueryCount
            : 0,
        encryptionTime: encryptionCount > 0
            ? encryptionTime ~/ encryptionCount
            : 0,
        decryptionTime: decryptionCount > 0
            ? decryptionTime ~/ decryptionCount
            : 0,
        searchTime: searchCount > 0 ? searchTime ~/ searchCount : 0,
        memoryUsage: memoryCount > 0 ? memoryUsage ~/ memoryCount : 0,
        cpuUsage: cpuCount > 0 ? cpuUsage / cpuCount : 0.0,
        networkRequestTime: networkCount > 0
            ? networkRequestTime ~/ networkCount
            : 0,
        cacheHits: cacheHits,
        cacheMisses: cacheMisses,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error getting performance metrics: $e');
      }
      return null;
    }
  }

  /// Получение детальной статистики производительности
  Future<Map<String, dynamic>> getDetailedStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (!_isInitialized || !enabled) return {};

    try {
      final events = await storage.getEvents(
        startDate: startDate,
        endDate: endDate,
        eventType: EventType.performance.name,
      );

      final operationStats = <String, List<int>>{};
      final slowestOperations = <String, int>{};

      for (final event in events) {
        final operationName =
            event.parameters['operation_name'] as String? ?? 'unknown';
        final duration = event.parameters['duration_ms'] as int? ?? 0;

        operationStats.putIfAbsent(operationName, () => []).add(duration);

        if (!slowestOperations.containsKey(operationName) ||
            duration > slowestOperations[operationName]!) {
          slowestOperations[operationName] = duration;
        }
      }

      final aggregatedStats = <String, Map<String, dynamic>>{};

      for (final entry in operationStats.entries) {
        final durations = entry.value;
        durations.sort();

        aggregatedStats[entry.key] = {
          'count': durations.length,
          'min': durations.isNotEmpty ? durations.first : 0,
          'max': durations.isNotEmpty ? durations.last : 0,
          'avg': durations.isNotEmpty
              ? durations.reduce((a, b) => a + b) / durations.length
              : 0,
          'p50': durations.isNotEmpty ? durations[durations.length ~/ 2] : 0,
          'p95': durations.isNotEmpty
              ? durations[(durations.length * 0.95).round()]
              : 0,
          'p99': durations.isNotEmpty
              ? durations[(durations.length * 0.99).round()]
              : 0,
        };
      }

      return {
        'operation_stats': aggregatedStats,
        'slowest_operations': slowestOperations,
        'total_operations': events.length,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error getting detailed performance stats: $e');
      }
      return {};
    }
  }

  Future<void> _updatePerformanceMetrics(
    String operationName,
    int durationMs,
  ) async {
    // Здесь можно обновлять агрегированные метрики в хранилище
    await storage.saveMetrics('performance_$operationName', {
      'operation_name': operationName,
      'duration_ms': durationMs,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  String _getPerformanceEventName(String operationName) {
    switch (operationName.toLowerCase()) {
      case 'app_startup':
        return PerformanceEvents.appStartup;
      case 'screen_load':
        return PerformanceEvents.screenLoadTime;
      case 'database_query':
      case 'db_query':
        return PerformanceEvents.databaseQuery;
      case 'encryption':
      case 'encrypt':
        return PerformanceEvents.encryptionTime;
      case 'decryption':
      case 'decrypt':
        return PerformanceEvents.decryptionTime;
      case 'search':
        return PerformanceEvents.searchTime;
      case 'network_request':
      case 'api_call':
        return PerformanceEvents.networkRequest;
      case 'cache_hit':
        return PerformanceEvents.cacheHit;
      case 'cache_miss':
        return PerformanceEvents.cacheMiss;
      default:
        return operationName;
    }
  }

  String _getPerformanceCategory(String operationName) {
    switch (operationName.toLowerCase()) {
      case 'app_startup':
      case 'screen_load':
        return 'ui';
      case 'database_query':
      case 'db_query':
        return 'database';
      case 'encryption':
      case 'decryption':
      case 'encrypt':
      case 'decrypt':
        return 'security';
      case 'search':
        return 'search';
      case 'network_request':
      case 'api_call':
        return 'network';
      case 'cache_hit':
      case 'cache_miss':
        return 'cache';
      default:
        return 'other';
    }
  }

  String _generatePerformanceEventId() {
    return '${DateTime.now().millisecondsSinceEpoch}_performance';
  }

  Future<EventMetadata> _getDefaultMetadata() async {
    return EventMetadata(
      appVersion: '1.0.0',
      platform: defaultTargetPlatform.name,
      osVersion: 'Unknown',
      deviceModel: 'Unknown',
      locale: 'en_US',
      timezone: DateTime.now().timeZoneName,
      screenSize: const ScreenSize(width: 0, height: 0, pixelRatio: 1.0),
      isDebugMode: kDebugMode,
    );
  }
}
