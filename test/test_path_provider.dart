import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main() async {
  // Инициализируем Flutter bindings для работы с path_provider
  WidgetsFlutterBinding.ensureInitialized();

  print('=== ТЕСТ PATH_PROVIDER ===\n');

  try {
    // Тестируем getApplicationDocumentsDirectory
    print('1. Получение директории документов приложения...');
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    print('   Путь: ${appDocDir.path}');
    print('   Существует: ${await appDocDir.exists()}');

    // Создаем тестовую директорию
    final Directory testDir = Directory('${appDocDir.path}/Codexa/logs');
    print('\n2. Создание директории логов...');
    print('   Путь: ${testDir.path}');

    if (!await testDir.exists()) {
      await testDir.create(recursive: true);
      print('   Директория создана');
    } else {
      print('   Директория уже существует');
    }

    // Создаем тестовый файл
    final File testFile = File(
      '${testDir.path}/test_${DateTime.now().millisecondsSinceEpoch}.log',
    );
    print('\n3. Создание тестового файла...');
    print('   Путь: ${testFile.path}');

    await testFile.writeAsString(
      '[${DateTime.now().toIso8601String()}] Тестовое сообщение path_provider\n',
    );

    print('   Файл создан');
    print('   Размер: ${await testFile.length()} байт');

    // Читаем содержимое
    final String content = await testFile.readAsString();
    print('   Содержимое: $content');

    print('\n✅ path_provider работает корректно!');
  } catch (e, stackTrace) {
    print('❌ Ошибка: $e');
    print('Stack trace: $stackTrace');
  }
}
