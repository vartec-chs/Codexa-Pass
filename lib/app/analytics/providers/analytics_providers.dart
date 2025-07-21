import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/analytics_service.dart';
import '../storage/analytics_storage.dart';
import '../models/analytics_event.dart';
import '../models/analytics_metrics.dart';
import '../models/user_models.dart';

/// Провайдер хранилища аналитики
final analyticsStorageProvider = Provider<AnalyticsStorage>((ref) {
  return InMemoryAnalyticsStorage();
});

/// Провайдер сервиса аналитики
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService.instance;
});

/// Провайдер инициализации аналитики
final analyticsInitializationProvider = FutureProvider<void>((ref) async {
  final service = ref.read(analyticsServiceProvider);
  final storage = ref.read(analyticsStorageProvider);

  await service.initialize(
    storage: storage,
    enablePerformanceTracking: true,
    enableSecurityTracking: true,
    enableUserBehaviorTracking: true,
    enableOfflineStorage: true,
  );
});

/// Провайдер потока событий аналитики
final analyticsEventStreamProvider = StreamProvider<AnalyticsEvent>((ref) {
  final service = ref.read(analyticsServiceProvider);
  return service.eventStream;
});

/// Провайдер метрик производительности
final performanceMetricsProvider =
    FutureProvider.family<PerformanceMetrics?, DateRange?>((
      ref,
      dateRange,
    ) async {
      final service = ref.read(analyticsServiceProvider);
      final metrics = await service.getMetrics(
        startDate: dateRange?.startDate,
        endDate: dateRange?.endDate,
      );

      final performanceData = metrics['performance'] as Map<String, dynamic>?;
      return performanceData != null
          ? PerformanceMetrics.fromJson(performanceData)
          : null;
    });

/// Провайдер метрик безопасности
final securityMetricsProvider =
    FutureProvider.family<SecurityMetrics?, DateRange?>((ref, dateRange) async {
      final service = ref.read(analyticsServiceProvider);
      final metrics = await service.getMetrics(
        startDate: dateRange?.startDate,
        endDate: dateRange?.endDate,
      );

      final securityData = metrics['security'] as Map<String, dynamic>?;
      return securityData != null
          ? SecurityMetrics.fromJson(securityData)
          : null;
    });

/// Провайдер метрик поведения пользователя
final userBehaviorMetricsProvider =
    FutureProvider.family<UserBehaviorMetrics?, DateRange?>((
      ref,
      dateRange,
    ) async {
      final service = ref.read(analyticsServiceProvider);
      final metrics = await service.getMetrics(
        startDate: dateRange?.startDate,
        endDate: dateRange?.endDate,
      );

      final behaviorData = metrics['behavior'] as Map<String, dynamic>?;
      return behaviorData != null
          ? UserBehaviorMetrics.fromJson(behaviorData)
          : null;
    });

/// Провайдер метрик ошибок
final errorMetricsProvider = FutureProvider.family<ErrorMetrics?, DateRange?>((
  ref,
  dateRange,
) async {
  final service = ref.read(analyticsServiceProvider);
  final metrics = await service.getMetrics(
    startDate: dateRange?.startDate,
    endDate: dateRange?.endDate,
  );

  final errorData = metrics['errors'] as Map<String, dynamic>?;
  return errorData != null ? ErrorMetrics.fromJson(errorData) : null;
});

/// Провайдер полных метрик
final allMetricsProvider =
    FutureProvider.family<Map<String, dynamic>, DateRange?>((
      ref,
      dateRange,
    ) async {
      final service = ref.read(analyticsServiceProvider);
      return await service.getMetrics(
        startDate: dateRange?.startDate,
        endDate: dateRange?.endDate,
      );
    });

/// Провайдер экспорта данных аналитики
final analyticsExportProvider =
    FutureProvider.family<Map<String, dynamic>, DateRange?>((
      ref,
      dateRange,
    ) async {
      final service = ref.read(analyticsServiceProvider);
      return await service.exportAnalyticsData(
        startDate: dateRange?.startDate,
        endDate: dateRange?.endDate,
      );
    });

/// Провайдер последних событий
final recentEventsProvider = FutureProvider.family<List<AnalyticsEvent>, int>((
  ref,
  limit,
) async {
  final storage = ref.read(analyticsStorageProvider);
  return await storage.getEvents(limit: limit);
});

