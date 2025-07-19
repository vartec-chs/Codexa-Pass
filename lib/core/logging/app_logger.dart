import 'dart:async';
import 'dart:io';
import 'package:codexa_pass/core/config/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'logger_messages.dart';
import 'safe_file_output.dart';

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
  File? _file;
  final int _maxFileSizeMB;
  final int _maxFiles;
  bool _isInitialized = false;

  FileOutput({
    int maxFileSizeMB = AppConstants.maxLogFileSizeMB,
    int maxFiles = AppConstants.maxLogFiles,
  }) : _maxFileSizeMB = maxFileSizeMB,
       _maxFiles = maxFiles;

  @override
  Future<void> init() async {
    super.init();
    await _initFile();
  }

  Future<void> _initFile() async {
    try {
      if (kDebugMode) {
        print('Initializing log file...');
      }

      Directory? appDocDir;
      try {
        appDocDir = await getApplicationDocumentsDirectory();
      } catch (e) {
        if (kDebugMode) {
          print('Could not get application documents directory: $e');
          print('Using fallback directory');
        }
        // Fallback: use current directory or user home
        final String fallbackPath =
            Platform.environment['USERPROFILE'] ??
            Platform.environment['HOME'] ??
            Directory.current.path;
        appDocDir = Directory(fallbackPath);
      }

      if (kDebugMode) {
        print('App documents directory: ${appDocDir.path}');
      }

      final Directory logDir = Directory(
        path.join(appDocDir.path, AppConstants.logPath),
      );

      if (kDebugMode) {
        print('Log directory path: ${logDir.path}');
      }

      if (!await logDir.exists()) {
        if (kDebugMode) {
          print('Creating log directory...');
        }
        await logDir.create(recursive: true);
      }

      final String fileName =
          'app_${DateTime.now().toString().split(' ')[0]}.log';
      _file = File(path.join(logDir.path, fileName));

      if (kDebugMode) {
        print('Log file path: ${_file!.path}');
      }

      // Создаем файл, если он не существует
      if (!await _file!.exists()) {
        if (kDebugMode) {
          print('Creating log file...');
        }
        await _file!.create();
      }

      // Проверяем размер файла и ротируем при необходимости
      await _rotateLogsIfNeeded(logDir);

      _isInitialized = true;

      if (kDebugMode) {
        print('Log file initialized successfully');
      }
    } catch (e) {
      final String errorMessage = LoggerMessages.instance.logErrorInitFile(
        e.toString(),
      );
      if (kDebugMode) {
        print(errorMessage);
        print('Stack trace: ${StackTrace.current}');
      }
      _isInitialized = false;
    }
  }

  Future<void> _rotateLogsIfNeeded(Directory logDir) async {
    try {
      if (_file != null && await _file!.exists()) {
        final fileStat = await _file!.stat();
        final fileSizeMB = fileStat.size / (1024 * 1024);

        if (fileSizeMB > _maxFileSizeMB) {
          await _rotateLogFiles(logDir);
        }
      }

      // Удаляем старые файлы, оставляя только последние _maxFiles
      await _cleanOldLogFiles(logDir);
    } catch (e) {
      final String errorMessage = LoggerMessages.instance.logErrorRotation(
        e.toString(),
      );
      if (kDebugMode) {
        print(errorMessage);
      }
    }
  }

  Future<void> _rotateLogFiles(Directory logDir) async {
    final String newFileName =
        'app_${DateTime.now().millisecondsSinceEpoch}.log';
    _file = File(path.join(logDir.path, newFileName));

    // Создаем новый файл
    if (!await _file!.exists()) {
      await _file!.create();
    }
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
          final String errorMessage = LoggerMessages.instance
              .logErrorDeletingOldFile(e.toString());
          if (kDebugMode) {
            print(errorMessage);
          }
        }
      }
    }
  }

  @override
  void output(OutputEvent event) {
    try {
      if (_isInitialized && _file != null) {
        final String logEntry = event.lines.join('\n');
        final String timestamp = DateTime.now().toIso8601String();
        _file!.writeAsStringSync(
          '[$timestamp] $logEntry\n',
          mode: FileMode.append,
        );
      } else if (!_isInitialized) {
        // Если файл ещё не инициализирован, выводим в консоль в debug режиме
        if (kDebugMode) {
          print('LOG (not initialized): ${event.lines.join('\n')}');
        }
      }
    } catch (e) {
      final String errorMessage = LoggerMessages.instance.logErrorWritingToFile(
        e.toString(),
      );
      if (kDebugMode) {
        print(errorMessage);
      }
    }
  }
}

