import 'log_level.dart';

/// Запись лога с полными метаданными
class LogEntry {
  final String id;
  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final String sessionId;
  final String logger;
  final String? module;
  final String? context;
  final String? className;
  final int? line;
  final String? function;
  final Map<String, dynamic>? metadata;
  final Object? error;
  final StackTrace? stackTrace;
  final DeviceInfo deviceInfo;
  final AppInfo appInfo;

  const LogEntry({
    required this.id,
    required this.timestamp,
    required this.level,
    required this.message,
    required this.sessionId,
    required this.logger,
    this.module,
    this.context,
    this.className,
    this.line,
    this.function,
    this.metadata,
    this.error,
    this.stackTrace,
    required this.deviceInfo,
    required this.appInfo,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'level': level.name,
    'message': message,
    'sessionId': sessionId,
    'logger': logger,
    if (module != null) 'module': module,
    if (context != null) 'context': context,
    if (className != null) 'className': className,
    if (line != null) 'line': line,
    if (function != null) 'function': function,
    if (metadata != null) 'metadata': metadata,
    if (error != null) 'error': error.toString(),
    if (stackTrace != null) 'stackTrace': stackTrace.toString(),
    'deviceInfo': deviceInfo.toJson(),
    'appInfo': appInfo.toJson(),
  };

  factory LogEntry.fromJson(Map<String, dynamic> json) => LogEntry(
    id: json['id'],
    timestamp: DateTime.parse(json['timestamp']),
    level: LogLevel.fromString(json['level']),
    message: json['message'],
    sessionId: json['sessionId'],
    logger: json['logger'],
    module: json['module'],
    context: json['context'],
    className: json['className'],
    line: json['line'],
    function: json['function'],
    metadata: json['metadata']?.cast<String, dynamic>(),
    error: json['error'],
    deviceInfo: DeviceInfo.fromJson(json['deviceInfo']),
    appInfo: AppInfo.fromJson(json['appInfo']),
  );
}

/// Информация об устройстве
class DeviceInfo {
  final String platform;
  final String version;
  final String model;
  final String? brand;
  final String? manufacturer;
  final bool? isPhysicalDevice;

  const DeviceInfo({
    required this.platform,
    required this.version,
    required this.model,
    this.brand,
    this.manufacturer,
    this.isPhysicalDevice,
  });

  Map<String, dynamic> toJson() => {
    'platform': platform,
    'version': version,
    'model': model,
    if (brand != null) 'brand': brand,
    if (manufacturer != null) 'manufacturer': manufacturer,
    if (isPhysicalDevice != null) 'isPhysicalDevice': isPhysicalDevice,
  };

  factory DeviceInfo.fromJson(Map<String, dynamic> json) => DeviceInfo(
    platform: json['platform'],
    version: json['version'],
    model: json['model'],
    brand: json['brand'],
    manufacturer: json['manufacturer'],
    isPhysicalDevice: json['isPhysicalDevice'],
  );
}

/// Информация о приложении
class AppInfo {
  final String appName;
  final String version;
  final String buildNumber;
  final String packageName;

  const AppInfo({
    required this.appName,
    required this.version,
    required this.buildNumber,
    required this.packageName,
  });

  Map<String, dynamic> toJson() => {
    'appName': appName,
    'version': version,
    'buildNumber': buildNumber,
    'packageName': packageName,
  };

  factory AppInfo.fromJson(Map<String, dynamic> json) => AppInfo(
    appName: json['appName'],
    version: json['version'],
    buildNumber: json['buildNumber'],
    packageName: json['packageName'],
  );
}

/// Конфигурация логгера
class LoggerConfig {
  final LogLevel minLevel;
  final bool enableConsole;
  final bool enableFile;
  final bool enableCrashReports;
  final int maxFileSizeMB;
  final int maxFileAgeDays;
  final bool enablePrettyPrint;
  final bool enableColors;
  final bool enableMetadata;
  final bool maskSensitiveData;
  final Set<String>? enabledModules;
  final Set<String>? disabledModules;
  final Map<String, LogLevel>? moduleLogLevels;

