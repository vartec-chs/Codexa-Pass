/// Типы событий аналитики для менеджера паролей
enum EventType {
  /// События аутентификации
  authentication,

  /// События управления паролями
  passwordManagement,

  /// События безопасности
  security,

  /// События пользовательского интерфейса
  userInterface,

  /// События синхронизации
  synchronization,

  /// События производительности
  performance,

  /// События ошибок
  error,

  /// События жизненного цикла приложения
  lifecycle,

  /// События настроек
  settings,

  /// События экспорта/импорта
  dataTransfer,
}

/// Названия событий для аутентификации
class AuthenticationEvents {
  static const String loginAttempt = 'login_attempt';
  static const String loginSuccess = 'login_success';
  static const String loginFailure = 'login_failure';
  static const String biometricAuthEnabled = 'biometric_auth_enabled';
  static const String biometricAuthDisabled = 'biometric_auth_disabled';
  static const String biometricAuthAttempt = 'biometric_auth_attempt';
  static const String biometricAuthSuccess = 'biometric_auth_success';
  static const String biometricAuthFailure = 'biometric_auth_failure';
  static const String masterPasswordChanged = 'master_password_changed';
  static const String accountLocked = 'account_locked';
  static const String accountUnlocked = 'account_unlocked';
  static const String sessionExpired = 'session_expired';
  static const String logoutManual = 'logout_manual';
  static const String logoutAutomatic = 'logout_automatic';
}

/// Названия событий для управления паролями
class PasswordManagementEvents {
  static const String passwordCreated = 'password_created';
  static const String passwordViewed = 'password_viewed';
  static const String passwordCopied = 'password_copied';
  static const String passwordEdited = 'password_edited';
  static const String passwordDeleted = 'password_deleted';
  static const String passwordGenerated = 'password_generated';
  static const String passwordStrengthChecked = 'password_strength_checked';
  static const String passwordSearched = 'password_searched';
  static const String passwordFiltered = 'password_filtered';
  static const String passwordSorted = 'password_sorted';
  static const String passwordCategorized = 'password_categorized';
  static const String passwordTagged = 'password_tagged';
  static const String passwordFavorited = 'password_favorited';
  static const String passwordUnfavorited = 'password_unfavorited';
  static const String bulkPasswordOperation = 'bulk_password_operation';
}

/// Названия событий для безопасности
class SecurityEvents {
  static const String weakPasswordDetected = 'weak_password_detected';
  static const String duplicatePasswordDetected = 'duplicate_password_detected';
  static const String oldPasswordDetected = 'old_password_detected';
  static const String compromisedPasswordDetected =
      'compromised_password_detected';
  static const String securityReportGenerated = 'security_report_generated';
  static const String twoFactorEnabled = 'two_factor_enabled';
  static const String twoFactorDisabled = 'two_factor_disabled';
  static const String securityBreachDetected = 'security_breach_detected';
  static const String suspiciousActivityDetected =
      'suspicious_activity_detected';
  static const String encryptionUpgraded = 'encryption_upgraded';
  static const String backupCreated = 'backup_created';
  static const String backupRestored = 'backup_restored';
}

/// Названия событий пользовательского интерфейса
class UserInterfaceEvents {
  static const String screenViewed = 'screen_viewed';
  static const String buttonClicked = 'button_clicked';
  static const String menuOpened = 'menu_opened';
  static const String menuClosed = 'menu_closed';
  static const String searchPerformed = 'search_performed';
  static const String filterApplied = 'filter_applied';
  static const String sortApplied = 'sort_applied';
  static const String themeChanged = 'theme_changed';
  static const String languageChanged = 'language_changed';
  static const String onboardingStarted = 'onboarding_started';
  static const String onboardingCompleted = 'onboarding_completed';
  static const String onboardingSkipped = 'onboarding_skipped';
  static const String tutorialStarted = 'tutorial_started';
  static const String tutorialCompleted = 'tutorial_completed';
  static const String helpRequested = 'help_requested';
}

/// Названия событий синхронизации
class SynchronizationEvents {
  static const String syncStarted = 'sync_started';
  static const String syncCompleted = 'sync_completed';
  static const String syncFailed = 'sync_failed';
  static const String syncConflictResolved = 'sync_conflict_resolved';
  static const String offlineModeEnabled = 'offline_mode_enabled';
  static const String offlineModeDisabled = 'offline_mode_disabled';
  static const String cloudBackupEnabled = 'cloud_backup_enabled';
  static const String cloudBackupDisabled = 'cloud_backup_disabled';
  static const String deviceConnected = 'device_connected';
  static const String deviceDisconnected = 'device_disconnected';
}

/// Названия событий производительности
class PerformanceEvents {
  static const String appStartup = 'app_startup';
  static const String screenLoadTime = 'screen_load_time';
  static const String databaseQuery = 'database_query';
  static const String encryptionTime = 'encryption_time';
  static const String decryptionTime = 'decryption_time';
  static const String searchTime = 'search_time';
  static const String memoryUsage = 'memory_usage';
  static const String cpuUsage = 'cpu_usage';
  static const String networkRequest = 'network_request';
  static const String cacheHit = 'cache_hit';
  static const String cacheMiss = 'cache_miss';
}

/// Названия событий ошибок
class ErrorEvents {
  static const String unexpectedError = 'unexpected_error';
  static const String networkError = 'network_error';
  static const String databaseError = 'database_error';
  static const String encryptionError = 'encryption_error';
  static const String authenticationError = 'authentication_error';
  static const String validationError = 'validation_error';
  static const String syncError = 'sync_error';
  static const String backupError = 'backup_error';
  static const String restoreError = 'restore_error';
  static const String importError = 'import_error';
  static const String exportError = 'export_error';
}

/// Названия событий жизненного цикла приложения
class LifecycleEvents {
  static const String appInstalled = 'app_installed';
  static const String appLaunched = 'app_launched';
  static const String appResumed = 'app_resumed';
  static const String appPaused = 'app_paused';
  static const String appTerminated = 'app_terminated';
  static const String appUpdated = 'app_updated';
  static const String appUninstalled = 'app_uninstalled';
  static const String appCrashed = 'app_crashed';
  static const String appRecovered = 'app_recovered';
  static const String firstRun = 'first_run';
}

/// Названия событий настроек
class SettingsEvents {
  static const String settingChanged = 'setting_changed';
  static const String autoLockEnabled = 'auto_lock_enabled';
  static const String autoLockDisabled = 'auto_lock_disabled';
  static const String autoLockTimeChanged = 'auto_lock_time_changed';
  static const String securityLevelChanged = 'security_level_changed';
  static const String notificationEnabled = 'notification_enabled';
  static const String notificationDisabled = 'notification_disabled';
  static const String privacySettingChanged = 'privacy_setting_changed';
  static const String dataRetentionChanged = 'data_retention_changed';
}

/// Названия событий экспорта/импорта
class DataTransferEvents {
  static const String exportStarted = 'export_started';
  static const String exportCompleted = 'export_completed';
  static const String exportFailed = 'export_failed';
  static const String importStarted = 'import_started';
  static const String importCompleted = 'import_completed';
  static const String importFailed = 'import_failed';
  static const String dataFormatSelected = 'data_format_selected';
  static const String migrationStarted = 'migration_started';
  static const String migrationCompleted = 'migration_completed';
  static const String migrationFailed = 'migration_failed';
}
