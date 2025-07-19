# 🚀 Быстрый старт: Система логирования

## � Последнее обновление: Исправлена ошибка LateInitializationError

✅ **Проблема решена:** `Error writing to log file: LateInitializationError`  
✅ **Добавлено:** Безопасное кеширование логов до инициализации файла  
✅ **Улучшено:** Автоматический fallback в консоль при ошибках  

📖 **Подробности:** [ERROR_FIX.md](ERROR_FIX.md)

## �📦 Что уже готово

Система логирования полностью готова к использованию:
- ✅ Многоязычная поддержка (RU/EN)
- ✅ Автоматическая ротация файлов
- ✅ Глобальная обработка ошибок
- ✅ Интеграция с Riverpod
- ✅ Утилиты для логирования
- ✅ **Защита от ошибок инициализации**

## ⚡ Минимальная интеграция (5 минут)

### 1. Обновите main.dart

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/logging/logging.dart';

void main() async {
  await _initializeLogging();
  runApp(ProviderScope(
    observers: [LogInterceptor()],
    child: const MyApp(),
  ));
}

Future<void> _initializeLogging() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    AppLogger.instance.fatal('Flutter Error', details.exception, details.stack);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.instance.fatal('Dart Error', error, stack);
    return true;
  };

  LogUtils.logAppInfo();
  AppLogger.instance.info('Система логирования запущена');
}
```

### 2. Добавьте в MaterialApp

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Локализация
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      
      // Логирование навигации
      navigatorObservers: [LogNavigatorObserver()],
      
      home: Builder(
        builder: (context) {
          // Инициализация многоязычности
          LoggerInitializer.initializeWithContext(context);
          return const HomePage();
        },
      ),
    );
  }
}
```

### 3. Используйте в коде

```dart
class MyWidget extends StatelessWidget {
  final AppLogger logger = AppLogger.instance;

  @override
  Widget build(BuildContext context) {
    logger.info('Виджет построен');
    
    return ElevatedButton(
      onPressed: () {
        LogUtils.logUserAction('button_pressed');
        logger.info('Кнопка нажата');
      },
      child: Text('Нажми меня'),
    );
  }
}
```

## 🎯 Готово!

Теперь у вас работает:
- 📝 Автоматическое сохранение логов в файлы
- 🌍 Многоязычные сообщения об ошибках
- ⚡ Логирование всех ошибок приложения
- 📊 Отслеживание действий пользователей

## 📖 Дополнительно

- Полная документация: [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md)
- Многоязычность: [LOCALIZATION.md](LOCALIZATION.md)
- Примеры использования: [example.dart](example.dart)

## 🔧 Управление логами

```dart
// Получить путь к логам
final logDir = await AppLogger.instance.getLogDirectory();

// Получить все файлы логов
final logFiles = await AppLogger.instance.getLogFiles();

// Очистить все логи
await AppLogger.instance.clearAllLogs();
```

**Логи сохраняются в:** `Documents/Codexa/logs/`
