import 'package:flutter/widgets.dart';
import '../lib/core/logging/app_logger.dart';
import '../lib/core/logging/log_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('=== ФИНАЛЬНЫЙ ТЕСТ ЧИСТЫХ ЛОГОВ ===\n');

  // Создаем логгер и ждем инициализации
  final logger = AppLogger.instance;
  await logger.waitForInitialization();

  print('1. Логгер инициализирован: ${logger.isFileLoggingReady}');

  // Записываем тестовые сообщения
  print('\n2. Записываем тестовые сообщения...');
  logger.info('=== ТЕСТ ЧИСТЫХ ЛОГОВ ===');
  LogUtils.logAppInfo();
  logger.debug('🔍 Debug сообщение с эмодзи');
  logger.info('ℹ️ Info сообщение с эмодзи');
  logger.warning('⚠️ Warning сообщение с эмодзи');
  logger.error('❌ Error сообщение с эмодзи');
  logger.info('=== КОНЕЦ ТЕСТА ===');

  // Ждем записи
  await Future.delayed(Duration(seconds: 1));

  // Проверяем файлы
  print('\n3. Проверяем созданные файлы...');
  final logFiles = await logger.getLogFiles();

  if (logFiles.isNotEmpty) {
    final logFile = logFiles.first;
    print('   Файл лога: ${logFile.path}');
    print('   Размер файла: ${await logFile.length()} байт');

    // Читаем содержимое
    final content = await logFile.readAsString();
    final lines = content.split('\n').where((line) => line.isNotEmpty).toList();

    print('   Количество строк: ${lines.length}');
    print('\n4. Последние 10 строк лога:');

    final startIndex = lines.length > 10 ? lines.length - 10 : 0;
    for (int i = startIndex; i < lines.length; i++) {
      print('   ${i + 1}: ${lines[i]}');
    }

    // Проверяем на наличие ANSI кодов
    final bool hasAnsiCodes = content.contains(
      RegExp(r'\x1B\[[0-9;]*[a-zA-Z]'),
    );
    print('\n5. Содержит ANSI коды: $hasAnsiCodes');

    if (!hasAnsiCodes) {
      print('   ✅ Лог файл чистый от ANSI кодов!');
    } else {
      print('   ❌ В лог файле остались ANSI коды!');
    }
  } else {
    print('   ❌ Файлы логов не найдены!');
  }

  print('\n=== ТЕСТ ЗАВЕРШЕН ===');
}
