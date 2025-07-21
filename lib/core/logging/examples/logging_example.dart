/// Пример интеграции системы логгирования Codexa Pass
///
/// Демонстрирует все возможности системы логгирования:
/// - Инициализацию и конфигурацию
/// - Модульное логирование
/// - Интеграцию с Riverpod
/// - Логирование ошибок и производительности
/// - Использование в виджетах
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../logging.dart';

/// Пример инициализации логгера в main.dart
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

/// Пример провайдера с логированием
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

class UserRepository {
  late final ModuleLogger _logger;

  UserRepository() {
    // Можно получить логгер напрямую или через провайдер
    _logger = ModuleLogger(AppLogger.instance, 'UserRepository');
  }

  /// Пример метода с логированием производительности
  Future<User?> getUser(String userId) async {
    return await PerformanceLogger.measure('UserRepository.getUser', () async {
      await _logger.info('Fetching user', metadata: {'userId': userId});

      try {
        // Симуляция запроса
        await Future.delayed(const Duration(milliseconds: 500));

        final user = User(id: userId, name: 'John Doe');

        await _logger.info(
          'User fetched successfully',
          metadata: {'userId': userId, 'userName': user.name},
        );

        return user;
      } catch (e, stackTrace) {
        await _logger.error(
          'Failed to fetch user',
          error: e,
          stackTrace: stackTrace,
          metadata: {'userId': userId},
        );
        rethrow;
      }
    }, module: 'UserRepository');
  }

  /// Пример логирования с маскировкой чувствительных данных
  Future<void> updatePassword(String userId, String password) async {
    await _logger.info(
      'Updating user password',
      metadata: {
        'userId': userId,
        'password': password, // Будет автоматически замаскирован
        'action': 'updatePassword',
      },
    );

    // Логика обновления пароля...
  }
}

/// Модель пользователя
class User {
  final String id;
  final String name;

  User({required this.id, required this.name});
}

/// Пример виджета с логированием
class LoggedWidget extends ConsumerStatefulWidget {
  const LoggedWidget({super.key});

  @override
  ConsumerState<LoggedWidget> createState() => _LoggedWidgetState();
}

class _LoggedWidgetState extends ConsumerState<LoggedWidget> with LoggingMixin {
  @override
  void initState() {
    super.initState();
    // Инициализируем логгер для виджета
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initLogger(ref, 'LoggedWidget');
      logger.info('Widget initialized');
    });
  }

  @override
  void dispose() {
    logger.info('Widget disposed');
    super.dispose();
  }

  Future<void> _handleButtonPress() async {
    await logger.info('Button pressed');

    try {
      // Пример использования провайдера с логированием
      final userRepo = ref.read(userRepositoryProvider);
      final user = await userRepo.getUser('123');

      await logger.info('User loaded', metadata: {'user': user?.name});
    } catch (e, stackTrace) {
      await logger.error(
        'Failed to load user',
        error: e,
        stackTrace: stackTrace,
      );

      // Показываем снекбар с ошибкой
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to load user')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Logging Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _handleButtonPress,
              child: const Text('Load User'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _demonstrateLogLevels(),
              child: const Text('Demonstrate Log Levels'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _demonstrateError(),
              child: const Text('Demonstrate Error'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _demonstrateLogLevels() async {
    await logger.debug('This is a debug message');
    await logger.info('This is an info message');
    await logger.warning('This is a warning message');
    await logger.error('This is an error message');
    await logger.fatal('This is a fatal message');
  }

  Future<void> _demonstrateError() async {
    try {
      throw Exception('Demonstration error');
    } catch (e, stackTrace) {
      await logger.error(
        'Caught demonstration error',
        error: e,
        stackTrace: stackTrace,
        metadata: {'context': 'demonstration', 'userAction': 'button_press'},
      );
    }
  }
}

/// Пример HTTP логгера с Dio
class LoggedHttpClient {
  static void setupDioLogging() {
    // Пример интеграции с Dio (если используется)
    // dio.interceptors.add(InterceptorsWrapper(
    //   onRequest: (options, handler) {
    //     HttpLogger.logRequest(
    //       method: options.method,
    //       url: options.uri.toString(),
    //       headers: options.headers.cast<String, String>(),
    //       body: options.data,
    //     );
    //     handler.next(options);
    //   },
    //   onResponse: (response, handler) {
    //     HttpLogger.logResponse(
    //       method: response.requestOptions.method,
    //       url: response.requestOptions.uri.toString(),
    //       statusCode: response.statusCode ?? 0,
    //       headers: response.headers.map.cast<String, String>(),
    //       body: response.data,
    //     );
    //     handler.next(response);
    //   },
    //   onError: (error, handler) {
    //     HttpLogger.logError(
    //       method: error.requestOptions.method,
    //       url: error.requestOptions.uri.toString(),
    //       error: error,
    //     );
    //     handler.next(error);
    //   },
    // ));
  }
}

/// Пример провайдера с автоматическим логированием состояний
final counterProvider = StateNotifierProvider<CounterNotifier, int>((ref) {
  return CounterNotifier();
});

class CounterNotifier extends StateNotifier<int> {
  late final ModuleLogger _logger;

  CounterNotifier() : super(0) {
    _logger = ModuleLogger(AppLogger.instance, 'Counter');
    _logger.info('Counter initialized', metadata: {'initialValue': state});
  }

  void increment() {
    _logger.debug('Incrementing counter', metadata: {'currentValue': state});
    state++;
    _logger.info('Counter incremented', metadata: {'newValue': state});
  }

  void decrement() {
    _logger.debug('Decrementing counter', metadata: {'currentValue': state});
    state--;
    _logger.info('Counter decremented', metadata: {'newValue': state});
  }

  void reset() {
    final oldValue = state;
    state = 0;
    _logger.info(
      'Counter reset',
      metadata: {'oldValue': oldValue, 'newValue': state},
    );
  }
}

/// Пример использования в main.dart
/*
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализируем логгер
  await initializeLogging();

  // Настраиваем observer для автоматического логирования состояний
  final container = ProviderContainer(
    observers: [LoggingProviderObserver()],
  );

  // Логируем запуск приложения
  AppLifecycleLogger.logAppStart();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: MyApp(),
    ),
  );
}
*/
