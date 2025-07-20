# Формат записей в лог файлах

Система логгирования теперь записывает JSON в красивом формате с разделителями.

## Пример записи в обычном лог файле (2025-07-20.log):

```
--------------------------------------------------------------------------------
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "timestamp": "2025-07-20T14:30:25.123Z",
  "level": "INFO",
  "message": "User successfully logged in",
  "sessionId": "session-123-456-789",
  "logger": "Auth",
  "module": "Authentication",
  "context": "LoginService",
  "className": "AuthController",
  "line": 42,
  "function": "login",
  "metadata": {
    "userId": "12345",
    "loginMethod": "password",
    "ip": "192.168.1.100",
    "userAgent": "Flutter App 1.0.0"
  },
  "deviceInfo": {
    "platform": "Android",
    "version": "13",
    "model": "Pixel 7",
    "brand": "Google",
    "manufacturer": "Google",
    "isPhysicalDevice": true
  },
  "appInfo": {
    "appName": "My App",
    "version": "1.0.0",
    "buildNumber": "1",
    "packageName": "com.example.myapp"
  }
}
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
{
  "id": "550e8400-e29b-41d4-a716-446655440001",
  "timestamp": "2025-07-20T14:31:12.456Z",
  "level": "ERROR",
  "message": "Failed to encrypt data",
  "sessionId": "session-123-456-789",
  "logger": "Encryption",
  "module": "Security",
  "context": "DataEncryption",
  "className": "EncryptionService",
  "line": 78,
  "function": "encryptUserData",
  "error": "CryptoException: Invalid key format",
  "stackTrace": "#0      EncryptionService.encryptUserData (package:myapp/encryption.dart:78:5)\n#1      UserController.saveUserData (package:myapp/user.dart:42:12)",
  "metadata": {
    "keyType": "AES-256",
    "dataSize": 1024,
    "operation": "encrypt"
  },
  "deviceInfo": {
    "platform": "Android",
    "version": "13",
    "model": "Pixel 7",
    "brand": "Google",
    "manufacturer": "Google",
    "isPhysicalDevice": true
  },
  "appInfo": {
    "appName": "My App",
    "version": "1.0.0",
    "buildNumber": "1",
    "packageName": "com.example.myapp"
  }
}
--------------------------------------------------------------------------------
```

## Пример краш репорта (2025-07-20_14-32-15_fatal.json):

```json
// Crash Report Generated: 2025-07-20T14:32:15.789Z
{
  "id": "550e8400-e29b-41d4-a716-446655440002",
  "timestamp": "2025-07-20T14:32:15.789Z",
  "level": "FATAL",
  "message": "Critical application failure - unhandled exception",
  "sessionId": "session-123-456-789",
  "logger": "App",
  "module": "Core",
  "context": "MainApplication",
  "className": "App",
  "line": 15,
  "function": "initializeApp",
  "error": "UnhandledException: Failed to initialize core services",
  "stackTrace": "#0      App.initializeApp (package:myapp/main.dart:15:3)\n#1      main (package:myapp/main.dart:8:5)\n#2      _delayEntrypointInvocation.<anonymous closure> (dart:isolate-patch/isolate_patch.dart:297:19)\n#3      _RawReceivePortImpl._handleMessage (dart:isolate-patch/isolate_patch.dart:192:12)",
  "metadata": {
    "crashType": "unhandled_exception",
    "severity": "critical",
    "memoryUsage": "512MB",
    "availableMemory": "2GB",
    "batteryLevel": 75,
    "networkStatus": "connected",
    "lastUserAction": "app_startup"
  },
  "deviceInfo": {
    "platform": "Android",
    "version": "13",
    "model": "Pixel 7",
    "brand": "Google",
    "manufacturer": "Google",
    "isPhysicalDevice": true
  },
  "appInfo": {
    "appName": "My App",
    "version": "1.0.0",
    "buildNumber": "1",
    "packageName": "com.example.myapp"
  }
}
// End of Crash Report
```

## Пример записи с маскировкой чувствительных данных:

```
--------------------------------------------------------------------------------
{
  "id": "550e8400-e29b-41d4-a716-446655440003",
  "timestamp": "2025-07-20T14:33:45.123Z",
  "level": "INFO",
  "message": "Processing user login with password: ***",
  "sessionId": "session-123-456-789",
  "logger": "Auth",
  "module": "Authentication",
  "context": "LoginController",
  "metadata": {
    "username": "u***@example.com",
    "password": "***",
    "token": "eyJhbGciOiJ...***",
    "ip": "192.168.1.100",
    "action": "login_attempt"
  },
  "deviceInfo": {
    "platform": "Android",
    "version": "13",
    "model": "Pixel 7",
    "brand": "Google",
    "manufacturer": "Google",
    "isPhysicalDevice": true
  },
  "appInfo": {
    "appName": "My App",
    "version": "1.0.0",
    "buildNumber": "1",
    "packageName": "com.example.myapp"
  }
}
--------------------------------------------------------------------------------
```

## Преимущества нового формата:

1. **Читаемость**: Каждая запись красиво отформатирована с отступами
2. **Разделение**: Визуальные разделители между записями
3. **Структурированность**: JSON формат позволяет легко парсить логи
4. **Безопасность**: Автоматическая маскировка чувствительных данных
5. **Контекст**: Полная информация об устройстве и приложении
6. **Метаданные**: Дополнительная информация для диагностики

## Файловая структура:

```
Documents/
├── logs/
│   ├── 2025-07-20.log          # Логи за сегодня
│   ├── 2025-07-19.log          # Логи за вчера
│   └── 2025-07-18_143052.log   # Ротированный файл
└── crash/
    ├── 2025-07-20_14-32-15_fatal.json     # Фатальная ошибка
    ├── 2025-07-20_13-45-22_error.json     # Обычная ошибка
    └── 2025-07-19_22-15-03_error.json     # Ошибка за вчера
```
