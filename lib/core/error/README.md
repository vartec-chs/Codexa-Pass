# Система обработки ошибок для Codexa Pass

Комплексная система обработки ошибок для менеджера паролей с интеграцией в Riverpod, автоматическим логированием и красивым UI.

## 🚀 Возможности

- ✅ **Типизированные ошибки** - четкая классификация по типам (аутентификация, шифрование, сеть и т.д.)
- ✅ **Критические и некритические ошибки** - автоматическое определение серьезности
- ✅ **Красивый UI** - модальные окна для критических ошибок, SnackBar для остальных
- ✅ **Интеграция с логированием** - автоматическая запись всех ошибок
- ✅ **Riverpod интеграция** - провайдеры и миксины для автоматической обработки
- ✅ **Result паттерн** - безопасное выполнение операций
- ✅ **Локализация** - русскоязычные сообщения и рекомендации
- ✅ **Расширяемость** - легкое добавление новых типов ошибок

## 📁 Структура файлов

```
lib/core/error/
├── app_error.dart              # Основные типы ошибок
├── error_handler.dart          # Result паттерн и ErrorManager
├── error_localizations.dart    # Локализация сообщений
├── error_dialogs.dart         # UI компоненты (диалоги, SnackBar)
├── error_providers.dart       # Интеграция с Riverpod
├── error_system.dart          # Главный файл экспорта
└── examples/
    └── error_examples.dart     # Примеры использования
```

## 🎯 Типы ошибок

### AuthenticationError
- `invalidCredentials` - Неверные учетные данные
- `userNotFound` - Пользователь не найден  
- `sessionExpired` - Сессия истекла
- `biometricFailed` - Ошибка биометрии
- `masterPasswordIncorrect` - Неверный мастер-пароль

### EncryptionError (критические)
- `encryptionFailed` - Ошибка шифрования
- `decryptionFailed` - Ошибка расшифровки
- `keyDerivationFailed` - Ошибка вывода ключа
- `corruptedData` - Поврежденные данные

### DatabaseError
- `connectionFailed` - Ошибка подключения к БД
- `queryFailed` - Ошибка запроса
- `corruptedDatabase` - База данных повреждена
- `recordNotFound` - Запись не найдена

### NetworkError
- `noConnection` - Нет интернета
- `timeout` - Превышено время ожидания
- `serverError` - Ошибка сервера
- `syncFailed` - Ошибка синхронизации

### ValidationError
- `required` - Обязательное поле
- `weakPassword` - Слабый пароль
- `invalidFormat` - Неверный формат
- `passwordMismatch` - Пароли не совпадают

### SecurityError (критические)
- `dataBreachDetected` - Утечка данных
- `unauthorizedAccess` - Несанкционированный доступ
- `deviceCompromised` - Устройство скомпрометировано

### StorageError
- `fileNotFound` - Файл не найден
- `accessDenied` - Доступ запрещен
- `insufficientSpace` - Недостаточно места
- `backupFailed` - Ошибка резервного копирования

### SystemError (критические)
- `outOfMemory` - Недостаточно памяти
- `diskFull` - Диск заполнен
- `permissionDenied` - Нет разрешений

## 💻 Использование

### 1. Базовое использование Result

```dart
import 'package:codexa_pass/core/error/error_system.dart';

// Безопасное выполнение операции
Future<Result<String>> loadData() async {
  return ResultUtils.safeAsync(() async {
    // Ваша логика здесь
    final data = await someApiCall();
    return data;
  });
}

// Использование результата
final result = await loadData();
result.when(
  success: (data) => print('Данные: $data'),
  failure: (error) => print('Ошибка: ${error.message}'),
);
```

### 2. Создание специфических ошибок

```dart
// Ошибка аутентификации
const authError = AppError.authentication(
  type: AuthenticationErrorType.invalidCredentials,
  message: 'Неверный логин или пароль',
  details: 'Проверьте правильность введенных данных',
);

// Критическая ошибка шифрования
const encryptionError = AppError.encryption(
  type: EncryptionErrorType.decryptionFailed,
  message: 'Не удалось расшифровать данные',
  isCritical: true,
);
```

### 3. Использование в виджетах

