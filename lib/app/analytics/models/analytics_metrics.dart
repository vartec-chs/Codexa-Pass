/// Модель для хранения метрик производительности
class PerformanceMetrics {
  /// Время запуска приложения в миллисекундах
  final int appStartupTime;

  /// Время загрузки экрана в миллисекундах
  final int screenLoadTime;

  /// Время выполнения запроса к базе данных в миллисекундах
  final int databaseQueryTime;

  /// Время шифрования в миллисекундах
  final int encryptionTime;

  /// Время дешифрования в миллисекундах
  final int decryptionTime;

  /// Время поиска в миллисекундах
  final int searchTime;

  /// Использование памяти в байтах
  final int memoryUsage;

  /// Использование CPU в процентах
  final double cpuUsage;

  /// Время сетевого запроса в миллисекундах
  final int networkRequestTime;

  /// Количество попаданий в кэш
  final int cacheHits;

  /// Количество промахов кэша
  final int cacheMisses;

  const PerformanceMetrics({
    required this.appStartupTime,
    required this.screenLoadTime,
    required this.databaseQueryTime,
    required this.encryptionTime,
    required this.decryptionTime,
    required this.searchTime,
    required this.memoryUsage,
    required this.cpuUsage,
    required this.networkRequestTime,
    required this.cacheHits,
    required this.cacheMisses,
  });

  factory PerformanceMetrics.fromJson(Map<String, dynamic> json) {
    return PerformanceMetrics(
      appStartupTime: json['appStartupTime'] as int,
      screenLoadTime: json['screenLoadTime'] as int,
      databaseQueryTime: json['databaseQueryTime'] as int,
      encryptionTime: json['encryptionTime'] as int,
      decryptionTime: json['decryptionTime'] as int,
      searchTime: json['searchTime'] as int,
      memoryUsage: json['memoryUsage'] as int,
      cpuUsage: (json['cpuUsage'] as num).toDouble(),
      networkRequestTime: json['networkRequestTime'] as int,
      cacheHits: json['cacheHits'] as int,
      cacheMisses: json['cacheMisses'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appStartupTime': appStartupTime,
      'screenLoadTime': screenLoadTime,
      'databaseQueryTime': databaseQueryTime,
      'encryptionTime': encryptionTime,
      'decryptionTime': decryptionTime,
      'searchTime': searchTime,
      'memoryUsage': memoryUsage,
      'cpuUsage': cpuUsage,
      'networkRequestTime': networkRequestTime,
      'cacheHits': cacheHits,
      'cacheMisses': cacheMisses,
    };
  }
}

/// Модель для хранения метрик безопасности
class SecurityMetrics {
  /// Количество слабых паролей
  final int weakPasswordCount;

  /// Количество дублирующихся паролей
  final int duplicatePasswordCount;

  /// Количество старых паролей (не менялись более X дней)
  final int oldPasswordCount;

  /// Количество скомпрометированных паролей
  final int compromisedPasswordCount;

  /// Общий балл безопасности (0-100)
  final int securityScore;

  /// Количество попыток входа
  final int loginAttempts;

  /// Количество неудачных попыток входа
  final int failedLoginAttempts;

  /// Количество заблокированных аккаунтов
  final int lockedAccounts;

  /// Количество включенных двухфакторных аутентификаций
  final int twoFactorEnabledCount;

  /// Количество обнаруженных нарушений безопасности
  final int securityBreaches;

  /// Количество подозрительных активностей
  final int suspiciousActivities;

  const SecurityMetrics({
    required this.weakPasswordCount,
    required this.duplicatePasswordCount,
    required this.oldPasswordCount,
    required this.compromisedPasswordCount,
    required this.securityScore,
    required this.loginAttempts,
    required this.failedLoginAttempts,
    required this.lockedAccounts,
    required this.twoFactorEnabledCount,
    required this.securityBreaches,
    required this.suspiciousActivities,
  });

  factory SecurityMetrics.fromJson(Map<String, dynamic> json) {
    return SecurityMetrics(
      weakPasswordCount: json['weakPasswordCount'] as int,
      duplicatePasswordCount: json['duplicatePasswordCount'] as int,
      oldPasswordCount: json['oldPasswordCount'] as int,
      compromisedPasswordCount: json['compromisedPasswordCount'] as int,
      securityScore: json['securityScore'] as int,
      loginAttempts: json['loginAttempts'] as int,
      failedLoginAttempts: json['failedLoginAttempts'] as int,
      lockedAccounts: json['lockedAccounts'] as int,
      twoFactorEnabledCount: json['twoFactorEnabledCount'] as int,
      securityBreaches: json['securityBreaches'] as int,
      suspiciousActivities: json['suspiciousActivities'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weakPasswordCount': weakPasswordCount,
      'duplicatePasswordCount': duplicatePasswordCount,
      'oldPasswordCount': oldPasswordCount,
      'compromisedPasswordCount': compromisedPasswordCount,
      'securityScore': securityScore,
      'loginAttempts': loginAttempts,
      'failedLoginAttempts': failedLoginAttempts,
      'lockedAccounts': lockedAccounts,
      'twoFactorEnabledCount': twoFactorEnabledCount,
      'securityBreaches': securityBreaches,
      'suspiciousActivities': suspiciousActivities,
    };
  }
}

/// Модель для хранения пользовательских метрик
class UserBehaviorMetrics {
  /// Общее количество сессий
  final int totalSessions;

