import 'dart:io';
import 'package:codexa_pass/core/config/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'logger_messages.dart';

/// Улучшенный файловый вывод для логгера с защитой от ошибок инициализации
class SafeFileOutput extends LogOutput {
  File? _file;
  final int _maxFileSizeMB;
  final int _maxFiles;
  bool _isInitialized = false;
  final List<String> _pendingLogs = [];

  SafeFileOutput({
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
        print('SafeFileOutput: Initializing log file...');
      }

      Directory? appDocDir;
      try {
        appDocDir = await getApplicationDocumentsDirectory();
      } catch (e) {
        if (kDebugMode) {
          print(
            'SafeFileOutput: Could not get application documents directory: $e',
          );
          print('SafeFileOutput: Using fallback directory');
        }
        // Fallback: use current directory or user home
        final String fallbackPath =
            Platform.environment['USERPROFILE'] ??
            Platform.environment['HOME'] ??
            Directory.current.path;
        appDocDir = Directory(fallbackPath);
      }

      if (kDebugMode) {
        print('SafeFileOutput: App documents directory: ${appDocDir.path}');
      }

      final Directory logDir = Directory(
        path.join(appDocDir.path, AppConstants.logPath),
      );

      if (kDebugMode) {
        print('SafeFileOutput: Log directory path: ${logDir.path}');
      }

      if (!await logDir.exists()) {
        if (kDebugMode) {
          print('SafeFileOutput: Creating log directory...');
        }
        await logDir.create(recursive: true);
      }

      final String fileName =
          'app_${DateTime.now().toString().split(' ')[0]}.log';
      _file = File(path.join(logDir.path, fileName));

      if (kDebugMode) {
        print('SafeFileOutput: Log file path: ${_file!.path}');
      }

      // Создаем файл, если он не существует
      if (!await _file!.exists()) {
        if (kDebugMode) {
          print('SafeFileOutput: Creating log file...');
        }
        await _file!.create();
      }

      // Проверяем размер файла и ротируем при необходимости
      await _rotateLogsIfNeeded(logDir);

      _isInitialized = true;

      // Записываем накопленные логи
      await _flushPendingLogs();

      if (kDebugMode) {
        print('SafeFileOutput: Log file initialized successfully');
      }
    } catch (e) {
      final String errorMessage = LoggerMessages.instance.logErrorInitFile(
        e.toString(),
      );
      if (kDebugMode) {
        print(errorMessage);
        print('SafeFileOutput Stack trace: ${StackTrace.current}');
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
      files.sort(
        (a, b) => b.statSync().modified.compareTo(a.statSync().modified),
      );

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

  Future<void> _flushPendingLogs() async {
    if (_pendingLogs.isNotEmpty && _file != null) {
      try {
        for (final logEntry in _pendingLogs) {
          await _file!.writeAsString(logEntry, mode: FileMode.append);
        }
        _pendingLogs.clear();
      } catch (e) {
        if (kDebugMode) {
          print('Failed to flush pending logs: $e');
        }
      }
    }
  }

  @override
  void output(OutputEvent event) {
    final String logEntry = event.lines.join('\n');
    final String timestamp = DateTime.now().toIso8601String();
    final String formattedEntry = '[$timestamp] $logEntry\n';

    if (_isInitialized && _file != null) {
      try {
        if (_file!.existsSync()) {
          _file!.writeAsStringSync(formattedEntry, mode: FileMode.append);
        }
      } catch (e) {
        // Если не удалось записать, добавляем в pending и выводим в консоль
        _pendingLogs.add(formattedEntry);
        if (kDebugMode) {
          print('LOG (write failed, cached): $logEntry');
        }
      }
    } else {
      // Если ещё не инициализированы, кешируем лог
      _pendingLogs.add(formattedEntry);
      if (kDebugMode) {
        print('LOG (cached): $logEntry');
      }
    }
  }

  bool get isInitialized => _isInitialized;
  int get pendingLogsCount => _pendingLogs.length;
}
