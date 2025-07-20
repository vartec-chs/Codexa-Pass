# Система обработки ошибок v2 для CodexaPass

Улучшенная система обработки ошибок с расширенными возможностями и современным подходом к управлению ошибками в Flutter приложениях.

## 🚀 Основные улучшения v2

### По сравнению с версией v1:

- **Более четкая типизация**: Расширенные категории и типы ошибок с предустановленными параметрами
- **Функциональный подход**: `Result<T>` для безопасного выполнения операций без исключений
- **Автоматическое восстановление**: Интеллектуальные стратегии восстановления для различных типов ошибок
- **Расширенная локализация**: Контекстно-зависимые сообщения с поддержкой множественных языков
- **Гибкие UI компоненты**: Множество способов отображения ошибок (снэкбары, диалоги, баннеры, полноэкранные страницы)
- **Интеграция с аналитикой**: Автоматическая отправка метрик и статистики ошибок
- **Async/await поддержка**: Полная интеграция с современными асинхронными паттернами
- **Retry механизм**: Автоматические повторные попытки с exponential backoff
- **Метрики и мониторинг**: Детальная статистика для анализа ошибок

## 📦 Структура системы

```
error_v2/
├── error_base.dart           # Базовые интерфейсы и классы
├── error_types.dart          # Конкретные типы ошибок
├── result.dart               # Система Result<T>
├── error_handler.dart        # Продвинутый обработчик ошибок
├── error_localization.dart   # Система локализации
├── error_ui.dart             # UI компоненты
├── examples.dart             # Примеры использования
├── error_system_v2.dart      # Главный файл библиотеки
└── README.md                 # Эта документация
```

## 🎯 Быстрый старт

### 1. Базовое использование

```dart
import 'package:codexa_pass/core/error_v2/error_system_v2.dart';

// Создание ошибки
final error = AuthenticationErrorV2(
  errorType: AuthenticationErrorType.invalidCredentials,
  message: 'Неверные учетные данные',
  username: 'user@example.com',
);

// Отображение ошибки
await ErrorDisplayV2.show(context, error);
```

### 2. Использование Result<T>

```dart
// Безопасное выполнение операции
final result = await ResultV2Utils.tryCallAsync(() async {
  return await fetchUserData(userId);
});

// Обработка результата
result.fold(
  (data) => print('Успех: $data'),
  (error) => print('Ошибка: ${error.localizedMessage}'),
);
```

### 3. Настройка обработчика ошибок

```dart
// Создание и настройка обработчика
final errorHandler = ErrorHandlerV2(
  logger: MyErrorLogger(),
  analytics: MyErrorAnalytics(),
  notification: MyErrorNotification(),
);

// Установка как глобального
setGlobalErrorHandler(errorHandler);

// Использование
final result = await errorHandler.executeWithRetry(() async {
  return await performNetworkOperation();
}, maxRetries: 3);
```

## 📋 Подробное руководство

### Типы ошибок

Система поддерживает следующие категории ошибок:

#### 🔐 Аутентификация (`AuthenticationErrorV2`)
```dart
final authError = AuthenticationErrorV2(
  errorType: AuthenticationErrorType.sessionExpired,
  message: 'Сессия истекла',
  username: 'user@example.com',
  attemptNumber: 1,
);
```

**Поддерживаемые типы:**
- `invalidCredentials` - неверные учетные данные
- `sessionExpired` - сессия истекла  
- `biometricFailed` - ошибка биометрии
- `accountLocked` - аккаунт заблокирован
- И другие...

#### 🔒 Шифрование (`EncryptionErrorV2`)
```dart
final cryptoError = EncryptionErrorV2(
  errorType: EncryptionErrorType.decryptionFailed,
  message: 'Ошибка расшифровки',
  algorithm: 'AES-256-GCM',
  keyId: 'key_12345',
);
```

