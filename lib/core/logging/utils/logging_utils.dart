import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../app_logger.dart';
import '../models/log_level.dart';

/// Декоратор для автоматического логирования выполнения функций
class LoggedFunction<T> {
  final String functionName;
  final String module;
  final LogLevel logLevel;
  final bool logParameters;
  final bool logResult;
  final bool logExecutionTime;

  LoggedFunction({
    required this.functionName,
    this.module = 'App',
    this.logLevel = LogLevel.debug,
    this.logParameters = false,
    this.logResult = false,
    this.logExecutionTime = true,
  });

  /// Выполнить функцию с логированием
  Future<T> execute(
    Future<T> Function() function, {
    Map<String, dynamic>? parameters,
  }) async {
    final logger = AppLogger.instance;
    final stopwatch = Stopwatch()..start();

    await logger.log(
      level: logLevel,
      message: 'Executing function: $functionName',
      logger: 'Function',
      module: module,
      function: functionName,
      metadata: {
        'action': 'start',
        if (logParameters && parameters != null) 'parameters': parameters,
      },
    );

    try {
      final result = await function();
      stopwatch.stop();

      await logger.log(
        level: logLevel,
        message: 'Function completed: $functionName',
        logger: 'Function',
        module: module,
        function: functionName,
        metadata: {
          'action': 'complete',
          if (logExecutionTime)
            'executionTimeMs': stopwatch.elapsedMilliseconds,
          if (logResult) 'result': result?.toString(),
        },
      );

      return result;
    } catch (error, stackTrace) {
      stopwatch.stop();

      await logger.log(
        level: LogLevel.error,
        message: 'Function failed: $functionName',
        logger: 'Function',
        module: module,
        function: functionName,
        error: error,
        stackTrace: stackTrace,
        metadata: {
          'action': 'error',
          if (logExecutionTime)
            'executionTimeMs': stopwatch.elapsedMilliseconds,
        },
      );

      rethrow;
    }
  }

  /// Выполнить синхронную функцию с логированием
  T executeSync(T Function() function, {Map<String, dynamic>? parameters}) {
    final logger = AppLogger.instance;
    final stopwatch = Stopwatch()..start();

    logger.log(
      level: logLevel,
      message: 'Executing function: $functionName',
      logger: 'Function',
      module: module,
      function: functionName,
      metadata: {
        'action': 'start',
        if (logParameters && parameters != null) 'parameters': parameters,
      },
    );

    try {
      final result = function();
      stopwatch.stop();

      logger.log(
        level: logLevel,
        message: 'Function completed: $functionName',
        logger: 'Function',
        module: module,
        function: functionName,
        metadata: {
          'action': 'complete',
          if (logExecutionTime)
            'executionTimeMs': stopwatch.elapsedMilliseconds,
          if (logResult) 'result': result?.toString(),
        },
      );

      return result;
    } catch (error, stackTrace) {
      stopwatch.stop();

      logger.log(
        level: LogLevel.error,
        message: 'Function failed: $functionName',
        logger: 'Function',
        module: module,
        function: functionName,
        error: error,
        stackTrace: stackTrace,
        metadata: {
          'action': 'error',
          if (logExecutionTime)
            'executionTimeMs': stopwatch.elapsedMilliseconds,
        },
      );

      rethrow;
    }
  }
}

/// Утилита для логирования производительности
class PerformanceLogger {
  static final Map<String, Stopwatch> _stopwatches = {};

  /// Начать измерение времени
  static void start(String operation, {String module = 'Performance'}) {
    final stopwatch = Stopwatch()..start();
    _stopwatches[operation] = stopwatch;

    AppLogger.instance.debug(
      'Performance tracking started: $operation',
      module: module,
      metadata: {'operation': operation, 'action': 'start'},
    );
  }

  /// Завершить измерение времени
  static void end(String operation, {String module = 'Performance'}) {
    final stopwatch = _stopwatches.remove(operation);
    if (stopwatch == null) {
      AppLogger.instance.warning(
        'Performance tracking not found: $operation',
        module: module,
      );
      return;
    }

    stopwatch.stop();
    final elapsedMs = stopwatch.elapsedMilliseconds;

    LogLevel level;
    if (elapsedMs > 5000) {
      level = LogLevel.error; // Очень медленно
    } else if (elapsedMs > 1000) {
      level = LogLevel.warning; // Медленно
    } else {
      level = LogLevel.info; // Нормально
    }

    AppLogger.instance.log(
      level: level,
      message: 'Performance tracking completed: $operation (${elapsedMs}ms)',
      logger: 'Performance',
      module: module,
      metadata: {
        'operation': operation,
        'action': 'end',
        'elapsedMs': elapsedMs,
        'elapsedSeconds': elapsedMs / 1000.0,
      },
    );
  }

