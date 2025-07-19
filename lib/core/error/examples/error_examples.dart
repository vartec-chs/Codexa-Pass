import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codexa_pass/core/error/error_system.dart';
import 'package:codexa_pass/core/logging/app_logger.dart';

/// Примеры использования системы ошибок
class ErrorSystemExamples {
  /// Пример 1: Использование Result для безопасного выполнения операций
  static Future<Result<String>> exampleSafeOperation() async {
    return ResultUtils.safeAsync(() async {
      // Имитация операции, которая может завершиться ошибкой
      await Future.delayed(const Duration(seconds: 1));

      // Имитация ошибки (раскомментируйте для теста)
      // throw Exception('Тестовая ошибка');

      return 'Операция выполнена успешно';
    });
  }

  /// Пример 2: Создание специфических ошибок
  static AppError createAuthenticationError() {
    return const AppError.authentication(
      type: AuthenticationErrorType.invalidCredentials,
      message: 'Неверный логин или пароль',
      details: 'Пользователь ввел неправильные учетные данные',
      isCritical: false,
    );
  }

  static AppError createEncryptionError() {
    return const AppError.encryption(
      type: EncryptionErrorType.decryptionFailed,
      message: 'Не удалось расшифровать данные',
      details: 'Возможно, данные повреждены или используется неверный ключ',
      isCritical: true,
    );
  }

  static AppError createValidationError() {
    return const AppError.validation(
      type: ValidationErrorType.weakPassword,
      message: 'Пароль слишком слабый',
      field: 'password',
      details:
          'Пароль должен содержать минимум 8 символов, заглавные и строчные буквы, цифры',
      isCritical: false,
    );
  }

  /// Пример 3: Работа с Result в цепочке операций
  static Future<Result<String>> exampleChainedOperations() async {
    final result1 = await exampleSafeOperation();

    return result1.flatMap((data) {
      // Выполняем следующую операцию только если первая успешна
      return ResultUtils.safe(() {
        if (data.length < 10) {
          throw const AppError.validation(
            type: ValidationErrorType.tooShort,
            message: 'Результат слишком короткий',
          );
        }
        return '$data + дополнительная обработка';
      });
    });
  }
}

/// Пример провайдера с обработкой ошибок
final exampleDataProvider = FutureProvider<String>((ref) async {
  try {
    // Имитация загрузки данных
    await Future.delayed(const Duration(seconds: 2));

    // Имитация различных ошибок (раскомментируйте для теста)
    // throw const AppError.network(
    //   type: NetworkErrorType.noConnection,
    //   message: 'Нет подключения к интернету',
    // );

    return 'Данные загружены успешно';
  } catch (error, stackTrace) {
    // Автоматическое логирование ошибки
    AppLogger.instance.error('Error loading data', error, stackTrace);

    // Обработка ошибки через менеджер ошибок
    if (error is AppError) {
      ref.read(errorManagerProvider.notifier).handleError(error);
    } else {
      ref
          .read(errorManagerProvider.notifier)
          .handleError(
            AppError.unknown(
              message: 'Ошибка загрузки данных',
              details: error.toString(),
              originalError: error,
              stackTrace: stackTrace,
            ),
          );
    }

    rethrow;
  }
});

/// Пример виджета с обработкой ошибок
class ExampleWidget extends ConsumerWidget with ErrorHandlerMixin {
  const ExampleWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(exampleDataProvider);

    // Обрабатываем ошибки автоматически
    dataAsync.handleErrorInWidget(ref);

