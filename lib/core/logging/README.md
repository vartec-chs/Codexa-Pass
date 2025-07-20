# Codexa Pass Logging System

Комплексная система логгирования для Flutter-приложения Codexa Pass. Разработана с учетом требований безопасности для менеджера паролей.

## 🚀 Возможности

### ✅ Основные функции
- **5 уровней логгирования**: DEBUG, INFO, WARNING, ERROR, FATAL
- **Асинхронная обработка**: Минимальное влияние на UI поток
- **Структурированные логи**: Полные метаданные для каждой записи
- **Красивый вывод**: Цветная консоль и структурированные файлы
- **Автоматическая ротация**: Управление размером и временем хранения файлов

### 🔒 Безопасность
- **Маскировка данных**: Автоматическое скрытие паролей и токенов
- **Фильтрация модулей**: Контроль логирования по компонентам
- **Конфигурируемые уровни**: Различные настройки для dev/prod сред
- **Краш репорты**: Отдельное хранение критичных ошибок

### 📱 Метаданные
- **Device Info**: Информация об устройстве и ОС
- **App Info**: Версия приложения и build number
- **Session ID**: Группировка логов по сессии пользователя
- **Context**: Модуль, класс, функция, строка кода

### 🔄 Интеграция
- **Riverpod**: Автоматическое отслеживание состояний
- **HTTP запросы**: Логирование сетевых операций
- **Навигация**: Отслеживание переходов между экранами
- **Жизненный цикл**: Логирование состояний приложения

## 📁 Структура модуля

```
lib/core/logging/
├── models/
│   ├── log_level.dart         # Уровни логгирования
│   └── log_entry.dart         # Модели данных
├── interfaces/
│   └── logging_interfaces.dart # Абстракции
├── services/
│   ├── system_info_provider.dart    # Информация о системе
│   └── sensitive_data_masker.dart   # Маскировка данных
├── formatters/
│   └── log_formatters.dart     # Форматирование вывода
├── handlers/
│   ├── base_handlers.dart      # Базовые обработчики
│   └── file_handlers.dart      # Файловые обработчики
├── providers/
│   └── logging_providers.dart  # Интеграция с Riverpod
├── utils/
│   └── logging_utils.dart      # Утилиты и хелперы
├── examples/
│   └── logging_example.dart    # Примеры использования
├── codexa_logger.dart          # Основной класс логгера
└── logging.dart               # Экспорты модуля
```

## 🛠 Установка и настройка

### 1. Зависимости

Добавлены в `pubspec.yaml`:
```yaml
dependencies:
  logger: ^2.6.0
  path_provider: ^2.1.5
  device_info_plus: ^11.5.0
  package_info_plus: ^8.3.0
  uuid: ^4.5.1
  intl: ^0.20.2
  flutter_riverpod: ^2.6.1
```

### 2. Инициализация

В `main.dart`:
```dart
import 'package:codexa_pass/core/logging/logging.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализируем систему логгирования
  await _initializeLogging();

  // Настраиваем observer для Riverpod
  final container = ProviderContainer(
    observers: [LoggingProviderObserver()],
  );

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: MyApp(),
    ),
  );
}

Future<void> _initializeLogging() async {
  final config = LoggerConfig(
    minLevel: kDebugMode ? LogLevel.debug : LogLevel.info,
    enableConsole: true,
    enableFile: true,
    enableCrashReports: kReleaseMode,
    maskSensitiveData: true,
  );

  await CodexaLogger.instance.initialize(config: config);
}
```

## 📖 Использование

### Базовое логирование

```dart
import 'package:codexa_pass/core/logging/logging.dart';

// Прямое использование
await CodexaLogger.instance.info('Application started');
await CodexaLogger.instance.error('Error occurred', error: e, stackTrace: st);

// С метаданными
await CodexaLogger.instance.info(
  'User action',
  metadata: {
    'userId': '12345',
    'action': 'login',
  },
);
```

### Модульное логирование

