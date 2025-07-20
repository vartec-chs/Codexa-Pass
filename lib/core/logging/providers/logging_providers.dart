import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../app_logger.dart';
import '../models/log_entry.dart';
import '../models/log_level.dart';

/// Провайдер для основного логгера
final loggerProvider = Provider<AppLogger>((ref) {
  return AppLogger.instance;
});

/// Провайдер для конфигурации логгера
final loggerConfigProvider =
    StateNotifierProvider<LoggerConfigNotifier, LoggerConfig>((ref) {
      return LoggerConfigNotifier();
    });

/// Notifier для управления конфигурацией логгера
class LoggerConfigNotifier extends StateNotifier<LoggerConfig> {
  LoggerConfigNotifier() : super(_getDefaultConfig());

  static LoggerConfig _getDefaultConfig() {
    return LoggerConfig(
      minLevel: kDebugMode ? LogLevel.debug : LogLevel.info,
      enableConsole: true,
      enableFile: true,
      enableCrashReports: !kDebugMode, // Только в release режиме
      maxFileSizeMB: 100,
      maxFileAgeDays: 30,
      enablePrettyPrint: kDebugMode,
      enableColors: kDebugMode,
      enableMetadata: true,
      maskSensitiveData: true,
    );
  }

  /// Обновить конфигурацию
  Future<void> updateConfig(LoggerConfig newConfig) async {
    state = newConfig;
    await AppLogger.instance.updateConfig(newConfig);
  }

  /// Изменить минимальный уровень логирования
  Future<void> setMinLevel(LogLevel level) async {
    final newConfig = LoggerConfig(
      minLevel: level,
      enableConsole: state.enableConsole,
      enableFile: state.enableFile,
      enableCrashReports: state.enableCrashReports,
      maxFileSizeMB: state.maxFileSizeMB,
      maxFileAgeDays: state.maxFileAgeDays,
      enablePrettyPrint: state.enablePrettyPrint,
      enableColors: state.enableColors,
      enableMetadata: state.enableMetadata,
      maskSensitiveData: state.maskSensitiveData,
      enabledModules: state.enabledModules,
      disabledModules: state.disabledModules,
      moduleLogLevels: state.moduleLogLevels,
    );
    await updateConfig(newConfig);
  }

  /// Включить/выключить модуль
  Future<void> toggleModule(String module, bool enabled) async {
    final newEnabledModules = Set<String>.from(state.enabledModules ?? {});
    final newDisabledModules = Set<String>.from(state.disabledModules ?? {});

    if (enabled) {
      newEnabledModules.add(module);
      newDisabledModules.remove(module);
    } else {
      newEnabledModules.remove(module);
      newDisabledModules.add(module);
    }

    final newConfig = LoggerConfig(
      minLevel: state.minLevel,
      enableConsole: state.enableConsole,
      enableFile: state.enableFile,
      enableCrashReports: state.enableCrashReports,
      maxFileSizeMB: state.maxFileSizeMB,
      maxFileAgeDays: state.maxFileAgeDays,
      enablePrettyPrint: state.enablePrettyPrint,
      enableColors: state.enableColors,
      enableMetadata: state.enableMetadata,
      maskSensitiveData: state.maskSensitiveData,
      enabledModules: newEnabledModules.isEmpty ? null : newEnabledModules,
      disabledModules: newDisabledModules.isEmpty ? null : newDisabledModules,
      moduleLogLevels: state.moduleLogLevels,
    );
    await updateConfig(newConfig);
  }

  /// Установить уровень логирования для конкретного модуля
  Future<void> setModuleLogLevel(String module, LogLevel level) async {
    final newModuleLevels = Map<String, LogLevel>.from(
      state.moduleLogLevels ?? {},
    );
    newModuleLevels[module] = level;

    final newConfig = LoggerConfig(
      minLevel: state.minLevel,
      enableConsole: state.enableConsole,
      enableFile: state.enableFile,
      enableCrashReports: state.enableCrashReports,
      maxFileSizeMB: state.maxFileSizeMB,
      maxFileAgeDays: state.maxFileAgeDays,
      enablePrettyPrint: state.enablePrettyPrint,
      enableColors: state.enableColors,
      enableMetadata: state.enableMetadata,
      maskSensitiveData: state.maskSensitiveData,
      enabledModules: state.enabledModules,
      disabledModules: state.disabledModules,
      moduleLogLevels: newModuleLevels,
    );
    await updateConfig(newConfig);
  }
}

