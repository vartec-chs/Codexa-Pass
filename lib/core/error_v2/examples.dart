/// Примеры использования улучшенной системы ошибок v2

import 'dart:async';
import 'package:flutter/material.dart';

import 'error_system_v2.dart';

/// Примеры создания различных типов ошибок
class ErrorExamplesV2 {
  /// Пример создания ошибки аутентификации
  static AuthenticationErrorV2 createAuthError() {
    return AuthenticationErrorV2(
      errorType: AuthenticationErrorType.invalidCredentials,
      message: 'Неверные учетные данные',
      username: 'user@example.com',
      attemptNumber: 3,
      technicalDetails: 'HTTP 401: Invalid username or password',
      context: {
        'loginMethod': 'email',
        'deviceId': 'device123',
        'ipAddress': '192.168.1.1',
      },
    );
  }

  /// Пример создания ошибки шифрования
  static EncryptionErrorV2 createEncryptionError() {
    return EncryptionErrorV2(
      errorType: EncryptionErrorType.decryptionFailed,
      message: 'Не удалось расшифровать данные',
      algorithm: 'AES-256-GCM',
      keyId: 'key_12345',
      technicalDetails:
          'javax.crypto.BadPaddingException: Given final block not properly padded',
    );
  }

  /// Пример создания сетевой ошибки
  static NetworkErrorV2 createNetworkError() {
    return NetworkErrorV2(
      errorType: NetworkErrorType.noConnection,
      message: 'Нет подключения к интернету',
      url: 'https://api.example.com/sync',
      method: 'POST',
      timeout: const Duration(seconds: 30),
      statusCode: null,
    );
  }

  /// Пример создания ошибки валидации
  static ValidationErrorV2 createValidationError() {
    return ValidationErrorV2(
      errorType: ValidationErrorType.weakPassword,
      message: 'Пароль слишком слабый',
      field: 'password',
      value: '123456',
      constraints: {
        'minLength': 8,
        'requireUppercase': true,
        'requireDigits': true,
        'requireSpecialChars': true,
      },
    );
  }
}

/// Примеры использования Result<T>
class ResultExamplesV2 {
  /// Пример безопасного выполнения операции
  static Future<ResultV2<String>> fetchUserData(String userId) async {
    return await ResultV2Utils.tryCallAsync(() async {
      // Имитация API запроса
      await Future.delayed(const Duration(seconds: 1));

      if (userId.isEmpty) {
        throw ValidationErrorV2(
          errorType: ValidationErrorType.required,
          message: 'ID пользователя обязателен',
          field: 'userId',
        );
      }

      if (userId == 'invalid') {
        throw NetworkErrorV2(
          errorType: NetworkErrorType.serverError,
          message: 'Ошибка сервера',
          statusCode: 500,
        );
      }

      return 'Данные пользователя: $userId';
    });
  }

  /// Пример цепочки операций с Result
  static Future<ResultV2<String>> processUserData(String userId) async {
    return await fetchUserData(userId)
        .then(
          (result) => result.flatMapAsync((userData) async {
            // Обработка данных пользователя
            await Future.delayed(const Duration(milliseconds: 500));
            return SuccessV2('Обработано: $userData');
          }),
        )
        .then(
          (result) => result.map((processedData) {
            // Дополнительная обработка
            return 'Финальный результат: $processedData';
          }),
        );
  }

  /// Пример обработки ошибок с восстановлением
  static Future<ResultV2<String>> fetchDataWithFallback(String userId) async {
    final result = await fetchUserData(userId);

    return result.recoverAsync((error) async {
      if (error is NetworkErrorV2) {
        // Попытка получить данные из кэша
        await Future.delayed(const Duration(milliseconds: 200));
        return 'Данные из кэша для $userId';
      }

      throw error; // Перебрасываем ошибку, если не можем восстановить
    });
  }

  /// Пример комбинирования нескольких результатов
  static Future<ResultV2<List<String>>> fetchMultipleUsers(
    List<String> userIds,
  ) async {
    final futures = userIds.map((id) => fetchUserData(id)).toList();
    return await ResultV2Utils.parallel(futures);
  }

  /// Пример фильтрации результата
  static Future<ResultV2<String>> fetchValidUser(String userId) async {
    final result = await fetchUserData(userId);

    return result.where(
      (userData) => userData.contains('valid'),
      ValidationErrorV2(
        errorType: ValidationErrorType.invalidFormat,
        message: 'Пользователь не прошел валидацию',
        field: 'userData',
      ),
    );
  }
}

/// Примеры использования ErrorHandler
class ErrorHandlerExamplesV2 {
  /// Настройка обработчика ошибок
  static ErrorHandlerV2 setupErrorHandler() {
    final handler = ErrorHandlerV2(
      logger: CustomErrorLogger(),
      analytics: CustomErrorAnalytics(),
      notification: CustomErrorNotification(),
      recoveryHandlers: [
        AuthRecoveryHandlerV2(),
        NetworkRecoveryHandlerV2(),
        CustomDatabaseRecoveryHandler(),
      ],
    );

    // Установка как глобального обработчика
    setGlobalErrorHandler(handler);

    return handler;
  }

  /// Пример выполнения операции с автоматической обработкой ошибок
  static Future<void> performDatabaseOperation() async {
    final handler = getGlobalErrorHandler();

    final result = await handler.executeWithErrorHandling(() async {
      // Имитация операции с базой данных
      await Future.delayed(const Duration(seconds: 1));

      // Имитация ошибки
      throw DatabaseErrorV2(
        errorType: DatabaseErrorType.connectionFailed,
        message: 'Не удалось подключиться к базе данных',
        tableName: 'users',
      );
    });

    result.fold(
      (data) => print('Операция выполнена успешно: $data'),
      (error) => print('Ошибка: ${error.localizedMessage}'),
    );
  }

