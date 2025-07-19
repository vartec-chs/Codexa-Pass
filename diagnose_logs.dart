import 'dart:io';

// Симуляция AppConstants для теста
class AppConstants {
  static const String logPath = 'Codexa/logs';
  static const int maxLogFileSizeMB = 10;
  static const int maxLogFiles = 5;
}

void main() async {
  print('=== ДИАГНОСТИКА СОЗДАНИЯ ЛОГ ФАЙЛОВ ===\n');

  // Тест 1: Проверка получения директории документов
  print('1. Тестирование получения директории документов...');

  String? documentsPath;
  try {
    // Пытаемся получить стандартную директорию документов
    final String? userProfile = Platform.environment['USERPROFILE'];
    final String? home = Platform.environment['HOME'];

    if (userProfile != null) {
      documentsPath = '$userProfile\\Documents';
      print('   Найден USERPROFILE: $userProfile');
    } else if (home != null) {
      documentsPath = '$home/Documents';
      print('   Найден HOME: $home');
    } else {
      documentsPath = Directory.current.path;
      print('   Используется текущая директория: $documentsPath');
    }

    print('   Предполагаемая директория документов: $documentsPath');

    final Directory docDir = Directory(documentsPath);
    final bool docExists = await docDir.exists();
    print('   Директория документов существует: $docExists');
  } catch (e) {
    print('   ❌ Ошибка при получении директории документов: $e');
    return;
  }

  // Тест 2: Создание директории логов
  print('\n2. Тестирование создания директории логов...');

  final String logDirPath = '$documentsPath/${AppConstants.logPath}';
  print('   Путь к директории логов: $logDirPath');

  try {
    final Directory logDir = Directory(logDirPath);

    if (!await logDir.exists()) {
      print('   Создаем директорию логов...');
      await logDir.create(recursive: true);
    }

    final bool logDirExists = await logDir.exists();
    print('   Директория логов существует: $logDirExists');

    if (logDirExists) {
      // Проверяем права доступа
      try {
        final testFile = File('$logDirPath/test_access.tmp');
        await testFile.writeAsString('test');
        await testFile.delete();
        print('   ✅ Права на запись в директорию: OK');
      } catch (e) {
        print('   ❌ Ошибка прав доступа: $e');
      }
    }
  } catch (e) {
    print('   ❌ Ошибка при создании директории логов: $e');
    return;
  }

  // Тест 3: Создание файла лога
  print('\n3. Тестирование создания файла лога...');

  try {
    final String fileName =
        'app_${DateTime.now().toString().split(' ')[0]}.log';
    final String logFilePath = '$logDirPath/$fileName';
    final File logFile = File(logFilePath);

    print('   Путь к файлу лога: $logFilePath');

    if (!await logFile.exists()) {
      print('   Создаем файл лога...');
      await logFile.create();
    }

    final bool fileExists = await logFile.exists();
    print('   Файл лога существует: $fileExists');

    if (fileExists) {
      // Тестируем запись
      final String testMessage =
          '[${DateTime.now().toIso8601String()}] Тестовое сообщение\n';
      await logFile.writeAsString(testMessage, mode: FileMode.append);

      final int fileSize = await logFile.length();
      print('   Размер файла после записи: $fileSize байт');

      final String content = await logFile.readAsString();
      print('   Последние 100 символов содержимого:');
      print(
        '   ${content.length > 100 ? content.substring(content.length - 100) : content}',
      );

      print('   ✅ Запись в файл лога: OK');
    }
  } catch (e) {
    print('   ❌ Ошибка при работе с файлом лога: $e');
    return;
  }

  // Тест 4: Список файлов в директории
  print('\n4. Содержимое директории логов:');
  try {
    final Directory logDir = Directory(logDirPath);
    final List<FileSystemEntity> entities = await logDir.list().toList();

    if (entities.isEmpty) {
      print('   Директория пуста');
    } else {
      for (final entity in entities) {
        if (entity is File) {
          final stat = await entity.stat();
          print(
            '   📄 ${entity.path} (${stat.size} байт, изменен: ${stat.modified})',
          );
        } else {
          print('   📁 ${entity.path}');
        }
      }
    }
  } catch (e) {
    print('   ❌ Ошибка при чтении содержимого директории: $e');
  }

  print('\n=== ДИАГНОСТИКА ЗАВЕРШЕНА ===');
}
