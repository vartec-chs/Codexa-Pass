# Миграционное руководство: от error к error_v2

## 🔄 Обзор изменений

Система ошибок v2 представляет собой полную переработку архитектуры обработки ошибок с современными подходами и улучшенной функциональностью.

## 📊 Сравнение систем

| Аспект | error (v1) | error_v2 |
|--------|------------|-----------|
| **Архитектура** | Императивная с try-catch | Функциональная с Result<T> |
| **Типизация** | Базовые типы ошибок | Расширенная типизация с контекстом |
| **Восстановление** | Ручное | Автоматическое с стратегиями |
| **Локализация** | Простые сообщения | Контекстно-зависимая локализация |
| **UI компоненты** | Базовые диалоги | Множественные типы отображения |
| **Аналитика** | Минимальная | Полная интеграция |
| **Retry логика** | Ручная реализация | Автоматическая с backoff |
| **Мониторинг** | Отсутствует | Детальные метрики |

## 🚀 Ключевые преимущества v2

### 1. Безопасность типов
```dart
// v1 - исключения могут "утечь"
try {
  final data = await fetchData();
  return data;
} catch (e) {
  // Обработка может быть пропущена
  throw e;
}

// v2 - все ошибки контролируются
final result = await ResultV2Utils.tryCallAsync(() => fetchData());
return result.fold(
  (data) => data,
  (error) => handleError(error), // Обязательная обработка
);
```

### 2. Автоматическое восстановление
```dart
// v1 - ручная логика retry
int attempts = 0;
while (attempts < 3) {
  try {
    return await operation();
  } catch (e) {
    attempts++;
    if (attempts >= 3) throw e;
    await Future.delayed(Duration(seconds: attempts));
  }
}

// v2 - автоматический retry
final result = await errorHandler.executeWithRetry(() => operation(),
  maxRetries: 3,
  useExponentialBackoff: true,
);
```

### 3. Интеллектуальная локализация
```dart
// v1 - статические сообщения
final error = AppError.authentication(
  type: AuthenticationErrorType.invalidCredentials,
  message: 'Invalid credentials', // Фиксированное сообщение
);

// v2 - контекстная локализация
final error = AuthenticationErrorV2(
  errorType: AuthenticationErrorType.invalidCredentials,
  message: 'Неверные учетные данные',
  username: 'user@example.com', // Контекст для локализации
);
print(error.localizedMessage); // Автоматическая локализация
print(error.localizedSolution); // Рекомендации по исправлению
```

### 4. Продвинутые UI компоненты
```dart
// v1 - простые диалоги
showDialog(context: context, builder: (_) => 
  AlertDialog(title: Text('Error'), content: Text(error.message)));

// v2 - настраиваемые компоненты
await ErrorDisplayV2.show(context, error,
  config: ErrorDisplayConfigV2.critical(),
  onRetry: () => retryOperation(),
  onReport: () => reportError(),
);
```

## 📋 План миграции

### Этап 1: Подготовка (низкий риск)
1. **Установка системы v2** параллельно с v1
2. **Создание адаптеров** для совместимости
3. **Обучение команды** новым концепциям

### Этап 2: Частичная миграция (средний риск)
1. **Новые модули** создаются с v2
2. **Критические компоненты** мигрируют первыми
3. **Постепенная замена** простых случаев

### Этап 3: Полная миграция (высокий риск)
1. **Замена обработчиков** в существующих модулях
2. **Обновление UI** компонентов
3. **Удаление v1** после завершения

## 🔧 Примеры миграции

### Базовая обработка ошибок

```dart
// ДО (v1)
class UserRepository {
  Future<User> getUser(String id) async {
    try {
      final response = await api.get('/users/$id');
      return User.fromJson(response.data);
    } on NetworkException catch (e) {
      throw AppError.network(
        type: NetworkErrorType.connectionFailed,
        message: e.message,
      );
    } catch (e) {
      throw AppError.unknown(message: e.toString());
    }
  }
}

// ПОСЛЕ (v2)
class UserRepository {
  final ErrorHandlerV2 _errorHandler = getGlobalErrorHandler();
  
  Future<ResultV2<User>> getUser(String id) async {
    return await _errorHandler.executeWithErrorHandling(() async {
      final response = await api.get('/users/$id');
      return User.fromJson(response.data);
    }, 
      operationName: 'getUserById',
      context: {'userId': id},
      errorMapper: (error, stackTrace) {
        if (error is NetworkException) {
          return NetworkErrorV2(
            errorType: NetworkErrorType.connectionFailed,
            message: error.message,
            url: '/users/$id',
            originalError: error,
            stackTrace: stackTrace,
          );
        }
        return null; // Используется маппер по умолчанию
      },
    );
  }
}
```

### UI компоненты