#### 🗄️ База данных (`DatabaseErrorV2`)
```dart
final dbError = DatabaseErrorV2(
  errorType: DatabaseErrorType.connectionFailed,
  message: 'Не удалось подключиться к БД',
  tableName: 'users',
  query: 'SELECT * FROM users WHERE id = ?',
);
```

#### 🌐 Сеть (`NetworkErrorV2`)
```dart
final netError = NetworkErrorV2(
  errorType: NetworkErrorType.timeout,
  message: 'Время ожидания истекло',
  url: 'https://api.example.com/data',
  statusCode: 408,
);
```

#### ✅ Валидация (`ValidationErrorV2`)
```dart
final validationError = ValidationErrorV2(
  errorType: ValidationErrorType.weakPassword,
  message: 'Пароль слишком слабый',
  field: 'password',
  value: '123456',
  constraints: {'minLength': 8},
);
```

### Система Result<T>

`Result<T>` позволяет обрабатывать ошибки функциональным способом:

#### Основные операции

```dart
// Создание результатов
final success = SuccessV2('данные');
final failure = FailureV2(error);

// Проверка результата
if (result.isSuccess) {
  print('Успех: ${result.value}');
}

// Преобразование
final transformed = result.map((data) => data.toUpperCase());

// Цепочка операций
final chained = result.flatMap((data) => processData(data));

// Восстановление после ошибки
final recovered = result.recover((error) => 'значение по умолчанию');
```

#### Асинхронные операции

```dart
// Асинхронное преобразование
final asyncResult = await result.mapAsync((data) async {
  return await processAsync(data);
});

// Асинхронная цепочка
final asyncChained = await result.flatMapAsync((data) async {
  return await fetchMoreData(data);
});

// Асинхронное восстановление
final asyncRecovered = await result.recoverAsync((error) async {
  return await getFromCache();
});
```

#### Утилиты

```dart
// Безопасное выполнение
final result = ResultV2Utils.tryCall(() {
  return riskyOperation();
});

// Комбинирование результатов
final combined = ResultV2Utils.combine([result1, result2, result3]);

// Параллельное выполнение
final parallel = await ResultV2Utils.parallel([
  future1,
  future2,
  future3,
]);
```

### Обработчик ошибок

`ErrorHandlerV2` предоставляет централизованную обработку ошибок:

#### Настройка

```dart
final handler = ErrorHandlerV2(
  logger: CustomErrorLogger(),
  analytics: CustomErrorAnalytics(), 
  notification: CustomErrorNotification(),
  recoveryHandlers: [
    AuthRecoveryHandlerV2(),
    NetworkRecoveryHandlerV2(),
    CustomRecoveryHandler(),
  ],
);
```

#### Выполнение операций

```dart
// Простое выполнение с обработкой ошибок
final result = await handler.executeWithErrorHandling(() async {
  return await fetchData();
});

// Выполнение с повторными попытками
final retryResult = await handler.executeWithRetry(() async {
  return await unreliableOperation();
}, 
  maxRetries: 3,
  useExponentialBackoff: true,
);

// Ручная обработка ошибки
await handler.handleError(error,
  shouldAttemptRecovery: true,
  shouldNotifyUser: true,
);
```

#### Стратегии восстановления

Система поддерживает различные стратегии восстановления:

- `none` - без восстановления
- `retry` - повторная попытка
- `retryWithBackoff` - повторная попытка с задержкой
- `fallback` - переключение на резервный механизм
- `reset` - сброс состояния
- `restart` - перезапуск сервиса
- `safeMode` - безопасный режим
- `custom` - пользовательская логика

### Локализация

Система автоматически локализует сообщения об ошибках:

```dart
// Получение локализованных сообщений
final localizedMessage = error.localizedMessage;
final localizedTitle = error.localizedTitle;
final localizedSolution = error.localizedSolution;

// Установка языка
getGlobalLocalizer().setLocale('en');

// Поддерживаемые языки
final supportedLocales = getGlobalLocalizer().supportedLocales; // ['ru', 'en']
```

