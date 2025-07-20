import 'dart:async';
import 'dart:io';

// Новая система ошибок v2
import 'package:codexa_pass/core/error_v2/error_system_v2.dart';

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

  // Инициализируем новую систему ошибок v2
  await _initializeErrorSystemV2();

  runApp(ProviderScope(observers: [LogInterceptor()], child: MyApp()));
}

/// Инициализация новой системы ошибок v2
Future<void> _initializeErrorSystemV2() async {
  try {
    // Создаем и настраиваем глобальный обработчик ошибок
    final errorHandler = ErrorHandlerV2(
      logger: CustomErrorLoggerV2(),
      analytics: CustomErrorAnalyticsV2(),
      notification: CustomErrorNotificationV2(),
      recoveryHandlers: [AuthRecoveryHandlerV2(), NetworkRecoveryHandlerV2()],
    );

    // Устанавливаем как глобальный обработчик
    setGlobalErrorHandler(errorHandler);

    // Настраиваем локализацию ошибок
    setGlobalLocalizer(DefaultErrorLocalizerV2());

    AppLogger.instance.info('✅ Система ошибок v2 успешно инициализирована');
  } catch (e, stackTrace) {
    AppLogger.instance.error(
      '❌ Ошибка инициализации системы ошибок v2',
      e,
      stackTrace,
    );
  }
}

/// Реализация логгера для системы ошибок v2
class CustomErrorLoggerV2 implements ErrorLoggerV2 {
  @override
  Future<void> logError(AppErrorV2 error) async {
    AppLogger.instance.error(
      'ErrorV2: ${error.localizedMessage}',
      error.originalError,
      error.stackTrace,
    );
  }

  @override
  Future<void> logInfo(String message, {Map<String, Object?>? context}) async {
    AppLogger.instance.info('ErrorV2 Info: $message');
  }

  @override
  Future<void> logWarning(
    String message, {
    Map<String, Object?>? context,
  }) async {
    AppLogger.instance.warning('ErrorV2 Warning: $message');
  }
}

/// Реализация аналитики для системы ошибок v2
class CustomErrorAnalyticsV2 implements ErrorAnalyticsV2 {
  @override
  Future<void> trackError(
    AppErrorV2 error,
    ErrorAnalyticsData analyticsData,
  ) async {
    AppLogger.instance.info('Analytics: Error tracked - ${error.id}');
  }

  @override
  Future<void> trackRecovery(AppErrorV2 error, bool successful) async {
    AppLogger.instance.info(
      'Analytics: Recovery ${successful ? 'successful' : 'failed'} for ${error.id}',
    );
  }

  @override
  Future<void> trackRetry(AppErrorV2 error, int attemptNumber) async {
    AppLogger.instance.info(
      'Analytics: Retry attempt $attemptNumber for ${error.id}',
    );
  }
}

/// Реализация уведомлений для системы ошибок v2
class CustomErrorNotificationV2 implements ErrorNotificationV2 {
  @override
  Future<void> showError(AppErrorV2 error) async {
    AppLogger.instance.info(
      'Notification: Showing error - ${error.localizedMessage}',
    );
  }

  @override
  Future<void> showRecoverySuccess(AppErrorV2 error) async {
    AppLogger.instance.info(
      'Notification: Recovery successful for ${error.id}',
    );
  }

  @override
  Future<void> showRecoveryFailure(AppErrorV2 error) async {
    AppLogger.instance.info('Notification: Recovery failed for ${error.id}');
  }
}