  /// Средняя продолжительность сессии в минутах
  final double averageSessionDuration;

  /// Количество просмотренных экранов
  final int screenViews;

  /// Наиболее используемые функции
  final Map<String, int> featureUsage;

  /// Количество созданных паролей
  final int passwordsCreated;

  /// Количество просмотренных паролей
  final int passwordsViewed;

  /// Количество скопированных паролей
  final int passwordsCopied;

  /// Количество поисковых запросов
  final int searchQueries;

  /// Количество использований генератора паролей
  final int passwordGeneratorUsage;

  /// Количество экспортов данных
  final int dataExports;

  /// Количество импортов данных
  final int dataImports;

  /// Количество синхронизаций
  final int syncOperations;

  const UserBehaviorMetrics({
    required this.totalSessions,
    required this.averageSessionDuration,
    required this.screenViews,
    required this.featureUsage,
    required this.passwordsCreated,
    required this.passwordsViewed,
    required this.passwordsCopied,
    required this.searchQueries,
    required this.passwordGeneratorUsage,
    required this.dataExports,
    required this.dataImports,
    required this.syncOperations,
  });

  factory UserBehaviorMetrics.fromJson(Map<String, dynamic> json) {
    return UserBehaviorMetrics(
      totalSessions: json['totalSessions'] as int,
      averageSessionDuration: (json['averageSessionDuration'] as num)
          .toDouble(),
      screenViews: json['screenViews'] as int,
      featureUsage: Map<String, int>.from(json['featureUsage'] as Map),
      passwordsCreated: json['passwordsCreated'] as int,
      passwordsViewed: json['passwordsViewed'] as int,
      passwordsCopied: json['passwordsCopied'] as int,
      searchQueries: json['searchQueries'] as int,
      passwordGeneratorUsage: json['passwordGeneratorUsage'] as int,
      dataExports: json['dataExports'] as int,
      dataImports: json['dataImports'] as int,
      syncOperations: json['syncOperations'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSessions': totalSessions,
      'averageSessionDuration': averageSessionDuration,
      'screenViews': screenViews,
      'featureUsage': featureUsage,
      'passwordsCreated': passwordsCreated,
      'passwordsViewed': passwordsViewed,
      'passwordsCopied': passwordsCopied,
      'searchQueries': searchQueries,
      'passwordGeneratorUsage': passwordGeneratorUsage,
      'dataExports': dataExports,
      'dataImports': dataImports,
      'syncOperations': syncOperations,
    };
  }
}

/// Модель для хранения ошибок
class ErrorMetrics {
  /// Общее количество ошибок
  final int totalErrors;

  /// Количество критических ошибок
  final int criticalErrors;

  /// Количество ошибок по типам
  final Map<String, int> errorsByType;

  /// Количество ошибок по экранам
  final Map<String, int> errorsByScreen;

  /// Количество сетевых ошибок
  final int networkErrors;

  /// Количество ошибок базы данных
  final int databaseErrors;

  /// Количество ошибок шифрования
  final int encryptionErrors;

  /// Количество ошибок аутентификации
  final int authenticationErrors;

  /// Количество ошибок синхронизации
  final int syncErrors;

  /// Время до первой ошибки в минутах
  final double? timeToFirstError;

  /// Количество восстановлений после ошибок
  final int errorRecoveries;

  const ErrorMetrics({
    required this.totalErrors,
    required this.criticalErrors,
    required this.errorsByType,
    required this.errorsByScreen,
    required this.networkErrors,
    required this.databaseErrors,
    required this.encryptionErrors,
    required this.authenticationErrors,
    required this.syncErrors,
    this.timeToFirstError,
    required this.errorRecoveries,
  });

  factory ErrorMetrics.fromJson(Map<String, dynamic> json) {
    return ErrorMetrics(
      totalErrors: json['totalErrors'] as int,
      criticalErrors: json['criticalErrors'] as int,
      errorsByType: Map<String, int>.from(json['errorsByType'] as Map),
      errorsByScreen: Map<String, int>.from(json['errorsByScreen'] as Map),
      networkErrors: json['networkErrors'] as int,
      databaseErrors: json['databaseErrors'] as int,
      encryptionErrors: json['encryptionErrors'] as int,
      authenticationErrors: json['authenticationErrors'] as int,
      syncErrors: json['syncErrors'] as int,
      timeToFirstError: (json['timeToFirstError'] as num?)?.toDouble(),
      errorRecoveries: json['errorRecoveries'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalErrors': totalErrors,
      'criticalErrors': criticalErrors,
      'errorsByType': errorsByType,
      'errorsByScreen': errorsByScreen,
      'networkErrors': networkErrors,
      'databaseErrors': databaseErrors,
      'encryptionErrors': encryptionErrors,
      'authenticationErrors': authenticationErrors,
      'syncErrors': syncErrors,
      'timeToFirstError': timeToFirstError,
      'errorRecoveries': errorRecoveries,
    };
  }
}
