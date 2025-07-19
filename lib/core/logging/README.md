# Система логирования Codexa Pass

Комплексная система логирования для Flutter приложения с поддержкой записи в файлы, ротации логов и различных уровней логирования.

## Возможности

- ✅ Логирование в консоль (только в debug режиме) и в файлы
- ✅ Автоматическая ротация логов по размеру и количеству файлов
- ✅ Поддержка различных уровней логирования (debug, info, warning, error, fatal)
- ✅ Интеграция с Riverpod для отслеживания состояния провайдеров
- ✅ Утилиты для логирования производительности, навигации и пользовательских действий
- ✅ Глобальная обработка ошибок Flutter и Dart
- ✅ Сохранение логов в папку Documents/Codexa/logs

## Зависимости

Система использует следующие пакеты (уже добавлены в pubspec.yaml):

```yaml
dependencies:
  logger: ^2.6.0           # Основная библиотека логирования
  path_provider: ^2.1.5    # Получение путей к директориям
  path: ^1.9.1            # Работа с путями файлов
  flutter_riverpod: ^2.6.1 # Для интерцептора провайдеров
```

## Структура файлов

```
lib/core/logging/
├── app_logger.dart      # Основной класс логгера
├── log_interceptor.dart # Интерцепторы для Riverpod и HTTP
├── log_utils.dart       # Утилиты для различных типов логирования
└── logging.dart         # Главный экспорт файл
```

## Быстрый старт

### 1. Инициализация в main.dart

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/logging/logging.dart';

void main() async {
  // Инициализация системы логирования
  await _initializeLogging();
  
  runApp(
    ProviderScope(
      observers: [LogInterceptor()], // Добавляем интерцептор для провайдеров
      child: const MyApp(),
    ),
  );
}

Future<void> _initializeLogging() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Глобальная обработка ошибок Flutter
  FlutterError.onError = (FlutterErrorDetails details) {
    AppLogger.instance.fatal('Flutter Error', details.exception, details.stack);
  };

  // Глобальная обработка ошибок Dart
  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.instance.fatal('Dart Error', error, stack);
    return true;
  };

  // Логирование информации о приложении
  LogUtils.logAppInfo();
  AppLogger.instance.info('Система логирования инициализирована');
}
```

### 2. Базовое использование

```dart
import 'core/logging/logging.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Логирование жизненного цикла виджета
    LogUtils.logWidgetLifecycle('MyWidget', 'build');
    
    return Container();
  }
  
  void _onButtonPressed() {
    // Логирование действий пользователя
    LogUtils.logUserAction('button_pressed', details: {'button': 'submit'});
    
    try {
      // Ваш код
    } catch (e, stackTrace) {
      // Логирование ошибок
      AppLogger.instance.error('Ошибка при нажатии кнопки', e, stackTrace);
    }
  }
}
```

## Подробное использование

### Основные методы логирования

```dart
final logger = AppLogger.instance;

// Отладочная информация (только в debug режиме)
logger.debug('Отладочное сообщение');

// Информационные сообщения
logger.info('Приложение запущено');

// Предупреждения
logger.warning('Низкий заряд батареи');

// Ошибки
logger.error('Ошибка подключения к серверу', error, stackTrace);

// Критические ошибки
logger.fatal('Критическая ошибка системы', error, stackTrace);
```

### Утилиты логирования

```dart
// Измерение производительности
final result = await LogUtils.measurePerformance(
  'загрузка_данных',
  () => loadDataFromServer(),
);

// Логирование навигации
LogUtils.logNavigation('/home', '/profile');

// Логирование пользовательских действий
LogUtils.logUserAction('login', details: {'method': 'google'});

// Логирование работы с БД
LogUtils.logDatabaseOperation('insert', table: 'users', data: userData);

// Логирование файловых операций
LogUtils.logFileOperation('read', '/path/to/file.txt');

// Критические ошибки с контекстом
LogUtils.logCriticalError(
  'инициализация_приложения',
  error,
  stackTrace,
  additionalInfo: {'version': '1.0.0', 'platform': 'android'},
);
```

### Управление лог-файлами

```dart
final logger = AppLogger.instance;

// Получение пути к директории логов
final logDir = await logger.getLogDirectory();
print('Логи сохраняются в: $logDir');

// Получение списка всех лог-файлов
final logFiles = await logger.getLogFiles();
print('Найдено ${logFiles.length} лог-файлов');

// Очистка всех логов
await logger.clearAllLogs();
```

### Интеграция с Riverpod

Интерцептор автоматически логирует:
- Создание и удаление провайдеров
- Обновления состояния провайдеров
- Ошибки в провайдерах

```dart
// Просто добавьте LogInterceptor в ProviderScope
ProviderScope(
  observers: [LogInterceptor()],
  child: MyApp(),
)
```

## Конфигурация

### Настройка ротации логов

По умолчанию:
- Максимальный размер файла: 10 МБ
- Максимальное количество файлов: 5
- Автоматическая очистка старых файлов

Можно изменить в конструкторе `FileOutput`:

```dart
FileOutput(
  maxFileSizeMB: 5,    // Максимальный размер файла в МБ
  maxFiles: 3,         // Максимальное количество файлов
)
```

### Уровни логирования

- **Debug режим**: все уровни логирования + вывод в консоль
- **Release режим**: только info, warning, error, fatal + только в файл

## Расположение файлов логов

Файлы логов сохраняются в:
- **Windows**: `%USERPROFILE%\Documents\Codexa\logs\`
- **macOS**: `~/Documents/Codexa/logs/`
- **Linux**: `~/Documents/Codexa/logs/`
- **Android**: `/storage/emulated/0/Android/data/[package]/files/Documents/Codexa/logs/`
- **iOS**: `Application Documents/Codexa/logs/`

## Формат лог-файлов

Каждая запись содержит:
- Временную метку в ISO 8601
- Уровень логирования
- Сообщение
- Стек трейс (при наличии)
- Контекстную информацию

Пример:
```
[2024-07-19T10:30:45.123Z] 💡 INFO: Приложение запущено
[2024-07-19T10:30:46.456Z] ⚠️  WARNING: Низкий заряд батареи
[2024-07-19T10:30:47.789Z] ❌ ERROR: Ошибка подключения к серверу
```

## Лучшие практики

1. **Используйте соответствующие уровни**: debug для отладки, info для важных событий, error для ошибок
2. **Добавляйте контекст**: используйте дополнительные параметры для важной информации
3. **Логируйте пользовательские действия**: помогает в анализе поведения пользователей
4. **Измеряйте производительность**: используйте `LogUtils.measurePerformance` для критических операций
5. **Обрабатывайте ошибки**: всегда логируйте исключения с полным стек трейсом

## Пример полной интеграции

См. файл `main_example.dart` для полного примера интеграции системы логирования в Flutter приложение.

## Устранение неполадок

1. **Логи не сохраняются**: Проверьте разрешения на запись в файловую систему
2. **Слишком много места**: Настройте параметры ротации логов
3. **Производительность**: В release режиме отключите debug логирование

## Дополнительные возможности

Система легко расширяется:
- Добавление новых типов вывода (например, отправка на сервер)
- Кастомные форматеры
- Интеграция с аналитическими системами
- Фильтрация логов по тегам