  const LoggerConfig({
    this.minLevel = LogLevel.info,
    this.enableConsole = true,
    this.enableFile = true,
    this.enableCrashReports = false,
    this.maxFileSizeMB = 100,
    this.maxFileAgeDays = 30,
    this.enablePrettyPrint = true,
    this.enableColors = true,
    this.enableMetadata = true,
    this.maskSensitiveData = true,
    this.enabledModules,
    this.disabledModules,
    this.moduleLogLevels,
  });

  Map<String, dynamic> toJson() => {
    'minLevel': minLevel.name,
    'enableConsole': enableConsole,
    'enableFile': enableFile,
    'enableCrashReports': enableCrashReports,
    'maxFileSizeMB': maxFileSizeMB,
    'maxFileAgeDays': maxFileAgeDays,
    'enablePrettyPrint': enablePrettyPrint,
    'enableColors': enableColors,
    'enableMetadata': enableMetadata,
    'maskSensitiveData': maskSensitiveData,
    if (enabledModules != null) 'enabledModules': enabledModules!.toList(),
    if (disabledModules != null) 'disabledModules': disabledModules!.toList(),
    if (moduleLogLevels != null)
      'moduleLogLevels': moduleLogLevels!.map((k, v) => MapEntry(k, v.name)),
  };

  factory LoggerConfig.fromJson(Map<String, dynamic> json) => LoggerConfig(
    minLevel: LogLevel.fromString(json['minLevel']),
    enableConsole: json['enableConsole'] ?? true,
    enableFile: json['enableFile'] ?? true,
    enableCrashReports: json['enableCrashReports'] ?? false,
    maxFileSizeMB: json['maxFileSizeMB'] ?? 100,
    maxFileAgeDays: json['maxFileAgeDays'] ?? 30,
    enablePrettyPrint: json['enablePrettyPrint'] ?? true,
    enableColors: json['enableColors'] ?? true,
    enableMetadata: json['enableMetadata'] ?? true,
    maskSensitiveData: json['maskSensitiveData'] ?? true,
    enabledModules: json['enabledModules']?.cast<String>()?.toSet(),
    disabledModules: json['disabledModules']?.cast<String>()?.toSet(),
    moduleLogLevels: json['moduleLogLevels']?.map<String, LogLevel>(
      (k, v) => MapEntry(k, LogLevel.fromString(v)),
    ),
  );
}

/// Фильтр для логов
class LogFilter {
  final LogLevel? minLevel;
  final LogLevel? maxLevel;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? sessionId;
  final String? module;
  final String? context;
  final String? logger;
  final String? messagePattern;

  const LogFilter({
    this.minLevel,
    this.maxLevel,
    this.startTime,
    this.endTime,
    this.sessionId,
    this.module,
    this.context,
    this.logger,
    this.messagePattern,
  });

  Map<String, dynamic> toJson() => {
    if (minLevel != null) 'minLevel': minLevel!.name,
    if (maxLevel != null) 'maxLevel': maxLevel!.name,
    if (startTime != null) 'startTime': startTime!.toIso8601String(),
    if (endTime != null) 'endTime': endTime!.toIso8601String(),
    if (sessionId != null) 'sessionId': sessionId,
    if (module != null) 'module': module,
    if (context != null) 'context': context,
    if (logger != null) 'logger': logger,
    if (messagePattern != null) 'messagePattern': messagePattern,
  };

  factory LogFilter.fromJson(Map<String, dynamic> json) => LogFilter(
    minLevel: json['minLevel'] != null
        ? LogLevel.fromString(json['minLevel'])
        : null,
    maxLevel: json['maxLevel'] != null
        ? LogLevel.fromString(json['maxLevel'])
        : null,
    startTime: json['startTime'] != null
        ? DateTime.parse(json['startTime'])
        : null,
    endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
    sessionId: json['sessionId'],
    module: json['module'],
    context: json['context'],
    logger: json['logger'],
    messagePattern: json['messagePattern'],
  );
}
