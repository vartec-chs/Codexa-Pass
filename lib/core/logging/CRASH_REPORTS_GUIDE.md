# Система краш-репортов

## Обзор

Система краш-репортов автоматически создает детальные отчеты об ошибках с сохранением в отдельные файлы по дате и времени в структурированных папках.

## Возможности

### 🔧 Типы краш-репортов
- **Flutter Error** - ошибки фреймворка Flutter
- **Dart Error** - ошибки времени выполнения Dart
- **Native Error** - нативные ошибки платформы
- **Custom Error** - пользовательские ошибки
- **Fatal Error** - критические ошибки

### 📁 Структура файлов
```
Documents/
├── AppLogs/
│   └── crash_reports/
│       ├── flutter_error/
│       │   ├── flutter_error_2025-07-20T15-30-45.json
│       │   └── flutter_error_2025-07-20T15-30-45.txt
│       ├── dart_error/
│       ├── native_error/
│       ├── custom_error/
│       └── fatal_error/
```

### 📊 Форматы сохранения
- **JSON** - структурированные данные для программной обработки
- **TXT** - читаемый текст для человека

## Использование

### Автоматическое создание краш-репортов

Краш-репорты автоматически создаются при возникновении ошибок:

```dart
// Настройка в main.dart (уже настроено)
FlutterError.onError = (details) {
  AppLogger.instance.fatal('Flutter Error', details.exception, details.stack);
  LogUtils.reportFlutterCrash(
    'Flutter Framework Error',
    details.exception,
    details.stack ?? StackTrace.current,
    additionalInfo: {
      'library': details.library,
      'context': details.context?.toString(),
    },
  );
};
```

### Ручное создание краш-репортов

```dart
import 'package:codexa_pass/core/logging/logging.dart';

// Flutter ошибка
await LogUtils.reportFlutterCrash(
  'Ошибка виджета',
  exception,
  stackTrace,
  additionalInfo: {'widget': 'MyWidget'},
);

// Dart ошибка
await LogUtils.reportDartCrash(
  'Ошибка логики',
  exception,
  stackTrace,
  additionalInfo: {'function': 'processData'},
);

// Пользовательская ошибка
await LogUtils.reportCustomCrash(
  'Ошибка валидации',
  exception,
  additionalInfo: {'field': 'email'},
);

// Критическая ошибка
await LogUtils.reportFatalCrash(
  'Критическая ошибка',
  exception,
  stackTrace,
  additionalInfo: {'severity': 'high'},
);
```

### Работа с краш-репортами

```dart
// Получение статистики
final stats = await LogUtils.getCrashReportsStatistics();
print('Flutter errors: ${stats[CrashType.flutter]}');

// Логирование статистики
await LogUtils.logCrashReportsStatistics();

// Очистка всех краш-репортов
await LogUtils.clearAllCrashReports();

// Очистка по типу
await LogUtils.clearCrashReportsByType(CrashType.custom);

// Путь к краш-репортам
final path = LogUtils.getCrashReportsPath();
```

### Программная работа с CrashReporter

```dart
final crashReporter = CrashReporter.instance;

// Инициализация
await crashReporter.initialize();

// Получение всех краш-репортов
final allReports = await crashReporter.getAllCrashReports();

// Фильтрация по типу
final flutterReports = await crashReporter.getCrashReportsByType(CrashType.flutter);

// Создание краш-репорта
final report = CrashReport.fromException(
  type: CrashType.custom,
  title: 'Custom Error',
  exception: Exception('Test'),
  stackTrace: StackTrace.current,
  additionalData: {'userId': '123'},
);

// Сохранение
final filePath = await crashReporter.saveCrashReport(report);
```

## Структура краш-репорта

### JSON формат
```json
{
  "id": "custom_error_2025-07-20T15-30-45-123Z",
  "timestamp": "2025-07-20T15:30:45.123Z",
  "type": "custom_error",
  "title": "User Input Validation Error",
  "message": "Exception: Invalid email format",
  "stackTrace": "...",
  "systemInfo": {
    "platform": "android",
    "deviceModel": "Samsung Galaxy S21",
    "osVersion": "Android 12 (API 31)",
    "appName": "MyApp",
    "version": "1.0.0+1"
  },
  "additionalData": {
    "field": "email",
    "value": "invalid-email",
    "userId": "12345"
  },
  "reportVersion": "1.0"
}
```

