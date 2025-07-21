import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/analytics_event.dart';
import '../models/user_models.dart';
import '../models/analytics_metrics.dart';

/// Абстрактный интерфейс для хранения данных аналитики
abstract class AnalyticsStorage {
  /// Инициализация хранилища
  Future<void> initialize();

  /// Сохранение события
  Future<void> saveEvent(AnalyticsEvent event);

  /// Получение событий
  Future<List<AnalyticsEvent>> getEvents({
    DateTime? startDate,
    DateTime? endDate,
    String? eventType,
    String? userId,
    int? limit,
  });

  /// Сохранение сессии
  Future<void> saveSession(UserSession session);

  /// Обновление сессии
  Future<void> updateSession(UserSession session);

  /// Получение сессий
  Future<List<UserSession>> getSessions({
    DateTime? startDate,
    DateTime? endDate,
    String? userId,
    int? limit,
  });

  /// Сохранение профиля пользователя
  Future<void> saveUserProfile(UserProfile profile);

  /// Получение профиля пользователя
  Future<UserProfile?> getUserProfile(String userId);

  /// Сохранение метрик
  Future<void> saveMetrics(String type, Map<String, dynamic> metrics);

  /// Получение метрик
  Future<Map<String, dynamic>?> getMetrics(
    String type, {
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Очистка старых данных
  Future<void> cleanupOldData(DateTime cutoffDate);

  /// Получение статистики хранилища
  Future<Map<String, int>> getStorageStats();

  /// Закрытие хранилища
  Future<void> close();
}

/// Реализация хранилища в памяти (для разработки и тестирования)
class InMemoryAnalyticsStorage implements AnalyticsStorage {
  final List<AnalyticsEvent> _events = [];
  final List<UserSession> _sessions = [];
  final Map<String, UserProfile> _userProfiles = {};
  final Map<String, Map<String, dynamic>> _metrics = {};

  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    if (kDebugMode) {
      print('InMemoryAnalyticsStorage initialized');
    }

    _isInitialized = true;
  }

  @override
  Future<void> saveEvent(AnalyticsEvent event) async {
    _ensureInitialized();
    _events.add(event);

    if (kDebugMode) {
      print('Event saved: ${event.eventName}');
    }
  }

  @override
  Future<List<AnalyticsEvent>> getEvents({
    DateTime? startDate,
    DateTime? endDate,
    String? eventType,
    String? userId,
    int? limit,
  }) async {
    _ensureInitialized();

    var filteredEvents = _events.where((event) {
      if (startDate != null && event.timestamp.isBefore(startDate)) {
        return false;
      }
      if (endDate != null && event.timestamp.isAfter(endDate)) {
        return false;
      }
      if (eventType != null && event.eventType != eventType) {
        return false;
      }
      if (userId != null && event.userId != userId) {
        return false;
      }
      return true;
    }).toList();

    // Сортируем по времени (новые сначала)
    filteredEvents.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (limit != null && filteredEvents.length > limit) {
      filteredEvents = filteredEvents.take(limit).toList();
    }

    return filteredEvents;
  }

  @override
  Future<void> saveSession(UserSession session) async {
    _ensureInitialized();
    _sessions.add(session);

    if (kDebugMode) {
      print('Session saved: ${session.sessionId}');
    }
  }

  @override
  Future<void> updateSession(UserSession session) async {
    _ensureInitialized();

    final index = _sessions.indexWhere((s) => s.sessionId == session.sessionId);
    if (index != -1) {
      _sessions[index] = session;
      if (kDebugMode) {
        print('Session updated: ${session.sessionId}');
      }
    }
  }

  @override
  Future<List<UserSession>> getSessions({
    DateTime? startDate,
    DateTime? endDate,
    String? userId,
    int? limit,
  }) async {
    _ensureInitialized();

    var filteredSessions = _sessions.where((session) {
      if (startDate != null && session.startTime.isBefore(startDate)) {
        return false;
      }
      if (endDate != null && session.startTime.isAfter(endDate)) {
        return false;
      }
      if (userId != null && session.userId != userId) {
        return false;
      }
      return true;
    }).toList();

    // Сортируем по времени начала (новые сначала)
    filteredSessions.sort((a, b) => b.startTime.compareTo(a.startTime));

    if (limit != null && filteredSessions.length > limit) {
      filteredSessions = filteredSessions.take(limit).toList();
    }

    return filteredSessions;
  }

  @override
  Future<void> saveUserProfile(UserProfile profile) async {
    _ensureInitialized();
    _userProfiles[profile.userId] = profile;

    if (kDebugMode) {
      print('User profile saved: ${profile.userId}');
    }
  }

  @override
  Future<UserProfile?> getUserProfile(String userId) async {
    _ensureInitialized();
    return _userProfiles[userId];
  }

  @override
  Future<void> saveMetrics(String type, Map<String, dynamic> metrics) async {
    _ensureInitialized();
    _metrics[type] = {
      ...metrics,
      'timestamp': DateTime.now().toIso8601String(),
    };

    if (kDebugMode) {
      print('Metrics saved: $type');
    }
  }

  @override
  Future<Map<String, dynamic>?> getMetrics(
    String type, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _ensureInitialized();

    final metrics = _metrics[type];
    if (metrics == null) return null;

    // Проверяем временные рамки
    if (startDate != null || endDate != null) {
      final timestamp = DateTime.tryParse(
        metrics['timestamp'] as String? ?? '',
      );
      if (timestamp != null) {
        if (startDate != null && timestamp.isBefore(startDate)) {
          return null;
        }
        if (endDate != null && timestamp.isAfter(endDate)) {
          return null;
        }
      }
    }

    return metrics;
  }

  @override
  Future<void> cleanupOldData(DateTime cutoffDate) async {
    _ensureInitialized();

    final initialEventCount = _events.length;
    final initialSessionCount = _sessions.length;

    // Удаляем старые события
    _events.removeWhere((event) => event.timestamp.isBefore(cutoffDate));

    // Удаляем старые сессии
    _sessions.removeWhere((session) => session.startTime.isBefore(cutoffDate));

    // Удаляем старые метрики
    _metrics.removeWhere((key, metrics) {
      final timestamp = DateTime.tryParse(
        metrics['timestamp'] as String? ?? '',
      );
      return timestamp != null && timestamp.isBefore(cutoffDate);
    });

    if (kDebugMode) {
      print(
        'Cleanup completed: ${initialEventCount - _events.length} events, '
        '${initialSessionCount - _sessions.length} sessions removed',
      );
    }
  }

  @override
  Future<Map<String, int>> getStorageStats() async {
    _ensureInitialized();

    return {
      'events_count': _events.length,
      'sessions_count': _sessions.length,
      'user_profiles_count': _userProfiles.length,
      'metrics_types_count': _metrics.length,
    };
  }

  @override
  Future<void> close() async {
    _events.clear();
    _sessions.clear();
    _userProfiles.clear();
    _metrics.clear();
    _isInitialized = false;

    if (kDebugMode) {
      print('InMemoryAnalyticsStorage closed');
    }
  }

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError('AnalyticsStorage not initialized');
    }
  }
}

