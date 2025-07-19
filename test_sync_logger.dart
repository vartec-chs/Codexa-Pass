import 'package:flutter/widgets.dart';
import 'lib/core/logging/app_logger.dart';
import 'lib/core/logging/log_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('=== ТЕСТ СИНХРОННОЙ ИНИЦИАЛИЗАЦИИ ЛОГГЕРА ===\n');

  // Создаем логгер
  print('1. Создание экземпляра логгера...');
  final logger = AppLogger.instance;

  // Проверяем состояние до инициализации
  print(
    '   Состояние до ожидания: isFileLoggingReady = ${logger.isFileLoggingReady}',
  );

  // Ждем инициализации
  print('\n2. Ожидание завершения инициализации...');
  await logger.waitForInitialization();

  // Проверяем состояние после инициализации
  print(
    '   Состояние после ожидания: isFileLoggingReady = ${logger.isFileLoggingReady}',
  );

  // Теперь пробуем логировать информацию о приложении
  print('\n3. Логирование информации о приложении...');
  LogUtils.logAppInfo();

  // Записываем дополнительные сообщения
  logger.info('Тестовое сообщение после инициализации');
  logger.debug('Debug сообщение после инициализации');

  // Проверяем файлы
  print('\n4. Проверка созданных файлов...');
  final logDir = await logger.getLogDirectory();
  print('   Директория логов: $logDir');

  final logFiles = await logger.getLogFiles();
  print('   Найдено файлов: ${logFiles.length}');

  for (final file in logFiles) {
    if (await file.exists()) {
      final size = await file.length();
      print('   📄 ${file.path} (${size} байт)');

      if (size > 0) {
        final content = await file.readAsString();
        final lines = content
            .split('\n')
            .where((line) => line.isNotEmpty)
            .toList();
        print('   Количество строк в логе: ${lines.length}');

        // Показываем первые несколько строк
        print('   Первые строки лога:');
        for (int i = 0; i < 5 && i < lines.length; i++) {
          print('     ${lines[i]}');
        }

        if (lines.length > 5) {
          print('     ... (ещё ${lines.length - 5} строк)');
        }
      }
    }
  }

  print('\n✅ Тест завершен!');
}
