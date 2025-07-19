import 'package:flutter_test/flutter_test.dart';
import 'package:codexa_pass/core/logging/logging.dart';

void main() {
  group('CrashReporter Tests', () {
    test('CrashReporter initialization', () async {
      final crashReporter = CrashReporter.instance;

      // Инициализируем краш-репортер
      await crashReporter.initialize();

      // Проверяем, что инициализация прошла успешно
      expect(crashReporter.isInitialized, isTrue);

      print('✅ CrashReporter initialization test passed');
    });

    test('CrashReport creation and serialization', () {
      final testError = Exception('Test exception');

      final report = CrashReport.fromException(
        type: CrashType.custom,
        title: 'Test Crash Report',
        exception: testError,
        stackTrace: StackTrace.current,
        additionalData: {'testKey': 'testValue', 'userId': '12345'},
      );

      // Проверяем базовые свойства
      expect(report.type, equals(CrashType.custom));
      expect(report.title, equals('Test Crash Report'));
      expect(report.message, equals(testError.toString()));
      expect(report.stackTrace, isNotNull);
      expect(report.additionalData, isNotNull);
      expect(report.additionalData!['testKey'], equals('testValue'));

      // Тестируем сериализацию в JSON
      final json = report.toJson();
      expect(json, isA<Map<String, dynamic>>());
      expect(json['title'], equals('Test Crash Report'));
      expect(json['type'], equals('custom_error'));

      // Тестируем десериализацию из JSON
      final reportFromJson = CrashReport.fromJson(json);
      expect(reportFromJson.title, equals(report.title));
      expect(reportFromJson.type, equals(report.type));
      expect(reportFromJson.message, equals(report.message));

      // Тестируем преобразование в читаемый текст
      final readableText = report.toReadableText();
      expect(readableText, isNotEmpty);
      expect(readableText, contains('КРАШ-РЕПОРТ'));
      expect(readableText, contains(report.title));
      expect(readableText, contains(report.message));

      print('✅ CrashReport creation and serialization test passed');
    });

    test('LogUtils crash reporting methods', () async {
      // Инициализируем системную информацию
      await LogUtils.initializeSystemInfo();

      final testError = Exception('Test LogUtils crash');

      // Тестируем различные типы краш-репортов
      final flutterCrashPath = await LogUtils.reportFlutterCrash(
        'Flutter Test Crash',
        testError,
        StackTrace.current,
        additionalInfo: {'source': 'test'},
      );
      expect(flutterCrashPath, isNotNull);

      final dartCrashPath = await LogUtils.reportDartCrash(
        'Dart Test Crash',
        testError,
        StackTrace.current,
        additionalInfo: {'source': 'test'},
      );
      expect(dartCrashPath, isNotNull);

      final customCrashPath = await LogUtils.reportCustomCrash(
        'Custom Test Crash',
        testError,
        stackTrace: StackTrace.current,
        additionalInfo: {'source': 'test'},
      );
      expect(customCrashPath, isNotNull);

      // Проверяем статистику
      final stats = await LogUtils.getCrashReportsStatistics();
      expect(stats, isA<Map<CrashType, int>>());
      expect(stats[CrashType.flutter], greaterThan(0));
      expect(stats[CrashType.dart], greaterThan(0));
      expect(stats[CrashType.custom], greaterThan(0));

      print('✅ LogUtils crash reporting methods test passed');
      print('Stats: $stats');
    });

    test('CrashReporter file management', () async {
      final crashReporter = CrashReporter.instance;

      // Инициализируем краш-репортер
      await crashReporter.initialize();

      // Создаем несколько тестовых краш-репортов
      for (int i = 0; i < 5; i++) {
        final report = CrashReport.fromException(
          type: CrashType.custom,
          title: 'Test Crash $i',
          exception: Exception('Test exception $i'),
          stackTrace: StackTrace.current,
          additionalData: {'index': i},
        );

        final path = await crashReporter.saveCrashReport(report);
        expect(path, isNotNull);
      }

      // Получаем все краш-репорты
      final allReports = await crashReporter.getAllCrashReports();
      expect(allReports.length, greaterThanOrEqualTo(5));

      // Получаем краш-репорты по типу
      final customReports = await crashReporter.getCrashReportsByType(
        CrashType.custom,
      );
      expect(customReports.length, greaterThanOrEqualTo(5));

      // Получаем статистику
      final counts = await crashReporter.getCrashReportsCount();
      expect(counts[CrashType.custom], greaterThanOrEqualTo(5));

      print('✅ CrashReporter file management test passed');
      print('Total reports: ${allReports.length}');
      print('Custom reports: ${customReports.length}');
    });

    test('CrashReporter cleanup operations', () async {
      final crashReporter = CrashReporter.instance;

      // Инициализируем краш-репортер
      await crashReporter.initialize();

      // Создаем тестовые краш-репорты разных типов
      await LogUtils.reportCustomCrash('Test Custom 1', Exception('Test'));
      await LogUtils.reportFlutterCrash(
        'Test Flutter 1',
        Exception('Test'),
        StackTrace.current,
      );

      // Проверяем, что репорты созданы
      final statsBeforeClear = await crashReporter.getCrashReportsCount();
      expect(statsBeforeClear[CrashType.custom], greaterThan(0));
      expect(statsBeforeClear[CrashType.flutter], greaterThan(0));

      // Очищаем только custom репорты
      await crashReporter.clearCrashReportsByType(CrashType.custom);

      final statsAfterPartialClear = await crashReporter.getCrashReportsCount();
      expect(statsAfterPartialClear[CrashType.custom], equals(0));
      expect(statsAfterPartialClear[CrashType.flutter], greaterThan(0));

      // Очищаем все репорты
      await crashReporter.clearAllCrashReports();

      final statsAfterFullClear = await crashReporter.getCrashReportsCount();
      statsAfterFullClear.values.forEach((count) {
        expect(count, equals(0));
      });

      print('✅ CrashReporter cleanup operations test passed');
    });
  });

  group('Performance Tests', () {
    test('CrashReporter performance', () async {
      final crashReporter = CrashReporter.instance;
      await crashReporter.initialize();

      final stopwatch = Stopwatch()..start();

      // Создаем 10 краш-репортов
      for (int i = 0; i < 10; i++) {
        await LogUtils.reportCustomCrash(
          'Performance Test $i',
          Exception('Performance test exception $i'),
          additionalInfo: {'iteration': i},
        );
      }

      stopwatch.stop();
      final duration = stopwatch.elapsedMilliseconds;

      print('Creating 10 crash reports took ${duration}ms');
      expect(duration, lessThan(5000)); // Должно завершиться за 5 секунд

      // Проверяем загрузку репортов
      stopwatch.reset();
      stopwatch.start();

      final reports = await crashReporter.getAllCrashReports();

      stopwatch.stop();
      final loadDuration = stopwatch.elapsedMilliseconds;

      print('Loading ${reports.length} crash reports took ${loadDuration}ms');
      expect(loadDuration, lessThan(2000)); // Должно завершиться за 2 секунды
    });
  });
}
