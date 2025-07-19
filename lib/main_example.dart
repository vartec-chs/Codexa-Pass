import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/logging/logging.dart';

void main() async {
  // Инициализация системы логирования
  await _initializeLogging();

  runApp(ProviderScope(observers: [LogInterceptor()], child: const MyApp()));
}

/// Инициализация системы логирования
Future<void> _initializeLogging() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Настройка глобального обработчика ошибок Flutter
  FlutterError.onError = (FlutterErrorDetails details) {
    AppLogger.instance.fatal('Flutter Error', details.exception, details.stack);
  };

  // Настройка глобального обработчика ошибок Dart
  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.instance.fatal('Dart Error', error, stack);
    return true;
  };

  // Логирование информации о приложении
  LogUtils.logAppInfo();
  AppLogger.instance.info('Система логирования инициализирована');
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    LogUtils.logWidgetLifecycle('MyApp', 'build');

    return MaterialApp(
      title: 'Codexa Pass',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Codexa Pass Home Page'),
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
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    LogUtils.logWidgetLifecycle('MyHomePage', 'initState');
  }

  @override
  void dispose() {
    LogUtils.logWidgetLifecycle('MyHomePage', 'dispose');
    super.dispose();
  }

  void _incrementCounter() {
    LogUtils.logUserAction(
      'increment_counter',
      details: {'previous_value': _counter},
    );
    setState(() {
      _counter++;
    });
  }

  void _showLogDirectory() async {
    final logDir = await AppLogger.instance.getLogDirectory();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Директория логов: ${logDir ?? "Недоступна"}')),
      );
    }
  }

  void _clearLogs() async {
    await AppLogger.instance.clearAllLogs();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Логи очищены')));
    }
  }

  @override
  Widget build(BuildContext context) {
    LogUtils.logWidgetLifecycle('MyHomePage', 'build');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'show_log_dir':
                  _showLogDirectory();
                  break;
                case 'clear_logs':
                  _clearLogs();
                  break;
                case 'test_error':
                  AppLogger.instance.error(
                    'Тестовая ошибка',
                    'Это тестовая ошибка для проверки логирования',
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'show_log_dir',
                child: Text('Показать директорию логов'),
              ),
              const PopupMenuItem(
                value: 'clear_logs',
                child: Text('Очистить логи'),
              ),
              const PopupMenuItem(
                value: 'test_error',
                child: Text('Тестовая ошибка'),
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