```dart
class UserService {
  late final ModuleLogger _logger;

  UserService() {
    _logger = ModuleLogger(CodexaLogger.instance, 'UserService');
  }

  Future<void> login(String email, String password) async {
    await _logger.info('User login attempt', metadata: {
      'email': email,
      'password': password, // Автоматически маскируется
    });
    
    try {
      // Логика входа...
      await _logger.info('User logged in successfully');
    } catch (e, stackTrace) {
      await _logger.error(
        'Login failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
```

### Использование в виджетах

```dart
class MyWidget extends ConsumerStatefulWidget {
  @override
  ConsumerState<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends ConsumerState<MyWidget> with LoggingMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initLogger(ref, 'MyWidget');
      logger.info('Widget initialized');
    });
  }

  Future<void> _handleAction() async {
    await logger.info('Action started');
    // Логика действия...
  }
}
```

### Интеграция с Riverpod

```dart
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

// Автоматическое логирование провайдеров
final providerObserverProvider = Provider<LoggingProviderObserver>((ref) {
  return LoggingProviderObserver();
});

// Модульный логгер через провайдер
final moduleLoggerProvider = Provider.family<ModuleLogger, String>((ref, module) {
  final logger = ref.watch(loggerProvider);
  return ModuleLogger(logger, module);
});
```

### Утилиты для специальных случаев

```dart
// Логирование производительности
await PerformanceLogger.measure(
  'database_query',
  () async {
    // Выполнение операции...
  },
  module: 'Database',
);

// HTTP логирование
HttpLogger.logRequest(
  method: 'POST',
  url: 'https://api.example.com/login',
  body: loginData,
);

// Навигация
NavigationLogger.logPush('/profile', arguments: userId);

// Жизненный цикл приложения
AppLifecycleLogger.logStateChange(AppLifecycleState.paused);
```

## ⚙️ Конфигурация

### Основные параметры

```dart
LoggerConfig(
  minLevel: LogLevel.info,           // Минимальный уровень
  enableConsole: true,               // Вывод в консоль
  enableFile: true,                  // Запись в файлы
  enableCrashReports: true,          // Краш репорты
  maxFileSizeMB: 100,               // Максимальный размер файлов
  maxFileAgeDays: 30,               // Время хранения файлов
  enablePrettyPrint: true,          // Красивый вывод
  enableColors: true,               // Цвета в консоли
  enableMetadata: true,             // Включить метаданные
  maskSensitiveData: true,          // Маскировка чувствительных данных
  enabledModules: {'Auth', 'Storage'}, // Включенные модули
  disabledModules: {'Debug'},       // Выключенные модули
  moduleLogLevels: {                // Уровни для модулей
    'Auth': LogLevel.warning,
    'Database': LogLevel.info,
  },
)
```

### Уровни для разных сред

```dart
// Development
LoggerConfig(
  minLevel: LogLevel.debug,
  enableConsole: true,
  enableColors: true,
  enableMetadata: true,
)

// Production
LoggerConfig(
  minLevel: LogLevel.info,
  enableConsole: false,
  enableFile: true,
  enableCrashReports: true,
  maskSensitiveData: true,
  enabledModules: {'Auth', 'Security', 'Storage'},
)
```

## 📁 Структура файлов

### Расположение логов
```
Documents/
├── logs/
│   ├── 2024-01-15.log           # Основные логи по датам
│   ├── 2024-01-16.log
│   └── 2024-01-17_143522.log    # Ротированные файлы
└── crash/
    ├── 2024-01-15_14-32-10_error.json    # Краш репорты
    └── 2024-01-15_15-45-23_fatal.json
```

### Формат записей

**Консоль:**
```
14:32:10.123 🔍 DEBUG   [Auth.LoginService] User authentication started
14:32:10.456 ℹ️ INFO     [Auth.LoginService] Authentication successful
14:32:10.789 ⚠️ WARNING [Storage.Database] Connection timeout, retrying...
14:32:11.012 ❌ ERROR   [Network.ApiClient] HTTP request failed: 500
```

