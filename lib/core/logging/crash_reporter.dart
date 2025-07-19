import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:codexa_pass/core/config/constants.dart';
import 'system_info.dart';
import 'app_logger.dart';

/// Типы краш-репортов
enum CrashType {
  flutter('flutter_error'),
  dart('dart_error'),
  native('native_error'),
  custom('custom_error'),
  fatal('fatal_error');

  const CrashType(this.folderName);
  final String folderName;
}

/// Модель краш-репорта
class CrashReport {
  final String id;
  final DateTime timestamp;
  final CrashType type;
  final String title;
  final String message;
  final String? stackTrace;
  final Map<String, dynamic> systemInfo;
  final Map<String, dynamic>? additionalData;

  CrashReport({
    required this.id,
    required this.timestamp,
    required this.type,
    required this.title,
    required this.message,
    this.stackTrace,
    required this.systemInfo,
    this.additionalData,
  });

  /// Создание краш-репорта из исключения
  factory CrashReport.fromException({
    required CrashType type,
    required String title,
    required dynamic exception,
    StackTrace? stackTrace,
    Map<String, dynamic>? additionalData,
  }) {
    final timestamp = DateTime.now();
    final id = _generateId(timestamp, type);

    return CrashReport(
      id: id,
      timestamp: timestamp,
      type: type,
      title: title,
      message: exception.toString(),
      stackTrace: stackTrace?.toString(),
      systemInfo: SystemInfo.instance.getPlatformInfo(),
      additionalData: additionalData,
    );
  }

  /// Генерация уникального ID для краш-репорта
  static String _generateId(DateTime timestamp, CrashType type) {
    final dateStr = timestamp
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-');
    return '${type.folderName}_$dateStr';
  }

  /// Преобразование в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'type': type.folderName,
      'title': title,
      'message': message,
      'stackTrace': stackTrace,
      'systemInfo': systemInfo,
      'additionalData': additionalData,
      'reportVersion': '1.0',
    };
  }

  /// Создание из JSON
  factory CrashReport.fromJson(Map<String, dynamic> json) {
    return CrashReport(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      type: CrashType.values.firstWhere(
        (t) => t.folderName == json['type'],
        orElse: () => CrashType.custom,
      ),
      title: json['title'],
      message: json['message'],
      stackTrace: json['stackTrace'],
      systemInfo: Map<String, dynamic>.from(json['systemInfo'] ?? {}),
      additionalData: json['additionalData'] != null
          ? Map<String, dynamic>.from(json['additionalData'])
          : null,
    );
  }

  /// Преобразование в читаемый текст
  String toReadableText() {
    final buffer = StringBuffer();

    buffer.writeln('=' * 80);
    buffer.writeln('КРАШ-РЕПОРТ: $title');
    buffer.writeln('=' * 80);
    buffer.writeln('ID: $id');
    buffer.writeln('Время: ${timestamp.toLocal()}');
    buffer.writeln('Тип: ${type.folderName}');
    buffer.writeln('');

    buffer.writeln('ОПИСАНИЕ ОШИБКИ:');
    buffer.writeln(message);
    buffer.writeln('');

    if (stackTrace != null) {
      buffer.writeln('СТЕК ВЫЗОВОВ:');
      buffer.writeln(stackTrace);
      buffer.writeln('');
    }

    buffer.writeln('СИСТЕМНАЯ ИНФОРМАЦИЯ:');
    systemInfo.forEach((key, value) {
      buffer.writeln('  $key: $value');
    });
    buffer.writeln('');

    if (additionalData != null && additionalData!.isNotEmpty) {
      buffer.writeln('ДОПОЛНИТЕЛЬНЫЕ ДАННЫЕ:');
      additionalData!.forEach((key, value) {
        buffer.writeln('  $key: $value');
      });
      buffer.writeln('');
    }

    buffer.writeln('=' * 80);
    return buffer.toString();
  }
}

/// Класс для управления краш-репортами
class CrashReporter {
  static CrashReporter? _instance;
  static const String _crashReportsFolder = 'crash_reports';
  static const int _maxCrashReports = 50;

  bool _isInitialized = false;
  String? _crashReportsPath;