    return Scaffold(
      appBar: AppBar(title: const Text('Пример системы ошибок')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Отображение данных с обработкой ошибок
            dataAsync.when(
              data: (data) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Данные: $data'),
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) {
                // Ошибка уже обработана в провайдере
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Ошибка загрузки данных. Проверьте уведомления.',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Кнопки для тестирования различных ошибок
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => _testAuthError(ref),
                  child: const Text('Тест: Ошибка аутентификации'),
                ),
                ElevatedButton(
                  onPressed: () => _testEncryptionError(ref),
                  child: const Text('Тест: Критическая ошибка'),
                ),
                ElevatedButton(
                  onPressed: () => _testValidationError(ref),
                  child: const Text('Тест: Ошибка валидации'),
                ),
                ElevatedButton(
                  onPressed: () => _testNetworkError(ref),
                  child: const Text('Тест: Сетевая ошибка'),
                ),
                ElevatedButton(
                  onPressed: () => _testUnknownError(ref),
                  child: const Text('Тест: Неизвестная ошибка'),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Кнопки для управления ошибками
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () =>
                      ref.read(errorManagerProvider.notifier).clearAllErrors(),
                  child: const Text('Очистить все ошибки'),
                ),
                ElevatedButton(
                  onPressed: () => ref.invalidate(exampleDataProvider),
                  child: const Text('Перезагрузить данные'),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Отображение состояния ошибок
            Consumer(
              builder: (context, ref, _) {
                final errorState = ref.watch(errorManagerProvider);
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Состояние системы ошибок:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text('Всего ошибок: ${errorState.errors.length}'),
                        Text(
                          'Текущая ошибка: ${errorState.currentError?.runtimeType ?? 'Нет'}',
                        ),
                        Text('Диалог открыт: ${errorState.isShowingDialog}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _testAuthError(WidgetRef ref) {
    handleError(ref, ErrorSystemExamples.createAuthenticationError());
  }

  void _testEncryptionError(WidgetRef ref) {
    handleError(ref, ErrorSystemExamples.createEncryptionError());
  }

  void _testValidationError(WidgetRef ref) {
    handleError(ref, ErrorSystemExamples.createValidationError());
  }

  void _testNetworkError(WidgetRef ref) {
    handleError(
      ref,
      const AppError.network(
        type: NetworkErrorType.timeout,
        message: 'Превышено время ожидания',
        details: 'Сервер не отвечает более 30 секунд',
      ),
    );
  }

  void _testUnknownError(WidgetRef ref) {
    handleError(
      ref,
      const AppError.unknown(
        message: 'Произошла неизвестная ошибка',
        details: 'Это пример неизвестной ошибки для тестирования',
        isCritical: true,
      ),
    );
  }
}

/// Пример сервиса с безопасными операциями
class ExamplePasswordService with ErrorHandlingProviderMixin {
  /// Пример операции с обработкой ошибок
  Future<Result<String>> encryptPassword(String password) async {
    return safeExecute(() async {
      // Валидация
      if (password.isEmpty) {
        throw const AppError.validation(
          type: ValidationErrorType.required,
          message: 'Пароль не может быть пустым',
          field: 'password',
        );
      }

      if (password.length < 8) {
        throw const AppError.validation(
          type: ValidationErrorType.weakPassword,
          message: 'Пароль слишком слабый',
          field: 'password',
          details: 'Минимальная длина пароля: 8 символов',
        );
      }

      // Имитация шифрования
      await Future.delayed(const Duration(milliseconds: 500));

      // Имитация ошибки шифрования (раскомментируйте для теста)
      // throw const AppError.encryption(
      //   type: EncryptionErrorType.encryptionFailed,
      //   message: 'Ошибка при шифровании пароля',
      // );

      return 'encrypted_$password';
    }, context: 'password encryption');
  }

  /// Пример операции с базой данных
  Future<Result<bool>> savePasswordToDatabase(String encryptedPassword) async {
    return safeExecute(() async {
      // Имитация сохранения в БД
      await Future.delayed(const Duration(milliseconds: 300));

      // Имитация ошибки БД (раскомментируйте для теста)
      // throw const AppError.database(
      //   type: DatabaseErrorType.connectionFailed,
      //   message: 'Не удалось подключиться к базе данных',
      // );

      return true;
    }, context: 'database save');
  }

  /// Пример цепочки операций
  Future<Result<bool>> createPassword(String password) async {
    final encryptResult = await encryptPassword(password);
    if (encryptResult.isFailure) {
      return Failure(encryptResult.error!);
    }

    final saveResult = await savePasswordToDatabase(encryptResult.data!);
    return saveResult;
  }
}
