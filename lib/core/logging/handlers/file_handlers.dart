import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';
import '../models/log_entry.dart';
import '../models/log_level.dart';
import '../formatters/log_formatters.dart';
import 'base_handlers.dart';

/// Обработчик для записи в файлы по датам
class DateFileHandler extends BaseFileHandler {
  final String logDirectory;
  final int maxFileSizeMB;
  final int maxFileAgeDays;

  DateFileHandler({
    required this.logDirectory,
    this.maxFileSizeMB = 10,
    this.maxFileAgeDays = 30,
    super.minLevel,
    super.formatter,
  }) : super(filePath: logDirectory);

  @override
  String getFilePath(LogEntry entry) {
    final dateStr = DateFormat('yyyy-MM-dd').format(entry.timestamp);
    return path.join(logDirectory, '$dateStr.log');
  }

  @override
  Future<void> ensureDirectoryExists(String filePath) async {
    final dir = Directory(path.dirname(filePath));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }

  @override
  Future<void> writeToFile(String filePath, String content) async {
    try {
      final file = File(filePath);

      // Проверяем размер файла
      if (await file.exists()) {
        final stat = await file.stat();
        if (stat.size > maxFileSizeMB * 1024 * 1024) {
          await _rotateFile(file);
        }
      }

      // Записываем с разделителем для красивого вывода JSON
      final separator = '${'-' * 80}\n';
      final formattedContent = '$separator$content\n$separator\n';
      await file.writeAsString(formattedContent, mode: FileMode.append);
    } catch (e) {
      // В случае ошибки записи выводим в консоль
      print('Failed to write log to file: $e');
    }
  }

  Future<void> _rotateFile(File file) async {
    try {
      final timestamp = DateFormat('HHmmss').format(DateTime.now());
      final baseName = path.basenameWithoutExtension(file.path);
      final extension = path.extension(file.path);
      final directory = path.dirname(file.path);

      final rotatedPath = path.join(
        directory,
        '${baseName}_$timestamp$extension',
      );
      await file.rename(rotatedPath);
    } catch (e) {
      print('Failed to rotate log file: $e');
    }
  }

  @override
  Future<void> rotateFiles() async {
    try {
      final logsDir = Directory(path.join(logDirectory));
      if (!await logsDir.exists()) return;

      final cutoffDate = DateTime.now().subtract(
        Duration(days: maxFileAgeDays),
      );

      await for (final entity in logsDir.list()) {
        if (entity is File) {
          final stat = await entity.stat();
          if (stat.modified.isBefore(cutoffDate)) {
            await entity.delete();
          }
        }
      }
    } catch (e) {
      print('Failed to rotate old log files: $e');
    }
  }

  @override
  Future<void> close() async {
    await rotateFiles();
  }

  /// Получить общий размер всех лог файлов
  Future<int> getTotalLogSize() async {
    try {
      final logsDir = Directory(path.join(logDirectory));
      if (!await logsDir.exists()) return 0;

      int totalSize = 0;
      await for (final entity in logsDir.list()) {
        if (entity is File) {
          final stat = await entity.stat();
          totalSize += stat.size;
        }
      }
      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  /// Очистить старые файлы если превышен лимит размера
  Future<void> cleanupBySize() async {
    try {
      final totalSize = await getTotalLogSize();
      final maxSizeBytes = maxFileSizeMB * 1024 * 1024;

      if (totalSize <= maxSizeBytes) return;

      final logsDir = Directory(path.join(logDirectory));
      final files = <File>[];

      await for (final entity in logsDir.list()) {
        if (entity is File) {
          files.add(entity);
        }
      }

      // Сортируем по дате модификации (старые первые)
      files.sort(
        (a, b) => a.statSync().modified.compareTo(b.statSync().modified),
      );

      int currentSize = totalSize;
      for (final file in files) {
        if (currentSize <= maxSizeBytes) break;

        final fileSize = file.statSync().size;
        await file.delete();
        currentSize -= fileSize;
      }
    } catch (e) {
      print('Failed to cleanup logs by size: $e');
    }
  }
}

/// Обработчик для краш репортов
class CrashReportHandler extends BaseFileHandler {
  final String crashDirectory;

  CrashReportHandler({
    required this.crashDirectory,
    super.minLevel = LogLevel.error,
  }) : super(
         filePath: crashDirectory,
         formatter: const JsonFileFormatter(prettyPrint: true),
       );

  @override
  String getFilePath(LogEntry entry) {
    final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(entry.timestamp);
    final levelName = entry.level.name.toLowerCase();
    return path.join(crashDirectory, '${timestamp}_$levelName.json');
  }

  @override
  Future<void> ensureDirectoryExists(String filePath) async {
    final dir = Directory(path.dirname(filePath));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }

  @override
  Future<void> writeToFile(String filePath, String content) async {
    try {
      final file = File(filePath);
      // Добавляем заголовок для краш репорта
      final header =
          '// Crash Report Generated: ${DateTime.now().toIso8601String()}\n';
      final footer = '\n// End of Crash Report\n';
      await file.writeAsString('$header$content$footer');
    } catch (e) {
      print('Failed to write crash report: $e');
    }
  }

  @override
  Future<void> rotateFiles() async {
    try {
      final crashDir = Directory(path.join(crashDirectory));
      if (!await crashDir.exists()) return;

      final cutoffDate = DateTime.now().subtract(
        const Duration(days: 90),
      ); // Храним краши дольше

      await for (final entity in crashDir.list()) {
        if (entity is File) {
          final stat = await entity.stat();
          if (stat.modified.isBefore(cutoffDate)) {
            await entity.delete();
          }
        }
      }
    } catch (e) {
      print('Failed to rotate crash reports: $e');
    }
  }

  @override
  Future<void> close() async {
    await rotateFiles();
  }

  @override
  bool canHandle(LogLevel level) {
    // Обрабатываем только ошибки и фатальные события
    return level >= LogLevel.error;
  }
}
