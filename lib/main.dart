import 'dart:async';

import 'package:codexa_pass/app.dart';
import 'package:codexa_pass/core/logging/logging.dart';
import 'package:codexa_pass/core/error/error_system.dart';
import 'package:codexa_pass/core/error/global_error_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализируем систему логгирования
  await _initializeLogging();

  // Настраиваем observer для автоматического логирования состояний Riverpod
  final container = ProviderContainer(observers: [LoggingProviderObserver()]);

  // Логируем запуск приложения
  AppLifecycleLogger.logAppStart();

  // Запускаем приложение с обработкой ошибок
  runAppWithErrorHandling(
    UncontrolledProviderScope(
      container: container,
      child: WrapperApp(container: container),
    ),
    errorConfig: const ErrorConfig(
      showErrorDetails: kDebugMode,
      enableErrorReporting: kReleaseMode,
      enableCrashReporting: kReleaseMode,
      enableDeduplication: true,
      enableRetryMechanism: true,
      enableCircuitBreaker: true,
      enableSensitiveDataMasking: true,
      moduleConfigs: {
        'Auth': ModuleErrorConfig(
          maxRetries: 3,
          retryDelay: Duration(seconds: 2),
          enableAutoRecovery: true,
          autoRecoveryStrategy: 'retry',
        ),
        'Database': ModuleErrorConfig(
          maxRetries: 5,
          retryDelay: Duration(milliseconds: 500),
          enableAutoRecovery: true,
          autoRecoveryStrategy: 'reset',
        ),
        'Network': ModuleErrorConfig(
          maxRetries: 3,
          retryDelay: Duration(seconds: 1),
          enableAutoRecovery: true,
          autoRecoveryStrategy: 'fallback',
        ),
      },
    ),
    container: container,
  );
}

/// Инициализация системы логгирования
Future<void> _initializeLogging() async {
  try {
    // Создаем конфигурацию в зависимости от режима сборки
    final config = LoggerConfig(
      minLevel: kDebugMode ? LogLevel.debug : LogLevel.info,
      enableConsole: true,
      enableFile: true,
      enableCrashReports: kReleaseMode, // Только в release режиме
      maxFileSizeMB: 100,
      maxFileAgeDays: 30,
      enablePrettyPrint: kDebugMode,
      enableColors: kDebugMode,
      enableMetadata: true,
      maskSensitiveData: true,
      // В продакшене логируем только критичные модули
      enabledModules: kReleaseMode
          ? {'Auth', 'Database', 'Network', 'Security', 'Error'}
          : null,
      // Настраиваем уровни для модулей
      moduleLogLevels: {
        'Network': LogLevel.info,
        'Auth': LogLevel.warning,
        'Security': LogLevel.error,
      },
    );

    // Инициализируем логгер
    await AppLogger.instance.initialize(config: config);

    // Логируем успешную инициализацию
    await AppLogger.instance.info(
      'Codexa Pass started successfully',
      logger: 'Main',
      metadata: {
        'version': '1.0.0',
        'buildMode': kDebugMode ? 'debug' : 'release',
        'platform': 'flutter',
      },
    );
  } catch (e, stackTrace) {
    // Если логгер не удалось инициализировать, выводим в консоль
    debugPrint('Failed to initialize logging system: $e');
    debugPrint('StackTrace: $stackTrace');
  }
}