/// Основной класс для логирования в приложении
class AppLogger {
  static AppLogger? _instance;
  late Logger _logger;
  late LogOutput _fileOutput;
  Completer<void>? _initCompleter;

  AppLogger._internal({bool useSafeFileOutput = false}) {
    _init(useSafeFileOutput: useSafeFileOutput);
  }

  static AppLogger get instance {
    _instance ??= AppLogger._internal();
    return _instance!;
  }

  /// Создает новый экземпляр с безопасным файловым выводом
  static AppLogger createSafe() {
    return AppLogger._internal(useSafeFileOutput: true);
  }

  /// Ожидание завершения инициализации
  Future<void> waitForInitialization() async {
    if (_initCompleter != null) {
      try {
        await _initCompleter!.future.timeout(
          Duration(seconds: 10),
          onTimeout: () {
            if (kDebugMode) {
              print('AppLogger: Initialization timeout after 10 seconds');
            }
            throw TimeoutException(
              'Logger initialization timeout',
              Duration(seconds: 10),
            );
          },
        );
      } catch (e) {
        if (kDebugMode) {
          print('AppLogger: Error during initialization: $e');
        }
        // Даже если инициализация не удалась, продолжаем работу
        // Логи будут выводиться только в консоль
      }
    }
  }

  void _init({bool useSafeFileOutput = false}) {
    _initCompleter = Completer<void>();

    if (kDebugMode) {
      print(
        'AppLogger: Initializing logger with useSafeFileOutput=$useSafeFileOutput',
      );
    }

    if (useSafeFileOutput) {
      _fileOutput = SafeFileOutput(
        maxFileSizeMB: AppConstants.maxLogFileSizeMB,
        maxFiles: AppConstants.maxLogFiles,
      );
    } else {
      _fileOutput = FileOutput(
        maxFileSizeMB: AppConstants.maxLogFileSizeMB,
        maxFiles: AppConstants.maxLogFiles,
      );
    }

    _logger = Logger(
      printer: AppLogPrinter(),
      output: kDebugMode
          ? MultiOutput([ConsoleOutput(), _fileOutput])
          : _fileOutput,
      level: kDebugMode ? Level.debug : Level.info,
    );

    // Инициализируем файловый вывод асинхронно
    _initializeFileOutput();
  }

  void _initializeFileOutput() async {
    try {
      await _fileOutput.init();
      _initCompleter!.complete();
      if (kDebugMode) {
        print('AppLogger: Logger initialized successfully');
      }
    } catch (error) {
      _initCompleter!.completeError(error);
      if (kDebugMode) {
        print('Failed to initialize file output: $error');
      }
    }
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

  /// Проверка готовности файлового логирования
  bool get isFileLoggingReady {
    if (_fileOutput is FileOutput) {
      return (_fileOutput as FileOutput)._isInitialized;
    } else if (_fileOutput is SafeFileOutput) {
      return (_fileOutput as SafeFileOutput).isInitialized;
    }
    return false;
  }

  /// Получение пути к директории с логами
  Future<String?> getLogDirectory() async {
    try {
      Directory? appDocDir;
      try {
        appDocDir = await getApplicationDocumentsDirectory();
      } catch (e) {
        // Fallback: use current directory or user home
        final String fallbackPath =
            Platform.environment['USERPROFILE'] ??
            Platform.environment['HOME'] ??
            Directory.current.path;
        appDocDir = Directory(fallbackPath);
      }

      final Directory logDir = Directory(
        path.join(appDocDir.path, AppConstants.logPath),
      );
      return logDir.path;
    } catch (e) {
      error(LoggerMessages.instance.logErrorGettingDirectory, e);
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
      error(LoggerMessages.instance.logErrorGettingFileList, e);
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
      info(LoggerMessages.instance.logAllFilesCleared);
    } catch (e) {
      error(LoggerMessages.instance.logErrorClearingFiles, e);
    }
  }

  /// Закрытие логгера
  void dispose() {
    _logger.close();
  }
}
