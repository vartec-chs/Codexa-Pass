/// Модель для хранения сессии пользователя
class UserSession {
  /// Уникальный идентификатор сессии
  final String sessionId;

  /// Время начала сессии
  final DateTime startTime;

  /// Время окончания сессии (может быть null для активной сессии)
  final DateTime? endTime;

  /// Продолжительность сессии в миллисекундах
  final int? duration;

  /// Идентификатор пользователя (анонимный)
  final String userId;

  /// События, происходившие в сессии
  final List<String> eventIds;

  /// Количество просмотренных экранов
  final int screenViews;

  /// Последний активный экран
  final String? lastActiveScreen;

  /// Является ли сессия активной
  final bool isActive;

  /// Причина окончания сессии
  final SessionEndReason? endReason;

  const UserSession({
    required this.sessionId,
    required this.startTime,
    this.endTime,
    this.duration,
    required this.userId,
    required this.eventIds,
    required this.screenViews,
    this.lastActiveScreen,
    required this.isActive,
    this.endReason,
  });

  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      sessionId: json['sessionId'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      duration: json['duration'] as int?,
      userId: json['userId'] as String,
      eventIds: List<String>.from(json['eventIds'] as List),
      screenViews: json['screenViews'] as int,
      lastActiveScreen: json['lastActiveScreen'] as String?,
      isActive: json['isActive'] as bool,
      endReason: json['endReason'] != null
          ? SessionEndReason.values.firstWhere(
              (e) => e.name == json['endReason'],
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'duration': duration,
      'userId': userId,
      'eventIds': eventIds,
      'screenViews': screenViews,
      'lastActiveScreen': lastActiveScreen,
      'isActive': isActive,
      'endReason': endReason?.name,
    };
  }

  /// Создать копию сессии с обновленными данными
  UserSession copyWith({
    String? sessionId,
    DateTime? startTime,
    DateTime? endTime,
    int? duration,
    String? userId,
    List<String>? eventIds,
    int? screenViews,
    String? lastActiveScreen,
    bool? isActive,
    SessionEndReason? endReason,
  }) {
    return UserSession(
      sessionId: sessionId ?? this.sessionId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      userId: userId ?? this.userId,
      eventIds: eventIds ?? this.eventIds,
      screenViews: screenViews ?? this.screenViews,
      lastActiveScreen: lastActiveScreen ?? this.lastActiveScreen,
      isActive: isActive ?? this.isActive,
      endReason: endReason ?? this.endReason,
    );
  }
}

/// Причины окончания сессии
enum SessionEndReason {
  /// Пользователь вышел вручную
  manualLogout,

  /// Автоматический выход по таймауту
  timeout,

  /// Приложение было закрыто
  appTerminated,

  /// Приложение было свернуто
  appPaused,

  /// Сессия истекла
  sessionExpired,

  /// Принудительный выход из-за безопасности
  securityLogout,

  /// Ошибка системы
  systemError,

  /// Обновление приложения
  appUpdate,
}

/// Модель для хранения данных о пользователе
class UserProfile {
  /// Уникальный анонимный идентификатор пользователя
  final String userId;

  /// Дата регистрации/первого запуска
  final DateTime firstSeenAt;

  /// Дата последней активности
  final DateTime lastSeenAt;

  /// Общее количество сессий
  final int totalSessions;

  /// Общее время в приложении в минутах
  final int totalTimeSpent;

  /// Средняя продолжительность сессии в минутах
  final double averageSessionDuration;

  /// Версия приложения при первом запуске
  final String firstAppVersion;

  /// Текущая версия приложения
  final String currentAppVersion;

  /// Платформа пользователя
  final String platform;

  /// Предпочитаемый язык
  final String preferredLanguage;

  /// Часовой пояс
  final String timezone;

  /// Настройки пользователя
  final Map<String, dynamic> settings;

  /// Уровень активности (low, medium, high)
  final String activityLevel;

  /// Последние использованные функции
  final List<String> recentFeatures;

  const UserProfile({
    required this.userId,
    required this.firstSeenAt,
    required this.lastSeenAt,
    required this.totalSessions,
    required this.totalTimeSpent,
    required this.averageSessionDuration,
    required this.firstAppVersion,
    required this.currentAppVersion,
    required this.platform,
    required this.preferredLanguage,
    required this.timezone,
    required this.settings,
    required this.activityLevel,
    required this.recentFeatures,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'] as String,
      firstSeenAt: DateTime.parse(json['firstSeenAt'] as String),
      lastSeenAt: DateTime.parse(json['lastSeenAt'] as String),
      totalSessions: json['totalSessions'] as int,
      totalTimeSpent: json['totalTimeSpent'] as int,
      averageSessionDuration: (json['averageSessionDuration'] as num)
          .toDouble(),
      firstAppVersion: json['firstAppVersion'] as String,
      currentAppVersion: json['currentAppVersion'] as String,
      platform: json['platform'] as String,
      preferredLanguage: json['preferredLanguage'] as String,
      timezone: json['timezone'] as String,
      settings: Map<String, dynamic>.from(json['settings'] as Map),
      activityLevel: json['activityLevel'] as String,
      recentFeatures: List<String>.from(json['recentFeatures'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'firstSeenAt': firstSeenAt.toIso8601String(),
      'lastSeenAt': lastSeenAt.toIso8601String(),
      'totalSessions': totalSessions,
      'totalTimeSpent': totalTimeSpent,
      'averageSessionDuration': averageSessionDuration,
      'firstAppVersion': firstAppVersion,
      'currentAppVersion': currentAppVersion,
      'platform': platform,
      'preferredLanguage': preferredLanguage,
      'timezone': timezone,
      'settings': settings,
      'activityLevel': activityLevel,
      'recentFeatures': recentFeatures,
    };
  }

  /// Создать копию профиля с обновленными данными
  UserProfile copyWith({
    String? userId,
    DateTime? firstSeenAt,
    DateTime? lastSeenAt,
    int? totalSessions,
    int? totalTimeSpent,
    double? averageSessionDuration,
    String? firstAppVersion,
    String? currentAppVersion,
    String? platform,
    String? preferredLanguage,
    String? timezone,
    Map<String, dynamic>? settings,
    String? activityLevel,
    List<String>? recentFeatures,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      firstSeenAt: firstSeenAt ?? this.firstSeenAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      totalSessions: totalSessions ?? this.totalSessions,
      totalTimeSpent: totalTimeSpent ?? this.totalTimeSpent,
      averageSessionDuration:
          averageSessionDuration ?? this.averageSessionDuration,
      firstAppVersion: firstAppVersion ?? this.firstAppVersion,
      currentAppVersion: currentAppVersion ?? this.currentAppVersion,
      platform: platform ?? this.platform,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      timezone: timezone ?? this.timezone,
      settings: settings ?? this.settings,
      activityLevel: activityLevel ?? this.activityLevel,
      recentFeatures: recentFeatures ?? this.recentFeatures,
    );
  }
}