/// Реализация хранилища на базе файловой системы
class FileAnalyticsStorage implements AnalyticsStorage {
  // Здесь может быть реализация с использованием файлов
  // Для упрощения используем InMemoryAnalyticsStorage как базу
  final InMemoryAnalyticsStorage _inMemoryStorage = InMemoryAnalyticsStorage();

  @override
  Future<void> initialize() async {
    await _inMemoryStorage.initialize();
    // Здесь можно добавить загрузку данных из файлов
  }

  @override
  Future<void> saveEvent(AnalyticsEvent event) async {
    await _inMemoryStorage.saveEvent(event);
    // Здесь можно добавить сохранение в файл
  }

  @override
  Future<List<AnalyticsEvent>> getEvents({
    DateTime? startDate,
    DateTime? endDate,
    String? eventType,
    String? userId,
    int? limit,
  }) async {
    return await _inMemoryStorage.getEvents(
      startDate: startDate,
      endDate: endDate,
      eventType: eventType,
      userId: userId,
      limit: limit,
    );
  }

  @override
  Future<void> saveSession(UserSession session) async {
    await _inMemoryStorage.saveSession(session);
  }

  @override
  Future<void> updateSession(UserSession session) async {
    await _inMemoryStorage.updateSession(session);
  }

  @override
  Future<List<UserSession>> getSessions({
    DateTime? startDate,
    DateTime? endDate,
    String? userId,
    int? limit,
  }) async {
    return await _inMemoryStorage.getSessions(
      startDate: startDate,
      endDate: endDate,
      userId: userId,
      limit: limit,
    );
  }

  @override
  Future<void> saveUserProfile(UserProfile profile) async {
    await _inMemoryStorage.saveUserProfile(profile);
  }

  @override
  Future<UserProfile?> getUserProfile(String userId) async {
    return await _inMemoryStorage.getUserProfile(userId);
  }

  @override
  Future<void> saveMetrics(String type, Map<String, dynamic> metrics) async {
    await _inMemoryStorage.saveMetrics(type, metrics);
  }

  @override
  Future<Map<String, dynamic>?> getMetrics(
    String type, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _inMemoryStorage.getMetrics(
      type,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Future<void> cleanupOldData(DateTime cutoffDate) async {
    await _inMemoryStorage.cleanupOldData(cutoffDate);
  }

  @override
  Future<Map<String, int>> getStorageStats() async {
    return await _inMemoryStorage.getStorageStats();
  }

  @override
  Future<void> close() async {
    await _inMemoryStorage.close();
  }
}
