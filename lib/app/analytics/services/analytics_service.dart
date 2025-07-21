import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/analytics_event.dart';
import '../models/analytics_events.dart';
import '../models/user_models.dart';
import '../storage/analytics_storage.dart';
import '../collectors/event_collector.dart';
import '../collectors/performance_collector.dart';
import '../collectors/security_collector.dart';
import '../collectors/user_behavior_collector.dart';

/// Основной сервис аналитики
class AnalyticsService {
  static AnalyticsService? _instance;
  static AnalyticsService get instance => _instance ??= AnalyticsService._();

  AnalyticsService._();

  late final AnalyticsStorage _storage;
  late final EventCollector _eventCollector;
  late final PerformanceCollector _performanceCollector;
  late final SecurityCollector _securityCollector;
  late final UserBehaviorCollector _userBehaviorCollector;

  bool _isInitialized = false;
  String? _currentSessionId;
  String? _userId;
  UserSession? _currentSession;

  final StreamController<AnalyticsEvent> _eventStreamController =
      StreamController<AnalyticsEvent>.broadcast();

  /// Поток событий аналитики
  Stream<AnalyticsEvent> get eventStream => _eventStreamController.stream;

  /// Инициализация сервиса аналитики
  Future<void> initialize({
    required AnalyticsStorage storage,
    String? userId,
    bool enablePerformanceTracking = true,
    bool enableSecurityTracking = true,
    bool enableUserBehaviorTracking = true,
    bool enableOfflineStorage = true,
  }) async {
    if (_isInitialized) return;

    _storage = storage;
    await _storage.initialize();

    _eventCollector = EventCollector(storage: _storage);
    _performanceCollector = PerformanceCollector(
      storage: _storage,
      enabled: enablePerformanceTracking,
    );
    _securityCollector = SecurityCollector(
      storage: _storage,
      enabled: enableSecurityTracking,
    );
    _userBehaviorCollector = UserBehaviorCollector(
      storage: _storage,
      enabled: enableUserBehaviorTracking,
    );

    // Инициализируем коллекторы
    await _eventCollector.initialize();
    await _performanceCollector.initialize();
    await _securityCollector.initialize();
    await _userBehaviorCollector.initialize();

    // Получаем или создаем пользователя
    _userId = userId ?? await _generateAnonymousUserId();

    // Начинаем новую сессию
    await _startNewSession();

    _isInitialized = true;

    // Логируем инициализацию
    await trackEvent(
      eventType: EventType.lifecycle.name,
      eventName: LifecycleEvents.appLaunched,
      parameters: {
        'is_first_launch': await _isFirstLaunch(),
        'app_version': await _getAppVersion(),
        'platform': await _getPlatform(),
      },
    );
  }

  /// Отслеживание события
  Future<void> trackEvent({
    required String eventType,
    required String eventName,
    Map<String, dynamic>? parameters,
    Map<String, dynamic>? context,
  }) async {
    if (!_isInitialized) {
      if (kDebugMode) {
        print('AnalyticsService not initialized');
      }
      return;
    }

    try {
      final event = AnalyticsEvent(
        id: _generateEventId(),
        eventType: eventType,
        eventName: eventName,
        timestamp: DateTime.now(),
        sessionId: _currentSessionId!,
        userId: _userId!,
        parameters: parameters ?? {},
        context: context ?? await _getDefaultContext(),
        metadata: await _getEventMetadata(),
      );

      // Сохраняем событие
      await _eventCollector.collectEvent(event);

      // Обновляем текущую сессию
      await _updateCurrentSession(event);

      // Отправляем в поток
      _eventStreamController.add(event);

      // Обновляем метрики поведения пользователя
      await _userBehaviorCollector.updateBehaviorMetrics(event);

      // Проверяем безопасность
      await _securityCollector.analyzeSecurityEvent(event);
    } catch (e) {
      if (kDebugMode) {
        print('Error tracking event: $e');
      }
    }
  }

  /// Отслеживание производительности
  Future<void> trackPerformance({
    required String operationName,
    required int durationMs,
    Map<String, dynamic>? additionalData,
  }) async {
    if (!_isInitialized) return;

    await _performanceCollector.trackPerformance(
      operationName: operationName,
      durationMs: durationMs,
      sessionId: _currentSessionId!,
      userId: _userId!,
      additionalData: additionalData,
    );
  }

  /// Отслеживание ошибки
  Future<void> trackError({
    required String errorType,
    required String errorMessage,
    String? stackTrace,
    Map<String, dynamic>? additionalData,
  }) async {
    await trackEvent(
      eventType: EventType.error.name,
      eventName: ErrorEvents.unexpectedError,
      parameters: {
        'error_type': errorType,
        'error_message': errorMessage,
        'stack_trace': stackTrace,
        ...?additionalData,
      },
    );
  }

  /// Отслеживание безопасности
  Future<void> trackSecurity({
    required String securityEventType,
    Map<String, dynamic>? details,
  }) async {
    await _securityCollector.trackSecurityEvent(
      eventType: securityEventType,
      sessionId: _currentSessionId!,
      userId: _userId!,
      details: details,
    );
  }

