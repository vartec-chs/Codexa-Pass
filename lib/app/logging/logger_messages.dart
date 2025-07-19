import 'package:flutter/material.dart';
import '../../generated/l10n.dart';

/// Класс для получения локализованных сообщений логирования
class LoggerMessages {
  static LoggerMessages? _instance;
  BuildContext? _context;

  LoggerMessages._internal();

  static LoggerMessages get instance {
    _instance ??= LoggerMessages._internal();
    return _instance!;
  }

  /// Устанавливает контекст для локализации
  void setContext(BuildContext context) {
    _context = context;
  }

  /// Получить локализованные строки
  S? get _localizations {
    if (_context != null) {
      return S.of(_context!);
    }
    // Попытка получить текущую локализацию
    try {
      return S.current;
    } catch (e) {
      return null;
    }
  }

  /// Сообщения об ошибках с параметрами
  String logErrorInitFile(String error) =>
      _localizations?.logErrorInitFile(error) ??
      'Error initializing log file: $error';

  String logErrorRotation(String error) =>
      _localizations?.logErrorRotation(error) ?? 'Error rotating logs: $error';

  String logErrorDeletingOldFile(String error) =>
      _localizations?.logErrorDeletingOldFile(error) ??
      'Error deleting old log file: $error';

  String logErrorWritingToFile(String error) =>
      _localizations?.logErrorWritingToFile(error) ??
      'Error writing to log file: $error';

  /// Сообщения без параметров
  String get logErrorGettingDirectory =>
      _localizations?.logErrorGettingDirectory ?? 'Error getting log directory';

  String get logErrorGettingFileList =>
      _localizations?.logErrorGettingFileList ?? 'Error getting log file list';

  String get logAllFilesCleared =>
      _localizations?.logAllFilesCleared ?? 'All log files cleared';

  String get logErrorClearingFiles =>
      _localizations?.logErrorClearingFiles ?? 'Error clearing log files';
}
