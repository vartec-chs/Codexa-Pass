import 'dart:io';

// Простой тест без зависимостей Flutter
void main() async {
  print('Testing log file creation...');

  // Тестируем создание директории и файла
  try {
    // Получаем домашнюю директорию пользователя
    final String homeDir =
        Platform.environment['USERPROFILE'] ??
        Platform.environment['HOME'] ??
        '.';

    final String logPath = '$homeDir/Documents/Codexa/logs';
    final Directory logDir = Directory(logPath);

    print('Log directory path: $logPath');

    // Создаем директорию если она не существует
    if (!await logDir.exists()) {
      print('Creating log directory...');
      await logDir.create(recursive: true);
    }

    print('Directory exists: ${await logDir.exists()}');

    // Создаем тестовый файл лога
    final String fileName =
        'app_${DateTime.now().toString().split(' ')[0]}.log';
    final File logFile = File('$logPath/$fileName');

    print('Creating log file: ${logFile.path}');

    if (!await logFile.exists()) {
      await logFile.create();
    }

    // Записываем тестовое сообщение
    final String timestamp = DateTime.now().toIso8601String();
    final String testMessage = '[$timestamp] Test log message\n';

    await logFile.writeAsString(testMessage, mode: FileMode.append);

    print('Log file created and written to successfully!');
    print('File size: ${await logFile.length()} bytes');

    // Читаем содержимое файла
    final String content = await logFile.readAsString();
    print('File content:\n$content');
  } catch (e, stackTrace) {
    print('Error: $e');
    print('Stack trace: $stackTrace');
  }
}