```dart
class MyWidget extends ConsumerWidget with ErrorHandlerMixin {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () async {
        final result = await someOperation();
        handleResult(ref, result); // Автоматическая обработка ошибок
      },
      child: Text('Выполнить операцию'),
    );
  }
}
```

### 4. Использование в провайдерах

```dart
class PasswordService with ErrorHandlingProviderMixin {
  Future<Result<String>> encryptPassword(String password) async {
    return safeExecute(
      () async {
        if (password.isEmpty) {
          throw const AppError.validation(
            type: ValidationErrorType.required,
            message: 'Пароль не может быть пустым',
          );
        }
        
        return await encryptionService.encrypt(password);
      },
      context: 'password encryption',
    );
  }
}
```

### 5. Цепочка операций

```dart
Future<Result<bool>> createPassword(String password) async {
  final encryptResult = await encryptPassword(password);
  
  return encryptResult.flatMap((encryptedPassword) async {
    final saveResult = await saveToDatabase(encryptedPassword);
    return saveResult;
  });
}
```

## 🎨 UI Компоненты

### Критические ошибки
Отображаются в **модальных диалогах** с:
- Красивой иконкой и заголовком
- Подробным описанием ошибки
- Рекомендациями по устранению
- Кнопками "Повторить" и "Закрыть"
- Возможностью копирования деталей

### Некритические ошибки
Отображаются в **SnackBar** с:
- Иконкой типа ошибки
- Кратким сообщением
- Кнопкой "Подробнее" для просмотра деталей

## 🔧 Настройка

### 1. Добавьте зависимости в pubspec.yaml

```yaml
dependencies:
  riverpod: ^2.6.1
  flutter_riverpod: ^2.6.1
  logger: ^2.6.0
```

### 2. Инициализируйте систему в main.dart

```dart
import 'package:codexa_pass/core/error/error_system.dart';

void main() {
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      // Важно: добавьте navigatorKey для отображения диалогов
      navigatorKey: ref.watch(navigatorKeyProvider),
      home: HomeScreen(),
    );
  }
}
```

## 🔄 Добавление новых типов ошибок

### 1. Добавьте новый enum в app_error.dart

```dart
enum CustomErrorType {
  customError1,
  customError2,
}
```

### 2. Добавьте новый класс ошибки

```dart
class CustomError extends AppError {
  final CustomErrorType type;
  // ... остальные поля
}
```

### 3. Добавьте в фабричный метод AppError

```dart
const factory AppError.custom({
  required CustomErrorType type,
  required String message,
  String? details,
  bool isCritical,
}) = CustomError;
```

### 4. Обновите локализацию в error_localizations.dart

```dart
String _getCustomMessage(CustomErrorType type, String fallback) {
  return switch (type) {
    CustomErrorType.customError1 => 'Описание первой ошибки',
    CustomErrorType.customError2 => 'Описание второй ошибки',
  };
}
```

## 📊 Интеграция с логированием

Система автоматически интегрируется с существующей системой логирования:

```dart
// Все ошибки автоматически логируются через AppLogger
AppLogger.instance.error('Error details', error, stackTrace);
```

## 🧪 Тестирование

Используйте примеры из `error_examples.dart` для тестирования различных типов ошибок:

```dart
// В отладочной версии приложения
import 'package:codexa_pass/core/error/examples/error_examples.dart';

// Добавьте ExampleWidget в ваше приложение для тестирования
```

## 🎯 Лучшие практики

1. **Используйте Result паттерн** для всех операций, которые могут завершиться ошибкой
2. **Создавайте специфические ошибки** вместо общих Exception
3. **Указывайте контекст** при использовании ErrorHandlingProviderMixin
4. **Обрабатывайте ошибки на уровне UI** с помощью ErrorHandlerMixin
5. **Логируйте критические ошибки** для дальнейшего анализа
6. **Предоставляйте пользователю четкие инструкции** по устранению ошибок

## 🔮 Будущие улучшения

- [ ] Интеграция с аналитикой (Firebase Crashlytics)
- [ ] Автоматическая отправка отчетов об ошибках
- [ ] Поддержка множественных языков
- [ ] Темная тема для диалогов ошибок
- [ ] Анимации для UI компонентов
- [ ] Retry механизмы для сетевых операций
- [ ] Кэширование и офлайн поддержка
