import 'package:flutter/widgets.dart';
import 'package:codexa_pass/app/logging/app_logger.dart';

void main() async {
  // Инициализируем Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();

  print('=== ТЕСТ ЛОГГЕРА ===\n');

  try {
    // Создаем экземпляр логгера
    print('1. Создание экземпляра логгера...');
    final logger = AppLogger.instance;
    print('   Логгер создан');

    // Ждем инициализации
    print('\n2. Ожидание инициализации (5 секунд)...');
    await Future.delayed(Duration(seconds: 5));

    // Проверяем статус
    print('\n3. Проверка статуса логгера...');
    print('   File logging ready: ${logger.isFileLoggingReady}');

    // Получаем путь к логам
    final logDir = await logger.getLogDirectory();
    print('   Log directory: $logDir');

    // Записываем тестовые сообщения
    print('\n4. Запись тестовых сообщений...');
    logger.debug('🔍 Тестовое debug сообщение');
    logger.info('ℹ️ Тестовое info сообщение');
    logger.warning('⚠️ Тестовое warning сообщение');
    logger.error('❌ Тестовое error сообщение');
    print('   Сообщения отправлены в логгер');

    // Ждем записи
    print('\n5. Ожидание записи (3 секунды)...');
    await Future.delayed(Duration(seconds: 3));

    // Проверяем файлы
    print('\n6. Проверка созданных файлов...');
    final logFiles = await logger.getLogFiles();
    print('   Найдено файлов: ${logFiles.length}');

    for (final file in logFiles) {
      if (await file.exists()) {
        final size = await file.length();
        print('   📄 ${file.path} ($size байт)');

        if (size > 0) {
          final content = await file.readAsString();
          print('   Последние 200 символов:');
          print(
            '   ${content.length > 200 ? content.substring(content.length - 200) : content}',
          );
        }
      }
    }

    print('\n✅ Тест завершен!');
  } catch (e, stackTrace) {
    print('❌ Ошибка: $e');
    print('Stack trace: $stackTrace');
  }
}
