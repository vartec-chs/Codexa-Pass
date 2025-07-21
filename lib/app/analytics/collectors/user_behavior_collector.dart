import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/analytics_event.dart';
import '../models/analytics_metrics.dart';
import '../models/analytics_events.dart';
import '../models/user_models.dart';
import '../storage/analytics_storage.dart';

/// Коллектор метрик поведения пользователя
class UserBehaviorCollector {
  final AnalyticsStorage storage;
  final bool enabled;
  bool _isInitialized = false;

  // Метрики поведения пользователя
  int _totalSessions = 0;
  double _averageSessionDuration = 0.0;
  int _screenViews = 0;
  final Map<String, int> _featureUsage = {};
  int _passwordsCreated = 0;
  int _passwordsViewed = 0;
  int _passwordsCopied = 0;
  int _searchQueries = 0;
  int _passwordGeneratorUsage = 0;
  int _dataExports = 0;
  int _dataImports = 0;
  int _syncOperations = 0;

  UserBehaviorCollector({required this.storage, this.enabled = true});

  /// Инициализация коллектора
  Future<void> initialize() async {
    if (_isInitialized || !enabled) return;

    if (kDebugMode) {
      print('UserBehaviorCollector initialized');
    }

    _isInitialized = true;
    await _loadExistingMetrics();
  }

  /// Обновление метрик поведения на основе события
  Future<void> updateBehaviorMetrics(AnalyticsEvent event) async {
    if (!_isInitialized || !enabled) return;

    try {
      switch (event.eventType) {
        case 'userInterface':
          await _processUIEvent(event);
          break;
        case 'passwordManagement':
          await _processPasswordEvent(event);
          break;
        case 'synchronization':
          await _processSyncEvent(event);
          break;
        case 'dataTransfer':
          await _processDataTransferEvent(event);
          break;
        case 'lifecycle':
          await _processLifecycleEvent(event);
          break;
      }

      // Обновляем использование функций
      _updateFeatureUsage(event.eventName);

      // Сохраняем обновленные метрики
      await _saveMetrics();
    } catch (e) {
      if (kDebugMode) {
        print('Error updating behavior metrics: $e');
      }
    }
  }