**Файл (JSON):**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "timestamp": "2024-01-15T14:32:10.123Z",
  "level": "INFO",
  "message": "User authentication successful",
  "sessionId": "session-123",
  "logger": "Auth",
  "module": "LoginService",
  "metadata": {
    "userId": "user123",
    "loginMethod": "email"
  },
  "deviceInfo": {
    "platform": "Android",
    "version": "14",
    "model": "Pixel 7"
  },
  "appInfo": {
    "version": "1.0.0",
    "buildNumber": "1"
  }
}
```

## 🔒 Безопасность и маскировка данных

### Автоматическая маскировка

Система автоматически маскирует:
- Пароли и PIN-коды
- Токены и API ключи
- Номера кредитных карт
- Email адреса (частично)
- JWT токены
- Персональные данные

### Примеры маскировки

```dart
// Исходные данные
{
  "password": "mySecretPassword123",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "email": "user@example.com",
  "creditCard": "4532-1234-5678-9012"
}

// После маскировки
{
  "password": "***",
  "token": "eyJhbGciOi...***",
  "email": "u***@example.com",
  "creditCard": "***"
}
```

## 📊 Мониторинг и отладка

### Отслеживание производительности

```dart
// Автоматическое измерение времени
await PerformanceLogger.measure('user_login', () async {
  return await userService.login(email, password);
});

// Результат в логах:
// Performance tracking completed: user_login (523ms)
```

### Отслеживание состояний Riverpod

```dart
// Автоматическое логирование через observer
final container = ProviderContainer(
  observers: [LoggingProviderObserver()],
);

// Логи включают:
// - Обновления состояний провайдеров
// - Создание и уничтожение провайдеров
// - Ошибки в провайдерах
```

### Анализ Session ID

Каждая сессия имеет уникальный ID, позволяющий:
- Группировать логи по сессиям пользователя
- Отслеживать путь пользователя через приложение
- Анализировать краши в контексте конкретной сессии

## 🚨 Обработка ошибок и крашей

### Краш репорты

```dart
// Автоматическое создание краш репортов для ERROR и FATAL
await logger.fatal(
  'Critical system failure',
  error: exception,
  stackTrace: stackTrace,
  metadata: {
    'systemState': getCurrentSystemState(),
    'userActions': getRecentUserActions(),
  },
);

// Создается файл: crash/2024-01-15_14-32-10_fatal.json
```

### Структура краш репорта

```json
{
  "id": "crash-550e8400-e29b-41d4-a716-446655440000",
  "timestamp": "2024-01-15T14:32:10.123Z",
  "level": "FATAL",
  "message": "Critical system failure",
  "error": "Exception: Database connection lost",
  "stackTrace": "...",
  "sessionId": "session-123",
  "deviceInfo": { "..." },
  "appInfo": { "..." },
  "metadata": {
    "systemState": "...",
    "userActions": "..."
  }
}
```

## 📈 Рекомендации по использованию

### В разработке
- Используйте `LogLevel.debug` для детального логирования
- Включайте цвета и красивый вывод
- Логируйте все модули для отладки
- Включайте полные метаданные

### В продакшене
- Используйте `LogLevel.info` или выше
- Отключайте консольный вывод
- Ограничивайте логирование критичными модулями
- Обязательно маскируйте чувствительные данные
- Включайте краш репорты

### Производительность
- Логирование асинхронное и не блокирует UI
- Файлы ротируются автоматически
- Старые логи удаляются по расписанию
- Краш репорты хранятся дольше обычных логов

## 🧪 Тестирование

Для тестирования системы используйте демонстрационные кнопки в приложении:
1. Запустите приложение
2. Нажмите "Test Logging System" на главном экране
3. Перейдите к "View Logging Demo" для детального тестирования
4. Проверьте консоль VS Code и файлы в директории документов

## 🤝 Интеграция с другими сервисами

Система легко расширяется для интеграции с:
- Внешними системами мониторинга (Sentry, Crashlytics)
- Аналитическими сервисами
- Системами уведомлений
- Базами данных для хранения логов

## 📚 Дополнительные ресурсы

- [Примеры использования](examples/logging_example.dart)
- [API документация](interfaces/logging_interfaces.dart)
- [Конфигурация](models/log_entry.dart)
- [Утилиты](utils/logging_utils.dart)

---

**Разработано для Codexa Pass** - Безопасный менеджер паролей с продвинутой системой логгирования.