  /// Пример выполнения с повторными попытками
  static Future<void> performNetworkOperationWithRetry() async {
    final handler = getGlobalErrorHandler();

    final result = await handler.executeWithRetry(
      () async {
        // Имитация сетевого запроса
        await Future.delayed(const Duration(seconds: 1));

        if (DateTime.now().millisecond % 3 != 0) {
          throw NetworkErrorV2(
            errorType: NetworkErrorType.timeout,
            message: 'Время ожидания истекло',
            url: 'https://api.example.com/data',
          );
        }

        return 'Данные получены успешно';
      },
      maxRetries: 3,
      useExponentialBackoff: true,
    );

    result.fold(
      (data) => print('Данные получены: $data'),
      (error) => print('Не удалось получить данные: ${error.localizedMessage}'),
    );
  }
}

/// Примеры UI компонентов
class UIExamplesV2 {
  /// Пример отображения ошибки в снэкбаре
  static void showSnackbarError(BuildContext context) {
    final error = ErrorExamplesV2.createNetworkError();

    ErrorDisplayV2.show(
      context,
      error,
      config: const ErrorDisplayConfigV2(
        type: ErrorDisplayType.snackbar,
        showSolution: true,
        showRetryButton: true,
      ),
      onRetry: () {
        print('Повторная попытка...');
      },
    );
  }

  /// Пример отображения критической ошибки в диалоге
  static void showCriticalErrorDialog(BuildContext context) {
    final error = ErrorExamplesV2.createEncryptionError();

    ErrorDisplayV2.show(
      context,
      error,
      config: ErrorDisplayConfigV2.critical(),
      onRetry: () {
        print('Повторная попытка...');
      },
      onReport: () {
        print('Отправка отчета об ошибке...');
      },
    );
  }

  /// Пример встроенного виджета ошибки
  static Widget buildInlineErrorWidget() {
    final error = ErrorExamplesV2.createValidationError();

    return InlineErrorWidgetV2(
      error: error,
      config: const ErrorDisplayConfigV2(
        showSolution: true,
        showRetryButton: false,
        isDismissible: true,
      ),
      onDismiss: () {
        print('Ошибка скрыта');
      },
    );
  }

  /// Пример страницы с обработкой ошибок
  static Widget buildErrorHandlingPage() {
    return Scaffold(
      appBar: AppBar(title: const Text('Примеры ошибок v2')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                final result = await ResultExamplesV2.fetchUserData('test');
                print('Результат: $result');
              },
              child: const Text('Тест Result'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ErrorHandlerExamplesV2.performDatabaseOperation();
              },
              child: const Text('Тест ErrorHandler'),
            ),
            const SizedBox(height: 16),
            ErrorExamplesV2.createValidationError().localizedSolution != null
                ? Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Пример встроенной ошибки:'),
                          const SizedBox(height: 8),
                          UIExamplesV2.buildInlineErrorWidget(),
                        ],
                      ),
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}

/// Пользовательские реализации интерфейсов

class CustomErrorLogger implements ErrorLoggerV2 {
  @override
  Future<void> logError(AppErrorV2 error) async {
    print('ERROR: ${error.toJson()}');
  }

  @override
  Future<void> logInfo(String message, {Map<String, Object?>? context}) async {
    print('INFO: $message ${context ?? ''}');
  }

  @override
  Future<void> logWarning(
    String message, {
    Map<String, Object?>? context,
  }) async {
    print('WARNING: $message ${context ?? ''}');
  }
}

class CustomErrorAnalytics implements ErrorAnalyticsV2 {
  @override
  Future<void> trackError(
    AppErrorV2 error,
    ErrorAnalyticsData analyticsData,
  ) async {
    print('ANALYTICS: Error tracked - ${error.id}');
  }

  @override
  Future<void> trackRecovery(AppErrorV2 error, bool successful) async {
    print(
      'ANALYTICS: Recovery ${successful ? 'successful' : 'failed'} for ${error.id}',
    );
  }

  @override
  Future<void> trackRetry(AppErrorV2 error, int attemptNumber) async {
    print('ANALYTICS: Retry attempt $attemptNumber for ${error.id}');
  }
}

class CustomErrorNotification implements ErrorNotificationV2 {
  @override
  Future<void> showError(AppErrorV2 error) async {
    print('NOTIFICATION: Showing error - ${error.localizedMessage}');
  }

  @override
  Future<void> showRecoverySuccess(AppErrorV2 error) async {
    print('NOTIFICATION: Recovery successful for ${error.id}');
  }

  @override
  Future<void> showRecoveryFailure(AppErrorV2 error) async {
    print('NOTIFICATION: Recovery failed for ${error.id}');
  }
}

class CustomDatabaseRecoveryHandler implements RecoveryHandlerV2 {
  @override
  bool canHandle(AppErrorV2 error) {
    return error is DatabaseErrorV2 &&
        error.errorType == DatabaseErrorType.connectionFailed;
  }

  @override
  Future<ResultV2<bool>> tryRecover(AppErrorV2 error) async {
    print('Attempting database recovery...');
    await Future.delayed(const Duration(seconds: 2));

    // Имитация успешного восстановления в 70% случаев
    if (DateTime.now().millisecond % 10 < 7) {
      print('Database recovery successful');
      return SuccessV2(true);
    } else {
      print('Database recovery failed');
      return FailureV2(error);
    }
  }
}
