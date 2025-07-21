import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/analytics_event.dart';
import '../models/analytics_metrics.dart';
import '../models/analytics_events.dart';
import '../storage/analytics_storage.dart';

/// Коллектор метрик безопасности
class SecurityCollector {
  final AnalyticsStorage storage;
  final bool enabled;
  bool _isInitialized = false;

  // Счетчики для отслеживания безопасности
  int _weakPasswordCount = 0;
  int _duplicatePasswordCount = 0;
  int _oldPasswordCount = 0;
  int _compromisedPasswordCount = 0;
  int _loginAttempts = 0;
  int _failedLoginAttempts = 0;
  int _lockedAccounts = 0;
  int _twoFactorEnabledCount = 0;
  int _securityBreaches = 0;
  int _suspiciousActivities = 0;

  SecurityCollector({required this.storage, this.enabled = true});

  /// Инициализация коллектора
  Future<void> initialize() async {
    if (_isInitialized || !enabled) return;

    if (kDebugMode) {
      print('SecurityCollector initialized');
    }

    _isInitialized = true;
    await _loadExistingMetrics();
  }

  /// Отслеживание события безопасности
  Future<void> trackSecurityEvent({
    required String eventType,
    required String sessionId,
    required String userId,
    Map<String, dynamic>? details,
  }) async {
    if (!_isInitialized || !enabled) return;

    try {
      final event = AnalyticsEvent(
        id: _generateSecurityEventId(),
        eventType: EventType.security.name,
        eventName: eventType,
        timestamp: DateTime.now(),
        sessionId: sessionId,
        userId: userId,
        parameters: {'security_event_type': eventType, ...?details},
        context: {
          'security_category': _getSecurityCategory(eventType),
          'risk_level': _getRiskLevel(eventType),
        },
        metadata: await _getDefaultMetadata(),
      );

      await storage.saveEvent(event);
      await _updateSecurityCounters(eventType, details);

      if (kDebugMode) {
        print('Security event tracked: $eventType');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error tracking security event: $e');
      }
    }
  }

  /// Анализ события на предмет безопасности
  Future<void> analyzeSecurityEvent(AnalyticsEvent event) async {
    if (!_isInitialized || !enabled) return;

    try {
      // Анализируем различные типы событий на предмет угроз безопасности
      switch (event.eventType) {
        case 'authentication':
          await _analyzeAuthenticationEvent(event);
          break;
        case 'passwordManagement':
          await _analyzePasswordEvent(event);
          break;
        case 'error':
          await _analyzeErrorEvent(event);
          break;
        case 'userInterface':
          await _analyzeUIEvent(event);
          break;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error analyzing security event: $e');
      }
    }
  }

  /// Получение метрик безопасности
  Future<SecurityMetrics?> getMetrics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (!_isInitialized || !enabled) return null;

