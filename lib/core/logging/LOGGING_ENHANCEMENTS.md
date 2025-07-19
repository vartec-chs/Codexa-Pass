# Дополнения к системе логирования

## Обзор

Система логирования была расширена с использованием пакетов `package_info_plus` и `device_info_plus` для сбора подробной информации о приложении и устройстве.

## Новые возможности

### 🔧 SystemInfo
- Автоматический сбор информации о приложении (название, версия, пакет)
- Подробная информация об устройстве (модель, ОС, архитектура)
- Поддержка всех платформ (Android, iOS, Windows, Linux, macOS)

### 📊 Расширенный LogUtils
- Логирование расширенной системной информации
- Измерение производительности операций
- Контекстное логирование ошибок
- Управление сессиями логирования

### ⚙️ Улучшенный LoggerInitializer
- Автоматическая инициализация системной информации
- Поддержка асинхронной инициализации
- Fallback на базовую функциональность при ошибках

## Быстрый старт

### 1. Инициализация в main()
```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Быстрая инициализация логгера
  LoggerInitializer.initializeQuick();
  
  runApp(MyApp());
}
```

### 2. Полная инициализация в приложении
```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) {
          // Полная инициализация после построения UI
          WidgetsBinding.instance.addPostFrameCallback((_) {
            LoggerInitializer.initializeComplete(context: context);
          });
          return MyHomePage();
        },
      ),
    );
  }
}
```

### 3. Использование в коде
```dart
// Логирование с системной информацией
await LogUtils.logExtendedAppInfo();

// Получение информации о системе
final systemInfo = SystemInfo.instance;
print(systemInfo.getShortSystemInfo());

// Контекстное логирование ошибок
LogUtils.logCriticalErrorWithContext(
  'Операция загрузки данных',
  error,
  stackTrace,
  additionalInfo: {'userId': userId},
);
```

## Файлы

### Основные компоненты
- `system_info.dart` - Сбор системной информации
- `log_utils.dart` - Расширенные утилиты логирования (обновлён)
- `logger_initializer.dart` - Улучшенная инициализация (обновлён)

### Демонстрация и тесты
- `logging_demo_page.dart` - Демонстрационная страница
- `system_info_test.dart` - Тесты новой функциональности
- `SYSTEM_INFO_GUIDE.md` - Подробное руководство

## Преимущества

1. **Подробная диагностика** - полная информация о среде выполнения
2. **Автоматизация** - минимум ручной настройки
3. **Безопасность** - обработка ошибок и fallback режимы
4. **Производительность** - асинхронная инициализация
5. **Совместимость** - работает со всей существующей системой логирования

## Миграция

Существующий код продолжает работать без изменений. Новые возможности доступны через:
- `LogUtils.logExtendedAppInfo()` вместо `LogUtils.logAppInfo()`
- `LoggerInitializer.initializeComplete()` для полной инициализации
- `SystemInfo.instance` для доступа к системной информации

## Зависимости

Добавлены в `pubspec.yaml`:
```yaml
dependencies:
  package_info_plus: ^8.3.0
  device_info_plus: ^11.5.0
```