### UI компоненты

#### Типы отображения

```dart
// Снэкбар (по умолчанию)
await ErrorDisplayV2.show(context, error);

// Диалог для критических ошибок
await ErrorDisplayV2.show(context, error,
  config: ErrorDisplayConfigV2.critical(),
);

// Баннер для предупреждений  
await ErrorDisplayV2.show(context, error,
  config: ErrorDisplayConfigV2.warning(),
);

// Полноэкранная страница
await ErrorDisplayV2.show(context, error,
  config: const ErrorDisplayConfigV2(
    type: ErrorDisplayType.fullscreen,
  ),
);
```

#### Встроенный виджет

```dart
Widget buildErrorSection() {
  return InlineErrorWidgetV2(
    error: error,
    config: const ErrorDisplayConfigV2(
      showSolution: true,
      showRetryButton: true,
    ),
    onRetry: () => performRetry(),
    onDismiss: () => hideError(),
  );
}
```

#### Кастомизация

```dart
const config = ErrorDisplayConfigV2(
  type: ErrorDisplayType.dialog,
  duration: Duration(seconds: 10),
  showTechnicalDetails: true,
  showSolution: true,
  showRetryButton: true,
  showReportButton: true,
  customTitle: 'Произошла ошибка',
  customIcon: Icon(Icons.warning, color: Colors.red),
  backgroundColor: Colors.red.shade100,
  customActions: [
    TextButton(
      onPressed: () => openHelp(),
      child: Text('Помощь'),
    ),
  ],
);
```

## 🔧 Продвинутые возможности

### Пользовательские обработчики восстановления

```dart
class CustomRecoveryHandler implements RecoveryHandlerV2 {
  @override
  bool canHandle(AppErrorV2 error) {
    return error is DatabaseErrorV2 && 
           error.errorType == DatabaseErrorType.corruptedDatabase;
  }
  
  @override
  Future<ResultV2<bool>> tryRecover(AppErrorV2 error) async {
    // Логика восстановления БД
    await repairDatabase();
    return SuccessV2(true);
  }
}

// Добавление к обработчику
errorHandler.addRecoveryHandler(CustomRecoveryHandler());
```

### Интеграция с аналитикой

```dart
class MyErrorAnalytics implements ErrorAnalyticsV2 {
  @override
  Future<void> trackError(AppErrorV2 error, ErrorAnalyticsData data) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'error_occurred',
      parameters: {
        'error_category': error.category.name,
        'error_type': error.type,
        'error_severity': error.severity.name,
        'user_id': data.userId,
        'session_id': data.sessionId,
        ...error.analyticsData,
      },
    );
  }
  
  @override
  Future<void> trackRecovery(AppErrorV2 error, bool successful) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'error_recovery',
      parameters: {
        'error_id': error.id,
        'successful': successful,
      },
    );
  }
  
  @override
  Future<void> trackRetry(AppErrorV2 error, int attemptNumber) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'error_retry',
      parameters: {
        'error_id': error.id,
        'attempt': attemptNumber,
      },
    );
  }
}
```

### Логирование

```dart
class MyErrorLogger implements ErrorLoggerV2 {
  @override
  Future<void> logError(AppErrorV2 error) async {
    final logEntry = {
      'timestamp': error.timestamp.toIso8601String(),
      'level': error.severity.name,
      'category': error.category.name,
      'type': error.type,
      'message': error.message,
      'technical_details': error.technicalDetails,
      'context': error.context,
      'error_id': error.id,
    };
    
    // Отправка в удаленную систему логирования
    await sendToLoggingService(logEntry);
    
    // Локальное логирование для критических ошибок
    if (error.severity.isCritical) {
      await saveToLocalLog(logEntry);
    }
  }
  
  @override
  Future<void> logInfo(String message, {Map<String, Object?>? context}) async {
    await sendToLoggingService({
      'level': 'info',
      'message': message,
      'context': context,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  @override
  Future<void> logWarning(String message, {Map<String, Object?>? context}) async {
    await sendToLoggingService({
      'level': 'warning', 
      'message': message,
      'context': context,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}
```

