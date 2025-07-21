import '../services/analytics_service.dart';
import '../models/analytics_events.dart';

/// Трекер для отслеживания производительности
class PerformanceTracker {
  final AnalyticsService _analyticsService;
  final Map<String, DateTime> _operationStartTimes = {};

  PerformanceTracker(this._analyticsService);

  /// Начало отслеживания операции
  void startTracking(String operationName) {
    _operationStartTimes[operationName] = DateTime.now();
  }

  /// Окончание отслеживания операции
  Future<void> endTracking({
    required String operationName,
    Map<String, dynamic>? additionalData,
  }) async {
    final startTime = _operationStartTimes[operationName];
    if (startTime == null) return;

    final duration = DateTime.now().difference(startTime).inMilliseconds;
    _operationStartTimes.remove(operationName);

    await _analyticsService.trackPerformance(
      operationName: operationName,
      durationMs: duration,
      additionalData: additionalData,
    );
  }

  /// Отслеживание времени запуска приложения
  Future<void> trackAppStartup({
    required int durationMs,
    String? startupType,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackPerformance(
      operationName: 'app_startup',
      durationMs: durationMs,
      additionalData: {
        'startup_type': startupType ?? 'cold',
        'timestamp': DateTime.now().toIso8601String(),
        ...?context,
      },
    );
  }

  /// Отслеживание времени загрузки экрана
  Future<void> trackScreenLoadTime({
    required String screenName,
    required int durationMs,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackPerformance(
      operationName: 'screen_load',
      durationMs: durationMs,
      additionalData: {
        'screen_name': screenName,
        'timestamp': DateTime.now().toIso8601String(),
        ...?context,
      },
    );
  }

  /// Отслеживание времени выполнения запроса к БД
  Future<void> trackDatabaseQuery({
    required int durationMs,
    required String queryType,
    String? tableName,
    int? resultCount,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackPerformance(
      operationName: 'database_query',
      durationMs: durationMs,
      additionalData: {
        'query_type': queryType,
        'table_name': tableName,
        'result_count': resultCount,
        'timestamp': DateTime.now().toIso8601String(),
        ...?context,
      },
    );
  }

  /// Отслеживание времени шифрования
  Future<void> trackEncryption({
    required int durationMs,
    int? dataSize,
    String? encryptionType,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackPerformance(
      operationName: 'encryption',
      durationMs: durationMs,
      additionalData: {
        'data_size_bytes': dataSize,
        'encryption_type': encryptionType ?? 'aes',
        'timestamp': DateTime.now().toIso8601String(),
        ...?context,
      },
    );
  }

  /// Отслеживание времени дешифрования
  Future<void> trackDecryption({
    required int durationMs,
    int? dataSize,
    String? encryptionType,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackPerformance(
      operationName: 'decryption',
      durationMs: durationMs,
      additionalData: {
        'data_size_bytes': dataSize,
        'encryption_type': encryptionType ?? 'aes',
        'timestamp': DateTime.now().toIso8601String(),
        ...?context,
      },
    );
  }

  /// Отслеживание времени поиска
  Future<void> trackSearchTime({
    required int durationMs,
    required String searchType,
    int? resultsCount,
    int? datasetSize,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackPerformance(
      operationName: 'search',
      durationMs: durationMs,
      additionalData: {
        'search_type': searchType,
        'results_count': resultsCount,
        'dataset_size': datasetSize,
        'timestamp': DateTime.now().toIso8601String(),
        ...?context,
      },
    );
  }

  /// Отслеживание использования памяти
  Future<void> trackMemoryUsage({
    required int memoryUsageBytes,
    String? context,
    Map<String, dynamic>? additionalData,
  }) async {
    await _analyticsService.trackEvent(
      eventType: EventType.performance.name,
      eventName: PerformanceEvents.memoryUsage,
      parameters: {
        'memory_usage_bytes': memoryUsageBytes,
        'memory_usage_mb': (memoryUsageBytes / (1024 * 1024)).round(),
        'context': context,
        'timestamp': DateTime.now().toIso8601String(),
        ...?additionalData,
      },
    );
  }

  /// Отслеживание использования CPU
  Future<void> trackCpuUsage({
    required double cpuPercentage,
    String? context,
    Map<String, dynamic>? additionalData,
  }) async {
    await _analyticsService.trackEvent(
      eventType: EventType.performance.name,
      eventName: PerformanceEvents.cpuUsage,
      parameters: {
        'cpu_usage_percent': cpuPercentage,
        'context': context,
        'timestamp': DateTime.now().toIso8601String(),
        ...?additionalData,
      },
    );
  }

  /// Отслеживание сетевого запроса
  Future<void> trackNetworkRequest({
    required int durationMs,
    required String method,
    required String endpoint,
    int? statusCode,
    int? responseSize,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackPerformance(
      operationName: 'network_request',
      durationMs: durationMs,
      additionalData: {
        'method': method,
        'endpoint': endpoint,
        'status_code': statusCode,
        'response_size_bytes': responseSize,
        'timestamp': DateTime.now().toIso8601String(),
        ...?context,
      },
    );
  }

  /// Отслеживание попадания в кэш
  Future<void> trackCacheHit({
    required String cacheType,
    required String key,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackEvent(
      eventType: EventType.performance.name,
      eventName: PerformanceEvents.cacheHit,
      parameters: {
        'cache_type': cacheType,
        'cache_key_hash': key.hashCode.toString(),
        'timestamp': DateTime.now().toIso8601String(),
        ...?context,
      },
    );
  }

  /// Отслеживание промаха кэша
  Future<void> trackCacheMiss({
    required String cacheType,
    required String key,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackEvent(
      eventType: EventType.performance.name,
      eventName: PerformanceEvents.cacheMiss,
      parameters: {
        'cache_type': cacheType,
        'cache_key_hash': key.hashCode.toString(),
        'timestamp': DateTime.now().toIso8601String(),
        ...?context,
      },
    );
  }

  /// Отслеживание производительности анимации
  Future<void> trackAnimationPerformance({
    required String animationType,
    required int durationMs,
    required double frameRate,
    int? droppedFrames,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackEvent(
      eventType: EventType.performance.name,
      eventName: 'animation_performance',
      parameters: {
        'animation_type': animationType,
        'duration_ms': durationMs,
        'frame_rate': frameRate,
        'dropped_frames': droppedFrames ?? 0,
        'is_smooth': (droppedFrames ?? 0) == 0,
        'timestamp': DateTime.now().toIso8601String(),
        ...?context,
      },
    );
  }

  /// Отслеживание времени отклика UI
  Future<void> trackUIResponseTime({
    required String actionType,
    required int responseTimeMs,
    required String screenName,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackPerformance(
      operationName: 'ui_response',
      durationMs: responseTimeMs,
      additionalData: {
        'action_type': actionType,
        'screen_name': screenName,
        'timestamp': DateTime.now().toIso8601String(),
        ...?context,
      },
    );
  }

  /// Отслеживание производительности прокрутки
  Future<void> trackScrollPerformance({
    required double scrollVelocity,
    required int itemCount,
    int? droppedFrames,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackEvent(
      eventType: EventType.performance.name,
      eventName: 'scroll_performance',
      parameters: {
        'scroll_velocity': scrollVelocity,
        'item_count': itemCount,
        'dropped_frames': droppedFrames ?? 0,
        'is_smooth': (droppedFrames ?? 0) < 5,
        'timestamp': DateTime.now().toIso8601String(),
        ...?context,
      },
    );
  }

  /// Отслеживание использования батареи
  Future<void> trackBatteryUsage({
    required double batteryLevel,
    required double batteryDrain,
    String? context,
    Map<String, dynamic>? additionalData,
  }) async {
    await _analyticsService.trackEvent(
      eventType: EventType.performance.name,
      eventName: 'battery_usage',
      parameters: {
        'battery_level_percent': batteryLevel,
        'battery_drain_percent': batteryDrain,
        'context': context,
        'timestamp': DateTime.now().toIso8601String(),
        ...?additionalData,
      },
    );
  }

  /// Измерение времени выполнения функции
  Future<T> measureExecutionTime<T>({
    required String operationName,
    required Future<T> Function() operation,
    Map<String, dynamic>? additionalData,
  }) async {
    final startTime = DateTime.now();
    try {
      final result = await operation();
      final duration = DateTime.now().difference(startTime).inMilliseconds;

      await _analyticsService.trackPerformance(
        operationName: operationName,
        durationMs: duration,
        additionalData: {
          'success': true,
          'timestamp': DateTime.now().toIso8601String(),
          ...?additionalData,
        },
      );

      return result;
    } catch (e) {
      final duration = DateTime.now().difference(startTime).inMilliseconds;

      await _analyticsService.trackPerformance(
        operationName: operationName,
        durationMs: duration,
        additionalData: {
          'success': false,
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
          ...?additionalData,
        },
      );

      rethrow;
    }
  }

  /// Отслеживание загрузки ресурсов
  Future<void> trackResourceLoad({
    required String resourceType,
    required int loadTimeMs,
    required int resourceSize,
    bool? fromCache,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackPerformance(
      operationName: 'resource_load',
      durationMs: loadTimeMs,
      additionalData: {
        'resource_type': resourceType,
        'resource_size_bytes': resourceSize,
        'from_cache': fromCache ?? false,
        'timestamp': DateTime.now().toIso8601String(),
        ...?context,
      },
    );
  }
}