  /// Отслеживание навигации
  Future<void> trackScreenView({
    required String screenName,
    Map<String, dynamic>? parameters,
  }) async {
    await trackEvent(
      eventType: EventType.userInterface.name,
      eventName: UserInterfaceEvents.screenViewed,
      parameters: {
        'screen_name': screenName,
        'timestamp': DateTime.now().toIso8601String(),
        ...?parameters,
      },
    );

    // Обновляем текущую сессию
    if (_currentSession != null) {
      _currentSession = _currentSession!.copyWith(
        screenViews: _currentSession!.screenViews + 1,
        lastActiveScreen: screenName,
      );
      await _storage.updateSession(_currentSession!);
    }
  }

  /// Начало новой сессии
  Future<void> _startNewSession() async {
    _currentSessionId = _generateSessionId();

    _currentSession = UserSession(
      sessionId: _currentSessionId!,
      startTime: DateTime.now(),
      userId: _userId!,
      eventIds: [],
      screenViews: 0,
      isActive: true,
    );

    await _storage.saveSession(_currentSession!);
  }

  /// Завершение текущей сессии
  Future<void> endSession({SessionEndReason? reason}) async {
    if (_currentSession == null) return;

    final endTime = DateTime.now();
    final duration = endTime
        .difference(_currentSession!.startTime)
        .inMilliseconds;

    _currentSession = _currentSession!.copyWith(
      endTime: endTime,
      duration: duration,
      isActive: false,
      endReason: reason ?? SessionEndReason.manualLogout,
    );

    await _storage.updateSession(_currentSession!);

    // Логируем завершение сессии
    await trackEvent(
      eventType: EventType.lifecycle.name,
      eventName: LifecycleEvents.appTerminated,
      parameters: {
        'session_duration': duration,
        'end_reason': reason?.name ?? 'manual',
        'screen_views': _currentSession!.screenViews,
      },
    );

    _currentSession = null;
    _currentSessionId = null;
  }

  /// Получение метрик
  Future<Map<String, dynamic>> getMetrics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (!_isInitialized) return {};

    final performanceMetrics = await _performanceCollector.getMetrics(
      startDate: startDate,
      endDate: endDate,
    );

    final securityMetrics = await _securityCollector.getMetrics(
      startDate: startDate,
      endDate: endDate,
    );

    final behaviorMetrics = await _userBehaviorCollector.getMetrics(
      startDate: startDate,
      endDate: endDate,
    );

    final errorMetrics = await _eventCollector.getErrorMetrics(
      startDate: startDate,
      endDate: endDate,
    );

    return {
      'performance': performanceMetrics?.toJson(),
      'security': securityMetrics?.toJson(),
      'behavior': behaviorMetrics?.toJson(),
      'errors': errorMetrics?.toJson(),
      'generated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Экспорт данных аналитики
  Future<Map<String, dynamic>> exportAnalyticsData({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (!_isInitialized) return {};

    final events = await _storage.getEvents(
      startDate: startDate,
      endDate: endDate,
    );

    final sessions = await _storage.getSessions(
      startDate: startDate,
      endDate: endDate,
    );

    final metrics = await getMetrics(startDate: startDate, endDate: endDate);

    return {
      'events': events.map((e) => e.toJson()).toList(),
      'sessions': sessions.map((s) => s.toJson()).toList(),
      'metrics': metrics,
      'export_date': DateTime.now().toIso8601String(),
      'user_id': _userId,
    };
  }

  /// Очистка старых данных
  Future<void> cleanupOldData({Duration? olderThan}) async {
    if (!_isInitialized) return;

    final cutoffDate = DateTime.now().subtract(
      olderThan ?? const Duration(days: 90),
    );

    await _storage.cleanupOldData(cutoffDate);
  }

  /// Приватные методы
  Future<void> _updateCurrentSession(AnalyticsEvent event) async {
    if (_currentSession == null) return;

    final updatedEventIds = [..._currentSession!.eventIds, event.id];

    _currentSession = _currentSession!.copyWith(eventIds: updatedEventIds);

    await _storage.updateSession(_currentSession!);
  }

  Future<Map<String, dynamic>> _getDefaultContext() async {
    return {
      'app_version': await _getAppVersion(),
      'platform': await _getPlatform(),
      'locale': await _getLocale(),
      'timezone': DateTime.now().timeZoneName,
      'is_debug': kDebugMode,
    };
  }

  Future<EventMetadata> _getEventMetadata() async {
    // Здесь можно получить реальные данные об устройстве
    // Для примера используем заглушки
    return EventMetadata(
      appVersion: await _getAppVersion(),
      platform: await _getPlatform(),
      osVersion: 'Unknown',
      deviceModel: 'Unknown',
      locale: await _getLocale(),
      timezone: DateTime.now().timeZoneName,
      screenSize: const ScreenSize(width: 0, height: 0, pixelRatio: 1.0),
      isDebugMode: kDebugMode,
    );
  }

  String _generateEventId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${_userId}_event';
  }

  String _generateSessionId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${_userId}_session';
  }

  Future<String> _generateAnonymousUserId() async {
    // В реальном приложении здесь должен быть уникальный идентификатор
    return 'user_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<bool> _isFirstLaunch() async {
    // Проверяем, есть ли сохраненные данные пользователя
    return true; // Заглушка
  }

  Future<String> _getAppVersion() async {
    return '1.0.0'; // Заглушка
  }

  Future<String> _getPlatform() async {
    return defaultTargetPlatform.name;
  }

  Future<String> _getLocale() async {
    return 'ru_RU'; // Заглушка
  }

  /// Освобождение ресурсов
  void dispose() {
    _eventStreamController.close();
  }
}