```dart
// ДО (v1)
class ProfilePage extends StatelessWidget {
  void _handleError(AppError error) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Ошибка'),
        content: Text(error.message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
  
  void _loadProfile() async {
    try {
      final user = await userRepository.getUser(userId);
      setState(() => this.user = user);
    } catch (error) {
      _handleError(error as AppError);
    }
  }
}

// ПОСЛЕ (v2)
class ProfilePage extends StatelessWidget {
  void _loadProfile() async {
    final result = await userRepository.getUser(userId);
    
    result.fold(
      (user) => setState(() => this.user = user),
      (error) => ErrorDisplayV2.show(context, error,
        config: const ErrorDisplayConfigV2(
          showRetryButton: true,
          showSolution: true,
        ),
        onRetry: _loadProfile,
      ),
    );
  }
}
```

### Сервисный слой

```dart
// ДО (v1)
class AuthService {
  Future<bool> authenticate(String email, String password) async {
    try {
      final response = await api.post('/auth/login', {
        'email': email,
        'password': password,
      });
      
      if (response.statusCode == 401) {
        throw AppError.authentication(
          type: AuthenticationErrorType.invalidCredentials,
          message: 'Неверные учетные данные',
        );
      }
      
      return true;
    } catch (e) {
      errorHandler.handleError(e as AppError);
      return false;
    }
  }
}

// ПОСЛЕ (v2)
class AuthService {
  final ErrorHandlerV2 _errorHandler = getGlobalErrorHandler();
  
  Future<ResultV2<bool>> authenticate(String email, String password) async {
    return await _errorHandler.executeWithRetry(() async {
      final response = await api.post('/auth/login', {
        'email': email,
        'password': password,
      });
      
      if (response.statusCode == 401) {
        throw AuthenticationErrorV2(
          errorType: AuthenticationErrorType.invalidCredentials,
          message: 'Неверные учетные данные',
          username: email,
          context: {
            'loginMethod': 'email_password',
            'clientIP': await getClientIP(),
          },
        );
      }
      
      return true;
    }, 
      maxRetries: 2,
      shouldRetry: (error) => 
        error is NetworkErrorV2 && error.errorType == NetworkErrorType.timeout,
    );
  }
}
```

## 🛠 Адаптеры для совместимости

Создайте адаптеры для плавной миграции:

```dart
// Адаптер для преобразования v1 -> v2
class ErrorMigrationAdapter {
  static AppErrorV2 fromV1(AppError v1Error) {
    // Логика преобразования старых ошибок в новые
    switch (v1Error.runtimeType) {
      case AuthenticationError:
        final authError = v1Error as AuthenticationError;
        return AuthenticationErrorV2(
          errorType: _mapAuthType(authError.type),
          message: authError.message,
          technicalDetails: authError.details,
        );
      // Добавить другие типы...
      default:
        return UnknownErrorV2(
          message: v1Error.message,
          technicalDetails: v1Error.details,
          originalError: v1Error,
        );
    }
  }
  
  static AuthenticationErrorType _mapAuthType(
    old.AuthenticationErrorType oldType
  ) {
    switch (oldType) {
      case old.AuthenticationErrorType.invalidCredentials:
        return AuthenticationErrorType.invalidCredentials;
      // Добавить другие маппинги...
      default:
        return AuthenticationErrorType.permissionDenied;
    }
  }
}

// Обертка для существующего кода
class ErrorHandlerWrapper {
  final ErrorHandlerV2 _v2Handler = getGlobalErrorHandler();
  
  Future<void> handleError(AppError v1Error) async {
    final v2Error = ErrorMigrationAdapter.fromV1(v1Error);
    await _v2Handler.handleError(v2Error);
  }
}
```

## ⚠️ Потенциальные проблемы

### 1. Изменение интерфейсов
**Проблема**: Методы возвращают `Result<T>` вместо прямых значений
**Решение**: Постепенная миграция с использованием адаптеров

### 2. Асинхронность
**Проблема**: Больше async/await кода
**Решение**: Рефакторинг синхронных методов

### 3. Размер кода
**Проблема**: Увеличение объема кода из-за обработки Result
**Решение**: Использование extension методов и утилит

## 📈 Метрики успеха миграции

Отслеживайте следующие показатели:

1. **Покрытие тестами** error handling логики
2. **Количество необработанных исключений** в продакшене
3. **Время восстановления** после ошибок
4. **UX метрики** связанные с обработкой ошибок
5. **Производительность** системы обработки ошибок

## 🎯 Чек-лист миграции

### Подготовка
- [ ] Изучена документация v2
- [ ] Созданы тестовые примеры
- [ ] Команда обучена новым концепциям
- [ ] Настроена инфраструктура мониторинга

### Реализация
- [ ] Система v2 установлена параллельно
- [ ] Созданы адаптеры совместимости
- [ ] Начата миграция критических компонентов
- [ ] Обновлены тесты

### Завершение
- [ ] Все модули мигрированы
- [ ] Удалена система v1
- [ ] Обновлена документация
- [ ] Команда обучена поддержке v2

## 🚀 Заключение

Миграция на систему ошибок v2 значительно улучшит:
- **Надежность** приложения
- **Опыт пользователей** при возникновении ошибок  
- **Процесс разработки** и отладки
- **Мониторинг** и анализ проблем

Рекомендуется проводить миграцию поэтапно, начиная с новых модулей и постепенно переводя существующий код.
