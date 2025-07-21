import 'dart:async';

import 'package:codexa_pass/app.dart';
import 'package:codexa_pass/app/window_manager/window_manager.dart';

import 'package:codexa_pass/core/error/global_error_handler.dart';
import 'package:codexa_pass/core/error/utils/error_config.dart';
import 'package:codexa_pass/core/logging/logging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:universal_platform/universal_platform.dart';

import 'package:sqlite3/open.dart';

Future<void> setupSqlCipher() async {
  await applyWorkaroundToOpenSqlCipherOnOldAndroidVersions();
  open.overrideFor(OperatingSystem.android, openCipherOnAndroid);
}

Future<void> main() async {
  if (UniversalPlatform.isWeb) {
    throw UnsupportedError('This platform is not supported by this app.');
  }

  WidgetsFlutterBinding.ensureInitialized();

  await initializeLogging();

  await WindowManager.initialize();

  await setupSqlCipher();

  // Настраиваем observer для автоматического логирования состояний Riverpod
  final container = ProviderContainer(observers: [LoggingProviderObserver()]);

  // Инициализируем систему обработки ошибок
  await _initializeErrorHandling(container);

  runApp(UncontrolledProviderScope(container: container, child: WrapperApp()));
}

Future<void> initializeLogging() async {
  // Создаем конфигурацию для разных сред
  final config = LoggerConfig(
    minLevel: const bool.fromEnvironment('dart.vm.product')
        ? LogLevel.info
        : LogLevel.debug,
    enableConsole: true,
    enableFile: true,
    enableCrashReports: const bool.fromEnvironment('dart.vm.product'),
    maxFileSizeMB: 100,
    maxFileAgeDays: 30,
    enablePrettyPrint: true,
    enableColors: !const bool.fromEnvironment('dart.vm.product'),
    enableMetadata: true,
    maskSensitiveData: true,
    // Включаем только определенные модули в продакшене
    enabledModules: const bool.fromEnvironment('dart.vm.product')
        ? {'Auth', 'Encryption', 'Storage'}
        : null,
    // Настраиваем уровни для модулей
    moduleLogLevels: {
      'Auth': LogLevel.info,
      'Encryption': LogLevel.warning,
      'Debug': LogLevel.debug,
    },
  );

  // Инициализируем логгер
  await AppLogger.instance.initialize(config: config);

  AppLogger.setupGlobalErrorHandling();

  // Логируем успешную инициализацию
  await AppLogger.instance.info(
    'Logging system initialized',
    metadata: {
      'environment': const bool.fromEnvironment('dart.vm.product')
          ? 'production'
          : 'development',
      'sessionId': AppLogger.instance.sessionId,
    },
  );
}

Future<void> _initializeErrorHandling(ProviderContainer container) async {
  try {
    // Создаем конфигурацию системы ошибок
    const errorConfig = ErrorConfig(
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
    );

    // Инициализируем глобальный обработчик ошибок
    await GlobalErrorHandler.initialize(
      config: errorConfig,
      container: container,
    );

    await AppLogger.instance.info(
      'Error handling system initialized successfully',
      logger: 'Main',
      metadata: {'errorConfig': errorConfig.toJson()},
    );
  } catch (e, stackTrace) {
    debugPrint('Failed to initialize error handling system: $e');
    debugPrint('StackTrace: $stackTrace');
  }
}
