import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codexa_pass/core/error/error_system.dart';

/// Простой пример для тестирования системы ошибок
class ErrorTestWidget extends ConsumerWidget {
  const ErrorTestWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Тест системы ошибок')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Тестирование системы обработки ошибок',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Тестовые кнопки
            ElevatedButton(
              onPressed: () => _testAuthError(ref),
              child: const Text('Тест: Ошибка входа (SnackBar)'),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () => _testEncryptionError(ref),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Тест: Критическая ошибка (Диалог)'),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () => _testValidationError(ref),
              child: const Text('Тест: Ошибка валидации'),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () => _testNetworkError(ref),
              child: const Text('Тест: Сетевая ошибка'),
            ),

            const SizedBox(height: 32),

            // Информация о состоянии системы ошибок
            Consumer(
              builder: (context, ref, _) {
                try {
                  final errorState = ref.watch(errorManagerProvider);
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Состояние системы ошибок:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text('Всего ошибок: ${errorState.errors.length}'),
                          Text('Диалог открыт: ${errorState.isShowingDialog}'),
                          if (errorState.currentError != null)
                            Text(
                              'Текущая: ${errorState.currentError.runtimeType}',
                            ),
                        ],
                      ),
                    ),
                  );
                } catch (e) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Ошибка при получении состояния системы ошибок',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }
              },
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () {
                try {
                  ref.read(errorManagerProvider.notifier).clearAllErrors();
                } catch (e) {
                  debugPrint('Ошибка при очистке: $e');
                }
              },
              child: const Text('Очистить все ошибки'),
            ),
          ],
        ),
      ),
    );
  }

  void _testAuthError(WidgetRef ref) {
    SafeErrorHandling.handleError(
      ref,
      const AuthenticationError(
        type: AuthenticationErrorType.invalidCredentials,
        message: 'Неверный логин или пароль',
        details: 'Пользователь ввел неправильные учетные данные',
        isCritical: false,
      ),
    );
  }

  void _testEncryptionError(WidgetRef ref) {
    SafeErrorHandling.handleError(
      ref,
      const EncryptionError(
        type: EncryptionErrorType.decryptionFailed,
        message: 'Не удалось расшифровать данные',
        details: 'Возможно, данные повреждены или используется неверный ключ',
        isCritical: true,
      ),
    );
  }

  void _testValidationError(WidgetRef ref) {
    SafeErrorHandling.handleError(
      ref,
      const ValidationError(
        type: ValidationErrorType.weakPassword,
        message: 'Пароль слишком слабый',
        field: 'password',
        details: 'Пароль должен содержать минимум 8 символов',
        isCritical: false,
      ),
    );
  }

  void _testNetworkError(WidgetRef ref) {
    SafeErrorHandling.handleError(
      ref,
      const NetworkError(
        type: NetworkErrorType.noConnection,
        message: 'Нет подключения к интернету',
        details: 'Проверьте подключение к сети',
        isCritical: false,
      ),
    );
  }
}
