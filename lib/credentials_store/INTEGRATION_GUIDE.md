# Инструкция по интеграции сервиса credentials_store

## Шаг 1: Завершение генерации кода

Запустите команду для генерации кода Drift:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Шаг 2: Добавление демо-страницы в приложение

Добавьте импорт в ваш основной файл роутинга:

```dart
import 'package:codexa_pass/credentials_store/credentials_store.dart';
```

Добавьте роут для демо-страницы:

```dart
GoRoute(
  path: '/credentials-demo',
  builder: (context, state) => const CredentialsDemoPage(),
),
```

## Шаг 3: Инициализация сервиса

В `main.dart` добавьте инициализацию:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализация сервиса работы с БД
  await CredentialsService.instance.initialize();
  
  runApp(MyApp());
}
```

## Шаг 4: Использование в коде

### Основные операции:

```dart
final credentialsService = CredentialsService.instance;

// Открытие базы данных
try {
  await credentialsService.openDatabase('user_password');
  print('База данных открыта');
} catch (e) {
  print('Ошибка открытия: $e');
}

// Создание новой записи метаданных
final metadata = await credentialsService.createDatabaseMetadata(
  name: 'Личные данные',
  description: 'База данных с личной информацией',
  password: 'secure_password_123',
);

// Получение всех записей
final allDatabases = await credentialsService.getAllDatabaseMetadata();

// Обновление времени последнего открытия
await credentialsService.updateLastOpenedAt(metadata.id);

// Блокировка/разблокировка записи
await credentialsService.setDatabaseLocked(metadata.id, true);

// Удаление записи
await credentialsService.deleteDatabaseMetadata(metadata.id);

// Проверка пароля
final isValid = credentialsService.verifyPassword(
  'user_input_password', 
  metadata.passwordHash,
);

// Закрытие базы данных
await credentialsService.closeDatabase();
```

## Шаг 5: Обработка ошибок

Все методы сервиса могут бросать `DatabaseError`. Рекомендуется обрабатывать их через систему ошибок приложения:

```dart
try {
  await credentialsService.openDatabase(password);
} on DatabaseError catch (e) {
  // Обработка через систему ошибок приложения
  ErrorController.instance.handleError(e);
} catch (e) {
  // Обработка неожиданных ошибок
  print('Неожиданная ошибка: $e');
}
```

## Шаг 6: Автоматическая блокировка

Сервис автоматически блокирует базу данных в следующих случаях:
- Через 15 минут неактивности
- При сворачивании окна приложения
- При закрытии приложения

Для изменения времени автоблокировки измените константу в `CredentialsService`:

```dart
static const Duration _inactivityTimeout = Duration(minutes: 30); // 30 минут
```

## Шаг 7: Тестирование

Запустите тесты для проверки функциональности:

```bash
flutter test test/credentials_store_test.dart
```

## Шаг 8: Безопасность

### Рекомендации по безопасности:

1. **Пароли**: Никогда не храните пароли в открытом виде
2. **Логирование**: Не логируйте чувствительную информацию
3. **Память**: Очищайте переменные с паролями после использования
4. **Файлы**: Убедитесь, что файлы БД имеют правильные права доступа

### Пример безопасной работы с паролями:

```dart
String? password;
try {
  password = await getUserPassword(); // Получаем пароль от пользователя
  await credentialsService.openDatabase(password);
  // Работаем с БД
} finally {
  // Очищаем пароль из памяти
  if (password != null) {
    password = ''; // Обнуляем строку
    password = null; // Убираем ссылку
  }
}
```

## Шаг 9: Мониторинг и логирование

Сервис интегрирован с системой ошибок приложения. Все ошибки автоматически логируются и могут быть отправлены в аналитику.

Для дополнительного логирования добавьте:

```dart
import 'package:logger/logger.dart';

final logger = Logger();

try {
  await credentialsService.openDatabase(password);
  logger.i('База данных открыта успешно');
} catch (e) {
  logger.e('Ошибка открытия БД', e);
}
```

## Готово!

После выполнения всех шагов сервис будет полностью интегрирован в ваше приложение и готов к использованию.
