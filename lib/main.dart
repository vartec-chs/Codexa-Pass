import 'dart:async';
import 'dart:io';
import 'package:codexa_pass/core/error/error_system.dart';
import 'package:codexa_pass/core/logging/app_logger.dart';
import 'package:codexa_pass/core/logging/logging.dart';

import 'package:codexa_pass/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализируем систему логирования
  await _initializeLogging();

  // Инициализируем систему ошибок
  ErrorSystemIntegration.initialize();

  runApp(ProviderScope(observers: [LogInterceptor()], child: MyApp()));
}

Future<void> _initializeLogging() async {
  FlutterError.onError = (details) {
    AppLogger.instance.fatal('Flutter Error', details.exception, details.stack);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.instance.fatal('Dart Error', error, stack);
    return true;
  };

  // Создаем экземпляр логгера и ждем его инициализации
  final logger = AppLogger.instance;

  // Ждем инициализации файлового вывода
  await logger.waitForInitialization();

  // Теперь можем безопасно логировать
  LogUtils.logAppInfo();
  AppLogger.instance.info('Система логирования запущена');

  // Тестируем создание файла лога
  _testLogFileCreation();
}

void _testLogFileCreation() async {
  final logger = AppLogger.instance;

  // Даем время на инициализацию
  await Future.delayed(Duration(seconds: 2));

  if (kDebugMode) {
    print('=== TEST LOG FILE CREATION ===');
    print('File logging ready: ${logger.isFileLoggingReady}');

    final logDir = await logger.getLogDirectory();
    print('Log directory: $logDir');

    // Записываем тестовые сообщения
    logger.debug('🔍 Тестовое debug сообщение');
    logger.info('ℹ️ Тестовое info сообщение');
    logger.warning('⚠️ Тестовое warning сообщение');
    logger.error('❌ Тестовое error сообщение');

    // Проверяем файлы после небольшой задержки
    Timer(Duration(seconds: 3), () async {
      final logFiles = await logger.getLogFiles();
      print('Found ${logFiles.length} log files:');
      for (final file in logFiles) {
        if (await file.exists()) {
          final size = await file.length();
          print('  ${file.path} ($size bytes)');
        }
      }
    });
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      // Локализация
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,

      // Логирование навигации
      navigatorObservers: [LogNavigatorObserver()],
      navigatorKey: ref.watch(navigatorKeyProvider),

      home: Builder(
        builder: (context) {
          // Инициализация многоязычности
          LoggerInitializer.initializeWithContext(context);
          return const MyHomePage(title: 'Flutter Demo Home Page');
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with ErrorHandlerMixin {
  @override
  void initState() {
    super.initState();
    // Инициализация логгера без контекста
    LoggerInitializer.initialize();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Установка контекста для локализации после получения context
    LoggerInitializer.initializeWithContext(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder<String?>(
              future: AppLogger.instance.getLogDirectory(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text('Лог директория: ${snapshot.data}');
                } else {
                  return Text('Загрузка директории логов...');
                }
              },
            ),
            SizedBox(height: 16),
            Text('Логгер готов: ${AppLogger.instance.isFileLoggingReady}'),
            SizedBox(height: 16),
            FutureBuilder<List<File>>(
              future: AppLogger.instance.getLogFiles(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text('Файлов логов: ${snapshot.data!.length}');
                } else {
                  return Text('Проверка файлов логов...');
                }
              },
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                _testLogging();
              },
              child: const Text('Тест логирования'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                // Повторно тестируем LogUtils.logAppInfo
                AppLogger.instance.info(
                  '=== Повторный тест LogUtils.logAppInfo ===',
                );
                LogUtils.logAppInfo();
                AppLogger.instance.info('=== Конец повторного теста ===');

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('LogUtils.logAppInfo выполнен!')),
                );
              },
              child: const Text('Тест LogUtils.logAppInfo'),
            ),
            SizedBox(height: 16),
            // Добавляем кнопку для тестирования системы ошибок
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SimpleErrorTestPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Тест системы ошибок'),
            ),

            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SimpleErrorTestPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Тест системы ошибок'),
            ),
            const SizedBox(height: 16),
            // тест ошибок _testNonCriticalError and _testCriticalError
            ElevatedButton(
              onPressed: _testNonCriticalError,
              child: const Text('Тест: Некритическая ошибка'),
            ),
            ElevatedButton(
              onPressed: _testCriticalError,
              child: const Text('Тест: Критическая ошибка'),
            ),
          ],
        ),
      ),
    );
  }

  void _testLogging() {
    // Примеры логирования
    AppLogger.instance.debug('Отладочное сообщение / Debug message');
    AppLogger.instance.info('Информационное сообщение / Info message');
    AppLogger.instance.warning('Предупреждение / Warning message');
    AppLogger.instance.error('Ошибка / Error message');

    // Тестирование локализованных системных сообщений
    _testSystemMessages();
  }

  void _testSystemMessages() async {
    try {
      // Это вызовет локализованные сообщения об ошибках
      await AppLogger.instance.getLogFiles();
      await AppLogger.instance.clearAllLogs();
    } catch (e) {
      AppLogger.instance.error(
        'Ошибка при тестировании системных сообщений',
        e,
      );
    }
  }

  /// Тестирует некритическую ошибку (SnackBar)
  void _testNonCriticalError() {
    // Используем SafeErrorHandling для безопасной обработки
    SafeErrorHandling.handleErrorWithContext(
      context,
      const AuthenticationError(
        type: AuthenticationErrorType.invalidCredentials,
        message: 'Тестовая ошибка аутентификации',
        details: 'Это пример некритической ошибки для демонстрации SnackBar',
        isCritical: false,
      ),
    );
  }

  /// Тестирует критическую ошибку (диалог)
  void _testCriticalError() {
    SafeErrorHandling.handleErrorWithContext(
      context,
      const EncryptionError(
        type: EncryptionErrorType.decryptionFailed,
        message: 'Критическая ошибка шифрования',
        details:
            'Это пример критической ошибки для демонстрации модального окна',
        isCritical: true,
      ),
    );
  }
}

/// Простая страница для тестирования системы ошибок
class SimpleErrorTestPage extends StatelessWidget {
  const SimpleErrorTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Тест системы ошибок')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Система ошибок успешно интегрирована!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'Система обработки ошибок готова к использованию.\n\n'
                'Для полного тестирования смотрите:\n'
                '• lib/core/error/test_widget.dart\n'
                '• lib/core/error/examples/error_examples.dart\n'
                '• lib/core/error/QUICK_START.md',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
