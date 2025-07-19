# Расширенная система логирования с системной информацией

Система логирования была дополнена новыми возможностями для сбора и логирования системной информации с использованием пакетов `package_info_plus` и `device_info_plus`.

## Новые компоненты

### SystemInfo
Класс для сбора информации о приложении и устройстве:

```dart
import 'package:codexa_pass/core/logging/logging.dart';

// Получение экземпляра
final systemInfo = SystemInfo.instance;

// Инициализация (обязательно)
await systemInfo.initialize();

// Получение информации
print(systemInfo.appName);          // Название приложения
print(systemInfo.version);          // Версия приложения
print(systemInfo.deviceModel);      // Модель устройства
print(systemInfo.osVersion);        // Версия ОС
print(systemInfo.platform);         // Платформа (android, ios, windows, etc.)
```

### Расширенные LogUtils
Дополнительные методы для работы с системной информацией:

```dart
import 'package:codexa_pass/core/logging/logging.dart';

// Инициализация системной информации
await LogUtils.initializeSystemInfo();

// Логирование расширенной информации о приложении
await LogUtils.logExtendedAppInfo();

// Логирование краткой системной информации
LogUtils.logShortSystemInfo();

// Логирование подробной информации об устройстве
LogUtils.logDeviceDetails();

// Логирование начала новой сессии
await LogUtils.logSessionStart();

// Логирование завершения сессии
LogUtils.logSessionEnd();
```

### Улучшенный LoggerInitializer
Новые методы инициализации с поддержкой системной информации:

```dart
import 'package:codexa_pass/core/logging/logging.dart';

// Полная инициализация с ожиданием
await LoggerInitializer.initializeComplete(context: context);

// Быстрая инициализация без ожидания
LoggerInitializer.initializeQuick(context: context);

// Получение системной информации
final systemInfo = LoggerInitializer.systemInfo;
```

## Примеры использования

### Инициализация в main()
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Быстрая инициализация логгера
  LoggerInitializer.initializeQuick();
  
  runApp(MyApp());
}
```

### Инициализация в MyApp
```dart
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _initializeLogging();
  }

  void _initializeLogging() async {
    // Полная инициализация после построения первого фрейма
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await LoggerInitializer.initializeComplete(context: context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ... ваш код
    );
  }
}
```

### Логирование ошибок с контекстом
```dart
try {
  // ваш код
} catch (e, stackTrace) {
  LogUtils.logCriticalErrorWithContext(
    'Ошибка при загрузке данных',
    e,
    stackTrace,
    additionalInfo: {
      'userId': currentUserId,
      'operation': 'loadUserData',
      'timestamp': DateTime.now().toIso8601String(),
    },
  );
}
```

### Получение информации о системе
```dart
final systemInfo = SystemInfo.instance;

// Краткая информация
final shortInfo = systemInfo.getShortSystemInfo();
print(shortInfo); // "MyApp 1.0.0+1 на android (Samsung Galaxy S21, Android 12)"

// Полная информация
final fullInfo = systemInfo.getSystemInfoString();
print(fullInfo);

// Информация о приложении
final appInfo = systemInfo.getAppInfo();
print(appInfo); // {'appName': 'MyApp', 'version': '1.0.0', ...}

// Информация о платформе
final platformInfo = systemInfo.getPlatformInfo();
print(platformInfo); // {'platform': 'android', 'deviceModel': 'Samsung Galaxy S21', ...}

// Подробная информация об устройстве
final deviceDetails = systemInfo.getDeviceDetails();
print(deviceDetails); // Полная информация зависит от платформы
```

## Поддерживаемые платформы

### Android
- Модель устройства, производитель, бренд
- Версия Android и API level
- ID устройства, отпечаток
- Поддерживаемые архитектуры
- Системные особенности

### iOS
- Модель устройства
- Версия iOS
- Локализованная модель
- Идентификатор для вендора
- Информация о системе Unix

### Windows
- Имя компьютера
- Информация о продукте и версии
- Количество ядер и память
- ID устройства
- Номер сборки

### Linux
- Название дистрибутива
- Версия и кодовое имя
- ID машины
- Информация о сборке

### macOS
- Модель компьютера
- Версия macOS
- Архитектура
- Частота процессора и память
- GUID системы

## Миграция с существующего кода

Старые методы помечены как `@Deprecated` но продолжают работать:

```dart
// Старый способ (устарел)
LogUtils.logAppInfo();

// Новый способ
await LogUtils.logExtendedAppInfo();
```

## Безопасность

- Все методы обрабатывают ошибки и не падают при недоступности информации
- В случае ошибок логируется минимальная информация
- Чувствительная информация (пути файлов, ID) может быть ограничена в production

## Производительность

- Инициализация системной информации асинхронная
- Информация кешируется после первой загрузки
- Минимальное влияние на запуск приложения
- Возможность фоновой инициализации
