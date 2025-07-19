import 'dart:io';

void main() async {
  print('=== ТЕСТ УДАЛЕНИЯ ANSI КОДОВ ===\n');

  // Тестовая строка с настоящими ANSI escape-кодами
  final String testWithAnsi =
      '\x1B[38;5;12m┌───────────────────────\x1B[0m\n'
      '\x1B[38;5;12m│ #0   AppLogPrinter.log\x1B[0m\n'
      '\x1B[38;5;12m├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄\x1B[0m\n'
      '\x1B[38;5;12m│ 💡 === Запуск приложения ===\x1B[0m\n'
      '\x1B[38;5;12m└───────────────────────\x1B[0m';

  print('Исходная строка с ANSI кодами:');
  print(testWithAnsi);
  print('\nДлина исходной строки: ${testWithAnsi.length} символов');

  // Функция удаления ANSI кодов (улучшенная)
  String removeAnsiEscapeCodes(String text) {
    // Более полное регулярное выражение для всех ANSI escape-кодов
    final ansiRegex = RegExp(r'\x1B\[[0-9;]*[a-zA-Z]');
    return text.replaceAll(ansiRegex, '');
  }

  // Очищаем строку
  final String cleanString = removeAnsiEscapeCodes(testWithAnsi);

  print('\n=== РЕЗУЛЬТАТ ===');
  print('Очищенная строка:');
  print(cleanString);
  print('\nДлина очищенной строки: ${cleanString.length} символов');
  print('Удалено символов: ${testWithAnsi.length - cleanString.length}');

  // Проверяем что ANSI коды действительно удалились
  final bool hasAnsiCodes = cleanString.contains(
    RegExp(r'\x1B\[[0-9;]*[a-zA-Z]'),
  );
  print('Остались ANSI коды: $hasAnsiCodes');

  if (!hasAnsiCodes) {
    print('\n✅ ANSI коды успешно удалены!');
  } else {
    print('\n❌ ANSI коды не были полностью удалены!');
  }

  // Тестируем запись в файл
  print('\n=== ТЕСТ ЗАПИСИ В ФАЙЛ ===');

  try {
    final File testFile = File('test_clean_log.txt');
    final String timestamp = DateTime.now().toIso8601String();
    final String logEntry = '[$timestamp] $cleanString\n';

    await testFile.writeAsString(logEntry);

    print('Файл создан: ${testFile.path}');
    print('Размер файла: ${await testFile.length()} байт');

    // Читаем обратно и проверяем
    final String fileContent = await testFile.readAsString();
    print('Содержимое файла:');
    print(fileContent);

    // Удаляем тестовый файл
    await testFile.delete();
    print('\nТестовый файл удален.');
  } catch (e) {
    print('Ошибка при работе с файлом: $e');
  }
}
