import 'package:flutter/material.dart';
import '../lib/core/logging/app_logger.dart';

void main() async {
  // Инициализируем Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();

  print('Testing AppLogger...');

  // Создаем экземпляр логгера
  final logger = AppLogger.instance;

  // Даем время на инициализацию
  await Future.delayed(Duration(seconds: 3));

  print('File logging ready: ${logger.isFileLoggingReady}');

  // Получаем путь к директории с логами
  final logDir = await logger.getLogDirectory();
  print('Log directory: $logDir');

  // Пробуем записать логи
  logger.debug('Test debug message from main');
  logger.info('Test info message from main');
  logger.warning('Test warning message from main');
  logger.error('Test error message from main');

  // Даем время на запись
  await Future.delayed(Duration(seconds: 2));

  // Проверяем файлы
  final logFiles = await logger.getLogFiles();
  print('Found ${logFiles.length} log files');

  for (final file in logFiles) {
    print('Log file: ${file.path}');
    if (await file.exists()) {
      final content = await file.readAsString();
      print('Content length: ${content.length} characters');
      print('Last 500 characters:');
      print(
        content.length > 500
            ? content.substring(content.length - 500)
            : content,
      );
    }
  }

  print('Test completed');
}