/// Провайдер активных сессий
final activeSessionsProvider = FutureProvider<List<UserSession>>((ref) async {
  final storage = ref.read(analyticsStorageProvider);
  final sessions = await storage.getSessions(limit: 10);
  return sessions.where((session) => session.isActive).toList();
});

/// Провайдер статистики хранилища
final storageStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final storage = ref.read(analyticsStorageProvider);
  return await storage.getStorageStats();
});

/// Класс для представления диапазона дат
class DateRange {
  final DateTime startDate;
  final DateTime endDate;

  const DateRange({required this.startDate, required this.endDate});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DateRange &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode => startDate.hashCode ^ endDate.hashCode;
}

/// Менеджер состояния аналитики
class AnalyticsStateNotifier extends StateNotifier<AnalyticsState> {
  final AnalyticsService _analyticsService;

  AnalyticsStateNotifier(this._analyticsService)
    : super(const AnalyticsState());

  /// Отслеживание события
  Future<void> trackEvent({
    required String eventType,
    required String eventName,
    Map<String, dynamic>? parameters,
    Map<String, dynamic>? context,
  }) async {
    try {
      state = state.copyWith(isTracking: true);

      await _analyticsService.trackEvent(
        eventType: eventType,
        eventName: eventName,
        parameters: parameters,
        context: context,
      );

      state = state.copyWith(isTracking: false, lastEventTime: DateTime.now());
    } catch (e) {
      state = state.copyWith(isTracking: false, error: e.toString());
    }
  }

  /// Отслеживание производительности
  Future<void> trackPerformance({
    required String operationName,
    required int durationMs,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      await _analyticsService.trackPerformance(
        operationName: operationName,
        durationMs: durationMs,
        additionalData: additionalData,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Отслеживание ошибки
  Future<void> trackError({
    required String errorType,
    required String errorMessage,
    String? stackTrace,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      await _analyticsService.trackError(
        errorType: errorType,
        errorMessage: errorMessage,
        stackTrace: stackTrace,
        additionalData: additionalData,
      );
    } catch (e) {
      // Избегаем бесконечной рекурсии при ошибке в трекинге ошибок
      print('Error tracking error: $e');
    }
  }

  /// Отслеживание просмотра экрана
  Future<void> trackScreenView({
    required String screenName,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _analyticsService.trackScreenView(
        screenName: screenName,
        parameters: parameters,
      );

      state = state.copyWith(currentScreen: screenName);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Очистка ошибки
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Состояние аналитики
class AnalyticsState {
  final bool isTracking;
  final String? error;
  final DateTime? lastEventTime;
  final String? currentScreen;

  const AnalyticsState({
    this.isTracking = false,
    this.error,
    this.lastEventTime,
    this.currentScreen,
  });

  AnalyticsState copyWith({
    bool? isTracking,
    String? error,
    DateTime? lastEventTime,
    String? currentScreen,
  }) {
    return AnalyticsState(
      isTracking: isTracking ?? this.isTracking,
      error: error,
      lastEventTime: lastEventTime ?? this.lastEventTime,
      currentScreen: currentScreen ?? this.currentScreen,
    );
  }
}

/// Провайдер менеджера состояния аналитики
final analyticsStateProvider =
    StateNotifierProvider<AnalyticsStateNotifier, AnalyticsState>((ref) {
      final service = ref.read(analyticsServiceProvider);
      return AnalyticsStateNotifier(service);
    });

/// Утилиты для работы с аналитикой
class AnalyticsUtils {
  /// Предопределенные диапазоны дат
  static DateRange get today {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return DateRange(startDate: startOfDay, endDate: endOfDay);
  }

  static DateRange get yesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final startOfDay = DateTime(yesterday.year, yesterday.month, yesterday.day);
    final endOfDay = DateTime(
      yesterday.year,
      yesterday.month,
      yesterday.day,
      23,
      59,
      59,
    );
    return DateRange(startDate: startOfDay, endDate: endOfDay);
  }

  static DateRange get thisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfDay = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return DateRange(startDate: startOfDay, endDate: endOfDay);
  }

  static DateRange get thisMonth {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    return DateRange(startDate: startOfMonth, endDate: endOfMonth);
  }

  static DateRange get last30Days {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 30));
    final startOfDay = DateTime(start.year, start.month, start.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return DateRange(startDate: startOfDay, endDate: endOfDay);
  }

  static DateRange customRange(DateTime start, DateTime end) {
    return DateRange(startDate: start, endDate: end);
  }
}
