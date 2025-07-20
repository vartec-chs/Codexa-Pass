import 'lib/core/error/error_system.dart';

Future<void> main() async {
  print('=== Простой тест истории ошибок ===');

  // Создаем контроллер напрямую
  const config = ErrorConfig();
  const formatter = ErrorFormatter();

  final controller = ErrorController(config: config, formatter: formatter);

  try {
    // Инициализируем
    await controller.initialize();
    print('Контроллер инициализирован');

    // Проверяем начальное состояние
    print('Начальная история: ${controller.errorHistory.length}');

    // Создаем тестовую ошибку
    final testError = BaseAppError(
      code: 'TEST_ERROR',
      message: 'Тестовая ошибка',
      severity: ErrorSeverity.error,
      timestamp: DateTime.now(),
    );

    print('Добавляем ошибку: ${testError.code}');

    // Обрабатываем ошибку
    await controller.handleError(testError);

    // Проверяем историю
    print('История после добавления: ${controller.errorHistory.length}');

    if (controller.errorHistory.isNotEmpty) {
      print('Ошибки в истории:');
      for (var error in controller.errorHistory) {
        print('  - ${error.code}: ${error.message}');
      }
    } else {
      print('ПРОБЛЕМА: История пуста!');
    }
  } finally {
    await controller.dispose();
  }
}
