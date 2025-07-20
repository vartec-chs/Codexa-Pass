import 'dart:async';
import 'package:codexa_pass/core/utils/path.dart';
import 'package:uuid/uuid.dart';
import 'models/log_entry.dart';
import 'models/log_level.dart';
import 'interfaces/logging_interfaces.dart';
import 'services/system_info_provider.dart';
import 'services/sensitive_data_masker.dart';
import 'handlers/base_handlers.dart';
import 'handlers/file_handlers.dart';
import 'formatters/log_formatters.dart';

/// Основной класс логгера с асинхронной обработкой
class AppLogger {
  static AppLogger? _instance;
  static final Uuid _uuid = Uuid();

  final String _sessionId = _uuid.v4();
  final List<LogHandler> _handlers = [];
  final SystemInfoProvider _systemInfoProvider = SystemInfoProviderImpl();
  final SensitiveDataMasker _dataMasker = SensitiveDataMaskerImpl();

  late final StreamController<LogEntry> _logController;
  late final StreamSubscription _logSubscription;

  LoggerConfig _config = const LoggerConfig();
  DeviceInfo? _deviceInfo;
  AppInfo? _appInfo;

  bool _isInitialized = false;
  final Completer<void> _initCompleter = Completer<void>();

  AppLogger._internal() {
    _logController = StreamController<LogEntry>.broadcast();
    _logSubscription = _logController.stream.listen(_processLogEntry);
  }

  /// Получить singleton инстанс логгера
  static AppLogger get instance {
    _instance ??= AppLogger._internal();
    return _instance!;
  }

  /// Инициализация логгера
  Future<void> initialize({LoggerConfig? config}) async {
    if (_isInitialized) return;

    _config = config ?? const LoggerConfig();

    try {
      // Загружаем информацию о системе
      _deviceInfo = await _systemInfoProvider.getDeviceInfo();
      _appInfo = await _systemInfoProvider.getAppInfo();

      // Настраиваем обработчики
      await _setupHandlers();

      _isInitialized = true;
      _initCompleter.complete();

      info(
        'Logger initialized',
        metadata: {
          'sessionId': _sessionId,
          'config': _config.toJson(),
          'deviceInfo': _deviceInfo!.toJson(),
          'appInfo': _appInfo!.toJson(),
        },
      );
    } catch (e, stackTrace) {
      _initCompleter.completeError(e, stackTrace);
      rethrow;
    }
  }

  /// Настройка обработчиков логов
  Future<void> _setupHandlers() async {
    _handlers.clear();

    // Консольный обработчик
    if (_config.enableConsole) {
      _handlers.add(
        ConsoleLogHandler(
          minLevel: _config.minLevel,
          enableColors: _config.enableColors,
          formatter: PrettyConsoleFormatter(
            enableColors: _config.enableColors,
            enableEmoji: true,
            showMetadata: _config.enableMetadata,
          ),
        ),
      );
    }

    // Файловый обработчик
    if (_config.enableFile) {
      final documentsDir = await getAppLogDirPath();
      final logsPath = documentsDir;

      _handlers.add(
        DateFileHandler(
          logDirectory: logsPath,
          maxFileSizeMB: _config.maxFileSizeMB,
          maxFileAgeDays: _config.maxFileAgeDays,
          minLevel: _config.minLevel,
          formatter: const JsonFileFormatter(prettyPrint: true),
        ),
      );
    }

    // Обработчик краш репортов
    if (_config.enableCrashReports) {
      final documentsDir = await getAppCrashDirPath();
      final crashPath = documentsDir;

      _handlers.add(CrashReportHandler(crashDirectory: crashPath));
    }
  }

  /// Обработка записи лога
  Future<void> _processLogEntry(LogEntry entry) async {
    for (final handler in _handlers) {
      try {
        if (handler.canHandle(entry.level)) {
          await handler.handle(entry);
        }
      } catch (e) {
        // Не логируем ошибки в обработчиках чтобы избежать бесконечной рекурсии
        print('Error in log handler: $e');
      }
    }
  }

  /// Создание записи лога
  LogEntry _createLogEntry({
    required LogLevel level,
    required String message,
    required String logger,
    String? module,
    String? context,
    String? className,
    int? line,
    String? function,
    Map<String, dynamic>? metadata,
    Object? error,
    StackTrace? stackTrace,
  }) {
    // Маскируем чувствительные данные если включено
    final maskedMessage = _config.maskSensitiveData
        ? _dataMasker.mask(message)
        : message;

    final maskedMetadata = _config.maskSensitiveData && metadata != null
        ? _dataMasker.maskMetadata(metadata)
        : metadata;

    return LogEntry(
      id: _uuid.v4(),
      timestamp: DateTime.now(),
      level: level,
      message: maskedMessage,
      sessionId: _sessionId,
      logger: logger,
      module: module,
      context: context,
      className: className,
      line: line,
      function: function,
      metadata: maskedMetadata,
      error: error,
      stackTrace: stackTrace,
      deviceInfo:
          _deviceInfo ??
          const DeviceInfo(
            platform: 'Unknown',
            version: 'Unknown',
            model: 'Unknown',
          ),
      appInfo:
          _appInfo ??
          const AppInfo(
            appName: 'Unknown',
            version: 'Unknown',
            buildNumber: 'Unknown',
            packageName: 'Unknown',
          ),
    );
  }

