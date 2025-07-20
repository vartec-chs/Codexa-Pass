import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'lib/core/error/error_system.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Создаем контейнер для тестирования провайдеров
  final container = ProviderContainer();

  try {
    print('=== Тест истории ошибок ===');

    // Получаем контроллер
    final errorController = container.read(errorControllerProvider);

    // Ждем инициализации
    await Future.delayed(Duration(seconds: 1));

    // Проверяем начальное состояние
    print(
      'Начальное состояние истории: ${errorController.errorHistory.length}',
    );

    // Создаем тестовую ошибку
    final testError = BaseAppError(
      code: 'TEST_ERROR',
      message: 'Это тестовая ошибка',
      severity: ErrorSeverity.error,
      timestamp: DateTime.now(),
    );

    print('Создали тестовую ошибку: ${testError.code}');

    // Обрабатываем ошибку
    await errorController.handleError(testError);

    // Ждем обработки
    await Future.delayed(Duration(milliseconds: 500));

    // Проверяем историю
    print(
      'История после добавления ошибки: ${errorController.errorHistory.length}',
    );

    if (errorController.errorHistory.isNotEmpty) {
      print('Ошибки в истории:');
      for (var error in errorController.errorHistory) {
        print('  - ${error.code}: ${error.message}');
      }
    } else {
      print('ПРОБЛЕМА: История пуста!');
    }

    // Проверяем стрим
    print('\n=== Тест стрима истории ===');

    errorController.historyStream.listen(
      (history) {
        print('Стрим получил обновление: ${history.length} ошибок');
        for (var error in history) {
          print('  - ${error.code}: ${error.message}');
        }
      },
      onError: (error) {
        print('Ошибка в стриме: $error');
      },
    );

    // Добавляем еще одну ошибку
    final testError2 = BaseAppError(
      code: 'TEST_ERROR_2',
      message: 'Вторая тестовая ошибка',
      severity: ErrorSeverity.warning,
      timestamp: DateTime.now(),
    );

    print('\nДобавляем вторую ошибку...');
    await errorController.handleError(testError2);

    // Ждем обработки стрима
    await Future.delayed(Duration(seconds: 1));

    print(
      '\nФинальное состояние истории: ${errorController.errorHistory.length}',
    );
  } finally {
    container.dispose();
  }
}