Future<void> _initializeLogging() async {
  FlutterError.onError = (details) {
    AppLogger.instance.fatal('Flutter Error', details.exception, details.stack);
    // Создаем краш-репорт для Flutter ошибок
    LogUtils.reportFlutterCrash(
      'Flutter Framework Error',
      details.exception,
      details.stack ?? StackTrace.current,
      additionalInfo: {
        'library': details.library,
        'context': details.context?.toString(),
        'informationCollector': details.informationCollector?.toString(),
      },
    );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.instance.fatal('Dart Error', error, stack);
    // Создаем краш-репорт для Dart ошибок
    LogUtils.reportDartCrash(
      'Dart Runtime Error',
      error,
      stack,
      additionalInfo: {
        'isolate': 'main',
        'errorType': error.runtimeType.toString(),
      },
    );
    return true;
  };

  // Инициализируем систему логирования с системной информацией
  try {
    // Быстрая инициализация для немедленного начала логирования
    LoggerInitializer.initializeQuick();

    // Создаем экземпляр логгера и ждем его инициализации
    final logger = AppLogger.instance;
    await logger.waitForInitialization();

    // Инициализируем системную информацию
    await LogUtils.initializeSystemInfo();

    // Логируем начало сессии с расширенной информацией
    await LogUtils.logSessionStart();

    AppLogger.instance.info('✅ Система логирования полностью инициализирована');
  } catch (e, stackTrace) {
    // Fallback на старую систему в случае ошибки
    AppLogger.instance.error(
      '❌ Ошибка инициализации расширенного логирования',
      e,
      stackTrace,
    );
    LogUtils.logAppInfo(); // Используем старый метод как запасной
    AppLogger.instance.info('⚠️ Система логирования запущена в базовом режиме');
  }

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

      home: Builder(
        builder: (context) {
          // Полная инициализация логгера с контекстом локализации
          // Выполняется асинхронно, чтобы не блокировать UI
          WidgetsBinding.instance.addPostFrameCallback((_) {
            LoggerInitializer.initializeComplete(context: context)
                .then((_) {
                  AppLogger.instance.info(
                    '🎯 Полная инициализация логгера завершена',
                  );
                  LogUtils.logEnvironmentInfo();
                })
                .catchError((e) {
                  AppLogger.instance.error(
                    '❌ Ошибка полной инициализации логгера',
                    e,
                  );
                  // Fallback на простую инициализацию
                  LoggerInitializer.initializeWithContext(context);
                });
          });

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
    // Базовая инициализация логгера уже выполнена в main()
    // Дополнительная инициализация будет выполнена в MyApp
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Полная инициализация уже выполняется в MyApp с постфреймовым колбэком
    // Здесь можно добавить специфичную для данной страницы логику
    LogUtils.logUserAction('Открытие главной страницы');
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
                  '=== Повторный тест LogUtils.logExtendedAppInfo ===',
                );
                LogUtils.logExtendedAppInfo();
                AppLogger.instance.info('=== Конец повторного теста ===');

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('LogUtils.logAppInfo выполнен!')),
                );
              },
              child: const Text('Тест LogUtils.logAppInfo'),
            ),
            SizedBox(height: 16),
            // Добавляем кнопку для тестирования системы ошибок v2
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ErrorSystemV2TestPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Тест системы ошибок v2'),
            ),

            const SizedBox(height: 16),

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
  void _testNonCriticalError() async {
    final error = AuthenticationErrorV2(
      errorType: AuthenticationErrorType.invalidCredentials,
      message: 'Неверные учетные данные для демонстрации',
      username: 'test@example.com',
    );

    await ErrorDisplayV2.show(
      context,
      error,
      config: const ErrorDisplayConfigV2(
        type: ErrorDisplayType.snackbar,
        showSolution: true,
        showRetryButton: true,
      ),
      onRetry: () {
        AppLogger.instance.info('Пользователь нажал повторить попытку');
      },
    );
  }

  /// Тестирует критическую ошибку (диалог)
  void _testCriticalError() async {
    final error = EncryptionErrorV2(
      errorType: EncryptionErrorType.decryptionFailed,
      message: 'Критическая ошибка расшифровки данных',
      algorithm: 'AES-256-GCM',
      technicalDetails: 'javax.crypto.BadPaddingException: Invalid padding',
    );

    await ErrorDisplayV2.show(
      context,
      error,
      config: ErrorDisplayConfigV2.critical(),
      onRetry: () {
        AppLogger.instance.info('Попытка восстановления...');
      },
      onReport: () {
        AppLogger.instance.info('Отправка отчета об ошибке...');
      },
    );
  }
}

/// Простая страница для тестирования системы ошибок (оставлена для совместимости)
class SimpleErrorTestPage extends StatelessWidget {
  const SimpleErrorTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Тест системы ошибок (старая)')),
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

/// Продвинутая страница для тестирования системы ошибок v2
class ErrorSystemV2TestPage extends StatefulWidget {
  const ErrorSystemV2TestPage({super.key});

