import 'dart:async';
import 'dart:io';
import 'package:codexa_pass/core/logging/app_logger.dart';
import 'package:codexa_pass/core/logging/logging.dart';

import 'package:codexa_pass/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeLogging();
  runApp(ProviderScope(observers: [LogInterceptor()], child: MyApp()));
}

Future<void> _initializeLogging() async {
  WidgetsFlutterBinding.ensureInitialized();

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
          print('  ${file.path} (${size} bytes)');
        }
      }
    });
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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

class _MyHomePageState extends State<MyHomePage> {
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
}
