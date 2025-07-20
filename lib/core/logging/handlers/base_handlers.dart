import 'dart:developer' as developer;
import '../interfaces/logging_interfaces.dart';
import '../models/log_entry.dart';
import '../models/log_level.dart';
import '../formatters/log_formatters.dart';

/// Обработчик для вывода в консоль
class ConsoleLogHandler implements LogHandler {
  final LogLevel minLevel;
  final LogFormatter formatter;
  final bool enableColors;

  ConsoleLogHandler({
    this.minLevel = LogLevel.debug,
    LogFormatter? formatter,
    this.enableColors = true,
  }) : formatter =
           formatter ?? PrettyConsoleFormatter(enableColors: enableColors);

  @override
  Future<void> handle(LogEntry entry) async {
    if (!canHandle(entry.level)) return;

    final message = formatter.format(entry);

    // Используем developer.log для лучшей интеграции с DevTools
    developer.log(
      message,
      time: entry.timestamp,
      level: entry.level.value,
      name: entry.logger,
      error: entry.error,
      stackTrace: entry.stackTrace,
    );
  }

  @override
  Future<void> close() async {
    // Консоль не требует закрытия
  }

  @override
  bool canHandle(LogLevel level) {
    return level >= minLevel;
  }
}

/// Базовый класс для файловых обработчиков
abstract class BaseFileHandler implements LogHandler {
  final LogLevel minLevel;
  final LogFormatter formatter;
  final String filePath;

  BaseFileHandler({
    required this.filePath,
    this.minLevel = LogLevel.debug,
    LogFormatter? formatter,
  }) : formatter = formatter ?? const JsonFileFormatter();

  @override
  bool canHandle(LogLevel level) {
    return level >= minLevel;
  }

  /// Получить путь к файлу для записи
  String getFilePath(LogEntry entry);

  /// Записать строку в файл
  Future<void> writeToFile(String filePath, String content);

  /// Проверить и создать директорию если нужно
  Future<void> ensureDirectoryExists(String filePath);

  /// Ротация файлов
  Future<void> rotateFiles();

  @override
  Future<void> handle(LogEntry entry) async {
    if (!canHandle(entry.level)) return;

    final content = formatter.format(entry);
    final targetPath = getFilePath(entry);

    await ensureDirectoryExists(targetPath);
    await writeToFile(targetPath, content);
  }
}