  /// Выполнить операцию с измерением времени
  static Future<T> measure<T>(
    String operation,
    Future<T> Function() function, {
    String module = 'Performance',
  }) async {
    start(operation, module: module);
    try {
      final result = await function();
      end(operation, module: module);
      return result;
    } catch (e) {
      end(operation, module: module);
      rethrow;
    }
  }
}

/// Утилита для логирования HTTP запросов
class HttpLogger {
  static const String _module = 'HTTP';

  /// Логировать HTTP запрос
  static void logRequest({
    required String method,
    required String url,
    Map<String, String>? headers,
    dynamic body,
  }) {
    AppLogger.instance.info(
      'HTTP Request: $method $url',
      module: _module,
      metadata: {
        'method': method,
        'url': url,
        'headers': headers,
        if (body != null) 'body': body.toString(),
        'type': 'request',
      },
    );
  }

  /// Логировать HTTP ответ
  static void logResponse({
    required String method,
    required String url,
    required int statusCode,
    Map<String, String>? headers,
    dynamic body,
    int? contentLength,
    Duration? duration,
  }) {
    final isError = statusCode >= 400;
    final level = isError ? LogLevel.error : LogLevel.info;

    AppLogger.instance.log(
      level: level,
      message: 'HTTP Response: $method $url - $statusCode',
      logger: 'HTTP',
      module: _module,
      metadata: {
        'method': method,
        'url': url,
        'statusCode': statusCode,
        'headers': headers,
        if (body != null) 'body': body.toString(),
        if (contentLength != null) 'contentLength': contentLength,
        if (duration != null) 'durationMs': duration.inMilliseconds,
        'type': 'response',
        'isError': isError,
      },
    );
  }

  /// Логировать ошибку HTTP запроса
  static void logError({
    required String method,
    required String url,
    required Object error,
    StackTrace? stackTrace,
    Duration? duration,
  }) {
    AppLogger.instance.error(
      'HTTP Error: $method $url',
      module: _module,
      error: error,
      stackTrace: stackTrace,
      metadata: {
        'method': method,
        'url': url,
        if (duration != null) 'durationMs': duration.inMilliseconds,
        'type': 'error',
      },
    );
  }
}

/// Утилита для логирования навигации
class NavigationLogger {
  static const String _module = 'Navigation';

  /// Логировать переход на новый экран
  static void logPush(String routeName, {Object? arguments}) {
    AppLogger.instance.info(
      'Navigation push: $routeName',
      module: _module,
      metadata: {
        'action': 'push',
        'route': routeName,
        if (arguments != null) 'arguments': arguments.toString(),
      },
    );
  }

  /// Логировать возврат с экрана
  static void logPop(String routeName, {Object? result}) {
    AppLogger.instance.info(
      'Navigation pop: $routeName',
      module: _module,
      metadata: {
        'action': 'pop',
        'route': routeName,
        if (result != null) 'result': result.toString(),
      },
    );
  }

  /// Логировать замену маршрута
  static void logReplace(
    String oldRoute,
    String newRoute, {
    Object? arguments,
  }) {
    AppLogger.instance.info(
      'Navigation replace: $oldRoute -> $newRoute',
      module: _module,
      metadata: {
        'action': 'replace',
        'oldRoute': oldRoute,
        'newRoute': newRoute,
        if (arguments != null) 'arguments': arguments.toString(),
      },
    );
  }
}

/// Утилита для логирования жизненного цикла приложения
class AppLifecycleLogger {
  static const String _module = 'Lifecycle';

  /// Логировать изменение состояния приложения
  static void logStateChange(AppLifecycleState state) {
    String message = 'App state changed';
    LogLevel level = LogLevel.info;

    switch (state) {
      case AppLifecycleState.resumed:
        message = 'App resumed';
        level = LogLevel.info;
        break;
      case AppLifecycleState.paused:
        message = 'App paused';
        level = LogLevel.info;
        break;
      case AppLifecycleState.inactive:
        message = 'App inactive';
        level = LogLevel.debug;
        break;
      case AppLifecycleState.detached:
        message = 'App detached';
        level = LogLevel.warning;
        break;
      case AppLifecycleState.hidden:
        message = 'App hidden';
        level = LogLevel.debug;
        break;
    }

    AppLogger.instance.log(
      level: level,
      message: message,
      logger: 'Lifecycle',
      module: _module,
      metadata: {
        'state': state.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Логировать запуск приложения
  static void logAppStart() {
    AppLogger.instance.info(
      'Application started',
      module: _module,
      metadata: {
        'action': 'start',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Логировать завершение работы приложения
  static void logAppExit() {
    AppLogger.instance.info(
      'Application exiting',
      module: _module,
      metadata: {
        'action': 'exit',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
}
