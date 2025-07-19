# Краш-репорты - Дополнение к системе логирования

## Обзор

Система логирования была расширена функциональностью автоматического создания краш-репортов с сохранением в отдельные файлы по дате и времени в структурированных папках.

## 🆕 Новые компоненты

### 1. CrashReporter (`crash_reporter.dart`)
- Основной класс для управления краш-репортами
- Автоматическое создание структуры папок
- Сохранение в JSON и текстовом формате
- Управление лимитами файлов

### 2. CrashReport (модель данных)
- Структурированное представление краш-репорта
- Сериализация в JSON и обратно
- Генерация читаемого текста
- Поддержка дополнительных данных

### 3. CrashType (перечисление)
- `flutter` - ошибки Flutter фреймворка
- `dart` - ошибки времени выполнения Dart
- `native` - нативные ошибки платформы
- `custom` - пользовательские ошибки
- `fatal` - критические ошибки

### 4. CrashReportsPage (`crash_reports_page.dart`)
- UI для просмотра краш-репортов
- Статистика по типам ошибок
- Детальный просмотр каждого краш-репорта
- Управление (очистка, экспорт)

## 📁 Структура хранения

```
Documents/AppLogs/crash_reports/
├── flutter_error/
│   ├── flutter_error_2025-07-20T15-30-45-123Z.json
│   └── flutter_error_2025-07-20T15-30-45-123Z.txt
├── dart_error/
├── native_error/
├── custom_error/
└── fatal_error/
```

## 🚀 Быстрый старт

### Автоматическая настройка
Краш-репорты автоматически настраиваются при инициализации логгера в `main.dart`:

```dart
// Уже настроено!
FlutterError.onError = (details) {
  // Логирование + создание краш-репорта
  AppLogger.instance.fatal('Flutter Error', details.exception, details.stack);
  LogUtils.reportFlutterCrash('Flutter Framework Error', details.exception, details.stack);
};
```

### Ручное создание краш-репортов

```dart
import 'package:codexa_pass/core/logging/logging.dart';

try {
  // ваш код
} catch (e, stackTrace) {
  // Создание краш-репорта
  await LogUtils.reportCustomCrash(
    'Ошибка обработки данных',
    e,
    stackTrace: stackTrace,
    additionalInfo: {
      'userId': currentUser.id,
      'operation': 'processData',
      'dataSize': data.length,
    },
  );
}
```

### Просмотр краш-репортов

```dart
// Навигация к странице краш-репортов
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const CrashReportsPage(),
  ),
);

// Или через демонстрационную страницу логирования
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const LoggingDemoPage(),
  ),
);
// Нажать кнопку "Краш-репорты"
```

## 🛠️ API методы

### Создание краш-репортов
```dart
// По типам ошибок
await LogUtils.reportFlutterCrash(title, error, stackTrace, additionalInfo: {});
await LogUtils.reportDartCrash(title, error, stackTrace, additionalInfo: {});
await LogUtils.reportNativeCrash(title, error, stackTrace: null, additionalInfo: {});
await LogUtils.reportCustomCrash(title, error, stackTrace: null, additionalInfo: {});
await LogUtils.reportFatalCrash(title, error, stackTrace, additionalInfo: {});
```

### Управление краш-репортами
```dart
// Статистика
final stats = await LogUtils.getCrashReportsStatistics();
await LogUtils.logCrashReportsStatistics();

// Очистка
await LogUtils.clearAllCrashReports();
await LogUtils.clearCrashReportsByType(CrashType.custom);

// Информация
final path = LogUtils.getCrashReportsPath();
final isReady = LogUtils.isCrashReporterInitialized;
```

### Программная работа
```dart
final crashReporter = CrashReporter.instance;
await crashReporter.initialize();

// Получение краш-репортов
final allReports = await crashReporter.getAllCrashReports();
final customReports = await crashReporter.getCrashReportsByType(CrashType.custom);

// Счетчики
final counts = await crashReporter.getCrashReportsCount();
```

## 📊 Содержимое краш-репорта

Каждый краш-репорт содержит:

### Основная информация
- Уникальный ID с временной меткой
- Тип ошибки
- Заголовок и описание
- Стек вызовов (если доступен)

### Системная информация
- Платформа и версия ОС
- Модель устройства
- Информация о приложении
- Режим сборки (debug/release)

### Дополнительные данные
- Пользовательские поля
- Контекст ошибки
- Связанные данные

## 🎯 Преимущества

### 1. Автоматизация
- Автоматическое создание при ошибках
- Структурированное хранение
- Контроль размера (лимит файлов)

### 2. Детализация
- Полная системная информация
- Стек вызовов
- Пользовательский контекст

### 3. Удобство
- Два формата (JSON + текст)
- UI для просмотра
- Простое API

### 4. Производительность
- Асинхронная обработка
- Минимальное влияние на UI
- Эффективное хранение

### 5. Безопасность
- Локальное хранение
- Возможность очистки
- Контроль данных

## 🔧 Настройки

### Лимиты файлов
```dart
// По умолчанию: 50 файлов на тип ошибки
// Настраивается в CrashReporter._maxCrashReports
```

### Структура папок
```dart
// По умолчанию: Documents/AppLogs/crash_reports/
// Настраивается в CrashReporter._crashReportsFolder
```

## 🧪 Тестирование

Полное покрытие тестами:
```bash
flutter test test/crash_reporter_test.dart
```

Включает тесты:
- Создания и сериализации краш-репортов
- Файловых операций
- API методов
- Производительности
- Операций очистки

## 📝 Миграция

### Существующий код
Продолжает работать без изменений - краш-репорты создаются дополнительно к обычным логам.

### Новые возможности
Доступны через новые методы `LogUtils.report*Crash()` и страницу `CrashReportsPage`.

## 🚀 Итого

Система краш-репортов предоставляет:

✅ **Автоматическое создание** детальных отчетов об ошибках  
✅ **Структурированное хранение** в файлах по дате/времени  
✅ **Удобный UI** для просмотра и управления  
✅ **Полная интеграция** с существующей системой логирования  
✅ **Производительность** без влияния на UI  
✅ **Безопасность** с локальным хранением  

Теперь при любой ошибке в приложении автоматически создается подробный краш-репорт с полной системной информацией для упрощения диагностики и исправления проблем.