  CrashReporter._internal();

  static CrashReporter get instance {
    _instance ??= CrashReporter._internal();
    return _instance!;
  }

  /// Инициализация краш-репортера
  Future<void> initialize() async {
    try {
      await _initializeCrashReportsDirectory();
      _isInitialized = true;

      if (kDebugMode) {
        print('CrashReporter: Инициализирован, путь: $_crashReportsPath');
      }
    } catch (e) {
      if (kDebugMode) {
        print('CrashReporter: Ошибка инициализации: $e');
      }
      _isInitialized = false;
    }
  }

  /// Создание директории для краш-репортов
  Future<void> _initializeCrashReportsDirectory() async {
    Directory? appDocDir;

    try {
      appDocDir = await getApplicationDocumentsDirectory();
    } catch (e) {
      // Fallback: использовать домашнюю директорию
      final String fallbackPath =
          Platform.environment['USERPROFILE'] ??
          Platform.environment['HOME'] ??
          Directory.current.path;
      appDocDir = Directory(fallbackPath);
    }

    final crashReportsDir = Directory(
      path.join(appDocDir.path, AppConstants.logPath, _crashReportsFolder),
    );

    if (!await crashReportsDir.exists()) {
      await crashReportsDir.create(recursive: true);
    }

    _crashReportsPath = crashReportsDir.path;

    // Создаем подпапки для разных типов ошибок
    for (final crashType in CrashType.values) {
      final typeDir = Directory(
        path.join(_crashReportsPath!, crashType.folderName),
      );
      if (!await typeDir.exists()) {
        await typeDir.create(recursive: true);
      }
    }
  }

  /// Сохранение краш-репорта
  Future<String?> saveCrashReport(CrashReport report) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (!_isInitialized || _crashReportsPath == null) {
      if (kDebugMode) {
        print(
          'CrashReporter: Не удалось сохранить краш-репорт - не инициализирован',
        );
      }
      return null;
    }

    try {
      final typeDir = Directory(
        path.join(_crashReportsPath!, report.type.folderName),
      );
      final fileName = '${report.id}.json';
      final filePath = path.join(typeDir.path, fileName);
      final file = File(filePath);

      // Сохраняем JSON
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(report.toJson()),
      );

      // Сохраняем читаемую версию
      final readableFileName = '${report.id}.txt';
      final readableFilePath = path.join(typeDir.path, readableFileName);
      final readableFile = File(readableFilePath);
      await readableFile.writeAsString(report.toReadableText());

      // Очищаем старые репорты
      await _cleanOldCrashReports(report.type);

      if (kDebugMode) {
        print('CrashReporter: Краш-репорт сохранен: $filePath');
      }