  /// Отслеживание сессии пользователя
  Future<void> trackSession(UserSession session) async {
    if (!_isInitialized || !enabled) return;

    try {
      if (session.endTime != null && session.duration != null) {
        _totalSessions++;

        // Обновляем среднюю продолжительность сессии
        final sessionDurationMinutes = session.duration! / (1000 * 60);
        _averageSessionDuration =
            ((_averageSessionDuration * (_totalSessions - 1)) +
                sessionDurationMinutes) /
            _totalSessions;

        _screenViews += session.screenViews;

        await _saveMetrics();

        if (kDebugMode) {
          print(
            'Session tracked: ${session.sessionId}, duration: ${sessionDurationMinutes.toStringAsFixed(2)} minutes',
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error tracking session: $e');
      }
    }
  }

  /// Получение метрик поведения пользователя
  Future<UserBehaviorMetrics?> getMetrics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (!_isInitialized || !enabled) return null;

    try {
      // Обновляем метрики из событий
      await _calculateMetricsFromEvents(startDate, endDate);

      return UserBehaviorMetrics(
        totalSessions: _totalSessions,
        averageSessionDuration: _averageSessionDuration,
        screenViews: _screenViews,
        featureUsage: Map.from(_featureUsage),
        passwordsCreated: _passwordsCreated,
        passwordsViewed: _passwordsViewed,
        passwordsCopied: _passwordsCopied,
        searchQueries: _searchQueries,
        passwordGeneratorUsage: _passwordGeneratorUsage,
        dataExports: _dataExports,
        dataImports: _dataImports,
        syncOperations: _syncOperations,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error getting behavior metrics: $e');
      }
      return null;
    }
  }

  /// Получение детального анализа поведения
  Future<Map<String, dynamic>> getBehaviorAnalysis({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (!_isInitialized || !enabled) return {};

    try {
      final events = await storage.getEvents(
        startDate: startDate,
        endDate: endDate,
      );

      final sessions = await storage.getSessions(
        startDate: startDate,
        endDate: endDate,
      );

      // Анализ активности по времени
      final activityByHour = <int, int>{};
      final activityByDayOfWeek = <int, int>{};

      for (final event in events) {
        final hour = event.timestamp.hour;
        final dayOfWeek = event.timestamp.weekday;

        activityByHour[hour] = (activityByHour[hour] ?? 0) + 1;
        activityByDayOfWeek[dayOfWeek] =
            (activityByDayOfWeek[dayOfWeek] ?? 0) + 1;
      }

      // Анализ популярных экранов
      final screenPopularity = <String, int>{};
      for (final event in events) {
        if (event.eventName == UserInterfaceEvents.screenViewed) {
          final screenName =
              event.parameters['screen_name'] as String? ?? 'unknown';
          screenPopularity[screenName] =
              (screenPopularity[screenName] ?? 0) + 1;
        }
      }

      // Анализ длительности сессий
      final sessionDurations = sessions
          .where((s) => s.duration != null)
          .map((s) => s.duration! / (1000 * 60)) // в минутах
          .toList();

      sessionDurations.sort();

      final metrics = await getMetrics(startDate: startDate, endDate: endDate);

      return {
        'activity_patterns': {
          'by_hour': activityByHour,
          'by_day_of_week': activityByDayOfWeek,
          'most_active_hour': activityByHour.entries.isNotEmpty
              ? activityByHour.entries
                    .reduce((a, b) => a.value > b.value ? a : b)
                    .key
              : null,
          'most_active_day': activityByDayOfWeek.entries.isNotEmpty
              ? activityByDayOfWeek.entries
                    .reduce((a, b) => a.value > b.value ? a : b)
                    .key
              : null,
        },
        'screen_popularity': screenPopularity,
        'session_analysis': {
          'total_sessions': sessions.length,
          'avg_duration_minutes': sessionDurations.isNotEmpty
              ? sessionDurations.reduce((a, b) => a + b) /
                    sessionDurations.length
              : 0,
          'median_duration_minutes': sessionDurations.isNotEmpty
              ? sessionDurations[sessionDurations.length ~/ 2]
              : 0,
          'longest_session_minutes': sessionDurations.isNotEmpty
              ? sessionDurations.last
              : 0,
          'shortest_session_minutes': sessionDurations.isNotEmpty
              ? sessionDurations.first
              : 0,
        },
        'feature_adoption': {
          'total_features_used': _featureUsage.length,
          'most_used_features': _getMostUsedFeatures(5),
          'feature_usage_distribution': _featureUsage,
        },
        'engagement_level': _calculateEngagementLevel(),
        'user_segments': _getUserSegment(),
        'metrics': metrics?.toJson(),
        'generated_at': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error getting behavior analysis: $e');
      }
      return {};
    }
  }

  /// Получение рекомендаций на основе поведения пользователя
  Future<List<Map<String, dynamic>>> getUserRecommendations() async {
    if (!_isInitialized || !enabled) return [];

    try {
      final recommendations = <Map<String, dynamic>>[];

      // Рекомендации на основе использования функций
      if (_passwordGeneratorUsage == 0) {
        recommendations.add({
          'type': 'feature_suggestion',
          'title': 'Попробуйте генератор паролей',
          'description': 'Создавайте надежные пароли автоматически',
          'priority': 'high',
          'category': 'security',
        });
      }

      if (_dataExports == 0 && _passwordsCreated > 10) {
        recommendations.add({
          'type': 'backup_suggestion',
          'title': 'Создайте резервную копию',
          'description': 'Защитите свои данные с помощью экспорта',
          'priority': 'medium',
          'category': 'backup',
        });
      }

      if (_syncOperations == 0 && _totalSessions > 5) {
        recommendations.add({
          'type': 'sync_suggestion',
          'title': 'Настройте синхронизацию',
          'description': 'Получите доступ к паролям на всех устройствах',
          'priority': 'medium',
          'category': 'convenience',
        });
      }

      // Рекомендации на основе паттернов активности
      if (_averageSessionDuration < 2.0) {
        recommendations.add({
          'type': 'tutorial_suggestion',
          'title': 'Изучите возможности приложения',
          'description': 'Узнайте больше о функциях безопасности',
          'priority': 'low',
          'category': 'education',
        });
      }

      if (_searchQueries > 20 && _passwordsCreated < 10) {
        recommendations.add({
          'type': 'organization_suggestion',
          'title': 'Организуйте пароли',
          'description': 'Используйте категории и теги для удобства поиска',
          'priority': 'medium',
          'category': 'organization',
        });
      }

      return recommendations;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user recommendations: $e');
      }
      return [];
    }
  }

  // Приватные методы
  Future<void> _loadExistingMetrics() async {
    final existingMetrics = await storage.getMetrics('user_behavior');
    if (existingMetrics != null) {
      _totalSessions = existingMetrics['total_sessions'] as int? ?? 0;
      _averageSessionDuration =
          (existingMetrics['average_session_duration'] as num?)?.toDouble() ??
          0.0;
      _screenViews = existingMetrics['screen_views'] as int? ?? 0;
      _featureUsage.addAll(
        Map<String, int>.from(existingMetrics['feature_usage'] as Map? ?? {}),
      );
      _passwordsCreated = existingMetrics['passwords_created'] as int? ?? 0;
      _passwordsViewed = existingMetrics['passwords_viewed'] as int? ?? 0;
      _passwordsCopied = existingMetrics['passwords_copied'] as int? ?? 0;
      _searchQueries = existingMetrics['search_queries'] as int? ?? 0;
      _passwordGeneratorUsage =
          existingMetrics['password_generator_usage'] as int? ?? 0;
      _dataExports = existingMetrics['data_exports'] as int? ?? 0;
      _dataImports = existingMetrics['data_imports'] as int? ?? 0;
      _syncOperations = existingMetrics['sync_operations'] as int? ?? 0;
    }
  }

  Future<void> _saveMetrics() async {
    await storage.saveMetrics('user_behavior', {
      'total_sessions': _totalSessions,
      'average_session_duration': _averageSessionDuration,
      'screen_views': _screenViews,
      'feature_usage': _featureUsage,
      'passwords_created': _passwordsCreated,
      'passwords_viewed': _passwordsViewed,
      'passwords_copied': _passwordsCopied,
      'search_queries': _searchQueries,
      'password_generator_usage': _passwordGeneratorUsage,
      'data_exports': _dataExports,
      'data_imports': _dataImports,
      'sync_operations': _syncOperations,
    });
  }

  Future<void> _calculateMetricsFromEvents(
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    final events = await storage.getEvents(
      startDate: startDate,
      endDate: endDate,
    );

    for (final event in events) {
      await updateBehaviorMetrics(event);
    }
  }

  Future<void> _processUIEvent(AnalyticsEvent event) async {
    switch (event.eventName) {
      case UserInterfaceEvents.screenViewed:
        _screenViews++;
        break;
      case UserInterfaceEvents.searchPerformed:
        _searchQueries++;
        break;
    }
  }

  Future<void> _processPasswordEvent(AnalyticsEvent event) async {
    switch (event.eventName) {
      case PasswordManagementEvents.passwordCreated:
        _passwordsCreated++;
        break;
      case PasswordManagementEvents.passwordViewed:
        _passwordsViewed++;
        break;
      case PasswordManagementEvents.passwordCopied:
        _passwordsCopied++;
        break;
      case PasswordManagementEvents.passwordGenerated:
        _passwordGeneratorUsage++;
        break;
    }
  }

  Future<void> _processSyncEvent(AnalyticsEvent event) async {
    switch (event.eventName) {
      case SynchronizationEvents.syncStarted:
      case SynchronizationEvents.syncCompleted:
        _syncOperations++;
        break;
    }
  }

  Future<void> _processDataTransferEvent(AnalyticsEvent event) async {
    switch (event.eventName) {
      case DataTransferEvents.exportCompleted:
        _dataExports++;
        break;
      case DataTransferEvents.importCompleted:
        _dataImports++;
        break;
    }
  }

  Future<void> _processLifecycleEvent(AnalyticsEvent event) async {
    switch (event.eventName) {
      case LifecycleEvents.appLaunched:
        // Обрабатываем запуск приложения
        break;
    }
  }

  void _updateFeatureUsage(String eventName) {
    _featureUsage[eventName] = (_featureUsage[eventName] ?? 0) + 1;
  }

  List<Map<String, dynamic>> _getMostUsedFeatures(int count) {
    final sortedFeatures = _featureUsage.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedFeatures
        .take(count)
        .map((entry) => {'feature': entry.key, 'usage_count': entry.value})
        .toList();
  }

  String _calculateEngagementLevel() {
    // Простой алгоритм определения уровня вовлеченности
    int score = 0;

    if (_averageSessionDuration > 5) {
      score += 2;
    } else if (_averageSessionDuration > 2)
      score += 1;

    if (_totalSessions > 20) {
      score += 2;
    } else if (_totalSessions > 5)
      score += 1;

    if (_featureUsage.length > 10) {
      score += 2;
    } else if (_featureUsage.length > 5)
      score += 1;

    if (_passwordsCreated > 10) score += 1;
    if (_syncOperations > 0) score += 1;
    if (_dataExports > 0) score += 1;

    if (score >= 7) return 'high';
    if (score >= 4) return 'medium';
    return 'low';
  }

  String _getUserSegment() {
    // Сегментация пользователей на основе поведения
    if (_passwordsCreated > 50 && _syncOperations > 10) {
      return 'power_user';
    } else if (_passwordsCreated > 20 && _averageSessionDuration > 3) {
      return 'regular_user';
    } else if (_totalSessions > 10 && _featureUsage.length > 5) {
      return 'exploring_user';
    } else if (_totalSessions < 5) {
      return 'new_user';
    } else {
      return 'casual_user';
    }
  }
}
