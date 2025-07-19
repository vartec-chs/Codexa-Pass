import 'package:flutter_test/flutter_test.dart';
import 'package:codexa_pass/core/logging/logging.dart';

void main() {
  group('SystemInfo Tests', () {
    test('SystemInfo initialization', () async {
      final systemInfo = SystemInfo.instance;

      // Инициализируем системную информацию
      await systemInfo.initialize();

      // Проверяем, что информация загружена
      expect(systemInfo.appName, isNotEmpty);
      expect(systemInfo.packageName, isNotEmpty);
      expect(systemInfo.version, isNotEmpty);
      expect(systemInfo.buildNumber, isNotEmpty);
      expect(systemInfo.platform, isNotEmpty);

      // Проверяем методы получения информации
      final shortInfo = systemInfo.getShortSystemInfo();
      expect(shortInfo, isNotEmpty);
      expect(shortInfo, contains(systemInfo.appName));
      expect(shortInfo, contains(systemInfo.version));

      final fullInfo = systemInfo.getSystemInfoString();
      expect(fullInfo, isNotEmpty);
      expect(fullInfo, contains('ИНФОРМАЦИЯ О ПРИЛОЖЕНИИ'));
      expect(fullInfo, contains('ИНФОРМАЦИЯ ОБ УСТРОЙСТВЕ'));

      final appInfo = systemInfo.getAppInfo();
      expect(appInfo, isA<Map<String, String>>());
      expect(appInfo['appName'], equals(systemInfo.appName));

      final platformInfo = systemInfo.getPlatformInfo();
      expect(platformInfo, isA<Map<String, String>>());
      expect(platformInfo['platform'], equals(systemInfo.platform));

      print('✅ SystemInfo test passed');
      print('Short info: $shortInfo');
    });

    test('LogUtils enhanced methods', () async {
      // Инициализируем системную информацию
      await LogUtils.initializeSystemInfo();

      // Тестируем новые методы логирования
      await LogUtils.logExtendedAppInfo();
      LogUtils.logShortSystemInfo();
      LogUtils.logBuildInfo();
      LogUtils.logEnvironmentInfo();

      // Тестируем создание заголовка лога
      final header = LogUtils.createLogHeader();
      expect(header, isNotEmpty);
      expect(header, contains('НОВАЯ СЕССИЯ ЛОГИРОВАНИЯ'));

      print('✅ LogUtils enhanced methods test passed');
    });

    test('LoggerInitializer enhanced methods', () async {
      // Тестируем новые методы инициализации
      await LoggerInitializer.initializeComplete();

      final logger = LoggerInitializer.logger;
      expect(logger, isA<AppLogger>());

      final safeLogger = LoggerInitializer.safeLogger;
      expect(safeLogger, isA<AppLogger>());

      final systemInfo = LoggerInitializer.systemInfo;
      expect(systemInfo, isA<SystemInfo>());

      print('✅ LoggerInitializer enhanced methods test passed');
    });

    test('Error logging with context', () async {
      await LogUtils.initializeSystemInfo();

      try {
        throw Exception('Test exception');
      } catch (e, stackTrace) {
        LogUtils.logCriticalErrorWithContext(
          'Test context',
          e,
          stackTrace,
          additionalInfo: {
            'testKey': 'testValue',
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
      }

      print('✅ Error logging with context test passed');
    });
  });

  group('Performance Tests', () {
    test('SystemInfo initialization performance', () async {
      final stopwatch = Stopwatch()..start();

      await SystemInfo.instance.initialize();

      stopwatch.stop();
      final duration = stopwatch.elapsedMilliseconds;

      print('SystemInfo initialization took ${duration}ms');
      expect(duration, lessThan(5000)); // Должно завершиться за 5 секунд
    });

    test('Log utils performance', () async {
      await LogUtils.initializeSystemInfo();

      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 100; i++) {
        LogUtils.logShortSystemInfo();
      }

      stopwatch.stop();
      final duration = stopwatch.elapsedMilliseconds;

      print('100 log entries took ${duration}ms');
      expect(duration, lessThan(1000)); // Должно завершиться за 1 секунду
    });
  });
}
