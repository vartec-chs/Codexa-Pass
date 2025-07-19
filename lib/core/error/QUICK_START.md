# Быстрый старт - Система ошибок Codexa Pass

## 🚀 Минимальная интеграция (5 минут)

### 1. Обновите main.dart

```dart
import 'package:codexa_pass/core/error/error_system.dart';

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
class MyWidget extends ConsumerWidget with ErrorHandlerMixin {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () async {
        // Пример обработки ошибки
        try {
          await someRiskyOperation();
        } catch (e) {
          handleError(ref, AppError.unknown(
            message: 'Произошла ошибка',
            details: e.toString(),
          ));
        }
      },
      child: Text('Выполнить операцию'),
    );
  }
}
```

## 🎯 Примеры типовых ошибок

### Ошибка аутентификации (SnackBar)
```dart
handleError(ref, AppError.authentication(
  type: AuthenticationErrorType.invalidCredentials,
  message: 'Неверный пароль',
));
```

### Критическая ошибка шифрования (Диалог)
```dart
handleError(ref, AppError.encryption(
  type: EncryptionErrorType.decryptionFailed,
  message: 'Не удалось расшифровать данные',
  isCritical: true,
));
```

### Ошибка валидации формы (SnackBar)
```dart
handleError(ref, AppError.validation(
  type: ValidationErrorType.weakPassword,
  message: 'Пароль слишком слабый',
  field: 'password',
));
```

## 🔧 Использование Result паттерна

```dart
// В сервисах
class PasswordService with ErrorHandlingProviderMixin {
  Future<Result<String>> encryptPassword(String password) async {
    return safeExecute(() async {
      if (password.isEmpty) {
        throw AppError.validation(
          type: ValidationErrorType.required,
          message: 'Пароль не может быть пустым',
        );
      }
      
      return await encrypt(password);
    });
  }
}

// Использование
final result = await passwordService.encryptPassword('mypassword');
if (result.isSuccess) {
  print('Зашифровано: ${result.data}');
} else {
  handleError(ref, result.error!);
}
```

## 📊 Автоматическая обработка в провайдерах

```dart
final dataProvider = FutureProvider<String>((ref) async {
  try {
    return await loadData();
  } catch (error, stackTrace) {
    // Ошибка будет автоматически обработана в UI
    if (error is AppError) {
      ref.read(errorManagerProvider.notifier).handleError(error);
    }
    rethrow;
  }
});

// В виджете
class DataWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(dataProvider);
    
    // Автоматическая обработка ошибок
    dataAsync.handleErrorInWidget(ref);
    
    return dataAsync.when(
      data: (data) => Text(data),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Ошибка (детали в уведомлениях)'),
    );
  }
}
```

## ✅ Готово!

Теперь все ошибки в вашем приложении будут:
- ✅ Автоматически логироваться
- ✅ Красиво отображаться пользователю
- ✅ Предоставлять четкие инструкции по устранению
- ✅ Различаться по критичности

## 📖 Дополнительно

- Полная документация: `lib/core/error/README.md`
- Примеры использования: `lib/core/error/examples/error_examples.dart`
- Пример интеграции: `lib/core/error/integration_example.dart`
