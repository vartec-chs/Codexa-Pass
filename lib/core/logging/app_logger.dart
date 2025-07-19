import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Уровни логирования для приложения
enum AppLogLevel { debug, info, warning, error, fatal }

/// Кастомный принтер для логгера с поддержкой файлового вывода
class AppLogPrinter extends LogPrinter {
  final PrettyPrinter _prettyPrinter = PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    printTime: true,
  );

  @override
  List<String> log(LogEvent event) {
    return _prettyPrinter.log(event);
  }
}

/// Файловый вывод для логгера
class FileOutput extends LogOutput {
  late File _file;
  final int _maxFileSizeMB;
  final int _maxFiles;

  FileOutput({int maxFileSizeMB = 10, int maxFiles = 5})
    : _maxFileSizeMB = maxFileSizeMB,
      _maxFiles = maxFiles;

  @override
  Future<void> init() async {
    super.init();
    await _initFile();
  }

  Future<void> _initFile() async {
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final Directory logDir = Directory(
        path.join(appDocDir.path, 'Codexa', 'logs'),
      );

      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }

      final String fileName =
          'app_${DateTime.now().toString().split(' ')[0]}.log';
      _file = File(path.join(logDir.path, fileName));

      // Проверяем размер файла и ротируем при необходимости
      await _rotateLogsIfNeeded(logDir);
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка инициализации файла логов: $e');
      }
    }
  }

  Future<void> _rotateLogsIfNeeded(Directory logDir) async {
    try {
      if (await _file.exists()) {
        final fileStat = await _file.stat();
        final fileSizeMB = fileStat.size / (1024 * 1024);

        if (fileSizeMB > _maxFileSizeMB) {
          await _rotateLogFiles(logDir);
        }
      }

      // Удаляем старые файлы, оставляя только последние _maxFiles
      await _cleanOldLogFiles(logDir);
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка ротации логов: $e');
      }
    }
  }

  Future<void> _rotateLogFiles(Directory logDir) async {
    final String newFileName =
        'app_${DateTime.now().millisecondsSinceEpoch}.log';
    _file = File(path.join(logDir.path, newFileName));
  }

  Future<void> _cleanOldLogFiles(Directory logDir) async {
    final List<FileSystemEntity> files = logDir
        .listSync()
        .where((entity) => entity is File && entity.path.endsWith('.log'))
        .toList();

    if (files.length > _maxFiles) {
      // Сортируем файлы по дате последнего изменения
      files.sort(
        (a, b) => b.statSync().modified.compareTo(a.statSync().modified),
      );

      // Удаляем старые файлы
      for (int i = _maxFiles; i < files.length; i++) {
        try {
          await files[i].delete();
        } catch (e) {
          if (kDebugMode) {
            print('Ошибка удаления старого лог-файла: $e');
          }
        }
      }
    }
  }

  @override
  void output(OutputEvent event) {
    try {
      if (_file.existsSync()) {
        final String logEntry = event.lines.join('\n');
        final String timestamp = DateTime.now().toIso8601String();
        _file.writeAsStringSync(
          '[$timestamp] $logEntry\n',
          mode: FileMode.append,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка записи в лог-файл: $e');
      }
    }
  }
}

/// Основной класс для логирования в приложении
class AppLogger {
  static AppLogger? _instance;
  late Logger _logger;
  late FileOutput _fileOutput;

  AppLogger._internal() {
    _init();
  }

  static AppLogger get instance {
    _instance ??= AppLogger._internal();
    return _instance!;
  }

  void _init() {
    _fileOutput = FileOutput(maxFileSizeMB: 10, maxFiles: 5);

    _logger = Logger(
      printer: AppLogPrinter(),
      output: kDebugMode
          ? MultiOutput([ConsoleOutput(), _fileOutput])
          : _fileOutput,
      level: kDebugMode ? Level.debug : Level.info,
    );
  }

  /// Логирование отладочной информации
  void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Логирование информационных сообщений
  void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Логирование предупреждений
  void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Логирование ошибок
  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Логирование критических ошибок
  void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  /// Получение пути к директории с логами
  Future<String?> getLogDirectory() async {
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final Directory logDir = Directory(
        path.join(appDocDir.path, 'Codexa', 'logs'),
      );
      return logDir.path;
    } catch (e) {
      error('Ошибка получения директории логов', e);
      return null;
    }
  }

  /// Получение списка всех лог-файлов
  Future<List<File>> getLogFiles() async {
    try {
      final String? logDirPath = await getLogDirectory();
      if (logDirPath == null) return [];

      final Directory logDir = Directory(logDirPath);
      if (!await logDir.exists()) return [];

      return logDir
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.log'))
          .toList();
    } catch (e) {
      error('Ошибка получения списка лог-файлов', e);
      return [];
    }
  }

  /// Очистка всех лог-файлов
  Future<void> clearAllLogs() async {
    try {
      final List<File> logFiles = await getLogFiles();
      for (final File file in logFiles) {
        await file.delete();
      }
      info('Все лог-файлы очищены');
    } catch (e) {
      error('Ошибка очистки лог-файлов', e);
    }
  }

  /// Закрытие логгера
  void dispose() {
    _logger.close();
  }
}