  @override
  State<ErrorSystemV2TestPage> createState() => _ErrorSystemV2TestPageState();
}

class _ErrorSystemV2TestPageState extends State<ErrorSystemV2TestPage> {
  String _lastResultMessage = 'Результат появится здесь';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Тестирование системы ошибок v2'),
        backgroundColor: Colors.purple[100],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Система ошибок v2 - Демонстрация',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple[700],
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Новая система включает:\n'
                      '• Result<T> для безопасного выполнения операций\n'
                      '• Автоматическое восстановление с retry логикой\n'
                      '• Расширенную локализацию\n'
                      '• Гибкие UI компоненты\n'
                      '• Интеграцию с аналитикой',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Секция тестирования типов ошибок
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Тестирование типов ошибок',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildTestButton(
                          'Аутентификация\n(SnackBar)',
                          Colors.blue,
                          () => _testAuthenticationError(),
                        ),
                        _buildTestButton(
                          'Шифрование\n(Dialog)',
                          Colors.red,
                          () => _testEncryptionError(),
                        ),
                        _buildTestButton(
                          'Сеть\n(Banner)',
                          Colors.orange,
                          () => _testNetworkError(),
                        ),
                        _buildTestButton(
                          'Валидация\n(Inline)',
                          Colors.green,
                          () => _testValidationError(),
                        ),
                        _buildTestButton(
                          'База данных\n(Fullscreen)',
                          Colors.brown,
                          () => _testDatabaseError(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Секция тестирования Result<T>
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Тестирование Result<T>',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading
                                ? null
                                : () => _testSuccessfulOperation(),
                            icon: const Icon(Icons.check_circle),
                            label: const Text('Успешная операция'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[100],
                              foregroundColor: Colors.green[700],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading
                                ? null
                                : () => _testFailedOperation(),
                            icon: const Icon(Icons.error),
                            label: const Text('Операция с ошибкой'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[100],
                              foregroundColor: Colors.red[700],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading
                            ? null
                            : () => _testRetryOperation(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Операция с автоматическим retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple[100],
                          foregroundColor: Colors.purple[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Результат последней операции
            Card(
              color: Colors.grey.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[600]),
                        const SizedBox(width: 8),
                        Text(
                          'Результат последней операции',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_isLoading)
                      const Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Выполняется...'),
                        ],
                      )
                    else
                      Text(
                        _lastResultMessage,
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Статистика системы ошибок
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Статистика системы ошибок',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FutureBuilder<Map<String, Object>>(
                      future: _getErrorHandlerStats(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final stats = snapshot.data!;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Всего ошибок отслежено: ${stats['totalErrorsTracked'] ?? 0}',
                              ),
                              Text(
                                'Активных попыток повтора: ${stats['activeRetryAttempts'] ?? 0}',
                              ),
                              Text(
                                'Обработчиков восстановления: ${stats['recoveryHandlersCount'] ?? 0}',
                              ),
                            ],
                          );
                        } else {
                          return const Text('Загрузка статистики...');
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => setState(() {}),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Обновить статистику'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestButton(String title, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: 120,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.1),
          foregroundColor: _getDarkColor(color),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  Color _getDarkColor(Color color) {
    // Преобразование базового цвета в более темный оттенок
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - 0.3).clamp(0.0, 1.0)).toColor();
  }

  // Тестирование различных типов ошибок

  Future<void> _testAuthenticationError() async {
    final error = AuthenticationErrorV2(
      errorType: AuthenticationErrorType.invalidCredentials,
      message: 'Неверные учетные данные',
      username: 'test@example.com',
      attemptNumber: 3,
    );

    await ErrorDisplayV2.show(
      context,
      error,
      config: const ErrorDisplayConfigV2(
        type: ErrorDisplayType.snackbar,
        showSolution: true,
        showRetryButton: true,
      ),
      onRetry: () => _setResult(
        'Пользователь нажал "Повторить" для ошибки аутентификации',
      ),
    );
  }

  Future<void> _testEncryptionError() async {
    final error = EncryptionErrorV2(
      errorType: EncryptionErrorType.decryptionFailed,
      message: 'Ошибка расшифровки данных',
      algorithm: 'AES-256-GCM',
      keyId: 'user_key_123',
      technicalDetails:
          'javax.crypto.BadPaddingException: Given final block not properly padded',
    );

    await ErrorDisplayV2.show(
      context,
      error,
      config: ErrorDisplayConfigV2.critical(),
      onRetry: () => _setResult('Попытка восстановления ключа шифрования'),
      onReport: () => _setResult('Отчет об ошибке шифрования отправлен'),
    );
  }

  Future<void> _testNetworkError() async {
    final error = NetworkErrorV2(
      errorType: NetworkErrorType.noConnection,
      message: 'Нет подключения к интернету',
      url: 'https://api.codexa-pass.com/sync',
      method: 'POST',
    );

    await ErrorDisplayV2.show(
      context,
      error,
      config: const ErrorDisplayConfigV2(
        type: ErrorDisplayType.banner,
        duration: Duration(seconds: 8),
        showSolution: true,
        showRetryButton: true,
      ),
      onRetry: () => _setResult('Повторная попытка сетевого запроса'),
    );
  }

  Future<void> _testValidationError() async {
    final error = ValidationErrorV2(
      errorType: ValidationErrorType.weakPassword,
      message: 'Пароль слишком слабый',
      field: 'password',
      value: '123456',
      constraints: {
        'minLength': 8,
        'requireUppercase': true,
        'requireDigits': true,
        'requireSpecialChars': true,
      },
    );

    // Показываем как встроенный виджет в диалоге
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Пример встроенного виджета ошибки'),
        content: InlineErrorWidgetV2(
          error: error,
          config: const ErrorDisplayConfigV2(
            showSolution: true,
            isDismissible: true,
          ),
          onDismiss: () {
            Navigator.of(context).pop();
            _setResult('Встроенная ошибка валидации закрыта');
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  Future<void> _testDatabaseError() async {
    final error = DatabaseErrorV2(
      errorType: DatabaseErrorType.corruptedDatabase,
      message: 'База данных повреждена',
      tableName: 'passwords',
      technicalDetails: 'SQLite error: database disk image is malformed',
    );

    await ErrorDisplayV2.show(
      context,
      error,
      config: const ErrorDisplayConfigV2(
        type: ErrorDisplayType.fullscreen,
        showTechnicalDetails: true,
        showSolution: true,
        showRetryButton: true,
        showReportButton: true,
      ),
      onRetry: () => _setResult('Попытка восстановления базы данных'),
      onReport: () =>
          _setResult('Отчет о повреждении БД отправлен в службу поддержки'),
    );
  }

  // Тестирование Result<T> операций

  Future<void> _testSuccessfulOperation() async {
    setState(() => _isLoading = true);

    try {
      final result = await _performSuccessfulOperation();

      result.fold(
        (data) => _setResult('✅ Успешная операция: $data'),
        (error) =>
            _setResult('❌ Неожиданная ошибка: ${error.localizedMessage}'),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testFailedOperation() async {
    setState(() => _isLoading = true);

    try {
      final result = await _performFailedOperation();

      result.fold(
        (data) => _setResult('✅ Неожиданный успех: $data'),
        (error) => _setResult('❌ Ожидаемая ошибка: ${error.localizedMessage}'),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testRetryOperation() async {
    setState(() => _isLoading = true);

    try {
      final handler = getGlobalErrorHandler();

      final result = await handler.executeWithRetry(
        () async {
          return await _performUnreliableOperation();
        },
        maxRetries: 3,
        useExponentialBackoff: true,
      );

      result.fold(
        (data) => _setResult('✅ Операция с retry успешна: $data'),
        (error) => _setResult(
          '❌ Операция не удалась после 3 попыток: ${error.localizedMessage}',
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Вспомогательные методы

  Future<ResultV2<String>> _performSuccessfulOperation() async {
    await Future.delayed(const Duration(seconds: 1));
    return SuccessV2('Данные успешно получены');
  }

  Future<ResultV2<String>> _performFailedOperation() async {
    await Future.delayed(const Duration(seconds: 1));

    final error = NetworkErrorV2(
      errorType: NetworkErrorType.serverError,
      message: 'Сервер временно недоступен',
      statusCode: 503,
      url: '/api/test',
    );

    return FailureV2(error);
  }

  Future<String> _performUnreliableOperation() async {
    await Future.delayed(const Duration(milliseconds: 500));

    // 70% шанс неудачи для демонстрации retry логики
    if (DateTime.now().millisecond % 10 < 7) {
      throw NetworkErrorV2(
        errorType: NetworkErrorType.timeout,
        message: 'Время ожидания истекло',
        url: '/api/unreliable',
      );
    }

    return 'Операция выполнена после нескольких попыток';
  }

  Future<Map<String, Object>> _getErrorHandlerStats() async {
    try {
      final handler = getGlobalErrorHandler();
      return handler.getErrorStats();
    } catch (e) {
      return {'error': 'Не удалось получить статистику'};
    }
  }

  void _setResult(String message) {
    setState(() {
      _lastResultMessage =
          '[${DateTime.now().toString().substring(11, 19)}] $message';
    });

    AppLogger.instance.info('ErrorV2 Test: $message');
  }
}
