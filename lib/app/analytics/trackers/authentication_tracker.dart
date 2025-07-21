import '../services/analytics_service.dart';
import '../models/analytics_events.dart';

/// Трекер для отслеживания аутентификации
class AuthenticationTracker {
  final AnalyticsService _analyticsService;

  AuthenticationTracker(this._analyticsService);

  /// Отслеживание попытки входа
  Future<void> trackLoginAttempt({
    String? authMethod,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackEvent(
      eventType: EventType.authentication.name,
      eventName: AuthenticationEvents.loginAttempt,
      parameters: {
        'auth_method': authMethod ?? 'master_password',
        'timestamp': DateTime.now().toIso8601String(),
      },
      context: context,
    );
  }

  /// Отслеживание успешного входа
  Future<void> trackLoginSuccess({
    required String authMethod,
    int? attemptCount,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackEvent(
      eventType: EventType.authentication.name,
      eventName: AuthenticationEvents.loginSuccess,
      parameters: {
        'auth_method': authMethod,
        'attempt_count': attemptCount ?? 1,
        'timestamp': DateTime.now().toIso8601String(),
      },
      context: context,
    );
  }

  /// Отслеживание неудачного входа
  Future<void> trackLoginFailure({
    required String authMethod,
    required String reason,
    int? attemptCount,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackEvent(
      eventType: EventType.authentication.name,
      eventName: AuthenticationEvents.loginFailure,
      parameters: {
        'auth_method': authMethod,
        'failure_reason': reason,
        'attempt_count': attemptCount ?? 1,
        'timestamp': DateTime.now().toIso8601String(),
      },
      context: context,
    );
  }

  /// Отслеживание включения биометрической аутентификации
  Future<void> trackBiometricAuthEnabled({
    required String biometricType,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackEvent(
      eventType: EventType.authentication.name,
      eventName: AuthenticationEvents.biometricAuthEnabled,
      parameters: {
        'biometric_type': biometricType,
        'timestamp': DateTime.now().toIso8601String(),
      },
      context: context,
    );
  }

  /// Отслеживание отключения биометрической аутентификации
  Future<void> trackBiometricAuthDisabled({
    required String biometricType,
    required String reason,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackEvent(
      eventType: EventType.authentication.name,
      eventName: AuthenticationEvents.biometricAuthDisabled,
      parameters: {
        'biometric_type': biometricType,
        'disable_reason': reason,
        'timestamp': DateTime.now().toIso8601String(),
      },
      context: context,
    );
  }

  /// Отслеживание попытки биометрической аутентификации
  Future<void> trackBiometricAuthAttempt({
    required String biometricType,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackEvent(
      eventType: EventType.authentication.name,
      eventName: AuthenticationEvents.biometricAuthAttempt,
      parameters: {
        'biometric_type': biometricType,
        'timestamp': DateTime.now().toIso8601String(),
      },
      context: context,
    );
  }

  /// Отслеживание успешной биометрической аутентификации
  Future<void> trackBiometricAuthSuccess({
    required String biometricType,
    int? attemptCount,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackEvent(
      eventType: EventType.authentication.name,
      eventName: AuthenticationEvents.biometricAuthSuccess,
      parameters: {
        'biometric_type': biometricType,
        'attempt_count': attemptCount ?? 1,
        'timestamp': DateTime.now().toIso8601String(),
      },
      context: context,
    );
  }

  /// Отслеживание неудачной биометрической аутентификации
  Future<void> trackBiometricAuthFailure({
    required String biometricType,
    required String reason,
    int? attemptCount,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackEvent(
      eventType: EventType.authentication.name,
      eventName: AuthenticationEvents.biometricAuthFailure,
      parameters: {
        'biometric_type': biometricType,
        'failure_reason': reason,
        'attempt_count': attemptCount ?? 1,
        'timestamp': DateTime.now().toIso8601String(),
      },
      context: context,
    );
  }

  /// Отслеживание смены мастер-пароля
  Future<void> trackMasterPasswordChanged({
    String? reason,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackEvent(
      eventType: EventType.authentication.name,
      eventName: AuthenticationEvents.masterPasswordChanged,
      parameters: {
        'change_reason': reason ?? 'user_initiated',
        'timestamp': DateTime.now().toIso8601String(),
      },
      context: context,
    );
  }

  /// Отслеживание блокировки аккаунта
  Future<void> trackAccountLocked({
    required String reason,
    int? failedAttempts,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackEvent(
      eventType: EventType.authentication.name,
      eventName: AuthenticationEvents.accountLocked,
      parameters: {
        'lock_reason': reason,
        'failed_attempts': failedAttempts,
        'timestamp': DateTime.now().toIso8601String(),
      },
      context: context,
    );
  }

  /// Отслеживание разблокировки аккаунта
  Future<void> trackAccountUnlocked({
    required String method,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackEvent(
      eventType: EventType.authentication.name,
      eventName: AuthenticationEvents.accountUnlocked,
      parameters: {
        'unlock_method': method,
        'timestamp': DateTime.now().toIso8601String(),
      },
      context: context,
    );
  }

  /// Отслеживание истечения сессии
  Future<void> trackSessionExpired({
    int? sessionDuration,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackEvent(
      eventType: EventType.authentication.name,
      eventName: AuthenticationEvents.sessionExpired,
      parameters: {
        'session_duration_minutes': sessionDuration,
        'timestamp': DateTime.now().toIso8601String(),
      },
      context: context,
    );
  }

  /// Отслеживание выхода из системы
  Future<void> trackLogout({
    required bool isManual,
    String? reason,
    int? sessionDuration,
    Map<String, dynamic>? context,
  }) async {
    await _analyticsService.trackEvent(
      eventType: EventType.authentication.name,
      eventName: isManual
          ? AuthenticationEvents.logoutManual
          : AuthenticationEvents.logoutAutomatic,
      parameters: {
        'logout_reason': reason ?? (isManual ? 'user_action' : 'system'),
        'session_duration_minutes': sessionDuration,
        'timestamp': DateTime.now().toIso8601String(),
      },
      context: context,
    );
  }
}