/// Провайдер для создания модульного логгера
final moduleLoggerProvider = Provider.family<ModuleLogger, String>((
  ref,
  module,
) {
  final logger = ref.watch(loggerProvider);
  return ModuleLogger(logger, module);
});

/// Обертка для модульного логирования
class ModuleLogger {
  final AppLogger _logger;
  final String _module;

  ModuleLogger(this._logger, this._module);

  Future<void> debug(
    String message, {
    String? context,
    String? className,
    int? line,
    String? function,
    Map<String, dynamic>? metadata,
  }) => _logger.debug(
    message,
    module: _module,
    context: context,
    className: className,
    line: line,
    function: function,
    metadata: metadata,
  );

  Future<void> info(
    String message, {
    String? context,
    String? className,
    int? line,
    String? function,
    Map<String, dynamic>? metadata,
  }) => _logger.info(
    message,
    module: _module,
    context: context,
    className: className,
    line: line,
    function: function,
    metadata: metadata,
  );

  Future<void> warning(
    String message, {
    String? context,
    String? className,
    int? line,
    String? function,
    Map<String, dynamic>? metadata,
  }) => _logger.warning(
    message,
    module: _module,
    context: context,
    className: className,
    line: line,
    function: function,
    metadata: metadata,
  );

  Future<void> error(
    String message, {
    String? context,
    String? className,
    int? line,
    String? function,
    Map<String, dynamic>? metadata,
    Object? error,
    StackTrace? stackTrace,
  }) => _logger.error(
    message,
    module: _module,
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
    String? context,
    String? className,
    int? line,
    String? function,
    Map<String, dynamic>? metadata,
    Object? error,
    StackTrace? stackTrace,
  }) => _logger.fatal(
    message,
    module: _module,
    context: context,
    className: className,
    line: line,
    function: function,
    metadata: metadata,
    error: error,
    stackTrace: stackTrace,
  );
}

/// Миксин для автоматического логирования в виджетах
mixin LoggingMixin {
  late final ModuleLogger _logger;

  /// Инициализация логгера (вызывать в initState или аналогичном методе)
  void initLogger(WidgetRef ref, String module) {
    _logger = ref.read(moduleLoggerProvider(module));
  }

  /// Получить логгер
  ModuleLogger get logger => _logger;
}

/// Расширение для автоматического логирования ошибок в провайдерах
extension RiverpodLoggingExtension on ProviderBase {
  /// Обертка для автоматического логирования ошибок
  T logError<T>(T Function() computation, String module) {
    try {
      return computation();
    } catch (error, stackTrace) {
      // Логируем ошибку
      AppLogger.instance.error(
        'Error in provider: $runtimeType',
        module: module,
        error: error,
        stackTrace: stackTrace,
        metadata: {'provider': runtimeType.toString(), 'module': module},
      );
      rethrow;
    }
  }
}

/// Провайдер для отслеживания состояния провайдеров
final providerObserverProvider = Provider<LoggingProviderObserver>((ref) {
  return LoggingProviderObserver();
});

/// Observer для автоматического логирования изменений состояния
class LoggingProviderObserver extends ProviderObserver {
  static const String _module = 'Riverpod';

  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    AppLogger.instance.debug(
      'Provider state updated: ${provider.runtimeType}',
      module: _module,
      metadata: {
        'provider': provider.runtimeType.toString(),
        'previousValue': previousValue?.runtimeType.toString(),
        'newValue': newValue?.runtimeType.toString(),
      },
    );
  }

  @override
  void didDisposeProvider(ProviderBase provider, ProviderContainer container) {
    AppLogger.instance.debug(
      'Provider disposed: ${provider.runtimeType}',
      module: _module,
      metadata: {'provider': provider.runtimeType.toString()},
    );
  }

  @override
  void providerDidFail(
    ProviderBase provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    AppLogger.instance.error(
      'Provider failed: ${provider.runtimeType}',
      module: _module,
      error: error,
      stackTrace: stackTrace,
      metadata: {'provider': provider.runtimeType.toString()},
    );
  }
}