### Текстовый формат
```
================================================================================
КРАШ-РЕПОРТ: User Input Validation Error
================================================================================
ID: custom_error_2025-07-20T15-30-45-123Z
Время: 2025-07-20 18:30:45.123456
Тип: custom_error

ОПИСАНИЕ ОШИБКИ:
Exception: Invalid email format

СТЕК ВЫЗОВОВ:
#0      validateEmail (package:myapp/validators.dart:15:5)
...

СИСТЕМНАЯ ИНФОРМАЦИЯ:
  platform: android
  deviceModel: Samsung Galaxy S21
  osVersion: Android 12 (API 31)
  appName: MyApp
  version: 1.0.0+1

ДОПОЛНИТЕЛЬНЫЕ ДАННЫЕ:
  field: email
  value: invalid-email
  userId: 12345

================================================================================
```

## UI для управления краш-репортами

### Демонстрационная страница
Доступна через `LoggingDemoPage` → кнопка "Краш-репорты"

### Страница краш-репортов (`CrashReportsPage`)
- 📊 Статистика по типам краш-репортов
- 📋 Список всех краш-репортов с фильтрацией
- 👁️ Просмотр деталей каждого краш-репорта
- 🗑️ Очистка краш-репортов
- 🧪 Создание тестовых краш-репортов

### Навигация
```dart
// Переход к странице краш-репортов
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const CrashReportsPage(),
  ),
);
```

## Настройки и ограничения

### Автоматическая очистка
- Максимум 50 краш-репортов на тип
- Автоматическое удаление старых файлов
- Сохранение новых краш-репортов при превышении лимита

### Производительность
- Асинхронное создание файлов
- Минимальное влияние на UI
- Эффективная сериализация JSON

### Безопасность
- Локальное хранение файлов
- Нет отправки на внешние серверы
- Возможность полной очистки данных

## Интеграция с существующими системами

### Совместимость с основным логгером
```dart
// Краш-репорты создаются дополнительно к основным логам
AppLogger.instance.fatal('Critical error', error, stackTrace);
LogUtils.reportFatalCrash('Critical error', error, stackTrace);
```

### Системная информация
Автоматически включается полная системная информация:
- Данные приложения (название, версия)
- Информация об устройстве (модель, ОС)
- Режим сборки (debug/release)

## Тестирование

Доступны comprehensive тесты:
```bash
flutter test test/crash_reporter_test.dart
```

Тесты покрывают:
- Создание и сериализацию краш-репортов
- Сохранение и загрузку файлов
- Управление статистикой
- Операции очистки
- Производительность

## Примеры использования

### В обработчике ошибок
```dart
try {
  // рискованная операция
  await processUserData();
} catch (e, stackTrace) {
  await LogUtils.reportCustomCrash(
    'Data Processing Error',
    e,
    stackTrace: stackTrace,
    additionalInfo: {
      'operation': 'processUserData',
      'userId': currentUser.id,
      'dataSize': data.length,
    },
  );
  // показать пользователю friendly сообщение
}
```

### При валидации
```dart
if (!isValidEmail(email)) {
  await LogUtils.reportCustomCrash(
    'Email Validation Failed',
    Exception('Invalid email format: $email'),
    additionalInfo: {
      'input': email,
      'validator': 'isValidEmail',
      'screen': 'RegistrationPage',
    },
  );
}
```

### В критических секциях
```dart
try {
  await criticalDatabaseOperation();
} catch (e, stackTrace) {
  await LogUtils.reportFatalCrash(
    'Database Operation Failed',
    e,
    stackTrace,
    additionalInfo: {
      'operation': 'criticalDatabaseOperation',
      'database': 'user_data',
      'severity': 'critical',
    },
  );
  // критическая обработка ошибки
}
```
