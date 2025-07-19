# Быстрый старт - Система ошибок Codexa Pass

## 🚀 Минимальная интеграция (5 минут)

### 1. Обновите main.dart

```dart
import 'package:codexa_pass/core/error/enhanced_error_system.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Ваша существующая инициализация...
  await _initializeLogging();
  
  // Добавьте инициализацию системы ошибок
  ErrorSystemIntegration.initialize();
  
  // Оберните ваше приложение
  runApp(
    ErrorSystemIntegration.wrapApp(
      ProviderScope(child: MyApp()),
    ),
  );
}
```

### 2. Обновите MyApp

```dart
class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      // Добавьте navigatorKey
      navigatorKey: ref.watch(navigatorKeyProvider),
      
      // Ваши остальные настройки...
      home: HomeScreen(),
    );
  }
}
```

### 3. Используйте в виджетах

```dart
class MyWidget extends ConsumerWidget with StateErrorHandlerMixin {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () async {
        // Пример с Result паттерном
        final result = await executeWithErrorHandling(() async {
          return await someRiskyOperation();
        });
        
        result.fold(
          onSuccess: (data) => print('Успешно: $data'),
          onError: (error) => print('Ошибка обработана автоматически'),
        );
      },
      child: Text('Выполнить операцию'),
    );
  }
}
```

## 🎯 Примеры типовых ошибок

### Ошибка аутентификации (SnackBar)
```dart
final error = AuthenticationError(
  type: AuthenticationErrorType.invalidCredentials,
  message: 'Неверный пароль',
);
ref.read(errorHandlerProvider).handleError(error);
```

### Критическая ошибка шифрования (Диалог)
```dart
final error = EncryptionError(
  type: EncryptionErrorType.decryptionFailed,
  message: 'Не удалось расшифровать данные',
  severity: ErrorSeverity.critical,
);
ref.read(errorHandlerProvider).handleError(error);
```

### Ошибка валидации формы (SnackBar)
```dart
final error = ValidationError(
  type: ValidationErrorType.weakPassword,
  message: 'Пароль слишком слабый',
  field: 'password',
);
ref.read(errorHandlerProvider).handleError(error);
```

## 🔧 Использование Result паттерна

```dart
// В сервисах
class PasswordService {
  final ErrorHandler _errorHandler;
  
  PasswordService(this._errorHandler);
  
  Future<Result<String>> encryptPassword(String password) async {
    return _errorHandler.execute(() async {
      if (password.isEmpty) {
        throw ValidationError(
          type: ValidationErrorType.required,
          message: 'Пароль не может быть пустым',
          field: 'password',
        );
      }
      
      return await encrypt(password);
    });
  }
}

// Использование
final passwordService = PasswordService(ref.read(errorHandlerProvider));
final result = await passwordService.encryptPassword('mypassword');

result.fold(
  onSuccess: (encryptedPassword) {
    print('Зашифровано: $encryptedPassword');
  },
  onError: (error) {
    // Ошибка уже обработана ErrorHandler'ом
    print('Ошибка шифрования');
  },
);
```

## 📊 Автоматическая обработка в провайдерах

```dart
final dataProvider = FutureProvider<String>((ref) async {
  final errorHandler = ref.read(errorHandlerProvider);
  
  final result = await errorHandler.execute(() async {
    return await loadData();
  });
  
  return result.fold(
    onSuccess: (data) => data,
    onError: (error) => throw error, // Будет обработано в UI
  );
});

// В виджете с миксином
class DataWidget extends ConsumerWidget with StateErrorHandlerMixin {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(dataProvider);
    
    // Автоматическая обработка ошибок через миксин
    return dataAsync.when(
      data: (data) => Text(data),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) {
        // Ошибка автоматически обработается через миксин
        handleAsyncError(error, stack);
        return ErrorRetryWidget(
          onRetry: () => ref.invalidate(dataProvider),
        );
      },
    );
  }
}
```

## ✅ Готово!

Теперь все ошибки в вашем приложении будут:
- ✅ Автоматически логироваться с полным контекстом
- ✅ Типизированы для лучшей обработки
- ✅ Обрабатываться через Result паттерн
- ✅ Красиво отображаться пользователю
- ✅ Поддерживать retry логику и chain обработку

## 🚀 Дополнительные возможности

### Chain обработка ошибок
```dart
final result = await errorHandler
  .withRetry(maxAttempts: 3, delay: Duration(seconds: 1))
  .withFallback((error) => 'Резервные данные')
  .execute(() => riskyOperation());
```

### Группировка ошибок
```dart
final handler = ErrorHandler()
  .addHandler<NetworkError>((error) => showNetworkError(error))
  .addHandler<ValidationError>((error) => showValidationError(error));
```

## 📖 Дополнительно

- Полная документация: `lib/core/error/README.md`
- Примеры использования: `lib/core/error/examples.dart`
- Тесты: `test/core/error/enhanced_error_system_test.dart`
