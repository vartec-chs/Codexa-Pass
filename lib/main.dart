import 'dart:async';

import 'package:codexa_pass/generated/l10n.dart';
import 'package:codexa_pass/core/logging/logging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализируем систему логгирования
  await _initializeLogging();

  // Настраиваем observer для автоматического логирования состояний Riverpod
  final container = ProviderContainer(observers: [LoggingProviderObserver()]);

  // Логируем запуск приложения
  AppLifecycleLogger.logAppStart();

  runApp(UncontrolledProviderScope(container: container, child: MyApp()));
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
          ? {'Auth', 'Encryption', 'Storage', 'Security'}
          : null,
      // Настраиваем уровни для модулей
      moduleLogLevels: {
        'Auth': LogLevel.info,
        'Encryption': LogLevel.warning,
        'Storage': LogLevel.info,
        'Security': LogLevel.warning,
        'UI': kDebugMode ? LogLevel.debug : LogLevel.warning,
        'Network': LogLevel.info,
      },
    );

    // Инициализируем логгер
    await AppLogger.instance.initialize(config: config);

    // Логируем успешную инициализацию
    await AppLogger.instance.info(
      'Codexa Pass started successfully',
      logger: 'Main',
      metadata: {
        'environment': kDebugMode ? 'development' : 'production',
        'sessionId': AppLogger.instance.sessionId,
        'flutterVersion': const String.fromEnvironment(
          'flutter.version',
          defaultValue: 'unknown',
        ),
      },
    );
  } catch (e, stackTrace) {
    // Если логгер не удалось инициализировать, выводим в консоль
    debugPrint('Failed to initialize logging system: $e');
    debugPrint('StackTrace: $stackTrace');
  }
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Codexa Pass',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        S.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(),
      // Логируем навигацию
      navigatorObservers: [LoggingNavigatorObserver()],
    );
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage>
    with LoggingMixin, WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    // Инициализируем логгер для данного виджета
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initLogger(ref, 'HomePage');
      logger.info('Home page initialized');
    });

    // Подписываемся на изменения жизненного цикла приложения
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_loggerInitialized) {
      logger.info('Home page disposed');
    }
    super.dispose();
  }

  bool _loggerInitialized = false;

  @override
  void initLogger(WidgetRef ref, String module) {
    super.initLogger(ref, module);
    _loggerInitialized = true;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    AppLifecycleLogger.logStateChange(state);
  }

  Future<void> _testLogging() async {
    if (!_loggerInitialized) return;

    await logger.info('Testing logging functionality');

    // Демонстрируем разные уровни логирования
    await logger.debug('Debug message - detailed information');
    await logger.info('Info message - general information');
    await logger.warning('Warning message - something to pay attention to');

    // Демонстрируем логирование с метаданными
    await logger.info(
      'User action performed',
      metadata: {
        'action': 'test_button_pressed',
        'timestamp': DateTime.now().toIso8601String(),
        'userAgent': 'Flutter App',
      },
    );

    // Демонстрируем логирование производительности
    await PerformanceLogger.measure('test_operation', () async {
      await Future.delayed(const Duration(milliseconds: 100));
      await logger.info('Test operation completed');
    }, module: 'HomePage');

    // Демонстрируем обработку ошибок
    try {
      throw Exception('Test exception for demonstration');
    } catch (e, stackTrace) {
      await logger.error(
        'Caught test exception',
        error: e,
        stackTrace: stackTrace,
        metadata: {'context': 'test_logging', 'expected': true},
      );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Check console and log files for output'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Codexa Pass"),
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () => _showLogInfo(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Welcome to Codexa Pass",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              "Your secure password manager with advanced logging",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _testLogging,
              icon: const Icon(Icons.bug_report),
              label: const Text('Test Logging System'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _showLoggingDemo(),
              icon: const Icon(Icons.play_arrow),
              label: const Text('View Logging Demo'),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logging Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Session ID: ${AppLogger.instance.sessionId}'),
            const SizedBox(height: 8),
            Text('Min Level: ${AppLogger.instance.config.minLevel.name}'),
            const SizedBox(height: 8),
            Text('Console: ${AppLogger.instance.config.enableConsole}'),
            const SizedBox(height: 8),
            Text('File: ${AppLogger.instance.config.enableFile}'),
            const SizedBox(height: 8),
            Text(
              'Crash Reports: ${AppLogger.instance.config.enableCrashReports}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLoggingDemo() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const LoggingDemoPage()));
  }
}

/// Демонстрационная страница для показа возможностей логгирования
class LoggingDemoPage extends ConsumerStatefulWidget {
  const LoggingDemoPage({Key? key}) : super(key: key);

  @override
  ConsumerState<LoggingDemoPage> createState() => _LoggingDemoPageState();
}

class _LoggingDemoPageState extends ConsumerState<LoggingDemoPage>
    with LoggingMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initLogger(ref, 'LoggingDemo');
      logger.info('Logging demo page opened');
    });
  }

  @override
  void dispose() {
    logger.info('Logging demo page closed');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Logging Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Codexa Pass Logging System Demo',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _buildDemoButton(
              'Debug Log',
              () => logger.debug('Debug message example'),
            ),
            _buildDemoButton(
              'Info Log',
              () => logger.info('Info message example'),
            ),
            _buildDemoButton(
              'Warning Log',
              () => logger.warning('Warning message example'),
            ),
            _buildDemoButton(
              'Error Log',
              () => logger.error('Error message example'),
            ),
            _buildDemoButton('Performance Test', _performanceTest),
            _buildDemoButton('Sensitive Data Test', _sensitiveDataTest),
            _buildDemoButton('HTTP Request Simulation', _httpRequestTest),
            const SizedBox(height: 20),
            const Text(
              'Check console output and log files in the app documents directory.',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoButton(String title, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ElevatedButton(onPressed: onPressed, child: Text(title)),
    );
  }

  Future<void> _performanceTest() async {
    await PerformanceLogger.measure('demo_performance_test', () async {
      await logger.info('Starting performance test');
      await Future.delayed(const Duration(milliseconds: 200));
      await logger.info('Performance test completed');
    }, module: 'LoggingDemo');
  }

  Future<void> _sensitiveDataTest() async {
    await logger.info(
      'Demonstrating sensitive data masking',
      metadata: {
        'password': 'secretPassword123',
        'token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.demo.token',
        'email': 'user@example.com',
        'normalData': 'This is not sensitive',
      },
    );
  }

  Future<void> _httpRequestTest() async {
    HttpLogger.logRequest(
      method: 'POST',
      url: 'https://api.example.com/auth/login',
      headers: {'Content-Type': 'application/json'},
      body: {'username': 'user@example.com', 'password': 'secretPassword'},
    );

    await Future.delayed(const Duration(milliseconds: 100));

    HttpLogger.logResponse(
      method: 'POST',
      url: 'https://api.example.com/auth/login',
      statusCode: 200,
      headers: {'Content-Type': 'application/json'},
      body: {'token': 'demo_token_12345', 'expires_in': 3600},
      duration: const Duration(milliseconds: 150),
    );
  }
}

/// Навигационный observer для логирования переходов
class LoggingNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    NavigationLogger.logPush(
      route.settings.name ?? 'Unknown',
      arguments: route.settings.arguments,
    );
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    NavigationLogger.logPop(route.settings.name ?? 'Unknown');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null && oldRoute != null) {
      NavigationLogger.logReplace(
        oldRoute.settings.name ?? 'Unknown',
        newRoute.settings.name ?? 'Unknown',
        arguments: newRoute.settings.arguments,
      );
    }
  }
}