      return filePath;
    } catch (e) {
      if (kDebugMode) {
        print('CrashReporter: Ошибка сохранения краш-репорта: $e');
      }
      return null;
    }
  }

  /// Очистка старых краш-репортов
  Future<void> _cleanOldCrashReports(CrashType type) async {
    try {
      final typeDir = Directory(path.join(_crashReportsPath!, type.folderName));
      final files = typeDir
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.json'))
          .toList();

      if (files.length > _maxCrashReports) {
        // Сортируем по дате изменения
        files.sort(
          (a, b) => a.statSync().modified.compareTo(b.statSync().modified),
        );

        // Удаляем старые файлы
        for (int i = 0; i < files.length - _maxCrashReports; i++) {
          final jsonFile = files[i];
          final txtFile = File(jsonFile.path.replaceAll('.json', '.txt'));

          await jsonFile.delete();
          if (await txtFile.exists()) {
            await txtFile.delete();
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('CrashReporter: Ошибка очистки старых краш-репортов: $e');
      }
    }
  }

  /// Создание и сохранение краш-репорта из исключения
  Future<String?> reportCrash({
    required CrashType type,
    required String title,
    required dynamic exception,
    StackTrace? stackTrace,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      // Инициализируем SystemInfo если нужно
      if (SystemInfo.instance.appName == 'Unknown') {
        await SystemInfo.instance.initialize();
      }

      final report = CrashReport.fromException(
        type: type,
        title: title,
        exception: exception,
        stackTrace: stackTrace,
        additionalData: additionalData,
      );

      final filePath = await saveCrashReport(report);

      // Логируем в основной лог
      AppLogger.instance.fatal(
        '💥 КРАШ-РЕПОРТ СОЗДАН: ${report.title}',
        exception,
        stackTrace,
      );

      return filePath;
    } catch (e) {
      if (kDebugMode) {
        print('CrashReporter: Ошибка создания краш-репорта: $e');
      }
      return null;
    }
  }

  /// Получение списка всех краш-репортов
  Future<List<CrashReport>> getAllCrashReports() async {
    if (!_isInitialized || _crashReportsPath == null) {
      return [];
    }

    final reports = <CrashReport>[];

    try {
      for (final crashType in CrashType.values) {
        final typeDir = Directory(
          path.join(_crashReportsPath!, crashType.folderName),
        );
        if (await typeDir.exists()) {
          final files = typeDir.listSync().whereType<File>().where(
            (file) => file.path.endsWith('.json'),
          );

          for (final file in files) {
            try {
              final content = await file.readAsString();
              final json = jsonDecode(content) as Map<String, dynamic>;
              final report = CrashReport.fromJson(json);
              reports.add(report);
            } catch (e) {
              if (kDebugMode) {
                print(
                  'CrashReporter: Ошибка чтения краш-репорта ${file.path}: $e',
                );
              }
            }
          }
        }
      }

      // Сортируем по времени (новые сначала)
      reports.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      if (kDebugMode) {
        print('CrashReporter: Ошибка получения списка краш-репортов: $e');
      }
    }

    return reports;
  }

  /// Получение краш-репортов определенного типа
  Future<List<CrashReport>> getCrashReportsByType(CrashType type) async {
    final allReports = await getAllCrashReports();
    return allReports.where((report) => report.type == type).toList();
  }

  /// Получение количества краш-репортов по типам
  Future<Map<CrashType, int>> getCrashReportsCount() async {
    final counts = <CrashType, int>{};

    if (!_isInitialized || _crashReportsPath == null) {
      return counts;
    }

    for (final crashType in CrashType.values) {
      final typeDir = Directory(
        path.join(_crashReportsPath!, crashType.folderName),
      );
      if (await typeDir.exists()) {
        final files = typeDir
            .listSync()
            .whereType<File>()
            .where((file) => file.path.endsWith('.json'))
            .length;
        counts[crashType] = files;
      } else {
        counts[crashType] = 0;
      }
    }

    return counts;
  }

  /// Удаление всех краш-репортов
  Future<void> clearAllCrashReports() async {
    if (!_isInitialized || _crashReportsPath == null) {
      return;
    }

    try {
      for (final crashType in CrashType.values) {
        final typeDir = Directory(
          path.join(_crashReportsPath!, crashType.folderName),
        );
        if (await typeDir.exists()) {
          final files = typeDir.listSync().whereType<File>();
          for (final file in files) {
            await file.delete();
          }
        }
      }

      AppLogger.instance.info('🗑️ Все краш-репорты удалены');
    } catch (e) {
      if (kDebugMode) {
        print('CrashReporter: Ошибка очистки краш-репортов: $e');
      }
    }
  }

  /// Удаление краш-репортов определенного типа
  Future<void> clearCrashReportsByType(CrashType type) async {
    if (!_isInitialized || _crashReportsPath == null) {
      return;
    }

    try {
      final typeDir = Directory(path.join(_crashReportsPath!, type.folderName));
      if (await typeDir.exists()) {
        final files = typeDir.listSync().whereType<File>();
        for (final file in files) {
          await file.delete();
        }
      }

      AppLogger.instance.info(
        '🗑️ Краш-репорты типа ${type.folderName} удалены',
      );
    } catch (e) {
      if (kDebugMode) {
        print(
          'CrashReporter: Ошибка очистки краш-репортов типа ${type.folderName}: $e',
        );
      }
    }
  }

  /// Получение пути к директории краш-репортов
  String? get crashReportsPath => _crashReportsPath;

  /// Проверка инициализации
  bool get isInitialized => _isInitialized;
}