  /// Проверка возможности логирования
  bool _canLog(LogLevel level, String? module) {
    // Проверяем минимальный уровень
    if (level < _config.minLevel) return false;

    // Проверяем модуль-специфичные настройки
    if (module != null && _config.moduleLogLevels != null) {
      final moduleLevel = _config.moduleLogLevels![module];
      if (moduleLevel != null && level < moduleLevel) return false;
    }

    // Проверяем включенные/выключенные модули
    if (_config.enabledModules != null && module != null) {
      return _config.enabledModules!.contains(module);
    }

    if (_config.disabledModules != null && module != null) {
      return !_config.disabledModules!.contains(module);
    }

    return true;
  }

  /// Основной метод логирования
  Future<void> log({
    required LogLevel level,
    required String message,
    required String logger,
    String? module,
    String? context,
    String? className,
    int? line,
    String? function,
    Map<String, dynamic>? metadata,
    Object? error,
    StackTrace? stackTrace,
  }) async {
    if (!_canLog(level, module)) return;

    // Ждем инициализации если она еще не завершена
    if (!_isInitialized) {
      await _initCompleter.future;
    }

    final entry = _createLogEntry(
      level: level,
      message: message,
      logger: logger,
      module: module,
      context: context,
      className: className,
      line: line,
      function: function,
      metadata: metadata,
      error: error,
      stackTrace: stackTrace,
    );

    _logController.add(entry);
  }

  // Удобные методы для разных уровней
  Future<void> debug(
    String message, {
    String logger = 'App',
    String? module,
    String? context,
    String? className,
    int? line,
    String? function,
    Map<String, dynamic>? metadata,
  }) => log(
    level: LogLevel.debug,
    message: message,
    logger: logger,
    module: module,
    context: context,
    className: className,
    line: line,
    function: function,
    metadata: metadata,
  );

  Future<void> info(
    String message, {
    String logger = 'App',
    String? module,
    String? context,
    String? className,
    int? line,
    String? function,
    Map<String, dynamic>? metadata,
  }) => log(
    level: LogLevel.info,
    message: message,
    logger: logger,
    module: module,
    context: context,
    className: className,
    line: line,
    function: function,
    metadata: metadata,
  );

  Future<void> warning(
    String message, {
    String logger = 'App',
    String? module,
    String? context,
    String? className,
    int? line,
    String? function,
    Map<String, dynamic>? metadata,
  }) => log(
    level: LogLevel.warning,
    message: message,
    logger: logger,
    module: module,
    context: context,
    className: className,
    line: line,
    function: function,
    metadata: metadata,
  );

  Future<void> error(
    String message, {
    String logger = 'App',
    String? module,
    String? context,
    String? className,
    int? line,
    String? function,
    Map<String, dynamic>? metadata,
    Object? error,
    StackTrace? stackTrace,
  }) => log(
    level: LogLevel.error,
    message: message,
    logger: logger,
    module: module,
    context: context,
    className: className,
    line: line,
    function: function,
    metadata: metadata,
    error: error,
    stackTrace: stackTrace,
  );

  Future<void> fatal(
    String message, {
    String logger = 'App',
    String? module,
    String? context,
    String? className,
    int? line,
    String? function,
    Map<String, dynamic>? metadata,
    Object? error,
    StackTrace? stackTrace,
  }) => log(
    level: LogLevel.fatal,
    message: message,
    logger: logger,
    module: module,
    context: context,
    className: className,
    line: line,
    function: function,
    metadata: metadata,
    error: error,
    stackTrace: stackTrace,
  );

  /// Получить ID текущей сессии
  String get sessionId => _sessionId;

  /// Получить конфигурацию
  LoggerConfig get config => _config;

  /// Обновить конфигурацию
  Future<void> updateConfig(LoggerConfig newConfig) async {
    _config = newConfig;
    await _setupHandlers();
    info('Logger configuration updated');
  }

  /// Закрытие логгера и освобождение ресурсов
  Future<void> close() async {
    for (final handler in _handlers) {
      await handler.close();
    }
    _handlers.clear();

    await _logController.close();
    await _logSubscription.cancel();

    _isInitialized = false;
  }
}
