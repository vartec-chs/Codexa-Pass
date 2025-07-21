/// Базовая модель для событий аналитики
class AnalyticsEvent {
  /// Уникальный идентификатор события
  final String id;

  /// Тип события
  final String eventType;

  /// Название события
  final String eventName;

  /// Временная метка события
  final DateTime timestamp;

  /// Идентификатор сессии
  final String sessionId;

  /// Идентификатор пользователя (анонимный)
  final String userId;

  /// Параметры события
  final Map<String, dynamic> parameters;

  /// Контекстные данные
  final Map<String, dynamic> context;

  /// Метаданные события
  final EventMetadata metadata;

  const AnalyticsEvent({
    required this.id,
    required this.eventType,
    required this.eventName,
    required this.timestamp,
    required this.sessionId,
    required this.userId,
    required this.parameters,
    required this.context,
    required this.metadata,
  });

  factory AnalyticsEvent.fromJson(Map<String, dynamic> json) {
    return AnalyticsEvent(
      id: json['id'] as String,
      eventType: json['eventType'] as String,
      eventName: json['eventName'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      sessionId: json['sessionId'] as String,
      userId: json['userId'] as String,
      parameters: Map<String, dynamic>.from(json['parameters'] as Map),
      context: Map<String, dynamic>.from(json['context'] as Map),
      metadata: EventMetadata.fromJson(
        json['metadata'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventType': eventType,
      'eventName': eventName,
      'timestamp': timestamp.toIso8601String(),
      'sessionId': sessionId,
      'userId': userId,
      'parameters': parameters,
      'context': context,
      'metadata': metadata.toJson(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AnalyticsEvent &&
        other.id == id &&
        other.eventType == eventType &&
        other.eventName == eventName &&
        other.timestamp == timestamp &&
        other.sessionId == sessionId &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        eventType.hashCode ^
        eventName.hashCode ^
        timestamp.hashCode ^
        sessionId.hashCode ^
        userId.hashCode;
  }
}

/// Метаданные события
class EventMetadata {
  /// Версия приложения
  final String appVersion;

  /// Платформа (iOS, Android, Windows, etc.)
  final String platform;

  /// Версия операционной системы
  final String osVersion;

  /// Модель устройства
  final String deviceModel;

  /// Локаль пользователя
  final String locale;

  /// Часовой пояс
  final String timezone;

  /// Размер экрана
  final ScreenSize screenSize;

  /// Тип подключения к интернету
  final String? connectionType;

  /// Является ли устройство рутованным/взломанным
  final bool? isDeviceJailbroken;

  /// Режим отладки
  final bool isDebugMode;

  const EventMetadata({
    required this.appVersion,
    required this.platform,
    required this.osVersion,
    required this.deviceModel,
    required this.locale,
    required this.timezone,
    required this.screenSize,
    this.connectionType,
    this.isDeviceJailbroken,
    required this.isDebugMode,
  });

  factory EventMetadata.fromJson(Map<String, dynamic> json) {
    return EventMetadata(
      appVersion: json['appVersion'] as String,
      platform: json['platform'] as String,
      osVersion: json['osVersion'] as String,
      deviceModel: json['deviceModel'] as String,
      locale: json['locale'] as String,
      timezone: json['timezone'] as String,
      screenSize: ScreenSize.fromJson(
        json['screenSize'] as Map<String, dynamic>,
      ),
      connectionType: json['connectionType'] as String?,
      isDeviceJailbroken: json['isDeviceJailbroken'] as bool?,
      isDebugMode: json['isDebugMode'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appVersion': appVersion,
      'platform': platform,
      'osVersion': osVersion,
      'deviceModel': deviceModel,
      'locale': locale,
      'timezone': timezone,
      'screenSize': screenSize.toJson(),
      'connectionType': connectionType,
      'isDeviceJailbroken': isDeviceJailbroken,
      'isDebugMode': isDebugMode,
    };
  }
}

/// Размер экрана
class ScreenSize {
  final double width;
  final double height;
  final double pixelRatio;

  const ScreenSize({
    required this.width,
    required this.height,
    required this.pixelRatio,
  });

  factory ScreenSize.fromJson(Map<String, dynamic> json) {
    return ScreenSize(
      width: json['width'] as double,
      height: json['height'] as double,
      pixelRatio: json['pixelRatio'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {'width': width, 'height': height, 'pixelRatio': pixelRatio};
  }
}