    try {
      // Обновляем счетчики из событий
      await _calculateMetricsFromEvents(startDate, endDate);

      // Вычисляем общий балл безопасности
      final securityScore = _calculateSecurityScore();

      return SecurityMetrics(
        weakPasswordCount: _weakPasswordCount,
        duplicatePasswordCount: _duplicatePasswordCount,
        oldPasswordCount: _oldPasswordCount,
        compromisedPasswordCount: _compromisedPasswordCount,
        securityScore: securityScore,
        loginAttempts: _loginAttempts,
        failedLoginAttempts: _failedLoginAttempts,
        lockedAccounts: _lockedAccounts,
        twoFactorEnabledCount: _twoFactorEnabledCount,
        securityBreaches: _securityBreaches,
        suspiciousActivities: _suspiciousActivities,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error getting security metrics: $e');
      }
      return null;
    }
  }

  /// Обнаружение подозрительной активности
  Future<void> detectSuspiciousActivity({
    required String userId,
    required String sessionId,
    required String activityType,
    Map<String, dynamic>? context,
  }) async {
    if (!_isInitialized || !enabled) return;

    _suspiciousActivities++;

    await trackSecurityEvent(
      eventType: SecurityEvents.suspiciousActivityDetected,
      sessionId: sessionId,
      userId: userId,
      details: {
        'activity_type': activityType,
        'detection_time': DateTime.now().toIso8601String(),
        'risk_level': 'medium',
        ...?context,
      },
    );
  }

  /// Отслеживание нарушения безопасности
  Future<void> reportSecurityBreach({
    required String userId,
    required String sessionId,
    required String breachType,
    required String severity,
    Map<String, dynamic>? details,
  }) async {
    if (!_isInitialized || !enabled) return;

    _securityBreaches++;

    await trackSecurityEvent(
      eventType: SecurityEvents.securityBreachDetected,
      sessionId: sessionId,
      userId: userId,
      details: {
        'breach_type': breachType,
        'severity': severity,
        'detection_time': DateTime.now().toIso8601String(),
        'requires_action': severity == 'critical' || severity == 'high',
        ...?details,
      },
    );
  }

  /// Получение отчета по безопасности
  Future<Map<String, dynamic>> getSecurityReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (!_isInitialized || !enabled) return {};

    try {
      final events = await storage.getEvents(
        startDate: startDate,
        endDate: endDate,
        eventType: EventType.security.name,
      );

      final securityEvents = <String, int>{};
      final riskLevels = <String, int>{};
      final timelineEvents = <Map<String, dynamic>>[];

      for (final event in events) {
        final eventName = event.eventName;
        final riskLevel = event.context['risk_level'] as String? ?? 'low';

        securityEvents[eventName] = (securityEvents[eventName] ?? 0) + 1;
        riskLevels[riskLevel] = (riskLevels[riskLevel] ?? 0) + 1;

        timelineEvents.add({
          'event_name': eventName,
          'timestamp': event.timestamp.toIso8601String(),
          'risk_level': riskLevel,
          'details': event.parameters,
        });
      }

      // Сортируем события по времени
      timelineEvents.sort(
        (a, b) => DateTime.parse(
          b['timestamp'],
        ).compareTo(DateTime.parse(a['timestamp'])),
      );

      final metrics = await getMetrics(startDate: startDate, endDate: endDate);

      return {
        'summary': {
          'total_security_events': events.length,
          'security_score': metrics?.securityScore ?? 0,
          'high_risk_events': riskLevels['high'] ?? 0,
          'critical_events': riskLevels['critical'] ?? 0,
        },
        'security_events': securityEvents,
        'risk_distribution': riskLevels,
        'timeline': timelineEvents.take(50).toList(), // Последние 50 событий
        'metrics': metrics?.toJson(),
        'generated_at': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error generating security report: $e');
      }
      return {};
    }
  }

  // Приватные методы
  Future<void> _loadExistingMetrics() async {
    // Загружаем существующие метрики из хранилища
    final existingMetrics = await storage.getMetrics('security');
    if (existingMetrics != null) {
      _weakPasswordCount = existingMetrics['weak_password_count'] as int? ?? 0;
      _duplicatePasswordCount =
          existingMetrics['duplicate_password_count'] as int? ?? 0;
      _oldPasswordCount = existingMetrics['old_password_count'] as int? ?? 0;
      _compromisedPasswordCount =
          existingMetrics['compromised_password_count'] as int? ?? 0;
      _loginAttempts = existingMetrics['login_attempts'] as int? ?? 0;
      _failedLoginAttempts =
          existingMetrics['failed_login_attempts'] as int? ?? 0;
      _lockedAccounts = existingMetrics['locked_accounts'] as int? ?? 0;
      _twoFactorEnabledCount =
          existingMetrics['two_factor_enabled_count'] as int? ?? 0;
      _securityBreaches = existingMetrics['security_breaches'] as int? ?? 0;
      _suspiciousActivities =
          existingMetrics['suspicious_activities'] as int? ?? 0;
    }
  }

  Future<void> _updateSecurityCounters(
    String eventType,
    Map<String, dynamic>? details,
  ) async {
    switch (eventType) {
      case SecurityEvents.weakPasswordDetected:
        _weakPasswordCount++;
        break;
      case SecurityEvents.duplicatePasswordDetected:
        _duplicatePasswordCount++;
        break;
      case SecurityEvents.oldPasswordDetected:
        _oldPasswordCount++;
        break;
      case SecurityEvents.compromisedPasswordDetected:
        _compromisedPasswordCount++;
        break;
      case SecurityEvents.twoFactorEnabled:
        _twoFactorEnabledCount++;
        break;
      case SecurityEvents.twoFactorDisabled:
        _twoFactorEnabledCount = (_twoFactorEnabledCount - 1)
            .clamp(0, double.infinity)
            .toInt();
        break;
      case AuthenticationEvents.loginAttempt:
        _loginAttempts++;
        break;
      case AuthenticationEvents.loginFailure:
        _failedLoginAttempts++;
        break;
      case AuthenticationEvents.accountLocked:
        _lockedAccounts++;
        break;
      case SecurityEvents.securityBreachDetected:
        _securityBreaches++;
        break;
      case SecurityEvents.suspiciousActivityDetected:
        _suspiciousActivities++;
        break;
    }

    // Сохраняем обновленные метрики
    await _saveMetrics();
  }

  Future<void> _saveMetrics() async {
    await storage.saveMetrics('security', {
      'weak_password_count': _weakPasswordCount,
      'duplicate_password_count': _duplicatePasswordCount,
      'old_password_count': _oldPasswordCount,
      'compromised_password_count': _compromisedPasswordCount,
      'login_attempts': _loginAttempts,
      'failed_login_attempts': _failedLoginAttempts,
      'locked_accounts': _lockedAccounts,
      'two_factor_enabled_count': _twoFactorEnabledCount,
      'security_breaches': _securityBreaches,
      'suspicious_activities': _suspiciousActivities,
    });
  }

  Future<void> _calculateMetricsFromEvents(
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    final events = await storage.getEvents(
      startDate: startDate,
      endDate: endDate,
      eventType: EventType.security.name,
    );

    // Подсчитываем метрики из событий за указанный период
    for (final event in events) {
      await _updateSecurityCounters(event.eventName, event.parameters);
    }
  }

  int _calculateSecurityScore() {
    int score = 100;

    // Снижаем балл за проблемы с паролями
    score -= _weakPasswordCount * 5;
    score -= _duplicatePasswordCount * 3;
    score -= _oldPasswordCount * 2;
    score -= _compromisedPasswordCount * 10;

    // Снижаем балл за неудачные попытки входа
    if (_loginAttempts > 0) {
      final failureRate = _failedLoginAttempts / _loginAttempts;
      score -= (failureRate * 20).round();
    }

    // Снижаем балл за заблокированные аккаунты
    score -= _lockedAccounts * 15;

    // Снижаем балл за нарушения безопасности
    score -= _securityBreaches * 25;
    score -= _suspiciousActivities * 5;

    // Повышаем балл за включенную двухфакторную аутентификацию
    score += _twoFactorEnabledCount * 10;

    return score.clamp(0, 100);
  }

  Future<void> _analyzeAuthenticationEvent(AnalyticsEvent event) async {
    // Анализируем события аутентификации на предмет подозрительной активности
    if (event.eventName == AuthenticationEvents.loginFailure) {
      final failureCount =
          event.parameters['consecutive_failures'] as int? ?? 1;
      if (failureCount >= 3) {
        await detectSuspiciousActivity(
          userId: event.userId,
          sessionId: event.sessionId,
          activityType: 'multiple_login_failures',
          context: {'failure_count': failureCount},
        );
      }
    }
  }

  Future<void> _analyzePasswordEvent(AnalyticsEvent event) async {
    // Анализируем события с паролями
    if (event.eventName == PasswordManagementEvents.passwordCreated) {
      final strength = event.parameters['password_strength'] as String?;
      if (strength == 'weak') {
        await trackSecurityEvent(
          eventType: SecurityEvents.weakPasswordDetected,
          sessionId: event.sessionId,
          userId: event.userId,
          details: {'detected_at': DateTime.now().toIso8601String()},
        );
      }
    }
  }

  Future<void> _analyzeErrorEvent(AnalyticsEvent event) async {
    // Анализируем ошибки на предмет угроз безопасности
    final errorType = event.parameters['error_type'] as String? ?? '';
    if (errorType.contains('security') || errorType.contains('auth')) {
      await detectSuspiciousActivity(
        userId: event.userId,
        sessionId: event.sessionId,
        activityType: 'security_error',
        context: {'error_type': errorType},
      );
    }
  }

  Future<void> _analyzeUIEvent(AnalyticsEvent event) async {
    // Анализируем события UI на предмет подозрительной активности
    if (event.eventName == UserInterfaceEvents.screenViewed) {
      final screenName = event.parameters['screen_name'] as String? ?? '';
      if (screenName.contains('admin') || screenName.contains('debug')) {
        await detectSuspiciousActivity(
          userId: event.userId,
          sessionId: event.sessionId,
          activityType: 'sensitive_screen_access',
          context: {'screen_name': screenName},
        );
      }
    }
  }

  String _getSecurityCategory(String eventType) {
    if (eventType.contains('password')) return 'password_security';
    if (eventType.contains('auth') || eventType.contains('login'))
      return 'authentication';
    if (eventType.contains('breach') || eventType.contains('suspicious'))
      return 'threat_detection';
    if (eventType.contains('two_factor') || eventType.contains('2fa'))
      return 'multi_factor_auth';
    return 'general';
  }

  String _getRiskLevel(String eventType) {
    switch (eventType) {
      case SecurityEvents.securityBreachDetected:
      case SecurityEvents.compromisedPasswordDetected:
        return 'critical';
      case SecurityEvents.suspiciousActivityDetected:
      case SecurityEvents.weakPasswordDetected:
      case AuthenticationEvents.accountLocked:
        return 'high';
      case SecurityEvents.duplicatePasswordDetected:
      case SecurityEvents.oldPasswordDetected:
        return 'medium';
      default:
        return 'low';
    }
  }

  String _generateSecurityEventId() {
    return '${DateTime.now().millisecondsSinceEpoch}_security';
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