### Мониторинг и метрики

```dart
// Получение статистики ошибок
final stats = errorHandler.getErrorStats();
print('Всего ошибок: ${stats['totalErrorsTracked']}');
print('Активных попыток: ${stats['activeRetryAttempts']}');

// Очистка старых данных
errorHandler.clearRetryData(olderThan: const Duration(hours: 24));

// Подписка на поток ошибок
errorHandler.errorStream.listen((error) {
  print('Новая ошибка: ${error.id}');
  
  // Отправка критических ошибок в мониторинг
  if (error.severity.isCritical) {
    sendToMonitoring(error);
  }
});
```

## 📱 Примеры интеграции

### В приложении

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CodexaPass',
      scaffoldMessengerKey: ErrorDisplayV2.scaffoldKey,
      home: MyHomePage(),
      builder: (context, child) {
        // Глобальная обработка ошибок UI
        return ErrorBoundary(
          child: child,
          onError: (error, stackTrace) async {
            final appError = mapToAppError(error, stackTrace);
            await getGlobalErrorHandler().handleError(appError);
          },
        );
      },
    );
  }
}
```

### В сервисах

```dart
class UserService {
  final ErrorHandlerV2 _errorHandler = getGlobalErrorHandler();
  
  Future<ResultV2<User>> getCurrentUser() async {
    return await _errorHandler.executeWithRetry(() async {
      final response = await http.get('/api/user/current');
      
      if (response.statusCode != 200) {
        throw NetworkErrorV2(
          errorType: NetworkErrorType.serverError,
          message: 'Ошибка получения пользователя',
          statusCode: response.statusCode,
          url: '/api/user/current',
        );
      }
      
      return User.fromJson(response.data);
    }, maxRetries: 2);
  }
  
  Future<ResultV2<void>> updateUser(User user) async {
    return await _errorHandler.executeWithErrorHandling(() async {
      // Валидация
      final validationResult = validateUser(user);
      if (validationResult.isFailure) {
        throw validationResult.error!;
      }
      
      // Отправка на сервер
      await http.put('/api/user/${user.id}', data: user.toJson());
    });
  }
}
```

## 🎨 Лучшие практики

### 1. Создание ошибок
- Используйте специфичные типы ошибок вместо общих
- Добавляйте контекстную информацию
- Устанавливайте правильный уровень критичности

### 2. Обработка ошибок
- Предпочитайте `Result<T>` вместо try-catch там, где это возможно
- Используйте автоматическое восстановление для временных ошибок
- Логируйте все ошибки для анализа

### 3. UI отображение
- Показывайте пользователю понятные сообщения
- Предоставляйте возможность повторить операцию
- Не показывайте технические детали обычным пользователям

### 4. Мониторинг
- Отслеживайте тренды ошибок
- Настройте алерты для критических ошибок
- Регулярно анализируйте логи

## 📊 Миграция с v1

Основные изменения при миграции:

```dart
// v1
try {
  final data = await fetchData();
} catch (e) {
  final error = AppError.network(
    type: NetworkErrorType.timeout,
    message: 'Timeout',
  );
  errorHandler.handleError(error);
}

// v2
final result = await getGlobalErrorHandler().executeWithRetry(() async {
  return await fetchData();
});

result.fold(
  (data) => processData(data),
  (error) => showError(error),
);
```

## 🚦 Заключение

Система ошибок v2 предоставляет мощные инструменты для:
- **Типобезопасной** работы с ошибками
- **Автоматического восстановления** после сбоев
- **Гибкого отображения** ошибок пользователю
- **Детального мониторинга** и анализа
- **Локализации** сообщений об ошибках

Используйте эту систему для создания надежных и пользовательски дружелюбных приложений.
