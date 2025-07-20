# Error System Demo - Руководство пользователя

## 🎯 Обзор

Демонстрационная страница Error System Demo предоставляет интерактивный способ изучения и тестирования комплексной системы обработки ошибок в приложении Codexa Pass.

## 🚀 Как запустить демо

1. **Запустите приложение:**
   ```bash
   flutter run
   ```

2. **Откройте демо:**
   - На главной странице найдите кнопку "Error System Demo" (красная кнопка)
   - Нажмите для перехода к демонстрации

## 📊 Возможности демо

### 1. Error Metrics (Метрики ошибок)
Отображает статистику в реальном времени:
- **Queue Size** - размер очереди ошибок
- **Total Errors** - общее количество обработанных ошибок  
- **Status** - статус системы (Ready/Init)

### 2. Basic Error Types (Основные типы ошибок)
Кнопки для симуляции базовых ошибок:
- **Database Error** - ошибки базы данных
- **Network Error** - сетевые ошибки
- **Auth Error** - ошибки аутентификации
- **Validation Error** - ошибки валидации

### 3. Advanced Error Types (Продвинутые типы ошибок)
- **Crypto Error** - ошибки криптографии
- **Serialization Error** - ошибки сериализации
- **Security Error** - ошибки безопасности
- **System Error** - системные ошибки

### 4. UI Error Demonstrations (Демонстрации UI ошибок)
- **Critical Dialog** - критический диалог ошибки
- **Error Report** - диалог отчета об ошибке
- **Recovery Dialog** - диалог восстановления
- **Throw Widget Error** - ошибка виджета (перехватывается ErrorBoundary)

### 5. Recovery & Circuit Breaker
- **Auto Recovery** - автоматическое восстановление
- **Retry Mechanism** - механизм повторов
- **Circuit Breaker** - автомат защиты
- **Cascade Failure** - каскадные сбои

### 6. Analytics & Monitoring
- **Clear All** - очистка всех ошибок
- **Export Report** - экспорт отчета

## 🔧 Примеры использования

### Тестирование обработки ошибок
```dart
// Простая симуляция ошибки базы данных
final error = DatabaseError(
  code: 'DB_CONNECTION_FAILED',
  message: 'Failed to connect to database',
  severity: ErrorSeverity.error,
  timestamp: DateTime.now(),
  metadata: {
    'operation': 'SELECT',
    'table': 'users',
    'connectionId': '12345',
  },
);

ref.read(errorControllerProvider).handleError(error);
```

### Проверка UI компонентов
```dart
// Показ критического диалога
showDialog(
  context: context,
  barrierDismissible: false,
  builder: (context) => CriticalErrorDialog(error: error),
);
```

### Тестирование ErrorBoundary
```dart
// Виджет с ErrorBoundary
ErrorBoundary(
  child: MyWidget(),
  onError: (error) {
    // Обработка ошибок виджета
    print('Widget error caught: ${error.message}');
  },
)
```

## 📱 Интерактивные сценарии

### Сценарий 1: Базовая обработка ошибок
1. Нажмите "Database Error" несколько раз
2. Наблюдайте увеличение счетчика "Total Errors"
3. Проверьте логи в консоли

### Сценарий 2: Тестирование Circuit Breaker
1. Нажмите "Circuit Breaker" 
2. Система создаст 6 ошибок подряд
3. Circuit Breaker должен активироваться

### Сценарий 3: Каскадные сбои
1. Нажмите "Cascade Failure"
2. Наблюдайте последовательность критических ошибок
3. Проверьте реакцию системы на множественные сбои

### Сценарий 4: UI ошибки
1. Нажмите "Critical Dialog" - увидите диалог критической ошибки
2. Нажмите "Throw Widget Error" - ErrorBoundary перехватит ошибку
3. Наблюдайте уведомления в SnackBar

## 🛠️ Возможности настройки

### Конфигурация ошибок
Система позволяет настроить:
- Уровни критичности
- Типы отображения
- Механизмы восстановления
- Аналитику и мониторинг

### Кастомные ошибки
```dart
// Создание собственного типа ошибки
final customError = BaseAppError(
  code: 'CUSTOM_ERROR_001',
  message: 'My custom error message',
  severity: ErrorSeverity.warning,
  timestamp: DateTime.now(),
  module: 'MyModule',
  metadata: {
    'customField': 'customValue',
  },
);
```

## 📊 Мониторинг

### Метрики в реальном времени
- Размер очереди ошибок
- Общее количество ошибок
- Статус инициализации системы

### Экспорт отчетов
- Нажмите "Export Report" для получения отчета
- Отчет содержит статистику и конфигурацию
- Возможность просмотра в диалоге

## 🎉 Результат

После работы с демо вы:
- Поймете как работает система обработки ошибок
- Увидите различные типы ошибок в действии
- Познакомитесь с UI компонентами
- Протестируете механизмы восстановления
- Изучите возможности мониторинга

Демо предоставляет полное представление о возможностях enterprise-grade системы обработки ошибок! 🚀
